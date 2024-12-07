#! /bin/bash

# bash regeneratePackageJson.sh ../../packages/reactnative/.env.development.local
#  Expecting a .env argument
if [ $# -eq 0 ]; then
    echo "No environment arguments provided."
    exit 1
fi

nameValue="APPLICATION_NAME"
versionValue="VERSION"

regeneratePackageJson() {
    # Check if the package.json file exists
    local envLines=()
    local newValuesFromEnv=()
    IFS=$'\n' read -r -d '' -a envLines < .env

    for line in "${envLines[@]}"; do
        if [[ "$line" == "$nameValue"* ]]; then
            newValuesFromEnv+=("\"name\": \"$(echo "$line" | cut -d'=' -f2)\"")
        elif [[ "$line" == "$versionValue"* ]]; then
            newValuesFromEnv+=("\"version\": \"$(echo "$line" | cut -d'=' -f2)\"")
        fi
    done

    if [ -f "package.json" ]; then
        # Read the version from the package.json file
        local pkgLines=()
        IFS=$'\n' read -r -d '' -a pkgLines < package.json
        local updatedPkgLines=()
        for line in "${pkgLines[@]}"; do
            if [[ "$line" != *"\"name\":"* && "$line" != *"\"version\":"* ]]; then
                updatedPkgLines+=("$line")
            fi
        done
        # Remove the first and last element from the array with the [@]:1-1
        pkgLines=("{" "${newValuesFromEnv[@]/%/","}" "${updatedPkgLines[@]:1}")
        echo "${pkgLines[@]}" > package.json
    else
        echo "package.json file not found"
        exit 1
    fi
}

regeneratePackageJson