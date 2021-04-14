version 1.0

workflow TB_Profiler {

  input {
    String  sample
    File    read1
    File    read2
  }

  call tb_profiler {
    input:
      sample= sample_id,
      read1= read1,
      read2= read2
  }

  output {
    File    results= tb_profiler.results
    File    result_table= tb_profiler.result_table
  }
}

task tb-profiler {

  input {
    String    read1
    String    read2
    String    sample
  }

  command <<<
    tb-profiler profile --read1 ~{read1} --read2 ~{read2} --prefix ~{sample}
    tb-profiler collate --prefix ~{sample}
    
  >>>

  output {
    File    results="${sample}.results.json"
    File    result_table= "${sample}.txt"
  }

  runtime {
    docker:       "quay.io/biocontainers/tb-profiler:3.0.3--pypyh3252c3a_0"
    memory:       "8 GB"
    cpu:          2
    disks:        "local-disk 100 SSD"
    preemptible:  1
  }
}
