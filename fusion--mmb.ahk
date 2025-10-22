#SingleInstance Force
#UseHook On
SetBatchLines, -1
SetKeyDelay, -1, 0

; --- helper: is Autodesk Fusion active? ---
IsFusionActive() {
    WinGetTitle, winTitle, A
    return InStr(winTitle, "Autodesk Fusion")
}

; --- helper: send low-level middle button down/up via mouse_event ---
MiddleDown() {
    ; MOUSEEVENTF_MIDDLEDOWN = 0x0020
    DllCall("mouse_event", "UInt", 0x0020, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
}
MiddleUp() {
    ; MOUSEEVENTF_MIDDLEUP = 0x0040
    DllCall("mouse_event", "UInt", 0x0040, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
}

; --- Ctrl + M (hold behavior) ---
^m::
    if (IsFusionActive()) {
        ; hold MMB while M is held
        MiddleDown()
        KeyWait, m          ; wait until key released
        MiddleUp()
    } else {
        ; pass-through: temporarily disable hotkey to avoid recursion
        Hotkey, ^m, Off
        Send, ^m
        Hotkey, ^m, On
    }
return

; --- Ctrl + Shift + M (hold behavior with Shift) ---
^+m::
    if (IsFusionActive()) {
        ; hold Shift + MMB while M is held
        Send, {Shift down}
        MiddleDown()
        KeyWait, m
        MiddleUp()
        Send, {Shift up}
    } else {
        Hotkey, ^+m, Off
        Send, ^+m
        Hotkey, ^+m, On
    }
return
