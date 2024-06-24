import os
import csv

# Specify the directory path
directory = '/Users/firhard/Desktop/projects'

# Get the list of all files and folders in the specified directory
contents = os.listdir(directory)
# Iterate over the contents and filter out folders
# folders = [item for item in contents if os.path.isdir(os.path.join(directory, item))]
folders = [file_name.replace(".zip","") for file_name in contents]

# Specify the path to the CSV file
csv_file = '/Users/firhard/Desktop/test-visibility-checker/filtered_projects4.csv'

# Open the CSV file
with open(csv_file, 'r') as file:
    # Create a CSV reader object
    reader = csv.reader(file)

    # Create a list to store the rows to be written to the new CSV file
    rows_to_write = []

    # Iterate over each row in the CSV file
    for row in reader:
        # Access the columns of each row
        name = row[0]
        fulllink = row[1]
        hash_value = row[2]
        link = row[1].rsplit('/', 1)[-1]
        if name not in folders:
            # Add the row to the list of rows to be written
            rows_to_write.append([name, fulllink, hash_value])

# Specify the path to the new CSV file
new_csv_file = '/Users/firhard/Desktop/test-visibility-checker/filtered_projects6.csv'

# Open the new CSV file in write mode
with open(new_csv_file, 'w', newline='') as file:
    # Create a CSV writer object
    writer = csv.writer(file)

    # Write the rows to the new CSV file
    writer.writerows(rows_to_write)

print(len(folders))