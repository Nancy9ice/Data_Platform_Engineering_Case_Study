# airflow/dags/sensor_data_pipeline.py

import logging
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

# Replace 'your_script_name' with the actual file name where you have your
# functions

# Input and Output Paths
INPUT_PATH = "s3://your-bucket-name/input-data/"
OUTPUT_PATH = "s3://your-bucket-name/processed-data/"

# Global Spark Session (can be shared across tasks if you want)
spark = None


# DAG definition
with DAG(
    dag_id="sensor_data_processing_pipeline",
    start_date=datetime(2024, 4, 1),
    schedule_interval="@daily",  # or "@once" for manual runs
    catchup=False,
    default_args={"owner": "airflow", "retries": 1},
) as dag:

    task_start_spark = PythonOperator(
        task_id="start_spark",
        python_callable=create_spark_session,
    )

    task_define_schema = PythonOperator(
        task_id="define_schema",
        python_callable=define_schema,
    )

    task_process_raw_data = PythonOperator(
        task_id="process_raw_data",
        python_callable=process_raw_data,
    )

    task_read_data = PythonOperator(
        task_id="read_data",
        python_callable=read_raw_data,
    )

    task_transform_raw_data = PythonOperator(
        task_id="transform_raw_data",
        python_callable=transform_data,
    )

    task_write_raw_data = PythonOperator(
        task_id="write_raw_data",
        python_callable=write_data,
    )

    # Set task dependencies
    (
        task_start_spark
        >> task_read_data
        >> task_define_schema
        >> task_process_raw_data
        >> task_read_data
        >> task_transform_raw_data
        >> task_write_raw_data
    )
