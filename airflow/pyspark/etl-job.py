from pyspark.sql import SparkSession
from pyspark.sql.functions import col, input_file_name, when
from pyspark.sql.types import StructType, StructField, \
                             StringType, LongType, DoubleType
import logging


def main():
    """Main function to execute the ETL process."""
    # Start Spark Session
    spark = SparkSession.builder \
        .appName("BuiltitAll Data Processing") \
        .getOrCreate()

    # Configure logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    # Set log level to avoid verbose logging
    spark.sparkContext.setLogLevel('WARN')

    # Define schema for the sensor data
    schema = StructType([
        StructField("subject_id", StringType(), nullable=False),
        StructField("activity_code", StringType(), nullable=False),
        StructField("timestamp", LongType(), nullable=False),
        StructField("x_value", DoubleType(), nullable=True),
        StructField("y_value", DoubleType(), nullable=True),
        StructField("z_value", DoubleType(), nullable=True)
    ])

    # S3 folder paths for input and output data
    input_path = "/data/raw/*/*.txt"
    output_path = "/data/processed/"

    try:
        logger.info("Starting ETL process for sensor data")

        # Read raw txt files from S3
        raw_data = spark.read.text(input_path)

        # Process each line to extract fields
        processed_data = raw_data.rdd.map(
            lambda row: process_line(row.value)
        ).toDF(schema)

        # Transformations
        transformed_data = processed_data \
            .withColumn("input_file", input_file_name()) \
            .withColumn(
                "device_type",
                when(
                    col("input_file").contains("phone"), "phone"
                ).otherwise("watch")
            ) \
            .withColumn(
                "sensor_type",
                when(
                    col("input_file").contains("accel"), "accelerometer"
                ).otherwise("gyroscope")
            )

        # Write processed data to Parquet
        # Partitioned by subject_id for better performance
        transformed_data.write \
            .partitionBy("subject_id") \
            .mode("overwrite") \
            .parquet(output_path)

        logger.info("ETL process completed successfully!")

    except Exception as e:
        logger.error(f"Error in ETL process: {str(e)}")
        raise e


def process_line(line):
    """
    Function to process each line of the data:
    - Remove the semicolon at the end of each line.
    - Split the line by commas to extract the fields.
    - Convert them to the appropriate data types.
    """
    try:
        # Remove semicolon and split by commas
        remove_semicolon = line.strip().rstrip(';')
        splitbycomma = remove_semicolon.split(',')

        # Extracting all fields from file
        subject_id = splitbycomma[0]
        activity_code = splitbycomma[1]
        timestamp = int(splitbycomma[2])  # Use int instead of long
        x_value = float(splitbycomma[3])
        y_value = float(splitbycomma[4])
        z_value = float(splitbycomma[5])

        return subject_id, activity_code, timestamp, x_value, y_value, z_value

    except (IndexError, ValueError) as e:
        logging.warning(f"Skipping malformed line: {line} - Error: {e}")
        return None


if __name__ == "__main__":
    main()
