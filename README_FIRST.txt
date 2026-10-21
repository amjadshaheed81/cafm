CAFM iOS — Monthly Audit TEST Fill — 21 October 2026
==========================================================

Purpose
- Adds a "Test Fill" button to the navigation bar of an editable Monthly Audit question.
- ONLY when the authenticated user profile email is Amjad.shaheed81@gmail.com (case-insensitive).
- ONLY when the selected API environment is TEST (testcp.corecafm.com).
- Does not appear on LIVE, on custom servers, for another account, or for saved/read-only answers.
- Does not save, upload or submit automatically. Use existing Save & Continue.

What Test Fill enters for the CURRENT question
- Observation and Suggested Action: explicitly labelled TEST ONLY.
- Consequence = 1; Likelihood = 1 (sample data, not real safety scores).
- Eligible assets only: adds all as Asset OK; leaves defective assets blank.
- Adds a generated JPG with large "TEST DATA ONLY / NOT INSPECTION EVIDENCE" text.
- Uses a confirmation dialog before replacing unsaved entries.

Important
- Button appears on each Monthly Audit QUESTION detail, not on the audit question list.
- Does NOT fill an entire audit in one tap. Each question remains a manual Save & Continue.
- Depends on backend-provided userDetail.email being loaded; without it the button is hidden.
- Previously saved questions are read-only in the current iOS app; the button is hidden on them.
- No Android, Java, database, storyboard, Podfile or iOS deployment-target change.
- The existing mobile save still uses legacy API; V2 migration remains a separate future task.
- Never use the generated answers as genuine inspection evidence or on LIVE.

On your Mac: BACK UP and QUIT Xcode first.

  cd "/Users/Amjad/Desktop/cafm/cafm"
  unzip -o "$HOME/Downloads/CAFM_iOS_Monthly_Audit_Test_Fill_2026-10-21.zip" -d .
  bash ./install_monthly_audit_test_fill.command --check
  # Only if preflight says PASS:
  bash ./install_monthly_audit_test_fill.command --apply
  open cafm.xcworkspace

Xcode > Product > Clean Build Folder > Command-B; then run on TEST.

The script patches one Swift file in place, checks syntax when swiftc exists,
creates a timestamped backup and refuses conflicts without writing files.
If it reports a CONFLICT, send the current MonthlyAuditQuestionResponseVC.swift.

Testing:
1. Log into TEST using the specified account; open an unsaved Monthly Audit question.
2. "Test Fill" should be visible at the top right.
3. Tap, confirm, and check sample notes, scores, eligible asset tags and TEST jpg.
4. Press Save & Continue; check the actual server response.
5. Repeat for another question. Reopen saved question: button hidden.
6. Switch to LIVE or log in as a different user: button hidden.
7. Check that only TEST environment data was written.

Validation: parse, pure Swift gating checks and installer simulations only.
Full iOS compilation and backend acceptance testing must run on your Mac.
