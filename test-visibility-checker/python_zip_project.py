import zipfile
import os
import csv

def zip_and_remove_file(file_path):
    # Ensure the file exists
    if not os.path.exists(file_path):
        print(f"File '{file_path}' does not exist.")
        return

    # Create a zip file with the same name as the original file
    zip_file_path = file_path + '.zip'
    with zipfile.ZipFile(zip_file_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        zipf.write(file_path, os.path.basename(file_path))

    # Remove the original file
    os.remove(file_path)
    print(f"'{file_path}' has been zipped and removed. Zip file: '{zip_file_path}'")

name = ["/Users/firhard/Desktop/mvn-test2/apache-commons-math2-mvn-test.log"]

if __name__ == "__main__":
    for row in name:
        file_path = row
        zip_and_remove_file(file_path)
