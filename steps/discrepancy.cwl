#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: Run the submission against the Organizers pipeline for Discrepancies

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: compressed_file
    type: File
  - id: database_created
    type: File

outputs:

  - id: scoring_results
    type: File
    outputBinding:
      glob: scoring_report_series.xlsx

  - id: discrepancy_results
    type: File
    outputBinding:
      glob: discrepancy_report_participant.csv
  
  - id: discrepancy_internal
    type: File
    outputBinding:
      glob: discrepancy_report_internal.csv
  

  # - id: results
  #   type: File
  #   outputBinding:
  #     glob: results.json

  # - id: status
  #   type: string
  #   outputBinding:
  #     glob: results.json
  #     outputEval: $(JSON.parse(self[0].contents)['submission_status'])
  #     loadContents: true

baseCommand: python
arguments:
  - valueFrom: /usr/local/bin/MIDI_validation_script/run_reports.py
  - prefix: --compressed_file
    valueFrom: $(inputs.compressed_file)

hints:
  DockerRequirement:
    dockerPull: docker.synapse.org/syn53065762/validate_score:v12
