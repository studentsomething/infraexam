#!/bin/sh

set -e

print() {
    local GREEN='\033[1;32m'
    local YELLOW='\033[1;33m'
    local RED='\033[0;31m'
    local NC='\033[0m'
    local BOLD='\e[1m'
    local REGULAR='\e[0m'
    case "$1" in
        'failure' ) echo -e "${RED}✗ $2${NC}" ;;
        'success' ) echo -e "${GREEN}√ $2${NC}" ;;
        'warning' ) echo -e "${YELLOW}⚠ $2${NC}" ;;
        'header'  ) echo -e "${BOLD}$2${REGULAR}" ;;
    esac
}

setup() {
    export DIR="$PWD"
    export GITHUB_TOKEN="${github_token}"
    export HEROKU_API_KEY="${heroku_api_key}"
    export STATUSCAKE_APIKEY="${statuscake_api_key}"
}

setup_cache() {
    export TF_DATA_DIR="${DIR}/terraform-cache/${1}"

    mkdir -p "${TF_DATA_DIR}"
    if [ -z "$(ls -A ${DIR}/terraform-cache/${1})" ]; then
        print warning "cache enabled but empty (fresh worker)"
    else
        print success "cache enabled and found existing cache"
    fi
}

terraform_fmt() {
    if ! terraform fmt -check=true >> /dev/null; then
        print failure "terraform fmt (Some files need to be formatted, run 'terraform fmt' to fix.)"
        exit 1
    fi
    print success "terraform fmt"
}

terraform_get() {
    # NOTE: We are using init here to download providers in addition to modules.
    terraform init -backend=false -input=false >> /dev/null
    print success "terraform get (init without backend)"
}

terraform_init() {
    terraform init -input=false -lock-timeout=$lock_timeout >> /dev/null
    print success "terraform init"
}

terraform_plan() {
    terraform_init
    terraform plan -lock=false -no-color | tee "${DIR}/terraform/full-plan"

    # Create a sanitized plan for Github comments
    echo "\`\`\`diff" > "${DIR}/terraform/plan"
    sed -n -e '/------------------------------------------------------------------------/,$p' "${DIR}/terraform/full-plan" >> "${DIR}/terraform/plan"
    echo "\`\`\`" >> "${DIR}/terraform/plan"
}

terraform_apply() {
    terraform_init
    terraform apply -refresh=true -auto-approve=true -lock-timeout=$lock_timeout
    # Fails if there is no output (which is not really a failure)
    set +e
    terraform output -json > ${DIR}/terraform/output.json
    set -e
    git config --global user.email "concourse-ci@localhost"
    git config --global user.name "concourse-ci"
    git add terraform.tfstate
    git status
    git commit -m"concourse CI@Localhost"
    git clone "${DIR}/source" "${DIR}/with-state"
}

terraform_test_module() {
    terraform_fmt
    terraform_get
    terraform validate -check-variables=false
    print success "terraform validate (not including variables)"
}

terraform_test() {
    terraform_fmt
    terraform_get
    terraform validate
    print success "terraform validate"
}

main() {
    if [ -z "$command" ]; then
        echo "Command is a required parameter and must be set."
        exit 1
    fi
    if [ -z "$directories" ]; then
        echo "No directories provided. Please set the parameter."
        exit 1
    fi

    setup
    for directory in $directories; do
        if [ ! -d "$DIR/source/$directory" ]; then
            print failure "Directory not found: $directory"
            exit 1
        fi
        cd $DIR/source/$directory
        print header "Current directory: $directory"
        if [ "$cache" = "true" ];then
            setup_cache "$directory"
        fi
        case "$command" in
            'test'        ) terraform_test ;;
            'test-module' ) terraform_test_module ;;
            'plan'        ) terraform_plan ;;
            'apply'       ) terraform_apply ;;
            *             ) echo "Command not supported: $command" && exit 1;;
        esac
    done
}

main
