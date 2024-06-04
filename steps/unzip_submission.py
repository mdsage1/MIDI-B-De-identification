#!/usr/bin/env python3
"""
Preparing the submission for Evaluation. MIDI-B 2024

Submissions will be made as a compressed collection of 
files and subfolders. The following should be included
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
    writeup = None

    for file_path in file_paths:
        if "mappings" in file_path and "uid_mapping" in file_path:
            config["uid_mapping_file"] = file_path
        elif "mappings" in file_path and "patid_mapping" in file_path:
            config["patid_mapping_file"] = file_path
        elif "writeup" in file_path:
            writeup = file_path
        else:
            images.append(file_path)

    if images:
        config["input_data_path"] = os.path.dirname(images[0])
    
    return config, writeup

def main():
    """Main function."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--compressed_file",
                        type=str, required=True)
    args = parser.parse_args()

    file_paths = inspect_zip(args.compressed_file)

    # Create the config.json file using the 
    # filepaths of the submission components
    config, writeup = create_config(file_paths)

    # Print the write-up file path and the config.json content
    print("Write-up file path:", writeup)
    print(json.dumps(config, indent=4))

if __name__ == "__main__":
    main()
