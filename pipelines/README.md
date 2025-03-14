# Pipeline Execution

This document provides an example of how to execute a pipeline using the CLI.

## Example

To execute the pipeline, use the following command:

```sh
python streaming_pipeline.py \
  --runner=DataflowRunner \
  --project=my-taxi-proc-860043411361 \
  --region=europe-southwest1 \
  --temp_location="gs://my-taxi-proc-default/dataflow/temp/" \
  --service_account_email="project-service-account@my-taxi-proc-860043411361.iam.gserviceaccount.com" \
  --subnetwork="https://www.googleapis.com/compute/v1/projects/sanguine-parsec-453303-j9/regions/europe-southwest1/subnetworks/subnet-processing" \
  --pubsub_subscription="projects/my-taxi-drop-860043411361/subscriptions/dropoff-realtime-subscription" \
  --bigquery_table="my-taxi-land-860043411361.landing_default.taxi_trips" \
  --bigquery_schema="ride_id:STRING,point_idx:INT64,latitude:FLOAT64,longitude:FLOAT64,timestamp:TIMESTAMP,meter_reading:FLOAT64,meter_increment:FLOAT64,ride_status:STRING,passenger_count:INT64"
```