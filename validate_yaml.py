import argparse
import json

import yaml
from jsonschema import exceptions, validate


def validate_yaml_against_schema(yaml_file, schema_file):
    # Load YAML file and convert to JSON
    with open(yaml_file, "r") as f:
        yaml_data = yaml.safe_load(f)

    # Load the JSON schema
    with open(schema_file, "r") as f:
        schema = json.load(f)

    # Validate the YAML data against the JSON schema
    try:
        validate(instance=yaml_data, schema=schema)
        print("YAML data is valid against the JSON schema!")
    except exceptions.ValidationError as e:
        print(f"Validation error: {e.message}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Validate a YAML file against a JSON schema.")
    parser.add_argument("yaml_file", help="Path to the YAML file to validate.")
    parser.add_argument("schema_file", help="Path to the JSON schema file.")

    args = parser.parse_args()
    validate_yaml_against_schema(args.yaml_file, args.schema_file)
