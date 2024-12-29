#!/bin/bash

# Specify the directory containing the files
directory="/Users/firhard/Desktop/projects"

# Iterate over the files in the directory
for folder in "$directory"/*; do
    # Check if the item is a file
    # if [[ -d "$folder" ]]; then
    #     # Get the filename without the directory path and extension
    #     filename=$(basename "$folder")
    #     filename_without_extension="${filename%.*}"

        
    #     # Zip the file individually
    #     zip_file="${filename_without_extension}.zip"
    #     zip -r "$directory/$zip_file" "$folder"

    #     echo "Zipped: $folder -> $zip_file"

    #     rm -rf "$folder"
    #     echo "Removed: $folder"
    # fi

    ## to remove everything inside a folder except for certain stuff
    if [[ -d "$folder" ]]; then
        find $folder -type f ! -name "mvn-test.log" ! -name "mvn-dependencies.log" ! -name "APP_SOURCE.cp" ! -name "TEST_SOURCE.cp" ! -name "mvn-compile.log" -exec rm {} +
        find $folder -mindepth 1 -type d -exec rm -rf {} +
        # shopt -s extglob
        # rm -r $folder/!(mvn-test.log|mvn-compile.log|mvn-dependencies.log|APP_SOURCE.cp|TEST_SOURCE.cp)
        echo "Removed everything from: $folder"
    fi
done