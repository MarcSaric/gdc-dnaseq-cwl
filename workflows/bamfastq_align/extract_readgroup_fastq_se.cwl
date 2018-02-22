#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - $import: ../../tools/readgroup.yml
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement

inputs:
  - id: readgroup_fastq_se_uuid
    type: ../../tools/readgroup.yml#readgroup_fastq_se_uuid
  - id: bioclient_config
    type: File

outputs:
  - id: output
    type: ../../tools/readgroup.yml#readgroup_fastq_se_file
    outputSource: emit_readgroup_fastq_se_file/output

steps:
  - id: extract_fastq
    run: ../../tools/bio_client_download.cwl
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: readgroup_fastq_se_uuid
        valueFrom: $(self.fastq_uuid)
      - id: file_size
        source: readgroup_fastq_se_uuid
        valueFrom: $(self.fastq_file_size)
    out:
      - id: output

  - id: extract_capture_kit_bait
    run: ../../tools/bio_client_download.cwl
    scatter: download_handle
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: readgroup_fastq_se_uuid
        valueFrom: $(self.readgroup_meta.capture_kit_bait_uuid)
      - id: file_size
        source: readgroup_fastq_se_uuid
        valueFrom: $(self.reverse_fastq_file_size)
    out:
      - id: output

  - id: extract_capture_kit_target
    run: ../../tools/bio_client_download.cwl
    scatter: download_handle
    in:
      - id: config-file
        source: bioclient_config
      - id: download_handle
        source: readgroup_fastq_se_uuid
        valueFrom: $(self.readgroup_meta.capture_kit_target_uuid)
      - id: file_size
        source: readgroup_fastq_se_uuid
        valueFrom: $(self.reverse_fastq_file_size)
    out:
      - id: output
      
  - id: emit_readgroup_fastq_se_file
    run: ../../tools/emit_readgroup_fastq_se_file.cwl
    in:
      - id: capture_kit_bait_file
        source: extract_capture_kit_bait/output
      - id: capture_kit_target_file
        source: extract_capture_kit_target/output
      - id: fastq
        source: extract_fastq/output
      - id: readgroup_meta
        source: readgroup_fastq_se_uuid
        valueFrom: $(self.readgroup_meta)
    out:
      - id: output

