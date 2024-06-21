#!/bin/bash
repository_dir="repositories"
mkdir -p ../${repository_dir}
cd ../${repository_dir}

repository_names=(
    "SmartFridgeManagerGUI" 
    "SmartFridgeManagerAPI" 
    "SmartFridgeManagerWorkers"
)

create_repository_clone_url() {
    local repository_name=$1
    local repository_base_url="https://github.com/adamcharusta/"
    local repository_url_suffix=".git"

    echo "$repository_base_url$repository_name$repository_url_suffix"
}

instal_dependencies() {
    local repository_name=$1

    echo "Installing dependencies for $repository_name..."

    if [ -f $repository_name/package.json ]; then
        cd $repository_name
        yarn install && yarn build
    elif [ -f $repository_name/${repository_name}.sln ]; then
        cd $repository_name
        dotnet restore && dotnet build
    else
        echo "No dependencies to install for $repository_name"
        exit 1
    fi

    cd - > /dev/null
}

clone_repository() {
    local repository_name=$1
    local repository_base_url="https://github.com/adamcharusta/"
    local repository_url_suffix=".git"

    if [ -d ./$repository_name ]; then
        echo "Repository $repository_name already exists. Pulling changes..."
        cd $repository_name
        git pull
        cd - > /dev/null
    else
        local url=$(create_repository_clone_url $repository_name)
        
        echo $url
        echo "Repository $repository_name does not exist. Cloning..."
        git clone $url
    fi

    if [ -f $repository_name ]; then
        echo "Repository $repository_name depends on other repositories. Please clone them first."
        exit 1
    fi
}


for repository_name in "${repository_names[@]}" ; do
    clone_repository $repository_name
    instal_dependencies $repository_name
done