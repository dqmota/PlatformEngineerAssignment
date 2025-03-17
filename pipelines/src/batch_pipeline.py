import argparse
import json
from datetime import datetime, timedelta
from apache_beam.options.pipeline_options import PipelineOptions
import apache_beam as beam

parser = argparse.ArgumentParser()
parser.add_argument(
    "--storage_bucket",
    required=True,
    help="GCS bucket to read data from."
)
parser.add_argument(
    "--bigquery_table",
    required=True,
    help="BigQuery table to write to."
)
known_args, pipeline_args = parser.parse_known_args()

yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y/%m/%d")


class ParseAvro(beam.DoFn):
    def process(self, element):
        if not element.get("data"):
            return
        yield json.loads(element.get("data"))


def run():
    pipeline_options = PipelineOptions(pipeline_args, runner="DataflowRunner")
    pipeline = beam.Pipeline(options=pipeline_options)
    (
        pipeline
        | "Read data from GCS" >> beam.io.ReadFromAvro(
            f"gs://{known_args.storage_bucket}/{yesterday}/**/*.avro"
        )
        | "Parse data" >> beam.ParDo(ParseAvro())
        | "Filter data" >> beam.Filter(lambda x: x.get("trip_id"))
        | "Write to BigQuery" >> beam.io.WriteToBigQuery(
            known_args.bigquery_table,
            schema="SCHEMA_AUTODETECT",
            create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
        )
    )
    pipeline.run()


if __name__ == "__main__":
    run()
