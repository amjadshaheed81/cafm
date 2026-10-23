# CAFM iPhone — Paul's Monthly Audit V2 patch (22 October 2026)

**Status:** source-reviewed integration candidate; NOT Xcode-built, iPhone-tested, Apple-signed or deployed.

## Authoritative source used
- Backend: `site-service(20261021-161800).zip` (MonthlyAuditController and related DTOs/services).
- iOS reference: original `cafm.zip` + supplied Phase 1 source overlay, latest asset-category fix, optional-question correction, and Test Fill patch.
- **Important:** The exact source currently on Amjad's Mac was not uploaded. The installer uses a three-way merge and refuses conflicts; it does NOT replace the whole iOS app or the working iOS 17.6 settings.

## Changed application files (3 only)
- `cafm/Controller/SiteCheck/AddSiteCheckVC.swift`
- `cafm/Controller/SiteCheck/MonthlyAudit/MonthlyAuditQuestionsVC.swift`
- `cafm/Controller/SiteCheck/MonthlyAudit/MonthlyAuditQuestionResponseVC.swift`

## V2 behaviour
- Monthly Audit ONLY: GET V2 `/context`, `/responses`, `/actions`; current audit period is server-owned.
- Save/edit: POST V2 `/responses`, with period token, inspection date, UUID request ID, response revision and explicit action choices for failed assets. Observation is sent in `position` (backend field), not the legacy `observation` key.
- An incomplete question can be saved. Inspection Date can be changed through Monthly Audit > Options.
- For each failed asset, explicitly choose a listed outstanding Action to reuse or create a NEW fault. Previously linked closed Actions can be retained when editing the same response.
- Refreshes Action candidates after each save so a newly created Action can be reused on another question.
- Photo upload uses the existing site-check attachment endpoint; no photo is required unless a user selects one. Saved photo URLs are viewable.
- Submit calls **POST `/submission/complete`**; server produces PDF + History atomically.
- Options include `Open Next Audit Early`, `Renew Overdue Audit` (only when enabled by server) and historical PDFs from GET `/api/site-check/{checkId}/history`.
- Other inspections, including Annual Winter Audit and Water Checks, do not switch to V2.
- TEST-only Test Fill for `amjad.shaheed81@gmail.com`, existing LIVE/TEST switch and iOS 17.6 build settings remain intact.

## Mac installation
1. Quit Xcode and make a separate copy/backup of your working CAFM folder.
2. Download this ZIP to Downloads.
3. Terminal:

```bash
cd "/Users/Amjad/Desktop/cafm/cafm"
unzip -o "$HOME/Downloads/CAFM_iOS_Paul_Monthly_Audit_V2_Safe_Merge_2026-10-22.zip" -d .
bash ./install_monthly_audit_v2.command --check
```

If and only if `--check` passes:

```bash
bash ./install_monthly_audit_v2.command --apply
open cafm.xcworkspace
```

In Xcode: Product > Clean Build Folder, then Command+B.

The installer backs up every replaced Swift file to `.cafm_monthly_v2_backup_YYYYMMDD-HHMMSS`. It will refuse conflicting local edits and will NOT change the Xcode project, Podfile, other inspection files or deployed API.

## Before Paul's real-device acceptance
- Check one valid TEST audit through opening, partial save/reopen, editing, risk changes, attachment view, existing Action reuse, new fault Action creation, submission, PDF and History.
- Check correct category selections at Middlesbrough and Leeds; Water Checks and Annual Winter Audit regression.
- Check 409 conflicts (another user changed question), 401 expired session, and TEST -> LIVE data isolation.
- Check no duplicate Action after a network-interrupted save and retry.
- Do **not** submit synthetic Test Fill data on LIVE.

## Limits
- Full Xcode build/type-check and runtime API tests have NOT run in this Linux environment.
- No code was edited in the user's Mac copy or deployed to Azure.
- Photo deletion was not exposed: the V2 backend removes the image association but retains the legacy `file` field, so deleting an image requires a separate data-consistency review.
- Real-file PDF access still depends on the stored `pdfUrl` and existing CAFM SAS token; if unavailable, the UI directs the user to Site Documents.
- Merge errors need the **current 3 Swift files from the Mac**. Do not bypass a conflict by forcing replacements.
