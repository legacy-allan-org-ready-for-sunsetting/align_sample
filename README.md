# align_sample

This set of CWLs uses the [`align_sort_bam.cwl`](https://github.com/mskcc-cwl/align_sort_bam) submodule to create BAM file(s) after Mark Duplicates.

```
inputs:
  reference_sequence
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
  r1
    type: 'File[]'
  r2
    type: 'File[]'
  sample_id
    type: string
  lane_id
    type: 'string[]'
    
outputs:
  sample_id_output
    type:
      - string
      - type: array
        items: string
  output_md_metrics
    outputSource:
      - gatk_markduplicatesgatk/output_md_metrics
    type: File
  output_merge_sort_bam
    outputSource:
      - samtools_merge/output_file
    type: File
  output_md_bam
    outputSource:
      - gatk_markduplicatesgatk/output_md_bam
    type: File
```
