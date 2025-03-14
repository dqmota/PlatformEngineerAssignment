"""
Infer BigQuery schema from a JSON message in a Pub/Sub subscription
Usage: python pubsub_infer_schema.py <project_id> <subscription_name>
"""
import sys
import json
from dateutil import parser as date_parser
from google.cloud import pubsub_v1


def get_sample_message(project_id, subscription_name):
    """
    Get a sample message from a Pub/Sub subscription
    Args:
        project_id: Google Cloud Project ID
        subscription_name: Pub/Sub subscription name
    Returns:
        str: Message data

    References: https://cloud.google.com/python/docs/reference/pubsub/latest#subscribing
    """
    
    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(project_id, subscription_name)
    response = subscriber.pull(subscription=subscription_path, max_messages=1)
    for message in response.received_messages:
        subscriber.acknowledge(subscription=subscription_path, ack_ids=[message.ack_id])
        return message.message.data.decode("utf-8")


def infer_schema(message):
    """
    Infer BigQuery schema from a JSON message
    Args:
        message: JSON message
    Returns:
        list: BigQuery schema

    References: https://cloud.google.com/bigquery/docs/schemas#standard_sql_data_types
    """
    schema = []
    for key, value in json.loads(message).items():
        if isinstance(value, int):
            schema.append(key + ":INT64")
        elif isinstance(value, float):
            schema.append(key + ":FLOAT64")
        elif isinstance(value, bool):
            schema.append(key + ":BOOL")
        elif isinstance(value, str):
            try:
                date_parser.isoparse(value)
                schema.append(key + ":TIMESTAMP")
            except ValueError:
                schema.append(key + ":STRING")
        else:
            schema.append(key + ":STRING")
    return schema


def main():
    try:
        project_id = sys.argv[1]
        subscription_name = sys.argv[2]
    except IndexError as exc:
        raise SystemExit(f"Usage: {sys.argv[0]} <project_id> <subscription_name>") from exc

    message = get_sample_message(project_id, subscription_name)

    # https://cloud.google.com/bigquery/docs/schemas#specify_schemas
    print(*infer_schema(message), sep=",") # Print Google SQL schema string


if __name__ == "__main__":
    main()
