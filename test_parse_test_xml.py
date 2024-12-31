# test_parse_test_xml.py
import os
import tempfile

from parse_test_xml import (parse_surefire, access_modifier, process_list,
                            process_and_append, process_methods_section,
                            start_parsing, find_test_xml_files, find_row, contains_list)


def create_temp_surefire_log(content):
    """Helper function to create a temporary surefire log file."""
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".xml")
    temp_file.write(content.encode('utf-8'))
    temp_file.close()
    return temp_file.name

def test_access_modifier_package():
    assert access_modifier(0) == "Package"

def test_access_modifier_public():
    assert access_modifier(1) == "Public"

def test_access_modifier_private():
    assert access_modifier(2) == "Private"

def test_access_modifier_protected():
    assert access_modifier(4) == "Protected"

def test_access_modifier_unknown():
    assert access_modifier(None) == "Unknown"
    assert access_modifier("string") == "Unknown"

def test_process_list_with_only_flat_elements():
    input_data = [1, 2, 3, 4, 5]
    result, extracted_lists = process_list(input_data)
    assert result == [1, 2, 3, 4, 5]
    assert extracted_lists == []

def test_process_list_with_only_nested_lists():
    input_data = [[1, 2], [3, 4], [5, 6]]
    result, extracted_lists = process_list(input_data)
    assert result == []
    assert extracted_lists == [[1, 2], [3, 4], [5, 6]]

def test_process_list_with_mixed_elements():
    input_data = [1, [2, 3], 4, [5, 6]]
    result, extracted_lists = process_list(input_data)
    assert result == [1, 4]
    assert extracted_lists == [[2, 3], [5, 6]]

def test_process_list_with_empty_list():
    input_data = []
    result, extracted_lists = process_list(input_data)
    assert result == []
    assert extracted_lists == []

def test_process_list_with_nested_empty_lists():
    input_data = [[], [], []]
    result, extracted_lists = process_list(input_data)
    assert result == []
    assert extracted_lists == [[], [], []]

def test_process_and_append_with_empty_extracted_list():
    extracted_list = []
    full_lists = []
    process_and_append(extracted_list, full_lists)
    assert full_lists == [[]]

def test_process_and_append_with_single_level_list():
    extracted_list = ['a', 'b', 'c']
    full_lists = []
    process_and_append(extracted_list, full_lists)
    assert isinstance(full_lists, list)
    assert len(full_lists) > 0

def test_process_and_append_with_nested_lists():
    extracted_list = [['a', 'b'], ['c', ['d', 'e']]]
    full_lists = []
    process_and_append(extracted_list, full_lists)
    assert len(full_lists) > 0

def test_process_and_append_appends_levels_correctly():
    extracted_list = ['level1', ['level2', ['level3']]]
    full_lists = []
    process_and_append(extracted_list, full_lists)
    assert len(full_lists) >= 1

def test_process_and_append_with_non_empty_initial_full_lists():
    extracted_list = ['x', ['y']]
    full_lists = [['initial_data']]
    process_and_append(extracted_list, full_lists)
    assert len(full_lists) > 1

def test_process_methods_section_basic_lines():
    lines = ["Start method call:", "Some method content", "End method call:"]
    result, index = process_methods_section(lines, 0)
    assert result == [["Start method call:", "Some method content", "End method call:"]]
    assert index == len(lines)

def test_process_methods_section_nested_calls():
    lines = [
        "Start method call:",
        "Start constructor call:",
        "Constructor content",
        "End constructor call:",
        "End method call:",
    ]
    result, index = process_methods_section(lines, 0)
    assert result == [
        ["Start method call:", ["Start constructor call:", "Constructor content", "End constructor call:"],
         "End method call:"]
    ]
    assert index == len(lines)

def test_process_methods_section_multiple_calls():
    lines = [
        "Start method call:",
        "Some method content",
        "End method call:",
        "Start constructor call:",
        "Constructor content",
        "End constructor call:",
    ]
    result, index = process_methods_section(lines, 0)
    assert result == [
        ["Start method call:", "Some method content", "End method call:"],
        ["Start constructor call:", "Constructor content", "End constructor call:"],
    ]
    assert index == len(lines)

def test_process_methods_section_incomplete_structure():
    lines = ["Start method call:", "Some method content"]
    result, index = process_methods_section(lines, 0)
    assert index == len(lines)
    assert index == len(lines)

def test_process_methods_section_empty_lines():
    lines = []
    result, index = process_methods_section(lines, 0)
    assert result == []
    assert index == 0

def test_process_methods_section_end_without_start():
    lines = ["End method call:"]
    result, index = process_methods_section(lines, 0)
    assert index == len(lines)

def test_start_parsing_valid_input():
    log = ["log line 1", "log line 2"]
    testcase_name = "TestCase1"
    file_name = "test_file.xml"
    result = start_parsing(log, testcase_name, file_name)
    assert result is not None
    assert isinstance(result, list)

def test_start_parsing_empty_log():
    log = []
    testcase_name = "TestCase1"
    file_name = "test_file.xml"
    result = start_parsing(log, testcase_name, file_name)
    assert result == []

def test_start_parsing_invalid_testcase_name():
    log = ["log line 1"]
    testcase_name = None  # Invalid testcase name
    file_name = "test_file.xml"
    result = start_parsing(log, testcase_name, file_name)
    assert result == []

def test_start_parsing_invalid_file_name():
    log = ["log line 1"]
    testcase_name = "TestCase1"
    file_name = None  # Invalid file name
    result = start_parsing(log, testcase_name, file_name)
    assert result == []

def test_start_parsing_exception_handling():
    log = ["log line 1"]
    testcase_name = "TestCase1"
    file_name = "test_file.xml"
    try:
        exception_result = start_parsing(None, testcase_name, file_name)
    except Exception:
        exception_result = None
    assert exception_result is None

def test_find_test_xml_files_no_files():
    with tempfile.TemporaryDirectory() as temp_dir:
        result = find_test_xml_files(temp_dir)
    assert result == []

def test_find_test_xml_files_with_matching_file():
    with tempfile.TemporaryDirectory() as temp_dir:
        file_path = os.path.join(temp_dir, "TEST-sample.xml")
        with open(file_path, "w") as f:
            f.write("<xml></xml>")
        result = find_test_xml_files(temp_dir)
    assert result == [file_path]

def test_find_test_xml_files_with_multiple_matching_files():
    with tempfile.TemporaryDirectory() as temp_dir:
        file1 = os.path.join(temp_dir, "TEST-a.xml")
        file2 = os.path.join(temp_dir, "TEST-b.xml")
        with open(file1, "w") as f1, open(file2, "w") as f2:
            f1.write("<xml></xml>")
            f2.write("<xml></xml>")
        result = find_test_xml_files(temp_dir)
        assert len(result) == 2
    assert file1 in result
    assert file2 in result

def test_find_test_xml_files_with_non_matching_files():
    with tempfile.TemporaryDirectory() as temp_dir:
        file_path = os.path.join(temp_dir, "NON-MATCHING.xml")
        with open(file_path, "w") as f:
            f.write("<xml></xml>")
        result = find_test_xml_files(temp_dir)
    assert result == []

def test_find_test_xml_files_in_nested_directories():
    with tempfile.TemporaryDirectory() as temp_dir:
        nested_dir = os.path.join(temp_dir, "nested")
        os.makedirs(nested_dir)
        file1 = os.path.join(temp_dir, "TEST-top.xml")
        file2 = os.path.join(nested_dir, "TEST-nested.xml")
        with open(file1, "w") as f1, open(file2, "w") as f2:
            f1.write("<xml></xml>")
            f2.write("<xml></xml>")
        result = find_test_xml_files(temp_dir)
    assert file1 in result
    assert file2 in result

def test_find_test_xml_files_sorted_by_size():
    with tempfile.TemporaryDirectory() as temp_dir:
        small_file = os.path.join(temp_dir, "TEST-a.xml")
        large_file = os.path.join(temp_dir, "TEST-b.xml")
        with open(small_file, "w") as f1, open(large_file, "w") as f2:
            f1.write("<xml></xml>")
            f2.write("<xml>" + "a" * 1000 + "</xml>")
        result = find_test_xml_files(temp_dir)
    assert result == [small_file, large_file]

def test_parse_surefire_valid_log():
    """Test parse_surefire with a valid surefire log."""
    xml_content = """<?xml version="1.0" encoding="UTF-8"?>
    <testsuite>
        <testcase classname="test.classname" name="testMethod">
            <system-out>
                <![CDATA[Start method\tEnd method]]>
            </system-out>
        </testcase>
    </testsuite>"""
    log_path = create_temp_surefire_log(xml_content)

    try:
        parse_surefire(log_path)
        pass  # Ensure no exception occurs
    finally:
        os.unlink(log_path)

def test_parse_surefire_missing_testcase():
    """Test parse_surefire with missing testcase element."""
    xml_content = """<?xml version="1.0" encoding="UTF-8"?>
    <testsuite></testsuite>"""
    log_path = create_temp_surefire_log(xml_content)

    try:
        parse_surefire(log_path)
        pass  # Ensure no exception occurs
    finally:
        os.unlink(log_path)

def test_parse_surefire_failure_in_testcase():
    """Test parse_surefire with a testcase containing a failure."""
    xml_content = """<?xml version="1.0" encoding="UTF-8"?>
    <testsuite>
        <testcase classname="test.classname" name="testMethod">
            <failure>Failure message</failure>
        </testcase>
    </testsuite>"""
    log_path = create_temp_surefire_log(xml_content)

    try:
        parse_surefire(log_path)
        pass  # Ensure no exception occurs
    finally:
        os.unlink(log_path)

def test_parse_surefire_error_in_testcase():
    """Test parse_surefire with a testcase containing an error."""
    xml_content = """<?xml version="1.0" encoding="UTF-8"?>
    <testsuite>
        <testcase classname="test.classname" name="testMethod">
            <error>Error message</error>
        </testcase>
    </testsuite>"""
    log_path = create_temp_surefire_log(xml_content)

    try:
        parse_surefire(log_path)
        pass  # Ensure no exception occurs
    finally:
        os.unlink(log_path)

def test_parse_surefire_skipped_testcase():
    """Test parse_surefire with a skipped testcase."""
    xml_content = """<?xml version="1.0" encoding="UTF-8"?>
    <testsuite>
        <testcase classname="test.classname" name="testMethod">
            <skipped />
        </testcase>
    </testsuite>"""
    log_path = create_temp_surefire_log(xml_content)

    try:
        parse_surefire(log_path)
        pass  # Ensure no exception occurs
    finally:
        os.unlink(log_path)

def test_parse_surefire_invalid_xml():
    """Test parse_surefire with invalid XML content."""
    xml_content = """<testsuite><testcase>"""
    log_path = create_temp_surefire_log(xml_content)

    try:
        parse_surefire(log_path)
        pass  # Ensure it handles invalid XML gracefully
    finally:
        os.unlink(log_path)

def test_parse_surefire_empty_log():
    """Test parse_surefire with an empty surefire log."""
    xml_content = """<?xml version="1.0" encoding="UTF-8"?>"""
    log_path = create_temp_surefire_log(xml_content)

    try:
        parse_surefire(log_path)
        pass  # Ensure no exception occurs
    finally:
        os.unlink(log_path)

def test_contains_list_with_empty_list():
    assert contains_list([]) is False

def test_contains_list_with_mixed_elements():
    assert contains_list([1, "string", [3, 4], {"key": "value"}]) is True

# def test_find_row_correct_case():
#     row = {
#         'Method Name': 'TestClass.testMethod()',
#         'Internal Test Case': 'TestCaseClass.testCase()',
#         'Access Modifier': 'Public'
#     }
#     assert find_row(row) is True
#
# def test_find_row_nonexistent_method():
#     row = {
#         'Method Name': 'NonExistentClass.nonExistentMethod()',
#         'Internal Test Case': 'TestCaseClass.testCase()',
#         'Access Modifier': 'Public'
#     }
#     assert find_row(row) is False
#
# def test_find_row_access_modifier_private():
#     row = {
#         'Method Name': 'PrivateClass.privateMethod()',
#         'Internal Test Case': 'PrivateCaseClass.privateCase()',
#         'Access Modifier': 'Private'
#     }
#     assert find_row(row) is True
#
# def test_find_row_empty_method_name():
#     row = {
#         'Method Name': '',
#         'Internal Test Case': 'TestCaseClass.testCase()',
#         'Access Modifier': 'Public'
#     }
#     assert find_row(row) is False
#
# def test_find_row_invalid_internal_test_case():
#     row = {
#         'Method Name': 'TestClass.testMethod()',
#         'Internal Test Case': '',
#         'Access Modifier': 'Public'
#     }
#     assert find_row(row) is False
#
# def test_find_row_ends_with_write_object():
#     row = {
#         'Method Name': 'TestClass.writeObject(java.io.ObjectOutputStream)',
#         'Internal Test Case': 'TestCaseClass.testCase()',
#         'Access Modifier': 'Public'
#     }
#     assert find_row(row) is False
#
# def test_find_row_ends_with_read_object():
#     row = {
#         'Method Name': 'TestClass.readObject(java.io.ObjectInputStream)',
#         'Internal Test Case': 'TestCaseClass.testCase()',
#         'Access Modifier': 'Public'
#     }
#     assert find_row(row) is False
#
# def test_find_row_no_matching_java_file():
#     row = {
#         'Method Name': 'NonMatchingClass.nonMatchingMethod()',
#         'Internal Test Case': 'NonMatchingTestCase.nonMatchingMethod()',
#         'Access Modifier': 'Public'
#     }
#     assert find_row(row) is False
#
# def test_find_row_with_special_modifier():
#     row = {
#         'Method Name': 'SpecialClass.specialMethod()',
#         'Internal Test Case': 'SpecialCase.specialCase()',
#         'Access Modifier': 'Protected'
#     }
#     assert find_row(row) is True
