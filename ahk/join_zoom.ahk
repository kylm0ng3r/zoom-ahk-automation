; ================================
; join_zoom.ahk
; AutoHotkey v1 ONLY
; Visual automation to join Zoom
; ================================

#NoEnv
#SingleInstance Force
SendMode Input
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%

; ---------- CONFIG ----------
zoomExe := "C:\Zoom64.exe"
imgDir  := "C:\zoom-images\"

meetingId := "7582551033"
passcode  := "Us8ESG"

zoomInitWaitMs := 120000      ; 2 minutes
defaultTimeout := 30000       ; 30 seconds per step
imageVariation := "*25"       ; ImageSearch tolerance

; ---------- UTILS ----------
ClickImage(image, timeoutMs := 30000) {
    global imageVariation, imgDir
    start := A_TickCount

    Loop {
        ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, % imageVariation " " imgDir image
        if (ErrorLevel = 0) {
            MouseMove, x + 5, y + 5, 10
            Sleep, 300
            Click
            Sleep, 800
            return true
        }

        if (A_TickCount - start > timeoutMs) {
            return false
        }

        Sleep, 500
    }
}

TypeText(text) {
    Sleep, 300
    SendInput, %text%
    Sleep, 500
}

; ---------- START ----------
Run, %zoomExe%

; Give Zoom enough time to fully initialize
Sleep, %zoomInitWaitMs%

; ---------- FLOW ----------

; 1. Click "Done" if install-success popup appears
ClickImage("zoom_done_button.png", 20000)

; 2. Click "Join a Meeting"
if (!ClickImage("zoom_join_meeting.png", defaultTimeout)) {
    MsgBox, Failed to find "Join a Meeting"
    ExitApp
}

; 3. Click Meeting ID input box
if (!ClickImage("zoom_meeting_id_box.png", defaultTimeout)) {
    MsgBox, Failed to find Meeting ID box
    ExitApp
}

; 4. Enter Meeting ID
TypeText(meetingId)

; 5. Click Join
if (!ClickImage("zoom_join_button.png", defaultTimeout)) {
    MsgBox, Failed to find Join button
    ExitApp
}

; 6. Click Passcode input box
if (!ClickImage("zoom_passcode_box.png", defaultTimeout)) {
    MsgBox, Failed to find Passcode box
    ExitApp
}

; 7. Enter Passcode
TypeText(passcode)

; 8. Click Join Meeting
ClickImage("zoom_join_meeting_button.png", defaultTimeout)

; 9. Final Join (waiting room / confirmation)
ClickImage("zoom_final_join_button.png", defaultTimeout)

ExitApp
