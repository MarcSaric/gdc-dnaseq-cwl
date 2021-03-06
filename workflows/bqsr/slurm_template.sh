#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --workdir=XX_SCRATCH_DIR_XX
#SBATCH --cpus-per-task=XX_RESOURCE_CORE_COUNT_XX
#SBATCH --mem=XX_RESOURCE_MEM_MEBIBYTES_XX
#SBATCH --gres=SCRATCH:XX_RESOURCE_DISK_GIBIBYTES_XX

##ENV VARIABLE
SCRATCH_DIR=XX_SCRATCH_DIR_XX
CACHE_DIR=${SCRATCH_DIR}/cache/cache
TMP_DIR=${SCRATCH_DIR}/tmp/tmp
VIRTUALENV_NAME=p2

##JOB VARIABLE
INPUT_GDC_ID=XX_INPUT_GDC_ID_XX
CWL_RUNNER_PATH=https://raw.githubusercontent.com/NCI-GDC/gdc-dnaseq-cwl/master/workflows/bqsr/runner.cwl
JSON_PATH=XX_JSON_PATH_XX

function activate_virtualenv()
{
    local virtualenv_name=${1}

    source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
    source ${HOME}/.virtualenvs/${virtualenv_name}/bin/activate
}

function runner()
{
    local cache_dir=${1}
    local cwl_path=${2}
    local job_dir=${3}
    local json_path=${4}
    local tmp_dir=${5}

    export http_proxy=http://cloud-proxy:3128; export https_proxy=http://cloud-proxy:3128;
    cwltool --debug --rm-tmpdir --rm-container --tmp-outdir-prefix ${cache_dir} --tmpdir-prefix ${tmp_dir} --custom-net bridge --outdir ${job_dir} ${cwl_path} ${json_path}
}

function main()
{
    local cwl_runner_path=${CWL_RUNNER_PATH}
    local cwl_status_path=${CWL_STATUS_PATH}
    local json_path=${JSON_PATH}
    local input_gdc_id=${INPUT_GDC_ID}
    local scratch_dir=${SCRATCH_DIR}

    local virtualenv_name=${VIRTUALENV_NAME}
    local cache_dir=${scratch_dir}/${input_gdc_id}/cache
    local job_dir=${scratch_dir}/${input_gdc_id}/
    local tmp_dir=${scratch_dir}/${input_gdc_id}/tmp

    mkdir -p ${cache_dir}
    mkdir -p ${job_dir}
    mkdir -p ${tmp_dir}
    activate_virtualenv ${virtualenv_name}
    runner ${cache_dir} ${cwl_runner_path} ${job_dir} ${json_path} ${tmp_dir}
    if [ $? -ne 0 ]
    then
        echo FAIL_RUNNER
        rm -rf ${job_dir}
        exit 1
    fi
    rm -rf ${job_dir}
}

main "$@"
