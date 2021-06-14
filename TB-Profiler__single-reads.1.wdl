version 1.0

workflow TB_Profiler {

  input {
  	String 	TB_P_docker_image
    String  sample_id
    File    read1
  }

  call tb_profiler {
    input:
      TB_P_docker_image= "quay.io/biocontainers/tb-profiler:3.0.2--pypyh3252c3a_0",
      sample= sample_id,
      read1= read1
  }
  
  output {
   File    result_table= tb_profiler.result_table
   String	DR_type= tb_profiler.DR_type
   String	num_dr_variants= tb_profiler.num_dr_variants
   String	rifampicin= tb_profiler.rifampicin
   String	isoniazid= tb_profiler.isoniazid
   String	pyrazinamide= tb_profiler.pyrazinamide
   String	ethambutol= tb_profiler.ethambutol
   String	streptomycin= tb_profiler.streptomycin
   String	fluoroquinolones= tb_profiler.fluoroquinolones
   String	moxifloxacin= tb_profiler.moxifloxacin
   String	ofloxacin= tb_profiler.ofloxacin
   String	levofloxacin= tb_profiler.levofloxacin
   String	ciprofloxacin= tb_profiler.ciprofloxacin
   String	aminoglycosides= tb_profiler.aminoglycosides
   String	amikacin= tb_profiler.amikacin
   String	kanamycin= tb_profiler.kanamycin
   String	capreomycin= tb_profiler.capreomycin
   String	ethionamide= tb_profiler.ethionamide
   String	para_aminosalicylic_acid= tb_profiler.para_aminosalicylic_acid
   String	cycloserine= tb_profiler.cycloserine
   String	linezolid= tb_profiler.linezolid
   String	bedaquiline= tb_profiler.bedaquiline
   String	clofazimine= tb_profiler.clofazimine
   String	delamanid= tb_profiler.delamanid
   
  }
}

task tb_profiler {

  input {
    File	read1
   	String	sample
    String	TB_P_docker_image	
  }

  command <<<
  
    tb-profiler profile --read1 ~{read1} --prefix ~{sample}
    tb-profiler collate --prefix ~{sample} 
    
    DR_type=$(cut -f4 ~{sample}.txt | grep -v "DR_type")
    num_dr_variants=$(cut -f5 ~{sample}.txt | grep -v "num_dr_variants")
    rifampicin=$(cut -f7 ~{sample}.txt | grep -v "rifampicin")
    isoniazid=$(cut -f8 ~{sample}.txt | grep -v "isoniazid")
    pyrazinamide=$(cut -f9 ~{sample}.txt | grep -v "pyrazinamide")
    ethambutol=$(cut -f10 ~{sample}.txt | grep -v "ethambutol")
    streptomycin=$(cut -f11 ~{sample}.txt | grep -v "streptomycin")
    fluoroquinolones=$(cut -f12 ~{sample}.txt | grep -v "fluoroquinolones")
    moxifloxacin=$(cut -f13 ~{sample}.txt | grep -v "moxifloxacin")
    ofloxacin=$(cut -f14 ~{sample}.txt | grep -v "ofloxacin")
    levofloxacin=$(cut -f15 ~{sample}.txt | grep -v "levofloxacin")
    ciprofloxacin=$(cut -f16 ~{sample}.txt | grep -v "ciprofloxacin")
    aminoglycosides=$(cut -f17 ~{sample}.txt | grep -v "aminoglycosides")
    amikacin=$(cut -f18 ~{sample}.txt | grep -v "amikacin")
    kanamycin=$(cut -f19 ~{sample}.txt | grep -v "kanamycin")
    capreomycin=$(cut -f20 ~{sample}.txt | grep -v "capreomycin")
    ethionamide=$(cut -f21 ~{sample}.txt | grep -v "ethionamide")
    para_aminosalicylic_acid=$(cut -f22 ~{sample}.txt | grep -v "para-aminosalicylic_acid")
    cycloserine=$(cut -f23 ~{sample}.txt | grep -v "cycloserine")
    linezolid=$(cut -f24 ~{sample}.txt | grep -v "linezolid")
    bedaquiline=$(cut -f25 ~{sample}.txt | grep -v "bedaquiline")
    clofazimine=$(cut -f26 ~{sample}.txt | grep -v "clofazimine")
    delamanid=$(cut -f27 ~{sample}.txt | grep -v "delamanid")

    echo $num_dr_variants | tee num_dr_variants
    echo $DR_type | tee DR_TYPE
    echo $rifampicin | tee rifampicin
    echo $isoniazid | tee isoniazid
    echo $pyrazinamide | tee pyrazinamide
    echo $ethambutol | tee ethambutol
    echo $streptomycin | tee streptomycin
    echo $fluoroquinolones | tee fluoroquinolones
    echo $moxifloxacin | tee moxifloxacin
    echo $ofloxacin | tee ofloxacin
    echo $levofloxacin | tee levofloxacin
    echo $ciprofloxacin | tee ciprofloxacin
    echo $aminoglycosides | tee aminoglycosides
    echo $amikacin | tee amikacin
    echo $kanamycin | tee kanamycin
    echo $capreomycin | tee capreomycin
    echo $ethionamide | tee ethionamide
    echo $para_aminosalicylic_acid | tee para_aminosalicylic_acid
    echo $cycloserine | tee cycloserine
    echo $linezolid | tee linezolid
    echo $bedaquiline | tee bedaquiline
    echo $clofazimine | tee clofazimine
    echo $delamanid | tee delamanid

    mv ~{sample}.txt ~{sample}.tsv

  >>>

  output {
   File    result_table= "${sample}.tsv"
   String	DR_type= read_string("DR_TYPE")
   String	num_dr_variants= read_string("num_dr_variants")
   String	rifampicin= read_string("rifampicin")
   String	isoniazid= read_string("isoniazid")
   String	pyrazinamide= read_string("pyrazinamide")
   String	ethambutol= read_string("ethambutol")
   String	streptomycin= read_string("streptomycin")
   String	fluoroquinolones= read_string("fluoroquinolones")
   String	moxifloxacin= read_string("moxifloxacin")
   String	ofloxacin= read_string("ofloxacin")
   String	levofloxacin= read_string("levofloxacin")
   String	ciprofloxacin= read_string("ciprofloxacin")
   String	aminoglycosides= read_string("aminoglycosides")
   String	amikacin= read_string("amikacin")
   String	kanamycin= read_string("kanamycin")
   String	capreomycin= read_string("capreomycin")
   String	ethionamide= read_string("ethionamide")
   String	para_aminosalicylic_acid= read_string("para_aminosalicylic_acid")
   String	cycloserine= read_string("cycloserine")
   String	linezolid= read_string("linezolid")
   String	bedaquiline= read_string("bedaquiline")
   String	clofazimine= read_string("clofazimine")
   String	delamanid= read_string("delamanid")

  }

  runtime {
    docker:       TB_P_docker_image
    memory:       "8 GB"
    cpu:          2
    disks:        "local-disk 100 SSD"
    preemptible:  1
  }
}