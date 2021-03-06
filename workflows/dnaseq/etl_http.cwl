#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
 - class: InlineJavascriptRequirement
 - class: StepInputExpressionRequirement
 - class: SubworkflowFeatureRequirement

inputs:
  - id: gdc_token
    type: File
  - id: input_bam_gdc_id
    type: string
  - id: input_bam_file_size
    type: long
  - id: known_snp_gdc_id
    type: string
  - id: known_snp_file_size
    type: long
  - id: known_snp_index_gdc_id
    type: string
  - id: known_snp_index_file_size
    type: long
  - id: reference_amb_gdc_id
    type: string
  - id: reference_amb_file_size
    type: long
  - id: reference_ann_gdc_id
    type: string
  - id: reference_ann_file_size
    type: long
  - id: reference_bwt_gdc_id
    type: string
  - id: reference_bwt_file_size
    type: long
  - id: reference_dict_gdc_id
    type: string
  - id: reference_dict_file_size
    type: long
  - id: reference_fa_gdc_id
    type: string
  - id: reference_fa_file_size
    type: long
  - id: reference_fai_gdc_id
    type: string
  - id: reference_fai_file_size
    type: long
  - id: reference_pac_gdc_id
    type: string
  - id: reference_pac_file_size
    type: long
  - id: reference_sa_gdc_id
    type: string
  - id: reference_sa_file_size
    type: long
  - id: thread_count
    type: long
  - id: job_uuid
    type: string

outputs:
  - id: bam
    type: File
    outputSource: transform/bam
  - id: sqlite
    type: File
    outputSource: transform/sqlite

steps:
  - id: extract_bam
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: input_bam_gdc_id
      - id: file_size
        source: input_bam_file_size
    out:
      - id: output

  - id: extract_known_snp
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: known_snp_gdc_id
      - id: file_size
        source: known_snp_file_size
    out:
      - id: output

  - id: extract_known_snp_index
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: known_snp_index_gdc_id
      - id: file_size
        source: known_snp_index_file_size
    out:
      - id: output

  - id: extract_reference_amb
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: reference_amb_gdc_id
      - id: file_size
        source: reference_amb_file_size
    out:
      - id: output

  - id: extract_reference_ann
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: reference_ann_gdc_id
      - id: file_size
        source: reference_ann_file_size
    out:
      - id: output

  - id: extract_reference_bwt
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: reference_bwt_gdc_id
      - id: file_size
        source: reference_bwt_file_size
    out:
      - id: output

  - id: extract_reference_dict
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: reference_dict_gdc_id
      - id: file_size
        source: reference_dict_file_size
    out:
      - id: output

  - id: extract_reference_fa
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: reference_fa_gdc_id
      - id: file_size
        source: reference_fa_file_size
    out:
      - id: output

  - id: extract_reference_fai
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: reference_fai_gdc_id
      - id: file_size
        source: reference_fai_file_size
    out:
      - id: output

  - id: extract_reference_pac
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: reference_pac_gdc_id
      - id: file_size
        source: reference_pac_file_size
    out:
      - id: output

  - id: extract_reference_sa
    run: ../../tools/gdc_get_object.cwl
    in:
      - id: gdc_token
        source: gdc_token
      - id: gdc_uuid
        source: reference_sa_gdc_id
      - id: file_size
        source: reference_sa_file_size
    out:
      - id: output

  - id: root_fasta_files
    run: ../../tools/root_fasta_dnaseq.cwl
    in:
      - id: fasta
        source: extract_reference_fa/output
      - id: fasta_amb
        source: extract_reference_amb/output
      - id: fasta_ann
        source: extract_reference_ann/output
      - id: fasta_bwt
        source: extract_reference_bwt/output
      - id: fasta_dict
        source: extract_reference_dict/output
      - id: fasta_fai
        source: extract_reference_fai/output
      - id: fasta_pac
        source: extract_reference_pac/output
      - id: fasta_sa
        source: extract_reference_sa/output
    out:
      - id: output

  - id: root_known_snp_files
    run: ../../tools/root_vcf.cwl
    in:
      - id: vcf
        source: extract_known_snp/output
      - id: vcf_index
        source: extract_known_snp_index/output
    out:
      - id: output
 
  - id: transform
    run: transform.cwl
    in:
      - id: input_bam
        source: extract_bam/output
      - id: known_snp
        source: root_known_snp_files/output
      - id: reference_sequence
        source: root_fasta_files/output
      - id: thread_count
        source: thread_count
      - id: job_uuid
        source: job_uuid
    out:
      - id: bam
      - id: sqlite
