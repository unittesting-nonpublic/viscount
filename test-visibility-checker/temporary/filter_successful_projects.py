import os
import pandas as pd
import csv

# Read the CSV file into a pandas DataFrame
successful_df = pd.read_csv('/Users/firhard/Desktop/test-visibility-checker/successful_nondup.csv')
path = "/Users/firhard/Desktop/reports-tmp/"
projects = successful_df.iloc[:, 0]

# for project in projects:
#     nonpublictest = project + "_method_visibility_non_public.tsv"
#     test = project + "_method_visibility.tsv"
#     cut = project + "_all_method_visibility.tsv"
#     nonpublictest_file_path = os.path.join(path, nonpublictest)
#     test_file_path = os.path.join(path, test)
#     cut_file_path = os.path.join(path, cut)
    
#     if not os.path.exists(nonpublictest_file_path):
#         print("File does not exist.")
        
#     if not os.path.exists(test_file_path):
#         print("File does not exist.")
    
#     if not os.path.exists(cut_file_path):
#         print("File does not exist.")

file_list = os.listdir(path)
remove_words = ['_all_method_visibility.tsv','_method_visibility.tsv','_method_visibility_non_public.tsv']
files = []
for file in file_list:
    new_text = file
    if remove_words[0] in file:
        new_text = file.replace(remove_words[0], "")
    elif remove_words[1] in file:
        new_text = file.replace(remove_words[1], "")
    elif remove_words[2] in file:
        new_text = file.replace(remove_words[2], "")
    files.append(new_text)
unique_files = set(files)
unique_successful = set(projects)

non_union = unique_successful.difference(unique_files)
print(len(unique_files))
print(len(unique_successful))
# print(non_union)

# remove projects with no test
# empty_project = []
# for project in unique_successful:
#     reportpath = ['/Users/firhard/Desktop/reports-tmp/' + project + '_all_method_visibility.tsv',
#                   '/Users/firhard/Desktop/reports-tmp/' + project + '_method_visibility.tsv',
#                   '/Users/firhard/Desktop/reports-tmp/' + project + '_method_visibility_non_public.tsv']
#     # print(path)
#     with open(reportpath[1], 'r', newline='') as file:
#         reader = csv.reader(file, delimiter='\t')  # Specify the tab delimiter
#         data = list(reader)  # Read the data from the TSV file into a list of rows
#         if len(data) == 1:
#             empty_project.append(project)

# print(len(empty_project))
# with open('/Users/firhard/Desktop/test-visibility-checker/empty_project.txt', 'w') as file:
#     # Convert the list elements to strings and write them into the file
#     file.write('\n'.join(str(element) for element in empty_project))

# files = []
# with open('/Users/firhard/Desktop/test-visibility-checker/empty_project.txt', 'r', newline='') as file:
#         reader = csv.reader(file, delimiter='\n')  # Specify the tab delimiter
#         data = list(reader)  # Read the data from the TSV file into a list of rows
#         for prj in data:
#             if os.path.exists('/Users/firhard/Desktop/reports-tmp/' + prj[0] + remove_words[0]):
#                 files.append('/Users/firhard/Desktop/reports-tmp/' + prj[0] + remove_words[0])
#                 os.remove('/Users/firhard/Desktop/reports-tmp/' + prj[0] + remove_words[0]) 
#             if os.path.exists('/Users/firhard/Desktop/reports-tmp/' + prj[0] + remove_words[1]):
#                 files.append('/Users/firhard/Desktop/reports-tmp/' + prj[0] + remove_words[1])
#                 os.remove('/Users/firhard/Desktop/reports-tmp/' + prj[0] + remove_words[1]) 
#             if os.path.exists('/Users/firhard/Desktop/reports-tmp/' + prj[0] + remove_words[2]):
#                 files.append('/Users/firhard/Desktop/reports-tmp/' + prj[0] + remove_words[2])
#                 os.remove('/Users/firhard/Desktop/reports-tmp/' + prj[0] + remove_words[2]) 
            
# print(len(files))

# check for project's CUT accessibility modifiers
for prj in unique_files:
    prj_df = pd.read_csv('/Users/firhard/Desktop/reports-tmp/' + 'apache-commons-lang' + remove_words[0])
    