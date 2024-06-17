#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Get result files then upload to Synapse

requirements:
- class: InlineJavascriptRequirement
- class: InitialWorkDirRequirement
  listing:
  - entryname: upload_results_to_synapse.py
    entry: |
      #!/usr/bin/env python
      import synapseclient
      import argparse
      import json
      import os
      import tarfile

      parser = argparse.ArgumentParser()
      parser.add_argument("--dciovdfy_file", required=True)
      parser.add_argument("-c", "--synapse_config", required=True)
      parser.add_argument("--parent_id", required=True)
      args = parser.parse_args()

      syn = synapseclient.Synapse(configPath=args.synapse_config)
      syn.login()

      results = {}
      dciovdfy = synapseclient.File(args.dciovdfy_file, parent=args.parent_id)
      dciovdfy = syn.store(dciovdfy)
      results['dciovdfy'] = dciovdfy.id
      with open('results.json', 'w') as out:
        out.write(json.dumps(results))

inputs:
- id: dciovdfy_results
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
- id: dciovdfy_synid
  type: string
  outputBinding:
    glob: results.json
    outputEval: $(JSON.parse(self[0].contents)['dciovdfy'])
    loadContents: true

baseCommand: python3
arguments:
- valueFrom: upload_results_to_synapse.py
- prefix: --dciovdfy_file
  valueFrom: $(inputs.dciovdfy_results)
- prefix: -c
  valueFrom: $(inputs.synapse_config.path)
- prefix: --parent
  valueFrom: $(inputs.parent_id)

hints:
  DockerRequirement:
    dockerPull: sagebionetworks/synapsepythonclient:v2.7.2