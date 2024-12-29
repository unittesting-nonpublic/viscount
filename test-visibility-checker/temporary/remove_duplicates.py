import pandas as pd

# Read the CSV file into a pandas DataFrame
df = pd.read_csv("/Users/firhard/Desktop/test-visibility-checker/successful.csv")

# Specify the column name that you want to remove duplicates from
column_name = 'project'

# Remove duplicates based on the specified column
df = df.drop_duplicates(subset=[column_name])

# Save the modified DataFrame back to a CSV file
df.to_csv("/Users/firhard/Desktop/test-visibility-checker/successful_nondup.csv", index=False)
