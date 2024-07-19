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
    outputBinding:
      glob: config.json

  - id: results
    type: File
    outputBinding:
      glob: results.json

  - id: status
    type: string
    outputBinding:
      glob: results.json
      outputEval: $(JSON.parse(self[0].contents)['status'])
      loadContents: true
  # remove check for writeup file
  # - id: writeup_file
  #   type: File

  - id: invalid_reasons
    type: string
    outputBinding:
      glob: results.json
      outputEval: $(JSON.parse(self[0].contents)['errors'])
      loadContents: true

baseCommand: python
arguments:
  - valueFrom: /usr/local/bin/MIDI_validation_script/unzip_submission.py
  - prefix: --compressed_file
    valueFrom: $(inputs.compressed_file)

hints:
  DockerRequirement:
    dockerPull: docker.synapse.org/syn53065762/validate_score:v12
