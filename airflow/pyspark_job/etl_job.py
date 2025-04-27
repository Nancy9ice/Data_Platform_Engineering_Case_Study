import logging

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, input_file_name, when
from pyspark.sql.types import (
    DoubleType,
    LongType,
    StringType,
    StructField,
    StructType,
)


def create_spark_session():
    """Start Spark session"""
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


def read_raw_data(spark, input_path):
    """Read raw data from s3 (input path)."""
    logging.info(f"Reading raw data from input path: {input_path}")
    raw_data = spark.read.text(input_path)
    logging.info("raw data read successfully.")
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
    logging.info("raw data processed successfully")
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
    """Write the transformed data to s3 (output path) in Parquet format"""
    logging.info(f"Writing transformed data to output path: {output_path}")
    transformed_data.write.partitionBy("subject_id").mode("overwrite").parquet(
        output_path
    )
    logging.info("Transformed data written successfully")


def main():
    """Main function to orchestrate the ETL process."""
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(_name_)

    try:
        logger.info("Starting ETL process for sensor data")

        # Create Spark session
        spark = create_spark_session()

        # Define schema
        schema = define_schema()

        # Input and output paths
        input_path = "s3://emr-datalake/input-folder/raw/*"
        output_path = "s3://emr-datalake/output-folder/processed-data/"

        # Read raw data
        raw_data = read_raw_data(spark, input_path)

        # Process raw data
        processed_data = process_raw_data(raw_data, schema)

        # Transform data
        transformed_data = transform_data(processed_data)

        # Write transformed data
        write_data(transformed_data, output_path)

        logger.info("ETL process completed successfully!")

    except Exception as e:
        logger.error(f"Error in ETL process: {str(e)}")
        raise e

    finally:
        logger.info("Stopping Spark session")
        spark.stop()


if __name__ == "_main_":
    main()
