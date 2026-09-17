import json
import sys
import tempfile
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from analyzer import analyze_file
from rule_registry import CATALOG
from parsers.integration_parser import parse_file as parse_sql
from parsers.device_status_parser import parse_file as parse_device

SQL = "INSERT INTO EXTERNAL_PAYMENT (Machine_id, Tran_date, Tran_time, Term_no, Mem_no, Tran_amt) VALUES ('00A01', '20260916', '100000', 'TERM1', 'TX1', '1000')"
def stamp(text, millis=0):
    return f'[09-17 10:00:00.{millis:03}] {text}\n'
def snapshot(n, slots, device='00A01', minute=0):
    return f'{n} {device} PS CSTA=GG {slots} 2026-09-17 오전 10:{minute:02}:00 OK\n'

class AnalysisTests(unittest.TestCase):
    def run_log(self, text, active=None, encoding='utf-8'):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)/'sample.log'
            path.write_bytes(text.encode(encoding))
            return analyze_file(path, set(CATALOG) if active is None else set(active))
    def test_explicit_success_pair_is_one_operation(self):
        r = self.run_log(stamp('setQuery Success=['+SQL+']')+stamp('setQuery dbCount=[1]'))
        self.assertEqual((1,0,0), (r['successCount'],r['errorCount'],r['unknownCount']))
        self.assertEqual('00A01',r['operations'][0]['deviceId'])
        self.assertEqual(2,r['operations'][0]['lineEnd'])
    def test_request_and_success_sql_are_same_attempt(self):
        r = self.run_log(stamp('DEBUG oracle - InsertPayment() SQL='+SQL)+stamp('setQuery Success=['+SQL+']')+stamp('setQuery dbCount=[1]'))
        self.assertEqual(1,len(r['operations']))
        self.assertEqual(1,r['successCount'])
    def test_row_count_after_request_is_explicit_evidence(self):
        r=self.run_log(stamp('DEBUG oracle - InsertPayment() SQL='+SQL)+stamp('setQuery dbCount=[1]'))
        self.assertEqual(1,r['successCount'])
    def test_next_device_does_not_prove_success(self):
        r=self.run_log(stamp('INFO mysql - selectPaymentDB(00A01)')+stamp('DEBUG oracle - InsertPayment() SQL='+SQL)+stamp('INFO mysql - selectPaymentDB(00A02)'))
        self.assertEqual((0,1,0),(r['successCount'],r['unknownCount'],r['failedOperationCount']))
    def test_eof_request_is_unknown(self):
        r=self.run_log(stamp('DEBUG oracle - InsertPayment() SQL='+SQL))
        self.assertEqual('UNKNOWN',r['operations'][0]['resultStatus'])
        self.assertEqual(0,r['errorCount'])
    def test_orphan_count_is_unknown(self):
        r=self.run_log(stamp('setQuery dbCount=[1]'))
        self.assertEqual(1,r['unknownCount'])
    def test_success_zero_count_is_conflicting(self):
        r=self.run_log(stamp('setQuery Success=['+SQL+']')+stamp('setQuery dbCount=[0]'))
        self.assertEqual(1,r['unknownCount'])
    def test_success_followed_by_error_is_unknown(self):
        r=self.run_log(stamp('setQuery Success=['+SQL+']')+stamp('ERROR oracle - InsertPayment(00A01): ORA-01400: NULL'))
        self.assertEqual(1,len(r['operations']))
        self.assertEqual(1,r['unknownCount'])
    def test_error_stack_and_wrapper_are_one_failure(self):
        r=self.run_log(stamp('DEBUG oracle - InsertPayment() SQL='+SQL)+stamp('ERROR oracle - InsertPayment(00A01): ORA-20001: 일마감처리된 영업장')+'ORA-06512: trigger\n'+stamp('ERROR mysql - selectPaymentDB(00A01) insert error'))
        self.assertEqual(1,r['failedOperationCount'])
        self.assertEqual(1,r['errorCount'])
        self.assertIn('ORA-20001',r['operations'][0]['reasonCode'])
    def test_null_error_does_not_claim_product_code_missing(self):
        r=self.run_log(stamp('DEBUG oracle - InsertPayment() SQL='+SQL)+stamp('ERROR oracle - InsertPayment(00A01): ORA-01400: NULL'))
        self.assertEqual('CONSTRAINT_ERROR',r['results'][0]['ruleType'])
        self.assertNotIn('상품코드 누락',r['results'][0]['detectedValue'])
    def test_same_device_different_transactions_stay_separate(self):
        r=self.run_log(stamp('setQuery Success=['+SQL+']')+stamp('setQuery dbCount=[1]')+stamp('setQuery Success=['+SQL.replace('TX1','TX2')+']')+stamp('setQuery dbCount=[1]'))
        self.assertEqual(2,r['successCount'])
        self.assertNotEqual(r['operations'][0]['transactionKey'],r['operations'][1]['transactionKey'])
    def test_interleaved_devices_match_explicit_identity(self):
        r=self.run_log(stamp('DEBUG oracle - InsertPayment() SQL='+SQL)+stamp('DEBUG oracle - InsertPayment() SQL='+SQL.replace('00A01','00B02'))+stamp('ERROR oracle - InsertPayment(00A01): ORA-01400: NULL'))
        self.assertEqual(['ERROR','UNKNOWN'],[o['resultStatus'] for o in r['operations']])
    def test_ambiguous_same_device_does_not_guess(self):
        r=self.run_log(stamp('DEBUG oracle - InsertPayment() SQL='+SQL)+stamp('DEBUG oracle - InsertPayment() SQL='+SQL.replace('TX1','TX2'))+stamp('ERROR oracle - InsertPayment(00A01): ORA-01400: NULL'))
        self.assertEqual(2,r['unknownCount'])
        self.assertEqual(1,r['failedOperationCount'])
        self.assertEqual('SQL:3',r['operations'][2]['operationId'])
    def test_empty_select_is_not_transfer(self):
        with self.assertRaises(ValueError):self.run_log(stamp('INFO mysql - selectPaymentDB(00A01)'))
    def test_unrelated_timestamp_is_unsupported(self):
        with self.assertRaises(ValueError):self.run_log(stamp('INFO keepalive'))
    def test_unknown_rule_is_explicit_error(self):
        with self.assertRaises(ValueError):self.run_log(snapshot(1,'TOYG01=1,100,상품'),['NEW_UNIMPLEMENTED_RULE'])
    def test_rules_off_does_not_hide_observed_operations(self):
        r=self.run_log(stamp('setQuery Success=['+SQL+']'),[])
        self.assertEqual([],r['results'])
        self.assertEqual(1,r['successCount'])
    def test_comm_state_and_control_character(self):
        r=self.run_log(stamp('INFO comm - RECV CATSN=00A01 TIME=20260917100000 CSTA=GG TOYG01=1,100,상\x01품'))
        self.assertEqual(1,r['parsedRecordCount'])
        self.assertEqual('CORRUPTED_DATA',r['results'][0]['ruleType'])
    def test_protocol_header_bytes_are_not_product_corruption(self):
        r=self.run_log(stamp('INFO comm - RECV \x01 CATSN=00A01 TIME=20260917100000 CSTA=GG TOYG01=1,100,상품'))
        self.assertEqual(0,r['errorCount'])
    def test_price_change_preserves_current_and_previous_evidence(self):
        r=self.run_log(snapshot(1,'TOYG01=1,100,상품')+snapshot(2,'TOYG01=1,200,상품',minute=1))
        change=next(x for x in r['results'] if x['ruleType']=='PRICE_CHANGED')
        self.assertEqual((2,1),(change['lineNo'],change['previousLineNo']))
        self.assertEqual(('100','200'),(change['previousValue'],change['currentValue']))
        self.assertEqual('CHANGE',change['resultStatus'])
        self.assertEqual(0,r['errorCount'])
    def test_numeric_format_does_not_make_price_change(self):
        r=self.run_log(snapshot(1,'TOYG01=1,0100,상품')+snapshot(2,'TOYG01=1,100.0,상품',minute=1))
        self.assertEqual(0,r['changeCount'])
    def test_stock_change_is_information(self):
        r=self.run_log(snapshot(1,'TOYG01=2,100,상품')+snapshot(2,'TOYG01=1,100,상품',minute=1))
        self.assertEqual('STOCK_CHANGED',r['results'][0]['ruleType'])
        self.assertEqual(0,r['errorCount'])
    def test_missing_and_restored(self):
        r=self.run_log(snapshot(1,'TOYG01=1,100,가 TOYG02=1,100,나')+snapshot(2,'TOYG01=1,100,가',minute=1)+snapshot(3,'TOYG01=1,100,가 TOYG02=1,100,나',minute=2))
        self.assertEqual(['MISSING_SLOT','SLOT_RESTORED'],[x['ruleType'] for x in r['results']])
    def test_incomplete_snapshot_not_used_for_missing(self):
        r=self.run_log(snapshot(1,'TOYG01=1,100,가 TOYG02=1,100,나')+snapshot(2,'TOYG01=broken TOYG02=1,100,나',minute=1))
        self.assertEqual(1,r['parseFailureCount'])
        self.assertNotIn('MISSING_SLOT',[x['ruleType'] for x in r['results']])
    def test_out_of_order_does_not_reverse_changes(self):
        r=self.run_log(snapshot(1,'TOYG01=1,200,가',minute=2)+snapshot(2,'TOYG01=1,100,가',minute=1))
        self.assertEqual(0,r['changeCount'])
    def test_mixed_file_runs_both_parsers(self):
        r=self.run_log(snapshot(1,'TOYG01=1,100,가')+stamp('setQuery Success=['+SQL+']')+stamp('setQuery dbCount=[1]'))
        self.assertEqual('MIXED',r['logType'])
        self.assertEqual(2,r['parsedRecordCount'])
    def test_cp949_and_utf8_bom(self):
        for encoding in ['cp949','utf-8-sig']:
            with self.subTest(encoding=encoding):self.assertEqual(1,self.run_log(snapshot(1,'TOYG01=1,100,상품'),encoding=encoding)['parsedRecordCount'])
    def test_memo_is_unparsed_not_normal(self):
        r=self.run_log(snapshot(1,'TOYG01=1,100,가')+'업무 메모입니다.\n')
        self.assertEqual(1,r['unparsedLineCount'])
    def test_response_echo_is_deduplicated(self):
        request=stamp('INFO request ?BSN_DAY=20260917&BODYS=item||1')
        xml='<RESULTS><CODE>1</CODE><MESSAGE>SUCC</MESSAGE></RESULTS>'
        r=self.run_log(request+stamp('Response='+xml)+stamp('finish')+stamp('RESULT= '+xml))
        self.assertEqual(1,len(r['operations']))
        self.assertEqual(1,r['successCount'])
    def test_missing_response_is_unknown(self):
        r=self.run_log(stamp('INFO request ?BSN_DAY=20260917&BODYS=item||1'))
        self.assertEqual(1,r['unknownCount'])
    def test_orphan_response_is_not_success(self):
        r=self.run_log(stamp('Response=<CODE>1</CODE><MESSAGE>SUCC</MESSAGE>'))
        self.assertEqual(1,r['unknownCount'])
    def test_sql_comma_in_quoted_value(self):
        r=self.run_log(stamp('setQuery Success=['+SQL.replace("'TX1'","'TX,1'")+']'))
        self.assertEqual('00A01',r['operations'][0]['deviceId'])
        self.assertEqual(1,r['successCount'])

if __name__ == '__main__':unittest.main()
