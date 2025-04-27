from datetime import datetime

from airflow.providers.standard.operators.python.PythonOperator import PythonOperator
from airflow.providers.amazon.aws.operators.emr import (
    EmrAddStepsOperator,
    EmrCreateJobFlowOperator,
    EmrTerminateJobFlowOperator,
)
from airflow.providers.amazon.aws.sensors.emr import EmrStepSensor

from airflow import DAG

from dag.pyspark_job.etl_job import upload_file_from_url_to_s3


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
    "JobFlowRole": "AmazonEMR-InstanceProfile-20250405T131154",
    "ServiceRole": "AmazonEMR-InstanceProfile-20250405T131154",
    "LogUri": "s3://builditall-bucket/builditall/logs/",
    "VisibleToAllUsers": True,
    "Tags": [
        {"Key": "Project", "Value": "BuildAll"},
        {"Key": "Environment", "Value": "Production"},
    ],
}

DATA_PROCESSING_STEPS = [
    {
        "Name": "Run Spark Job",
        "ActionOnFailure": "TERMINATE_CLUSTER",
        "HadoopJarStep": {
            "Jar": "command-runner.jar",
            "Args": [
                "spark-submit",
                "--deploy-mode",
                "client",
                "s3://builditall-bucket/mwaa/pyspark/etl_job.py",
            ],
        },
    },
        ]

# DAG definition for processing sensor data
# This pipeline reads raw sensor data, applies schema
# definitions, processes it,
# transforms it, and writes the output to an S3 bucket.
with DAG(
    dag_id="sensor_data_processing_pipeline",
    start_date=datetime(2024, 4, 1),
    catchup=False,
    default_args={
        "owner": "airflow",
        "retries": 1,
        "schedule_interval": "@daily",
    },
) as dag:
    upload_file_from_url_to_s3_task = PythonOperator(
        task_id="upload_file_from_url_to_s3_task",
        python_callable=upload_file_from_url_to_s3,
    )

    # Create a temporary EMR Spark cluster
    create_emr_cluster = EmrCreateJobFlowOperator(
        task_id="create_emr_cluster",
        job_flow_overrides=JOB_FLOW_OVERRIDES,
        aws_conn_id="aws_default",
        emr_conn_id="emr_default",
    )

    # Add steps for pyspark execution
    add_spark_step = EmrAddStepsOperator(
        task_id="add_spark_step",
        job_flow_id=(
            "{{ task_instance.xcom_pull(task_ids='create_emr_cluster', "
            "key='return_value') }}"
        ),
        steps=DATA_PROCESSING_STEPS,
        aws_conn_id="aws_default",
    )

    # add step to make sure all other step finishes
    wait_for_spark_step = EmrStepSensor(
        task_id="wait_for_spark_step",
        job_flow_id=(
            "{{ task_instance.xcom_pull(task_ids='create_emr_cluster', "
            "key='return_value') }}"
        ),
        step_id=(
            "{{ task_instance.xcom_pull(task_ids='add_spark_step', "
            "key='return_value')[0] }}"
        ),
        aws_conn_id="aws_default",
    )

    # terminate the emr cluster
    terminate_emr_cluster = EmrTerminateJobFlowOperator(
        task_id="terminate_emr_cluster",
        job_flow_id=(
            "{{ task_instance.xcom_pull(task_ids='create_emr_cluster', "
            "key='return_value') }}"
        ),
        aws_conn_id="aws_default",
    )

    # Set task dependencies to define the sequence
    # of execution for the pipeline. The tasks are
    # organized in a way that ensures proper data flow
    # and processing
    (
        upload_file_from_url_to_s3_task
        >> create_emr_cluster
        >> add_spark_step
        >> wait_for_spark_step
        >> terminate_emr_cluster
    )
