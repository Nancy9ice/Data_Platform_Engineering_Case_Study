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


from airflow.providers.amazon.aws.operators.emr import (
    EmrAddStepsOperator,
    EmrCreateJobFlowOperator,
    EmrTerminateJobFlowOperator,
)
from airflow.providers.amazon.aws.sensors.emr import EmrStepSensor

# INPUT_PATH: Path to the raw sensor data stored in an S3 bucket
# OUTPUT_PATH: Path to store the processed and transformed data in an S3 bucket
INPUT_PATH = "s3://your-bucket-name/input-data/"
OUTPUT_PATH = "s3://your-bucket-name/processed-data/"


JOB_FLOW_OVERRIDES = {
    "Name": "BuildAll-Temporary-Spark-Cluster",
    "ReleaseLabel": "emr-6.9.0",
    "Applications": [{"Name": "Spark"}, {"Name": "Hadoop"}],
    "Instances": {
        "InstanceGroups": [
            {
                "Name": "Master node",
                "Market": "ON_DEMAND",
                "InstanceRole": "MASTER",
                "InstanceType": "m5.xlarge",
                "InstanceCount": 1,
            },
            {
                "Name": "Core nodes",
                "Market": "ON_DEMAND",
                "InstanceRole": "CORE",
                "InstanceType": "m5.xlarge",
                "InstanceCount": 2,
            },
        ],
        "KeepJobFlowAliveWhenNoSteps": True,
        "TerminationProtected": False,
    },
    "JobFlowRole": "EMR_EC2_DefaultRole",
    "ServiceRole": "EMR_DefaultRole",
    "LogUri": "s3://buildall-airflow-assets/emr-logs/",
    "VisibleToAllUsers": True,
    "Tags": [
        {"Key": "Project", "Value": "BuildAll"},
        {"Key": "Environment", "Value": "Production"},
    ],
}

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

    # Step 1: Create a temporary EMR Spark cluster
    create_emr_cluster = EmrCreateJobFlowOperator(
        task_id="create_emr_cluster",
        job_flow_overrides=JOB_FLOW_OVERRIDES,
        aws_conn_id="aws_default",
        emr_conn_id="emr_default",
        dag=dag,
    )

    # Task 2: Start a Spark session using the create_spark_session function
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

    terminate_emr_cluster = EmrTerminateJobFlowOperator(
        task_id="terminate_emr_cluster",
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster')['JobFlowId'] }}",
        aws_conn_id="aws_default",
        region_name="us-west-2",
        dag=dag,
    )

    # Set task dependencies to define the sequence
    # of execution for the pipeline. The tasks are
    # organized in a way that ensures proper data flow
    # and processing
    (
        create_emr_cluster
        >> task_start_spark
        >> task_read_data
        >> task_define_schema
        >> task_process_raw_data
        >> task_read_data
        >> task_transform_raw_data
        >> task_write_raw_data
        >> terminate_emr_cluster
    )
