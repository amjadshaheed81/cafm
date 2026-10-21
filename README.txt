CAFM iOS — Monthly Audit optional question compile correction
21 October 2026

Fixes Xcode errors at line ~478 in:
  cafm/Controller/SiteCheck/MonthlyAudit/MonthlyAuditQuestionResponseVC.swift

Cause:
  question is declared SiteCheckAssessmentQuestions?, but the Paul asset
  matching patch accesses question.order and question.assetCategory.

Fix (ONE line within reloadViews(), not the other guard in the file):
  before: guard let response else { return }
  after:  guard let response, let question else { return }

Works on top of Paul's category-filtering patch, preserving other changes.
It does not modify other Swift files, the API, deployment target, or the login/server switch.

INSTALL ON YOUR MAC:
  1. Quit Xcode. Download/extract this ZIP into /Users/Amjad/Desktop/cafm/cafm/
  2. cd "/Users/Amjad/Desktop/cafm/cafm"
  3. bash ./fix_monthly_audit_question_optional.command --check
  4. If PASS, run: bash ./fix_monthly_audit_question_optional.command --apply
  5. Open cafm.xcworkspace, Clean Build Folder, then Command-B.

The script backs up the original Swift file in _CAFM_PATCH_BACKUPS.
It refuses to apply if the expected source differs, and is safe to run twice.

Alternatively, edit just the one line in reloadViews() manually; do not
change the separate guard in saveContinueBtnClicked().

Validation: 1-line patch tested on previous ZIP's Swift source; full
Xcode compilation must still be confirmed on your Mac.
