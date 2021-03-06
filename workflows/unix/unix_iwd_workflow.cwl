#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

inputs:
  - id: INPUT
    type: File

outputs:
  - id: index_bam_output
    type: File
    outputSource: index_bam/OUTPUT
  - id: fastq1
    type:
      type: array
      items: File
    outputSource: bamtofastq/output_fastq1
  - id: fastq2
    type:
      type: array
      items: File
    outputSource: bamtofastq/output_fastq2
    
steps:
  - id: index_bam
    run: unix_initialworkdirrequirement.cwl
    in:
      - id: INPUT
        source: INPUT
    out:
      - id: OUTPUT

  - id: bamtofastq
    run: unix_bamtofastq_cmd.cwl
    in:
      - id: bam
        source: index_bam/OUTPUT
    out:
      - id: output_fastq1
      - id: output_fastq2
