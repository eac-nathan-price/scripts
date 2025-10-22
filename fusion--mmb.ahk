#SingleInstance Force
#UseHook On
SetBatchLines, -1
SetKeyDelay, -1, 0

debug := 0   ; set to 1 to get tray tips for debugging

; --- helper: is Autodesk Fusion active? ---
IsFusionActive() {
    WinGetTitle, winTitle, A
    return InStr(winTitle, "Autodesk Fusion")
}

; --- low-level SendInput wrapper for mouse ---
; flag: MIDDLEDOWN = 0x0020, MIDDLEUP = 0x0040
SendMouseInput(flag) {
    ; Create an INPUT (MOUSEINPUT) structure
    VarSetCapacity(inpt, 28, 0)            ; 28 bytes works for both x86 and x64 here
    NumPut(0, inpt, 0, "UInt")             ; type = 0 (INPUT_MOUSE)
    NumPut(0, inpt, 4, "Int")              ; dx
    NumPut(0, inpt, 8, "Int")              ; dy
    NumPut(0, inpt, 12, "UInt")            ; mouseData
    NumPut(flag, inpt, 16, "UInt")         ; dwFlags
    NumPut(0, inpt, 20, "UInt")            ; time
    ; dwExtraInfo left 0
    DllCall("SendInput", "UInt", 1, "Ptr", &inpt, "Int", 28)
}

MiddleDown() { SendMouseInput(0x0020) }  ; MIDDLEDOWN
MiddleUp()   { SendMouseInput(0x0040) }  ; MIDDLEUP

; Use SC029 which is the typical scan code for the grave/backtick key (` / ~)
; Ctrl + `  (pressing the key while held will trigger)
^SC029::
    if (IsFusionActive()) {
        if (debug)
            TrayTip, AHK, "Fusion active: Ctrl+` -> MMB down", 1
        MiddleDown()
        KeyWait, SC029                   ; wait until the physical key is released
        MiddleUp()
        if (debug)
            TrayTip, AHK, "MMB released", 1
    } else {
        ; Pass through the original keypress to the target app
        Hotkey, ^SC029, Off
        ; Use {Blind}{SC029} so the currently-held modifiers (Ctrl/Shift) are preserved
        SendInput, {Blind}{SC029}
        Hotkey, ^SC029, On
    }
return

; Ctrl + Shift + `  -> hold Shift + MMB
^+SC029::
    if (IsFusionActive()) {
        if (debug)
            TrayTip, AHK, "Fusion active: Ctrl+Shift+` -> Shift+MMB down", 1
        ; Make sure Shift is down so the app sees Shift+MMB
        SendInput, {Shift down}
        MiddleDown()
        KeyWait, SC029
        MiddleUp()
        SendInput, {Shift up}
        if (debug)
            TrayTip, AHK, "Shift+MMB released", 1
    } else {
        Hotkey, ^+SC029, Off
        SendInput, {Blind}{SC029}
        Hotkey, ^+SC029, On
    }
return
