#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: MICCAI 2024 MIDI-B Challenge Evaluation
doc: >
  Image de-identification is a requirement for the 
  public sharing of medical images. The goal of the 
  Medical Image Deidentification Benchmark (MIDI-B) 
  challenge is to guide the assessment of rule-based 
  DICOM image de-identification algorithms using 
  clinical images with synthetic identifiers.

requirements:
  - class: StepInputExpressionRequirement

inputs:
  submissionId:
    label: Submission ID
    type: int
  adminUploadSynId:
    label: Synapse Folder ID accessible by the admin
    type: string
  submitterUploadSynId:
    label: Synapse Folder ID accessible by the submitter
    type: string
  synapseConfig:
    label: filepath to .synapseConfig file
    type: File
  organizers:
    label: User or team ID for challenge organizers
    type: string
    default: "3487813"

outputs: {}

steps:
  # organizers_log_access:
  #   doc: >
  #     Give challenge organizers `download` permissions to the submission logs
  #   run: |-
  #     https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.1/cwl/set_permissions.cwl
  #   in:
  #     - id: entityid
  #       source: "#adminUploadSynId"
  #     - id: principalid
  #       source: "#organizers"
  #     - id: permissions
  #       valueFrom: "download"
  #     - id: synapse_config
  #       source: "#synapseConfig"
  #   out: []

  set_submitter_folder_permissions:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.1/cwl/set_permissions.cwl
    in:
      - id: entityid
        source: "#submitterUploadSynId"
      # TODO: replace `valueFrom` with the admin user ID or admin team ID
      - id: principalid
        valueFrom: "#organizers" 
      - id: permissions
        valueFrom: "download"
      - id: synapse_config
        source: "#synapseConfig"
    out: []
    
    download_submission:
    doc: Download submission
    run: |-
      https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.1/cwl/get_submission.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: synapse_config
        source: "#synapseConfig"
    out:
      - id: filepath
      - id: entity_id
      - id: entity_type
      - id: results
      
  # Commented out as this process is still pending 
  # and this was a placeholder
  # create_config_file:
  #   run: /bin/bash
  #   label: "Create config.json"
  #   in:
  #     - id: submitter_folder_id
  #       source: "#submitter_folder_id"
  #     - id: submissionId
  #       source: "#submissionId"
  #   out: [config_file]

  download_goldstandard:
    run: https://raw.githubusercontent.com/Sage-Bionetworks-Workflows/cwl-tool-synapseclient/v1.4/cwl/synapse-get-tool.cwl
    in:
      # TODO: replace `valueFrom` with the Synapse ID to the challenge goldstandard
      - id: synapseid
        valueFrom: "syn58613732"
      - id: synapse_config
        source: "#synapseConfig"
    out:
      - id: filepath
      
    validate:
    run: writeup/validate.cwl
    in:
      - id: synapse_config
        source: "#synapseConfig"
      - id: submissionid
        source: "#submissionId"
      - id: challengewiki
        valueFrom: "syn53065762"  # TODO: update to the Challenge's staging synID
    # UNCOMMENT THE FOLLOWING IF NEEDED
    #   - id: public
    #     default: true
    #   - id: admin
    #     source: "#admin"
    out:
      - id: results
      - id: status
      - id: invalid_reasons
  
  validation_email:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.1/cwl/validate_email.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: synapse_config
        source: "#synapseConfig"
      - id: status
        source: "#validate/status"
      - id: invalid_reasons
        source: "#validate/invalid_reasons"
      # UNCOMMENT IF EMAIL SHOULD ONLY BE SENT FOR ERRORS
      # - id: errors_only
      #   default: true
    out: [finished]

  annotate_validation_with_output:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.1/cwl/annotate_submission.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: annotation_values
        source: "#validate/results"
      - id: to_public
        default: true
      - id: force
        default: true
      - id: synapse_config
        source: "#synapseConfig"
    out: [finished]

  check_status:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.1/cwl/check_status.cwl
    in:
      - id: status
        source: "#validate/status"
      - id: previous_annotation_finished
        source: "#annotate_validation_with_output/finished"
      - id: previous_email_finished
        source: "#validation_email/finished"
    out: [finished]
 
  archive:
    run: writeup/archive.cwl
    in:
      - id: synapse_config
        source: "#synapseConfig"
      - id: submissionid
        source: "#submissionId"
      - id: admin
        source: "#admin"
      - id: check_validation_finished 
        source: "#check_status/finished"
    out:
      - id: results

  annotate_archive_with_output:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.1/cwl/annotate_submission.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: annotation_values
        source: "#archive/results"
      - id: to_public
        default: true
      - id: force
        default: true
      - id: synapse_config
        source: "#synapseConfig"
      - id: previous_annotation_finished
        source: "#annotate_validation_with_output/finished"
    out: [finished]

 