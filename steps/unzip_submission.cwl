#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: compressed_file
    type: File

outputs:
  - id: config_file
    type: File
  - id: writeup_file
    type: File
  - id: results
    type: File
    outputBinding:
      glob: results.json
  - id: status
    type: string
    outputBinding:
      glob: results.json
      outputEval: $(JSON.parse(self[0].contents)['submission_status'])
      loadContents: true

baseCommand: python
arguments:
  - valueFrom: unzip_submission.py
  - prefix: --compressed_file
    valueFrom: $(inputs.compressed_file)