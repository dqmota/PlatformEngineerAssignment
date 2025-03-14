import argparse
import json
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions


parser = argparse.ArgumentParser()
parser.add_argument(
    "--pubsub_subscription", 
    required=True, 
    help="Pub/Sub subscription to read from."
)
parser.add_argument(
    "--bigquery_table", 
    required=True, 
    help="BigQuery table to write to."
)
parser.add_argument(
    "--bigquery_schema", 
    required=True, 
    help="BigQuery table schema notation."
)
known_args, pipeline_args = parser.parse_known_args()


class ParsePubSubMessage(beam.DoFn):
    def process(self, element):
        data = json.loads(element.decode("utf-8"))
        return [data]


def run():
    pipeline_options = PipelineOptions(
        pipeline_args,
        streaming=True,
        runner="DataflowRunner"
    )
    
    pipeline = beam.Pipeline(options=pipeline_options)
    (
        pipeline
        | "Read from Pub/Sub" >> beam.io.ReadFromPubSub(subscription=known_args.pubsub_subscription)
        | "Decode JSON" >> beam.ParDo(ParsePubSubMessage())
        | "Write to BigQuery" >> beam.io.WriteToBigQuery(
            known_args.bigquery_table,
            schema=known_args.bigquery_schema,
            create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
        )
    )
    pipeline.run()


if __name__ == "__main__":
    run()
