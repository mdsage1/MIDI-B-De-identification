#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Get result files then upload to Synapse

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      # - entryname: setup.sh
      #   entry: |
          #!/bin/bash
          # pip install openpyxl
      - entryname: upload_results_to_synapse.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import json
          # import openpyxl
          import os
          # import pandas as pd

          parser = argparse.ArgumentParser()
          parser.add_argument("--discrepancy_file", required=True)
          parser.add_argument("--scoring_file", required=True)
          parser.add_argument("--synapse_config", required=True)
          parser.add_argument("--parent_id", required=True)
          args = parser.parse_args()

          # Create a dataframe of the scoring file
          # score_data = pd.read_excel(args.scoring_file)

          # Record the score for display in the Synapse View
          # final_score = score_data['Score'][0]

          # Begin template Synapse Upload script
          syn = synapseclient.Synapse(configPath=args.synapse_config)

          syn.login()

          results = {}

          discrepancy = synapseclient.File(args.discrepancy_file, parent=args.parent_id)
          discrepancy = syn.store(discrepancy)
          results['discrepancy'] = discrepancy.id

          scoring = synapseclient.File(args.scoring_file, parent=args.parent_id)
          scoring = syn.store(scoring)
          results['scoring'] = scoring.id

          # Add the final score to the results file for synapse annotation
          # results['score'] = final_score
          # results['score'] = syn.getColumn(5)
          with open('results.json', 'w') as out:
              json.dump(results, out)

inputs:
  - id: discrepancy_results
    type: File
  - id: scoring_results
    type: File
  - id: parent_id
    type: string
  - id: synapse_config
    type: File

outputs:
  - id: results
    type: File
    outputBinding:
      glob: results.json

baseCommand: python3
arguments:
  - upload_results_to_synapse.py
  - valueFrom: --discrepancy_file
  - valueFrom: $(inputs.discrepancy_results.path)
  - valueFrom: --scoring_file
  - valueFrom: $(inputs.scoring_results.path)
  - valueFrom: --synapse_config
  - valueFrom: $(inputs.synapse_config.path)
  - valueFrom: --parent_id
  - valueFrom: $(inputs.parent_id)
  
# baseCommand: ["/bin/bash", "-c"]
# arguments:
#   - valueFrom: |
      # set -e
      # chmod +x setup.sh
      # ./setup.sh
      # python3 upload_results_to_synapse.py \
      #   --discrepancy_file $(inputs.discrepancy_results.path) \
      #   --scoring_file $(inputs.scoring_results.path) \
      #   --synapse_config $(inputs.synapse_config.path) \
      #   --parent_id $(inputs.parent_id)

hints:
  DockerRequirement:
    dockerPull: sagebionetworks/synapsepythonclient:v2.7.2