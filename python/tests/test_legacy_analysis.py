"""Regression checks for the original, default inspection entry point."""
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ANALYZER = Path(__file__).resolve().parents[1] / 'analyzer.py'
RULES = 'PRICE_CHANGED,PRODUCT_NAME_CHANGED,DB_TRANSFER_SUCCESS,DB_TRANSFER_FAILED,CONSTRAINT_ERROR,BUSINESS_PROCESS_ERROR'

class LegacyAnalysisTests(unittest.TestCase):
    def run_file(self, path, rules=RULES, analyzer=ANALYZER):
        run = subprocess.run([sys.executable, str(analyzer), str(path), rules], capture_output=True, text=True, encoding='utf-8', timeout=30)
        self.assertEqual(0, run.returncode, run.stderr)
        return json.loads(run.stdout)

    def run_text(self, text, rules=RULES):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'sample.log'
            path.write_text(text, encoding='utf-8')
            return self.run_file(path, rules)

    def test_default_restores_price_and_name_changes_as_errors(self):
        result = self.run_text('1 00100 PS CSTA=GG TOYG01=1,100,상품 2026-09-17 오전 10:00:00 OK\n2 00100 PS CSTA=GG TOYG01=1,200,새상품 2026-09-17 오전 10:01:00 OK\n')
        self.assertTrue(result['success'])
        self.assertEqual((0, 2), (result['successCount'], result['errorCount']))
        self.assertEqual(['PRICE_CHANGED', 'PRODUCT_NAME_CHANGED'], [r['ruleType'] for r in result['results']])
        self.assertEqual({'ERROR'}, {r['resultStatus'] for r in result['results']})
        self.assertEqual([1, 1], [r['lineNo'] for r in result['results']])

    def test_completed_transfer_keeps_original_success(self):
        result = self.run_text('[09-17 10:00:00.000] INFO mysql - selectPaymentDB(00100)\n[09-17 10:00:00.001] DEBUG oracle - InsertPayment() SQL=INSERT INTO SAMPLE VALUES (1)\n[09-17 10:00:00.002] INFO mysql - PAYMENT: finish\n')
        self.assertTrue(result['success'])
        self.assertEqual((1, 0), (result['successCount'], result['errorCount']))
        self.assertEqual('SUCCESS', result['results'][0]['resultStatus'])

    def test_disabled_rules_do_not_create_results(self):
        result = self.run_text('1 00100 PS CSTA=GG TOYG01=1,100,상품 2026-09-17 오전 10:00:00 OK\n2 00100 PS CSTA=GG TOYG01=1,200,상품 2026-09-17 오전 10:01:00 OK\n', '')
        self.assertTrue(result['success'])
        self.assertEqual([], result['results'])
        self.assertEqual(0, result['errorCount'])

    def test_empty_file_remains_an_error(self):
        result = self.run_text('')
        self.assertFalse(result['success'])
        self.assertEqual('빈 로그 파일입니다.', result['message'])

    @unittest.skipUnless(os.environ.get('LOGAZAC_PRIVATE_SAMPLES') and os.environ.get('LOGAZAC_BASELINE_ANALYZER'), 'Private corpus and original analyzer are optional local inputs')
    def test_private_corpus_matches_original_complete_json(self):
        rules = ','.join(['MISSING_PRODUCT_NAME', 'CORRUPTED_DATA', 'MISSING_SLOT', 'PRICE_CHANGED', 'PRODUCT_NAME_CHANGED', 'RETRANSMISSION_SUCCESS', 'DUPLICATE_RESPONSE', 'RETRANSMISSION_FAILED', 'DB_TRANSFER_SUCCESS', 'CONSTRAINT_ERROR', 'BUSINESS_PROCESS_ERROR', 'DB_TRANSFER_FAILED'])
        samples = [p for p in Path(os.environ['LOGAZAC_PRIVATE_SAMPLES']).iterdir() if p.suffix in {'.txt', '.log'}]
        self.assertTrue(samples)
        for index, path in enumerate(sorted(samples), 1):
            with self.subTest(sample=index):
                self.assertEqual(self.run_file(path, rules, os.environ['LOGAZAC_BASELINE_ANALYZER']), self.run_file(path, rules))

if __name__ == '__main__':
    unittest.main()
