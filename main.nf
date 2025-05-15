include { NEXTFLOW_RUN as NFCORE_RNAFUSION         } from 'modules/local/nextflow/run/main'
include { NEXTFLOW_RUN as GMS_TOMTE                } from 'modules/local/nextflow/run/main'
include { createTomteSamplesheet                   } from 'functions/local/utils'

workflow {

    NFCORE_RNAFUSION ( // Args: pipeline name, workflow opts, params file, samplesheet, custom config
        Channel.value('nf-core/rnafusion').filter{ params.rnafusion_enabled },
        "${params.all_cli?: ''} ${params.rnafusion_cli?: ''}",
        params.rnafusion_enabled && params.rnafusion_params ? file( params.rnafusion_params, checkIfExists: true ) : [],
        [], // Read from params-file
        params.rnafusion_enabled && params.rnafusion_config ? file(params.rnafusion_config, checkIfExists: true) : [],
        workflow.workDir.resolve('nf-core/rnafusion').toUriString(),
    )
    rnafusion_output             = NFCORE_RNAFUSION.out.output

    GMS_TOMTE (
        Channel.value('gms/tomte').filter{ params.tomte_enabled },
        "${params.all_cli?: ''} ${params.tomte_cli?: ''}",
        params.tomte_enabled && params.tomte_params ? file( params.tomte_params, checkIfExists: true ) : [],
        createTomteSamplesheet(rnafusion_output),
        params.tomte_enabled && params.tomte ? file(params.tomte, checkIfExists: true) : [],
        workflow.workDir.resolve('gms/tomte').toUriString(),
    )
}