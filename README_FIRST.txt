CAFM iOS — LIVE / TEST environment switch correction (21 Oct 2026)

USE WITH THE EXISTING WORKING PHASE 1 INSTALLATION / iOS 17.6 PROJECT.
This is NOT a complete app source archive. It changes only these 3 source files:
  cafm/Helper/Settings/ServerConfiguration.swift
  cafm/Helper/Settings/ServerSettingsVC.swift
  cafm/Controller/SignUpFlow/LoginVC.swift

FIXES:
  * Admin Save and Switch no longer silently stops when the optional health endpoint fails.
  * Admin confirmation signs out, clears tokens & caches, saves chosen server and returns to login.
  * Login screen has LIVE / TEST buttons and shows active hostname near the bottom.
  * TEST is visually identified. Anyone may select LIVE/TEST BEFORE logging in;
    Custom address remains Admin-only under Settings.
  * A previous Unite customer switching TEST -> LIVE returns to the Unite production alias;
    a new CAFM customer returns to app.corecafm.com.
  * Original login form scrolls so server controls do not cover the form on small phones.
  * Late login results from an environment switched away from are ignored.

MAC STEPS:
  1) Quit Xcode and make a copy/backup of your existing cafm project.
  2) Extract THIS ZIP into the folder containing cafm.xcworkspace:
     /Users/Amjad/Desktop/cafm/cafm/
  3) Terminal:
     cd "/Users/Amjad/Desktop/cafm/cafm"
     bash ./install_live_test_switch.command --check
  4) If the check passes:
     bash ./install_live_test_switch.command --apply
     open cafm.xcworkspace
  5) In Xcode choose Product > Clean Build Folder, then Build and Run.

TEST:
  a) In Settings > Admin > Server Configuration choose TEST and Save and switch.
     The app must confirm, sign out and show TEST MODE on login.
  b) At bottom of Login press LIVE. Confirm, verify correct production address.
  c) At bottom of Login press TEST. Confirm and enter test-system credentials.
  d) Restart app and verify selected server persists.
  e) Verify Site Checks, Monthly Audit, Water Checks, site list and file access
     against the correct environment, with different accounts if available.

WARNING: This change is only locally syntax-checked, not compiled with Xcode here.
No changes to backend, Site Service, deployment target, CocoaPods, signed IPA or Apple release.
If preflight reports local merge conflict, STOP and share the named Mac Swift file.
