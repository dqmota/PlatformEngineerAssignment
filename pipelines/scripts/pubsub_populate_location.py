"""
This script is used to publish fake location data to a Pub/Sub topic.
Usage: python pubsub_populate_location.py <project_id> <topic_name>
"""

import sys
import json
from random import randint
from faker import Faker
from google.cloud import pubsub_v1


def get_sample_dataset(records):
    """
    Generate a sample dataset
    Returns:
        list: Sample dataset
    """
    fake = Faker()
    return [
        {
            "driver_id": randint(1, 100),
            "lat": float(fake.latitude()),
            "long": float(fake.longitude()),
            "trip_id": randint(1001, 9999) if randint(0, 1) else None,
        }
        for _ in range(records)
    ]


def publish_message(project_id, topic_name, dataset):
    """
    Publish a message to a Pub/Sub topic
    Args:
        project_id: Google Cloud Project ID
        topic_name: Pub/Sub topic name
        dataset: Sample dataset
    
    Reference: https://cloud.google.com/pubsub/docs/publisher
    """
    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_name)
    for data in dataset:
        message = json.dumps(data)
        future = publisher.publish(topic_path, data=message.encode("utf-8"))
        print(future.result())


def main():
    try:
        project_id = sys.argv[1]
        topic_name = sys.argv[2]
        messages_number = int(sys.argv[3])
    except IndexError as exc:
        raise SystemExit(f"Usage: {sys.argv[0]} <project_id> <topic_name> <messages_number>") from exc

    dataset = get_sample_dataset(messages_number)
    publish_message(project_id, topic_name, dataset)

if __name__ == "__main__":
    main()
