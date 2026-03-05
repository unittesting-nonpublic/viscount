import sys
from unittest.mock import MagicMock
sys.modules['matplotlib'] = MagicMock()
sys.modules['matplotlib.pyplot'] = MagicMock()

import time
import os
import shutil
from parse_test_xml import parse_surefire, start_parsing
import parse_test_xml

# Setup fake surefire logs
os.makedirs('benchmark_tmp', exist_ok=True)
os.makedirs('benchmark_report', exist_ok=True)

xml_content_template = """<?xml version="1.0" encoding="UTF-8"?>
<testsuite>
    {}
</testsuite>
"""

testcase_template = """
    <testcase classname="test.classname{}" name="testMethod{}">
        <system-out>
            <![CDATA[Start test
Start method call: 1 public method{}
End method call: 1 public method{}
End test]]>
        </system-out>
    </testcase>
"""

log_paths = []
# Create 100 logs with 2000 testcases each to really test the quadratic runtime
for i in range(20):
    testcases = "".join([testcase_template.format(i, j, j, j) for j in range(2000)])
    xml_content = xml_content_template.format(testcases)
    path = f'benchmark_tmp/TEST-{i}.xml'
    with open(path, 'w') as f:
        f.write(xml_content)
    log_paths.append(path)

parse_test_xml.df = __import__('pandas').DataFrame(columns=['Project','Project Module','Test Case','Internal Test Case','Access Modifier','Access Modifier Number','Method Name'])
parse_test_xml.name = 'bench'
parse_test_xml.report_path = 'benchmark_report/'
parse_test_xml.project_parent_path = 'benchmark_tmp/'

start_time = time.time()
for path in log_paths:
    parse_test_xml.parse_surefire(path)
end_time = time.time()

print(f"Time taken: {end_time - start_time:.4f} seconds")

shutil.rmtree('benchmark_tmp')
shutil.rmtree('benchmark_report')
