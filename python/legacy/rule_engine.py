from log_type_detector import DEVICE_STATUS, EXTERNAL_RETRANSMISSION, EXTERNAL_INTEGRATION
from rules.device_status_rules import analyze as analyze_device_status
from rules.retransmission_rules import analyze as analyze_retransmission
from rules.integration_rules import analyze as analyze_integration

def analyze(log_type, records, active_rules):
    if log_type == DEVICE_STATUS:
        return analyze_device_status(records, active_rules)
    if log_type == EXTERNAL_RETRANSMISSION:
        return analyze_retransmission(records, active_rules)
    if log_type == EXTERNAL_INTEGRATION:
        return analyze_integration(records, active_rules)
    raise ValueError("지원하지 않는 로그 형식입니다.")