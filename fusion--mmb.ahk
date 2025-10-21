; --- Function to check if active window is Fusion 360 ---
isFusionActive() {
    winTitle := WinGetTitle("A")
    return InStr(winTitle, "Autodesk Fusion")
}

; --- Alt alone or Shift+Alt in Fusion ---
*Alt::
{
    if isFusionActive() {
        if GetKeyState("Shift", "P") {
            ; Shift + Alt → Shift + MMB
            SendEvent("{Shift down}")
            SendEvent("{MButton down}")
            KeyWait("Alt")
            SendEvent("{MButton up}")
            SendEvent("{Shift up}")
        } else {
            ; Alt alone → MMB
            SendEvent("{MButton down}")
            KeyWait("Alt")
            SendEvent("{MButton up}")
        }
        return
    }

    ; Not in Fusion → behave normally
    SendEvent("{Alt down}")
    KeyWait("Alt")
    SendEvent("{Alt up}")
}
