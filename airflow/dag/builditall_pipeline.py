"""
BuildAll Case Study - Spark Processing DAG
This DAG implements the complete flow shown in the diagram:
1. Creates a temporary Spark cluster on EMR
2. Generates test data
3. Stores records in S3
4. Runs aggregations
5. Stores results in S3
6. Destroys the cluster
"""

import logging
from datetime import timedelta

import boto3

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.operators.emr import (
    EmrAddStepsOperator,
    EmrCreateJobFlowOperator,
    EmrTerminateJobFlowOperator,
)
from airflow.providers.amazon.aws.sensors.emr import EmrStepSensor
from airflow.utils.dates import days_ago

# Default arguments
default_args = {
    "owner": "buildall",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

# EMR cluster configuration
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


# Generate unique test data function
def generate_data(**kwargs):
    pass


# Store results in S3 (verification step)
def store_results(**kwargs):
    """
    Verify results exist in S3 and log the output
    """
    s3_client = boto3.client("s3")

    try:
        response = s3_client.list_objects_v2(
            Bucket="<TAKE_BUCKET_FROM_NANCY>",
            Prefix="results/",
        )

        if "Contents" in response:
            result_files = [item["Key"] for item in response["Contents"]]
            logging.info(f"Results stored in S3: {result_files}")
            return True
        else:
            logging.warning("No results found in S3 results directory")
            return False
    except Exception as e:
        logging.error(f"Error checking results: {str(e)}")
        raise


# DAG definition
with DAG(
    "spark_processing_pipeline",
    default_args=default_args,
    description="Process data with temporary Spark cluster",
    schedule_interval="@daily",
    start_date=days_ago(1),
    tags=["buildall", "spark"],
    catchup=False,
) as dag:

    # Step 1: Create a temporary EMR Spark cluster
    create_emr_cluster = EmrCreateJobFlowOperator(
        task_id="create_emr_cluster",
        job_flow_overrides=JOB_FLOW_OVERRIDES,
        aws_conn_id="aws_default",
    )

    # Step 2: Generate unique test data
    generate_data = PythonOperator(
        task_id="generate_data",
        python_callable=generate_data,
    )

    # Step 3: Submit Spark job for aggregations
    SPARK_STEPS = [
        {
            "Name": "Run Data Aggregation",
            "ActionOnFailure": "CONTINUE",
            "HadoopJarStep": {
                "Jar": "command-runner.jar",
                "Args": [
                    "spark-submit",
                    "--deploy-mode",
                    "cluster",
                    "--master",
                    "yarn",
                    "--conf",
                    "spark.dynamicAllocation.enabled=true",
                    "--conf",
                    "spark.shuffle.service.enabled=true",
                    "s3://buildall-airflow-assets/scripts/aggregate_data.py",
                    '{{ task_instance.xcom_pull(task_ids="generate_data", '
                    'key="test_data_path") }}',
                    "s3://buildall-airflow-assets/results/",
                ],
            },
        }
    ]

    submit_spark_job = EmrAddStepsOperator(
        task_id="submit_spark_job",
        job_flow_id=(
            "{{ task_instance.xcom_pull(task_ids='create_emr_cluster') }}"
        ),
        aws_conn_id="aws_default",
        steps=SPARK_STEPS,
    )

    # Step 4: Wait for Spark job to complete
    wait_for_spark_job = EmrStepSensor(
        task_id="wait_for_spark_job",
        job_flow_id=(
            "{{ task_instance.xcom_pull(task_ids='create_emr_cluster') }}"
        ),
        step_id=(
            "{{ task_instance.xcom_pull(task_ids='submit_spark_job')[0] }}"
        ),
        aws_conn_id="aws_default",
    )

    # Step 5: Store results
    store_results_task = PythonOperator(
        task_id="store_results",
        python_callable=store_results,
    )

    # Step 6: Terminate the EMR cluster
    terminate_emr_cluster = EmrTerminateJobFlowOperator(
        task_id="terminate_emr_cluster",
        job_flow_id=(
            "{{ task_instance.xcom_pull(task_ids='create_emr_cluster') }}"
        ),
        aws_conn_id="aws_default",
    )

    # Set task dependencies
    (
        create_emr_cluster
        >> generate_data
        >> submit_spark_job
        >> wait_for_spark_job
        >> store_results_task
        >> terminate_emr_cluster
    )
