#!/usr/bin/env python3
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import sys
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def main():
    """
    Main function to run Spark aggregation job
    """
    # Validate command line arguments
    if len(sys.argv) != 3:
        logger.error("Usage: aggregate_data.py <input_path> <output_path>")
        sys.exit(1)
    
    # Get input and output paths from command line arguments
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    
    logger.info(f"Starting Spark job with input: {input_path} and output: {output_path}")
    
    # Initialize Spark session
    spark = SparkSession.builder \
        .appName("BuildAll Data Aggregation") \
        .config("spark.sql.warehouse.dir", "/tmp/spark-warehouse") \
        .config("spark.executor.memory", "2g") \
        .config("spark.driver.memory", "2g") \
        .enableHiveSupport() \
        .getOrCreate()
    
    try:
        #TODO: 
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
    