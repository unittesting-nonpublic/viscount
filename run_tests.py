import sys
from unittest.mock import MagicMock
sys.modules['matplotlib'] = MagicMock()
sys.modules['matplotlib.pyplot'] = MagicMock()

import pytest
pytest.main(['test_parse_test_xml.py', '--cov=parse_test_xml', '--cov-report=term-missing'])
