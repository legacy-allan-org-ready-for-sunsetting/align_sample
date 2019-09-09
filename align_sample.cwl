class: Workflow
cwlVersion: v1.0
id: align_sample
label: align_sample
inputs:
  - id: reference_sequence
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
  - id: r1
    type: 'File[]'
  - id: r2
    type: 'File[]'
  - id: sample_id
    type: string
  - id: lane_id
    type: 'string[]'
  - id: known_sites
    type:
      type: array
      items: File
    secondaryFiles:
      - .idx
outputs:
  - id: sample_id_output
    outputSource:
      - bwa_sort/sample_id_output
    type:
      - string
      - type: array
        items: string
  - id: output_md_metrics
    outputSource:
      - gatk_markduplicatesgatk/output_md_metrics
    type: File
  - id: output_merge_sort_bam
    outputSource:
      - samtools_merge/output_file
    type: File
  - id: output_md_bam
    outputSource:
      - gatk_markduplicatesgatk/output_md_bam
    type: File
  - id: output_baserecal
    outputSource:
      - gatk_base_recalibrator/output
    type: File

steps:
  - id: samtools_merge
    in:
      - id: input_bams
        source:
          - bwa_sort/output_file
    out:
      - id: output_file
    run: command_line_tools/samtools-merge_1.9/samtools-merge_1.9.cwl
  - id: bwa_sort
    in:
      - id: r1
        source: r1
      - id: r2
        source: r2 
      - id: reference_sequence
        source: reference_sequence
      - id: read_pair
        valueFrom: ${ var data = []; data.push(inputs.r1); data.push(inputs.r2); return data; } 
      - id: sample_id
        source: sample_id
      - id: lane_id
        source: lane_id
    out:
      - id: output_file
      - id: sample_id_output
      - id: lane_id_output
    run: align_sort_bam/align_sort_bam.cwl
    label: bwa_sort
    scatter:
      - r1
      - r2
      - lane_id
    scatterMethod: dotproduct
  - id: gatk_markduplicatesgatk
    in:
      - id: input
        source: samtools_merge/output_file
    out:
      - id: output_md_bam
      - id: output_md_metrics
    run: >-
      command_line_tools/gatk_mark_duplicates_4.1.0.0/gatk_mark_duplicates_4.1.0.0.cwl
    label: GATK MarkDuplicates
  - id: gatk_base_recalibrator
    in:
      - id: reference
        source: reference_sequence
      - id: input
        source:  gatk_markduplicatesgatk/output_md_bam
      - id: known_sites
        source: known_sites
    out:
      - id: output
    run: >-
      command_line_tools/gatk_base_recalibrator_4.1.0.0/gatk_base_recalibrator_4.1.0.0.cwl
    label: GATK Base Recalibrator
  - id: gatk_apply_bqsr
    in:
      - id: reference
        source: reference_sequence
      - id: input
        source:  gatk_markduplicatesgatk/output_md_bam
      - id: bqsr_recal_file 
        source: gatk_base_recalibrator/output
    out:
      - id: output
    run: >-
      command_line_tools/gatk_apply_bqsr_4.1.0.0/gatk_apply_bqsr_4.1.0.0.cwl
    label: GATK Apply BQSR
requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
