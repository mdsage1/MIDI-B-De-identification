#!/usr/bin/env python3
"""Preparing the submission for Evaluation. MIDI-B 2024

Submissions will be made as a compressed collection of 
files and subfolders. The folllowing should be included
in the submission but only the last 3 will be used in 
the config.json:
1. Write-up
2. uid_mapping_file.csv
3. patid_mapping.csv
4. Folder with the de-identified images. 
This script will decompress the submission and create a config file
to be used when evaluating the submission using a Docker image.
"""

import os
import argparse
import json
import zipfile

def inspect_zip(zip_path):
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall("submission")
        file_paths = [os.path.join("submission", name) for name in zip_ref.namelist()]
    return file_paths

def create_config(file_paths):
    """Create config.json from file paths."""
    config = {
        "run_name": "MIDI_1_1_Testing",
        "input_data_path": None,
        "output_data_path": "~/results",
        "answer_db_file": "~/MIDI_validation_script/midi_1_1_answer_data_1.db",
        "uid_mapping_file": None,
        "patid_mapping_file": None,
        "multiprocessing": "True",
        "multiprocessing_cpus": "5",
        "log_path": "~/logs",
        "log_level": "info",
        "report_series": "True"
    }

    images = []

    for file_path in file_paths:
        if file_path.contains("uid_mapping"):
            config["uid_mapping_file"] = file_path
        elif file_path.contains("patid_mapping"):
            config["patid_mapping_file"] = file_path
        else:
            images.append(file_path)

    if images:
        config["input_data_path"] = os.path.dirname(images[0])

    with open("config.json", "w") as config_file:
        json.dump(config, config_file, indent=4)

def main():
    """Main function."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--compressed_file",
                        type=str, required=True)
    args = parser.parse_args()

    file_paths = inspect_zip(args.compressed_file)

    # Create the config.json file using the 
    # filepaths of the submission components
    create_config(file_paths)

    # Return the config.json content
    print(json.dumps(config, indent=4))

if __name__ == "__main__":
    main()