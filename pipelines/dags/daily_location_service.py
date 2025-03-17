from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.apache.beam.operators.beam import BeamRunPythonPipelineOperator
from airflow.providers.google.cloud.hooks.dataflow import DataflowJobStatus
from airflow.providers.google.cloud.operators.dataflow import DataflowConfiguration
from airflow.providers.google.cloud.sensors.dataflow import DataflowJobStatusSensor

PROJECT_ID = "my-taxi-proc-860043411361"
REGION = "europe-southwest1"
SUBNETWORK = "https://www.googleapis.com/compute/v1/projects/sanguine-parsec-453303-j9/regions/europe-southwest1/subnetworks/subnet-processing"
SERVICE_ACCOUNT_EMAIL = "project-service-account@my-taxi-proc-860043411361.iam.gserviceaccount.com"
DATAFLOW_TEMP_LOCATION = "gs://my-taxi-proc-default/dataflow/temp/"
DATAFLOW_PY_FILE = "gs://europe-southwest1-proc-defa-5090e184-bucket/pipelines/batch_pipeline.py"
INPUT_STORAGE_BUCKET = "my-taxi-drop-location-service"
OUTPUT_BIGQUERY_TABLE = "my-taxi-land-860043411361.landing_default.location_service_updates"

yesterday = datetime.now() - timedelta(days=1)

default_args = {
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    "Dataflow_Batch_Pipeline",
    default_args=default_args,
    start_date=yesterday,
    schedule="@daily",
    catchup=False,
) as dag:
    run_dataflow_job = BeamRunPythonPipelineOperator(
        task_id="run_dataflow_job",
        runner="DataflowRunner",
        py_file=DATAFLOW_PY_FILE,
        pipeline_options={
            "temp_location": DATAFLOW_TEMP_LOCATION,
            "service_account_email": SERVICE_ACCOUNT_EMAIL,
            "subnetwork": SUBNETWORK,
            "storage_bucket": INPUT_STORAGE_BUCKET,
            "bigquery_table": OUTPUT_BIGQUERY_TABLE,
        },
        py_options=[],
        py_requirements=["apache-beam[gcp]==2.63.0"],
        py_interpreter="python3",
        py_system_site_packages=False,
        dataflow_config=DataflowConfiguration(
            job_name="{{task.task_id}}",
            project_id=PROJECT_ID,
            location=REGION,
            wait_until_finished=False,
        ),
    )

    wait_dataflow_job = DataflowJobStatusSensor(
        task_id="wait_dataflow_job",
        job_id="{{task_instance.xcom_pull('run_dataflow_job')['dataflow_job_id']}}",
        expected_statuses={DataflowJobStatus.JOB_STATE_DONE, DataflowJobStatus.JOB_STATE_FAILED},
        project_id=PROJECT_ID,
        location=REGION,
    )

    run_dataflow_job >> wait_dataflow_job
