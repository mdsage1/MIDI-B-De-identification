#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: Run the submission against the Organizers pipeline for dciodvfy

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 16000  # Request 16GB of memory
inputs:
  compressed_file:
    type: File
    inputBinding:
      position: 1  # Ensures this input appears directly as the first argument

  results_folder:
    type: Directory
  
outputs:
  dciodvfy_results:
    type: File
    outputBinding:
      glob: 'results/MIDI_1_1_Testing/dciodvfy/dciodvfy_report.csv'

  results:
    type: File
    outputBinding:
      glob: results.json

  status:
    type: string
    outputBinding:
      glob: results.json
      outputEval: $(JSON.parse(self[0].contents)['dciovdfy_status'])
      loadContents: true

  invalid_reasons:
    type: string
    outputBinding:
      glob: results.json
      outputEval: $(JSON.parse(self[0].contents)['errors'])
      loadContents: true
      
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

baseCommand: ["/bin/bash", "-c"]
arguments:
  - |
    mkdir dciodvfy && \
    python /usr/local/bin/MIDI_validation_script/run_dciodvfy.py $(inputs.compressed_file.path)

hints:
  DockerRequirement:
    dockerPull: docker.synapse.org/syn53065762/validate_score:v13
