version 1.0

workflow AMRfinder {

  input {
  	String 	AMR_docker_image
    String  sample_id
    File    assembly_fasta
  }

  call amr_finder {
    input:
      AMR_docker_image= "ncbi/amr:latest",
      sample= sample_id,
      fasta= assembly_fasta
  }
  
  output {
   File    result_table= amr_finder.result_table
   String	num_amr_genes= amr_finder.num_amr_genes
   String	amr_genes= amr_finder.amr_genes
  }
}

task amr_finder {

  input {
    File	fasta
   	String	sample
    String	AMR_docker_image	
  }

command <<<
amrfinder -n ~{fasta} -o ~{sample}.tsv
amr_genes=$(awk -F "\t" '{if ($9 == "AMR") print $6}' ~{sample}.tsv)
echo "$amr_genes" | wc -w | tee amr_count
echo $amr_genes | tr ' ' , | tee amr_genes
>>>

  output {
   File    result_table= "${sample}.tsv"
   String	amr_genes= read_string("amr_genes")
   String	num_amr_genes= read_string("amr_count")
     }

  runtime {
    docker:       AMR_docker_image
    memory:       "8 GB"
    cpu:          2
    disks:        "local-disk 100 SSD"
    preemptible:  1
  }
}