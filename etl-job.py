from pyspark.sql import SparkSession
#from pyspark.sql import functions as F
import logging

def main():
    # start Spark Session
    spark = SparkSession.builder \
        .appName("BuiltitAll Big Data Processing job") \
        .getOrCreate()
        
    # Configure logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    
    # log level to avoid verbose logging
    spark.sparkContext.setLogLevel('WARN')

    # s3 Input and output paths
    input_path = ''
    output_path = ''
