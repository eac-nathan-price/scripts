#SingleInstance Force
#UseHook On
SetBatchLines, -1
SetKeyDelay, -1, 0

; Toggle debug messages (0 = off, 1 = on)
debug := 0

; --- Helpers ---
IsFusionActive() {
    WinGetTitle, winTitle, A
    return InStr(winTitle, "Autodesk Fusion")
}

; Send mouse button using SendInput (reliable low-level)
; flag: MIDDLEDOWN = 0x0020, MIDDLEUP = 0x0040
SendMouseInput(flag) {
    ; INPUT struct (type = 0 for mouse)
    local INPUT_SIZE := 28  ; 32-bit/64-bit safe size used here
    VarSetCapacity(inpt, INPUT_SIZE, 0)

    ; type (DWORD) = 0 -> mouse
    NumPut(0, inpt, 0, "UInt")

    ; MOUSEINPUT fields start at offset 4:
    ; dx (LONG) = 0
    ; dy (LONG) = 0
    ; mouseData (DWORD) = 0
    ; dwFlags (DWORD) = flag
    ; time (DWORD) = 0
    ; dwExtraInfo (ULONG_PTR) = 0
    NumPut(0, inpt, 4, "Int")      ; dx
    NumPut(0, inpt, 8, "Int")      ; dy
    NumPut(0, inpt, 12, "UInt")    ; mouseData
    NumPut(flag, inpt, 16, "UInt") ; dwFlags
    NumPut(0, inpt, 20, "UInt")    ; time
    ; dwExtraInfo stays 0

    ; Call SendInput(1, &inpt, sizeof(INPUT))
    DllCall("SendInput", "UInt", 1, "UInt", &inpt, "Int", INPUT_SIZE)
}

MiddleDown() { SendMouseInput(0x0020) }  ; MIDDLEDOWN
MiddleUp()   { SendMouseInput(0x0040) }  ; MIDDLEUP

; --- Ctrl + M: hold MMB while M held ---
^m::
    if (IsFusionActive()) {
        if (debug)
            TrayTip, AHK, "Fusion active: Ctrl+M -> MMB down", 1
        MiddleDown()
        KeyWait, m   ; wait until M released
        MiddleUp()
        if (debug)
            TrayTip, AHK, "MMB released", 1
    } else {
        ; Pass through in other apps
        Hotkey, ^m, Off
        Send, ^m
        Hotkey, ^m, On
    }
return

; --- Ctrl + Shift + M: hold Shift + MMB while M held ---
^+m::
    if (IsFusionActive()) {
        if (debug)
            TrayTip, AHK, "Fusion active: Ctrl+Shift+M -> Shift+MMB down", 1
        ; Send a low-level Shift down so the target app reliably sees it
        SendInput, {Shift down}
        MiddleDown()
        KeyWait, m
        MiddleUp()
        SendInput, {Shift up}
        if (debug)
            TrayTip, AHK, "Shift+MMB released", 1
    } else {
        Hotkey, ^+m, Off
        Send, ^+m
        Hotkey, ^+m, On
    }
return
