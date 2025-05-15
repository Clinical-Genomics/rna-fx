/**
 * Returns a channel with the path if it's defined, otherwise returns a default channel.
 *
 * @param path             The path to include into the channel
 * @param default_channel  A channel to use as the default if no path is defined.
 * @return                 A channel with a path, or the default channel
 */

def createTomteSamplesheet ( Object dir ){
    if ( dir ) {
        dir.map { results ->
                def bam_file = file(results.resolve('star/*bam'), checkIfExists: true)
                def bai_file = file("star/*bam.bai", checkIfExists: true)
                def strandedness = 'reverse'
                "${bam_file.simpleName},0,${strandedness},${bam_file},${bai_file}"
                    }
            //     files( results.resolve( 'cram/*cram' ), checkIfExists: true )
            //         .collect {
            //             "${it.simpleName},0,${it},,"
            //         }
            // }
            .flatMap { [ "case,sample,strandedness,bam_cram,bai_crai" ] + it }
            .collectFile( name: 'tomte_samplesheet.csv', newLine: true, sort: false )
    } else {
        Channel.value([])
    }
}
