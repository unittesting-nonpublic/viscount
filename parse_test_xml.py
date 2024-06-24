
import pandas as pd
import warnings
import xml.etree.ElementTree as ET
# import junitparser
from multiprocessing.dummy import Pool as ThreadPool
from junitparser import Error, Failure, JUnitXml, TestCase, TestSuite, Properties
import glob
import fnmatch
import os
import traceback
import matplotlib.pyplot as plt
import javalang

warnings.simplefilter(action='ignore', category=FutureWarning)
import sys
sys.setrecursionlimit(200000) 

full_lists = []

name=sys.argv[1]
project_path=sys.argv[2]
report_path=sys.argv[3]

# name="javapoet"
# project_path="/Users/firhard/Documents/javapoet" + "/"
# report_path="/Users/firhard/Documents/trial" + "/"


surefire_log_paths = []
project_parent_path = "/".join(report_path.split("/")[:-2]) + "/"


def access_modifier(num):
    switch_dict = {0: "Package", 1: "Public", 2: "Private", 4: "Protected"}
    return switch_dict.get(num, "Unknown")

def process_list(lst):
    result = []
    extracted_lists = []
    i = 0
    while i < len(lst):
        if isinstance(lst[i], list):
            extracted_lists.append(lst[i])
            i += 1
        else:
            result.append(lst[i])
            i += 1
    return result, extracted_lists

def process_and_append(extracted_list, full_lists):
    levels, extracted_lists = process_list(extracted_list)
    full_lists.append(levels)
    for extracted_sublist in extracted_lists:
        process_and_append(extracted_sublist, full_lists)
        
def contains_list(lst):
    for item in lst:
        if isinstance(item, list):
            return True
    return False

def process_section(lines, index):
    try:
        result = []
        while index < len(lines):
            line = lines[index]
            index += 1
            if line.startswith("Start test"):
                sub_section, index = process_section(lines, index)
                result.append([line] + sub_section)
            elif line.startswith("End test"):
                result.append(line)
                return result, index
            else:
                result.append(line)
        return result, index
    except Exception as e:
        return e

def process_methods_section(lines, index):
    try:
        result = []
        while index < len(lines):
            line = lines[index]
            index += 1
            if line.startswith("Start method call:") or line.startswith("Start constructor call:"):
                sub_section, index = process_methods_section(lines, index)
                result.append([line] + sub_section)
            elif line.startswith("End method call:") or line.startswith("End constructor call:"):
                    result.append(line)
                    return result, index 
            else:
                result.append(line)
        return result, index
    except Exception as e:
        return e

def start_parsing(log, testcaseName, fileName):
    try:
        # print("Start:",testcaseName,"on",fileName)
        full_lists = []
        lines = log
        result = []
        index = 0
        sections, index = process_section(lines, index)
        for section in sections:
            result.append(section)
        process_and_append(result, full_lists)
        full_lists = [x for x in full_lists if x]
        invoked = []
        for full_stacks in full_lists:
            if len(full_stacks) > 0:
                test_name = full_stacks[0]
                resultsTmp, indexTmp = process_methods_section(full_stacks,0)
                for resultTmp in resultsTmp:
                    if type(resultTmp) == list:
                        invoked_methods = [x for x in resultTmp if not isinstance(x,list)]
                        if len(invoked_methods) > 1 and len(test_name) > 0  and not invoked_methods[0].startswith("Start constructor"):
                            end = invoked_methods[len(invoked_methods)-1].split(": ")[1]
                            start = invoked_methods[0].split(": ")[1]
                            if start == end:
                                invoked.append([fileName.split("/")[0],fileName,testcaseName,test_name.split(": ")[1].split(" ")[len(test_name.split(": ")[1].split(" "))-1],
                                    (access_modifier(int(invoked_methods[0].split(": ")[1].split(" ")[0])%8)),int(invoked_methods[0].split(": ")[1].split(" ")[0]),
                                    invoked_methods[0].split(": ")[1].split(" ")[1]])
                            else:
                                raise Exception()
        return invoked
    except Exception as e:
        return
        # print("Fail:",testcaseName,"on",fileName)
        # print("Skip test:",testcaseName,"on",fileName)


def find_test_xml_files(directory):
    pattern = "TEST-*.xml"
    matches_df = pd.DataFrame(columns=["Path","Size"])
    matches = []
    for root, dirs, files in os.walk(directory):
        for filename in fnmatch.filter(files, pattern):
            matches_df = pd.concat([matches_df, pd.DataFrame([[os.path.join(root, filename),os.path.getsize(root + "/" +filename)]], columns=matches_df.columns)], ignore_index=True)
            matches.append(os.path.join(root, filename))
    matches_df = matches_df.sort_values(by=['Size'])
    return matches_df['Path'].tolist()

def find_row(row):
    if row['Method Name'].endswith(".writeObject(java.io.ObjectOutputStream)") or row['Method Name'].endswith(".readObject(java.io.ObjectInputStream)"):
        return False
    search_string = row['Method Name'].split("(")[0].split(".")[len(row['Method Name'].split("(")[0].split("."))-1].split("$")[len(row['Method Name'].split("(")[0].split(".")[len(row['Method Name'].split("(")[0].split("."))-1].split("$"))-1]
    java_files = glob.glob(project_parent_path + row['Project Module'] + "/" + '**/' + row['Internal Test Case'].split("(")[0].split(".")[len(row['Internal Test Case'].split("(")[0].split("."))-2].split("$")[0] + ".java", recursive=True)
    if len(search_string) > 0:
        for file in java_files:
            found = False
            with open(file, 'r') as file:
                test_found = False
                ix = 0
                test_string = row['Internal Test Case'].split("(")[0].split(".")[len(row['Internal Test Case'].split("(")[0].split("."))-1].split("$")[len(row['Internal Test Case'].split("(")[0].split(".")[len(row['Internal Test Case'].split("(")[0].split("."))-1].split("$"))-1] + "("
                internal_params = ("(" + row['Internal Test Case'].replace(row['Internal Test Case'].split("(")[0],"").replace("(","").replace(")","") + ")").count(",") + 1
                # print(file.read())
                # tree = javalang.parse.parse(file.read())
                # print(tree)
                for line in file:
                    if test_string in line and test_found == False and ";" not in line:# and '{' in line:        
                        line_params = ("(" + line.replace(line.split("(")[0],"").replace(line.split(")")[-1],"").replace("(","").replace(")","") + ")").count(",") + 1
                        # if row['Internal Test Case'].endswith("()") and test_string + ")" in line.replace(" ","") and ";" not in line:
                        test_found = True
                        if '{' in line:
                            ix = ix + 1
                            continue
                        # elif internal_params == line_params and test_string in line and ";" not in line:
                            # test_found = True
                            # if '{' in line:
                            #     ix = ix + 1
                            #     continue

                    if test_found == True:
                        if '{' in line:
                            ix = ix + 1

                        if row['Method Name'].split("(")[1] == ")" and search_string + "(" in line and len(line.split(search_string)) > 1:
                            x = list(line.split(search_string + "(")[1])
                            if len(x) > 1 and x[0]==(")"):
                                found = True
                                break
                        
                        if "\"" + search_string + "\"" in line and row['Access Modifier'] == "Private":
                            found = True
                            break

                        if search_string + "(" in line and len(line.split(search_string)) > 1:
                            x = list(line.split(search_string + "(")[1])
                            if len(x) > 1 and x[0]==(")"):
                                continue
                            else:
                                found = True
                                break

                        if '"' + search_string + '"' in line:
                            found = True
                            break

                        if '}' in line:
                            ix = ix - 1
                            if ix <= 0: 
                                break
            if found:
                return True
                # final_df = pd.concat([final_df, pd.DataFrame([row], columns=final_df.columns)], ignore_index=True)
                # break
    print(row['Method Name'], row['Internal Test Case'], "not found in")
    return False


def parse_surefire(surefire_log_path):
    try:
        global df
        tree = ET.parse(surefire_log_path)
        print("Currently parsing", surefire_log_path.split("/TEST-")[-1:][0].replace(".xml","") + "() test class report...")
        root = tree.getroot()
        for testcase in root.findall('.//testcase'):
            testcaseName = testcase.get('classname') + "." + testcase.get('name') + "()"
            if testcase.find('failure') is not None or testcase.find('error') is not None or testcase.find('skipped') is not None or len(testcase.findall('.//system-err')) > 0 or len(testcase.findall('.//system-out')) == 0:
                # print(testcaseName)
                continue
            for sysout in testcase.findall('.//system-out'):
                lines = sysout.text.strip().split('\t')
                start_strings = ["Start method","End method", "Start test", "End test", "Start constructor", "End constructor"]

                substring_found = False

                for string in lines:
                    if not any(string.startswith(start) for start in start_strings):
                        substring_found = True
                        break  # Exit the loop if the substring is found

                if substring_found is False:
                    filtered_lines = [line for line in lines if any(line.strip().startswith(start) for start in start_strings)]
                    fileName = surefire_log_path.replace(project_parent_path,"").split("/target/surefire-reports")[0]
                    rslt = start_parsing(filtered_lines, testcaseName,fileName)
                    if rslt is not None:
                        _tmp_df = pd.DataFrame(rslt, columns=['Project','Project Module','Test Case','Internal Test Case','Access Modifier','Access Modifier Number','Method Name'])
                        # _tmp_df = _tmp_df[_tmp_df.apply(find_row, axis=1)]
                        if not _tmp_df.empty:
                            df = pd.concat([df, _tmp_df], ignore_index=True)
                            tsv_string = '\n'.join('\t'.join(map(str, row)) for row in _tmp_df.values)
                            with open(report_path + name + '_tmp.tsv', 'a') as tsv_file:
                                tsv_file.write(tsv_string + '\n')
                    # else:
                        # print(testcaseName, "removed. Not parsed correctly")
    except Exception as e:
        print("fail",surefire_log_path, ":",e)
        print(traceback.format_exc())
        return
    
matching_files = find_test_xml_files(project_path)
for file in matching_files:
    surefire_log_paths.append(file.strip())


with open(report_path + name + '_tmp.tsv', 'w') as tsv_file:
    tsv_file.write('Project\tProject Module\tTest Case\tInternal Test Case\tAccess Modifier\tAccess Modifier Number\tMethod Name\n')

df = pd.DataFrame(columns=['Project','Project Module','Test Case','Internal Test Case','Access Modifier','Access Modifier Number','Method Name'])
for surefire_log_path in surefire_log_paths:
    parse_surefire(surefire_log_path)

print("Finished parsing all test logs... now checking if the method is in the test case...")
final_df = pd.DataFrame(columns=['Project','Project Module','Test Case','Internal Test Case','Access Modifier','Access Modifier Number','Method Name'])
final_df = pd.concat([final_df, df], ignore_index=True)

final_df['Count'] = final_df.groupby(final_df.columns.tolist()).transform('size')
final_df = final_df.drop_duplicates()

print("Filter every row...")
final_df = final_df[final_df.apply(find_row, axis=1)]
final_df.to_csv(report_path + name +'_test_method.tsv', sep='\t', index=False)

print("Finished checking if the method is in the test case... now generating a bar chart for direct method coverage")
cut_visibility_df = pd.read_csv(report_path + name + "_all_method_visibility.tsv", sep='\t', header=0)
test_directly_df = pd.read_csv(report_path + name + "_test_method.tsv", sep='\t', header=0)

cut_count = cut_visibility_df['visibility'].value_counts().reindex(['public', 'protected', 'package-private', 'private'], fill_value=0)

test_directly_df = test_directly_df[['Access Modifier', 'Method Name']].drop_duplicates()  
test_count = test_directly_df['Access Modifier'].value_counts().reindex(['Public', 'Protected', 'Package', 'Private'], fill_value=0)

percentage_df = pd.DataFrame({'Access Modifier': ['public', 'protected', 'package-private', 'private'], 
                            '# production method': [
                                ((cut_count['public']/len(cut_visibility_df)) * 100), 
                                ((cut_count['protected']/len(cut_visibility_df)) * 100),
                                ((cut_count['package-private']/len(cut_visibility_df)) * 100),
                                ((cut_count['private']/len(cut_visibility_df)) * 100)],
                            '# method directly covered in test': [
                                ((test_count['Public']/len(cut_visibility_df) * 100)), 
                                ((test_count['Protected']/len(cut_visibility_df) * 100)),
                                ((test_count['Package']/len(cut_visibility_df) * 100)),
                                ((test_count['Private']/len(cut_visibility_df) * 100))]
                             })

ax = percentage_df.plot(x = 'Access Modifier',y = ['# production method','# method directly covered in test'],kind='bar',colormap="Pastel2_r", width=0.9)
plt.ylim(0, 100)
plt.xticks(rotation=0) 
for c in ax.containers:
    labels = [(f'{int(len(cut_visibility_df) * v.get_height() / 100)}\n' +f'({float("{:.1f}".format(v.get_height()))}%)' if v.get_height() > 0 else f'{int(len(cut_visibility_df) * v.get_height()/100)}') for v in c]
    ax.bar_label(c, labels=labels)

plt.savefig(report_path + name + ".pdf")