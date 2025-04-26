#!/usr/bin/env python3
import logging
import sys

from ..pyspark_job.etl_job import (
    create_spark_session,
    define_schema,
    process_raw_data,
    read_raw_data,
    transform_data,
    write_data,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def main():
    """
    Main function to run Spark aggregation job
    """
    logging.basicConfig(level=logging.INFO)

    # Check command line arguments
    if len(sys.argv) != 3:
        logging.error("Usage: aggregate_data.py <input_path> <output_path>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    # Execute the processing pipeline
    spark = create_spark_session()
    schema = define_schema()
    raw_data = read_raw_data(spark, input_path)
    processed_data = process_raw_data(raw_data, schema)
    transformed_data = transform_data(processed_data)
    write_data(transformed_data, output_path)

    try:
        # TODO:
        pass

    except Exception as e:
        logger.error(f"Error processing data: {str(e)}")
        raise

    finally:
        # Stop Spark session
        logger.info("Stopping Spark session")
        spark.stop()


if __name__ == "__main__":
    main()
