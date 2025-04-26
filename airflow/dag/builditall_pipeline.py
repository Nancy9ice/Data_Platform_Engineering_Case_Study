from datetime import datetime

from airflow.operators.python import PythonOperator

from airflow import DAG

from ..pyspark_job.etl_job import (
    create_spark_session,
    define_schema,
    process_raw_data,
    read_raw_data,
    transform_data,
    write_data,
)

# INPUT_PATH: Path to the raw sensor data stored in an S3 bucket
# OUTPUT_PATH: Path to store the processed and transformed data in an S3 bucket
INPUT_PATH = "s3://your-bucket-name/input-data/"
OUTPUT_PATH = "s3://your-bucket-name/processed-data/"

# DAG definition for processing sensor data
# This pipeline reads raw sensor data, applies schema
# definitions, processes it,
# transforms it, and writes the output to an S3 bucket.
with DAG(
    dag_id="sensor_data_processing_pipeline",
    start_date=datetime(2024, 4, 1),
    schedule_interval="@daily",
    catchup=False,
    default_args={"owner": "airflow", "retries": 1},
) as dag:

    #
    # Task 1: Start a Spark session using the create_spark_session function
    task_start_spark = PythonOperator(
        task_id="start_spark",
        python_callable=create_spark_session,
    )

    # Task 2: Define the schema for sensor data using the define_schema
    # function
    task_define_schema = PythonOperator(
        task_id="define_schema",
        python_callable=define_schema,
    )

    # Task 3: Process the raw sensor data to clean and structure it using the
    # process_raw_data function
    task_process_raw_data = PythonOperator(
        task_id="process_raw_data",
        python_callable=process_raw_data,
    )

    # Task 4: Read the raw data from the input path using the read_raw_data
    # function
    task_read_data = PythonOperator(
        task_id="read_data",
        python_callable=read_raw_data,
    )

    # Task 5: Transform the structured data  using the transform_data function
    task_transform_raw_data = PythonOperator(
        task_id="transform_raw_data",
        python_callable=transform_data,
    )

    # Task 6: Write the transformed data to the output path using the
    # write_data function
    task_write_raw_data = PythonOperator(
        task_id="write_raw_data",
        python_callable=write_data,
    )

    # Set task dependencies to define the sequence
    # of execution for the pipeline. The tasks are
    # organized in a way that ensures proper data flow
    # and processing
    (
        task_start_spark
        >> task_read_data
        >> task_define_schema
        >> task_process_raw_data
        >> task_read_data
        >> task_transform_raw_data
        >> task_write_raw_data
    )
