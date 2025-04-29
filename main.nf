include { NEXTFLOW_RUN as NFCORE_RNAFUSION         } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as GMS_TOMTE                } from "$projectDir/modules/local/nextflow/run/main"


workflow {
    // TODO: Check params-file for values that override channel inputs

    NFCORE_RNAFUSION ( // Args: pipeline name, workflow opts, params file, samplesheet, custom config
        Channel.value('nf-core/rnafusion').filter{ params.rnafusion_enabled },
        "${params.all_cli?: ''} ${params.rnafusion_cli?: ''}",
        params.rnafusion_enabled && params.rnafusion_params ? file( params.rnafusion_params, checkIfExists: true ) : [],
        [], // Read from params-file
        params.rnafusion_enabled && params.rnafusion_config ? file(params.rnafusion_config, checkIfExists: true) : [],
        workflow.workDir.resolve('nf-core/rnafusion').toUriString(),
    )

    NFCORE_DETAXIZER (
        Channel.value('gms/tomte').filter{ params.tomte_enabled },
        "${params.all_cli?: ''} ${params.tomte_cli?: ''}",
        params.tomte_enabled && params.tomte_params ? file( params.tomte_params, checkIfExists: true ) : [],
        [], // Read from params-file
        params.tomte_enabled && params.tomte ? file(params.tomte, checkIfExists: true) : [],
        workflow.workDir.resolve('gms/tomte').toUriString(),
    )
}