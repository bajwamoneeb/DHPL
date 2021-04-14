version 1.0

workflow TB_Profiler {

  input {
    File    read1
    File    read2
  }

  call fetch_bs {
    input:
      read1=read1,
      read2=read2,
  }

  output {
    File    results   =tb_profiler.results
  }
}

task fetch_bs {

  input {
    String    sample
    String    dataset
    String    api
    String    token
  }

  command <<<
    tb-profiler profile --read1 read1 --read2 read2
    tb-profiler collate
    
    bs --api-server=~{api} --access-token=~{token} download dataset -n ~{dataset} -o .

    mv *_R1_* ~{sample}_R1.fastq.gz
    mv *_R2_* ~{sample}_R2.fastq.gz

  >>>

  output {
    File    read1="${sample}_R1.fastq.gz"
    File    read2="${sample}_R2.fastq.gz"
  }

  runtime {
    docker:       "quay.io/biocontainers/tb-profiler:3.0.3--pypyh3252c3a_0"
    memory:       "8 GB"
    cpu:          2
    disks:        "local-disk 100 SSD"
    preemptible:  1
  }
}
