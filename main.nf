#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process get_images {
  stageInMode 'symlink'
  stageOutMode 'move'

  input:
    val image_folder

  output:
    val "images"

  script:
    """

    if [[ "${params.run_type}" == "r2d2" ]] || [[ "${params.run_type}" == "raven" ]] ; 

      then

        cd ${image_folder}

        if [[ ! -f rnaseq.python-3.8-1.sif ]] ;
          then
            singularity pull rnaseq.python-3.8-1.sif docker://index.docker.io/mpgagebioinformatics/rnaseq.python:3.8-1
        fi
    fi

    if [[ "${params.run_type}" == "local" ]] ; 

      then

        docker pull mpgagebioinformatics/rnaseq.python:3.8-1

    fi

    """

}

process parser {
  stageInMode 'symlink'
  stageOutMode 'move'

  input:
    val images
    val david_email
  
  script:
  """
    #!/usr/local/bin/python
    import json
    import os
    import pandas as pd
    with open("/flaski.json", "r") as f:
        c=json.load(f)
    excel_files=[ s for s in list(c.keys()) if ".xlsx" in s ]
    json_file=[ s for s in list(c.keys()) if ".json" in s ][0]

    for excel_file in excel_files:
    
        excel_sheets=list(c[excel_file].keys())

        EXCout=pd.ExcelWriter(f"/workdir/{excel_file}")
        for e in excel_sheets:
            df=pd.read_json(c[excel_file][e])
            df.to_excel(EXCout, e, index=None )
        EXCout.save()

    json_out=c[json_file]

    json_in=json.loads(json_out)
    json_in=json_in["${params.run_type}"]
    if "ftp" in list(json_in.keys()) :
        json_out=json_out.replace("<ftp>",json_in["ftp"])

    json_out=json_out.replace("<path_to_raw_data>","${params.raw}")
    json_out=json_out.replace("<path_to_run_data>","${params.out}")
    json_out=json_out.replace("<your.david.registered@email.com>","${david_email}")

    json_out=json.loads(json_out)
    json_out=json_out["${params.run_type}"]
    with open("/workdir/params.json" , "w") as f:
        json.dump(json_out, f)
  """
}

workflow {

  folder=file("${params.out}")
  if( ! folder.isDirectory() ) {
    folder.mkdirs()
  }

  if ( 'david' in params.keySet() ) {
    david=${params.david}
  } else {
    david="<your.david.registered@email.com>"
  }

  if ( 'image_folder' in params.keySet() ) {
    image_folder="${params.image_folder}"
  } else {
    image_folder=""
  }

  get_images( image_folder )
  parser( get_images.out.collect(), david )

}
