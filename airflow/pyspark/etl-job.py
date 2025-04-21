from pyspark.sql import SparkSession
from pyspark.sql.functions import col, input_file_name, when
from pyspark.sql.types import StructType, StructField, \
                             StringType, LongType, DoubleType
import logging


def create_spark_session():
    """start Spark session."""
    spark = SparkSession.builder \
        .appName("BuiltitAll Data Processing") \
        .getOrCreate()
    spark.sparkContext.setLogLevel('WARN')
    return spark


def configure_logging():
    """logging for the ETL process."""
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    return logger


def define_schema():
    """Define schema for the sensor data processing"""
    return StructType([
        StructField("subject_id", StringType(), nullable=False),
        StructField("activity_code", StringType(), nullable=False),
        StructField("timestamp", LongType(), nullable=False),
        StructField("x_value", DoubleType(), nullable=True),
        StructField("y_value", DoubleType(), nullable=True),
        StructField("z_value", DoubleType(), nullable=True)
    ])


def read_raw_data(spark, input_path):
    """Read raw data from s3 (input path)"""
    return spark.read.text(input_path)

def process_line(line):
    """
    Process every single line of raw data:
    - Remove the semicolon at the end of the line
    - Split the line by commas to extract fields
    - Convert fields to appropriate data types
    """
    try:
        remove_semicolon = line.strip().rstrip(';')
        splitbycomma = remove_semicolon.split(',')

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
    # Process each line to extract values
    return raw_data.rdd.map(
        lambda row: process_line(row.value)
    ).toDF(schema)


def transform_data(processed_data):
    """Transform the processed data by adding 3 additional columns:
    - input_file column: name of the input file
    - device_type column: type of device (phone or watch)
    - sensor_type column: type of sensor (accelerometer or gyroscope)
    """
    return processed_data \
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


def write_data(transformed_data, output_path):
    """Write the transformed data to s3 (output path) in Parquet format."""
    transformed_data.write \
        .partitionBy("subject_id") \
        .mode("overwrite") \
        .parquet(output_path)



def main():
    """Main function to orchestrate the ETL process."""
    spark = create_spark_session()
    logger = configure_logging()
    schema = define_schema()

    input_path = "/data/raw/*/*.txt"
    output_path = "/data/processed/"

    try:
        logger.info("Starting ETL process for sensor data")

        raw_data = read_raw_data(spark, input_path)
        processed_data = process_raw_data(raw_data, schema)
        transformed_data = transform_data(processed_data)
        write_data(transformed_data, output_path)

        logger.info("ETL process completed successfully!")

    except Exception as e:
        logger.error(f"Error in ETL process: {str(e)}")
        raise e

    finally:
        spark.stop()


# if __name__ == "__main__":
#     main()
