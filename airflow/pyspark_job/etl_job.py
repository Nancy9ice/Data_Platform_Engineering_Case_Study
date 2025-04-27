import logging

import boto3
import requests
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, input_file_name, when
from pyspark.sql.types import (
    DoubleType,
    LongType,
    StringType,
    StructField,
    StructType,
)

url = (
    "https://archive.ics.uci.edu/static/public/507/"
    "wisdm+smartphone+and+smartwatch+activity+and+"
    "biometrics+dataset.zip"
)
bucket_name = "builditall-bucket"
s3_key = "builditall/raw.zip"


def create_spark_session():
    """Start Spark session..........."""
    logging.info("Starting Spark session")
    spark = SparkSession.builder.appName(
        "BuiltitAll Data Processing"
    ).getOrCreate()
    spark.sparkContext.setLogLevel("WARN")
    logging.info("Spark session started successfully.")
    return spark


def define_schema():
    """Define schema for the sensor data processing."""
    logging.info("Defining schema for the sensor data")
    schema = StructType(
        [
            StructField("subject_id", StringType(), nullable=False),
            StructField("activity_code", StringType(), nullable=False),
            StructField("timestamp", LongType(), nullable=False),
            StructField("x_value", DoubleType(), nullable=True),
            StructField("y_value", DoubleType(), nullable=True),
            StructField("z_value", DoubleType(), nullable=True),
        ]
    )
    logging.info("Schema defined successfully")
    return schema


def upload_zip_to_s3(url, bucket_name, s3_key):
    """
    Download sensor dataset from URL and push to S3
    - url: URL of the ZIP file to download
    - bucket_name: S3 bucket name to upload the file
    """
    logging.info(f"Downloading ZIP file from URL: {url}")
    response = requests.get(url, stream=True)
    response.raise_for_status()  # Check for HTTP errors
    logging.info("ZIP file downloaded successfully")

    logging.info("Uploading ZIP file to S3bucket")
    s3_client = boto3.client("s3")
    s3_client.upload_fileobj(response.raw, bucket_name, s3_key)
    logging.info("ZIP file uploaded to S3 successfully")


def read_raw_data_from_zip(spark, input_path):
    """
    Read data from a ZIP file stored in S3.
    """
    logging.info(f"Reading raw data from ZIP file at: {input_path}")
    raw_data = spark.read.text(input_path)
    logging.info("Raw data read successfully from ZIP file.")
    return raw_data


def process_line(line):
    """Process every single line of raw data:
    - Remove the semicolon at the end of the line
    - Split the line by commas to extract fields
    - Convert fields to appropriate data types
    """
    try:
        remove_semicolon = line.strip().rstrip(";")
        splitbycomma = remove_semicolon.split(",")

        subject_id = splitbycomma[0]
        activity_code = splitbycomma[1]
        timestamp = int(splitbycomma[2])
        x_value = float(splitbycomma[3])
        y_value = float(splitbycomma[4])
        z_value = float(splitbycomma[5])

        return subject_id, activity_code, timestamp, x_value, y_value, z_value

    except (IndexError, ValueError) as e:
        # Handle malformed lines, log the error and return None
        logging.warning(f"Skipping malformed line: {line} - Error: {e}")
        return None


def process_raw_data(raw_data, schema):
    """Process raw data and return a DataFrame with the defined schema:
    - Read the raw data from input path
    - Process each line to extract values
    - Convert them to the appropriate data types
    """
    logging.info("Processing raw data")
    processed_data = raw_data.rdd.map(
        lambda row: process_line(row.value)
    ).toDF(schema)
    logging.info("Raw data processed successfully")
    return processed_data


def transform_data(processed_data):
    """Transform the processed data by adding 3 additional columns:
    - input_file column: name of the input file
    - device_type column: type of device (phone or watch)
    - sensor_type column: type of sensor (accelerometer or gyroscope)
    """
    logging.info("Transforming processed data")
    transformed_data = (
        processed_data.withColumn("input_file", input_file_name())
        .withColumn(
            "device_type",
            when(col("input_file").contains("phone"), "phone").otherwise(
                "watch"
            ),
        )
        .withColumn(
            "sensor_type",
            when(
                col("input_file").contains("accel"), "accelerometer"
            ).otherwise("gyroscope"),
        )
    )
    logging.info("Processed data transformed successfully")
    return transformed_data


def write_data(transformed_data, output_path):
    """Write the transformed data to S3 (output path) in Parquet format."""
    logging.info(f"Writing transformed data to output path: {output_path}")
    transformed_data.write.partitionBy("subject_id").mode("overwrite").parquet(
        output_path
    )
    logging.info("Transformed data written successfully")


def main():
    """Main function to orchestrate the ETL process."""
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    try:
        logger.info("Starting ETL process for sensor data")

        # Task 1: Create Spark session
        spark = create_spark_session()

        # Task 2: Define schema
        schema = define_schema()

        # Task 3: Read raw data from ZIP file in S3
        input_path = f"s3://{bucket_name}/{s3_key}"
        raw_data = read_raw_data_from_zip(spark, input_path)

        # Task 4: Process raw data
        processed_data = process_raw_data(raw_data, schema)

        # Task 5: Transform data
        transformed_data = transform_data(processed_data)

        # Task 6: Write transformed data to S3
        output_path = f"s3://{bucket_name}/processed-data/"
        write_data(transformed_data, output_path)

        logger.info("ETL process completed successfully!")

    except Exception as e:
        logger.error(f"Error in ETL process: {str(e)}")
        raise e

    finally:
        logger.info("Stopping Spark session")
        spark.stop()


if __name__ == "__main__":
    main()
