#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Function to check if active window is Fusion 360 ---
isFusionActive() {
    winTitle := WinGetTitle("A")
    return InStr(winTitle, "Autodesk Fusion")
}

; --- Alt alone → acts as MMB ---
*Alt::
{
    if isFusionActive() {
        SendEvent("{MButton down}")
        ; Wait until Alt is released
        KeyWait("Alt")
        SendEvent("{MButton up}")
        return
    }
    ; If not in Fusion, pass Alt through normally
    SendEvent("{Alt down}")
    KeyWait("Alt")
    SendEvent("{Alt up}")
}

; --- Shift + Alt → acts as Shift + MMB ---
*Shift & Alt::
{
    if isFusionActive() {
        SendEvent("{Shift down}")
        SendEvent("{MButton down}")
        KeyWait("Alt")
        SendEvent("{MButton up}")
        SendEvent("{Shift up}")
        return
    }
    ; If not in Fusion, just hold Shift+Alt normally
    SendEvent("{Shift down}")
    SendEvent("{Alt down}")
    KeyWait("Alt")
    SendEvent("{Alt up}")
    SendEvent("{Shift up}")
}
