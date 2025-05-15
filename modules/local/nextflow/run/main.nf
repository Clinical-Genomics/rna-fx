process NEXTFLOW_RUN {
    // directives:
    tag "$pipeline_name"

    input:
    val pipeline_name     // String
    val nextflow_opts     // String
    val params_file       // pipeline params-file
    val samplesheet       // pipeline samplesheet
    val additional_config // custom configs
    val cache_dir         // cache directory

    exec:
    // Set cache directory so workflow can `-resume`
    def cache_path = file(cache_dir)
    assert cache_path.mkdirs()
    // Construct nextflow command
    def nxf_cmd = [
        'nextflow run',
            pipeline_name,
            nextflow_opts,
            params_file ? "-params-file $params_file" : '',
            additional_config ? "-c $additional_config" : '',
            samplesheet ? "--input $samplesheet" : '',
            "--outdir ${task.workDir}/results",
    ].join(" ")
    // Copy command to shell script in work dir for reference/debugging.
    file("$task.workDir/nf-cmd.sh").text = nxf_cmd
    // Run nextflow command locally in cache directory
    def process = nxf_cmd.execute(null, cache_path.toFile())
    def stdout = new StringBuilder()
    def stderr = new StringBuilder()
    process.consumeProcessOutput(stdout, stderr)
    process.waitFor()

    // Save output logs
    file("${task.workDir}/stdout.log").text = stdout.toString()
    file("${task.workDir}/stderr.log").text = stderr.toString()
    // Copy nextflow log if it exists
    def nf_log = cache_path.resolve(".nextflow.log")
    if (nf_log.exists()) {
        nf_log.copyTo("${task.workDir}/nextflow.log")
    }

    // Check exit status with detailed error message
    if (process.exitValue() != 0) {
        error """
            Nested Nextflow process failed with exit code: ${process.exitValue()}
            Command: ${nxf_cmd}
            STDOUT: ${stdout.toString()}
            STDERR: ${stderr.toString()}
            See logs in: ${task.workDir}
        """
    }

    output:
    path "results" , emit: output
    val stdout.toString(), emit: log

    // stdout = process.text
    // assert process.exitValue() == 0: stdout
    // Copy nextflow log to work directory
    // cache_path.resolve(".nextflow.log").copyTo("${task.workDir}/nextflow.log")

    // output:
    // path "results" , emit: output
    // val stdout, emit: log
}
