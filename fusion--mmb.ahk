#Requires AutoHotkey v2.0

; --- Only activate these hotkeys when Fusion is active ---
#HotIf WinActive("ahk_exe Fusion360.exe") || InStr(WinGetTitle("A"), "Autodesk Fusion")

; Ctrl + ` → Hold MMB
^`:: {
    Send("{MButton down}")
    KeyWait("Ctrl")
    KeyWait("``")
    Send("{MButton up}")
}

; Ctrl + Shift + ` (aka ~) → Hold Shift + MMB
^+`:: {
    Send("{Shift down}{MButton down}")
    KeyWait("Ctrl")
    KeyWait("Shift")
    KeyWait("``")
    Send("{MButton up}{Shift up}")
}

#HotIf  ; Disable the hotkeys elsewhere — VS Code gets its Ctrl+` back
