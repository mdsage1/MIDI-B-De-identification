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

baseCommand: python
arguments:
  - valueFrom: unzip_submission.py
  - prefix: --compressed_file
    valueFrom: $(inputs.compressed_file)