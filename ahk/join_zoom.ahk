#NoEnv
#SingleInstance Force
SetTitleMatchMode, 2
SendMode Input
SetWorkingDir %A_ScriptDir%

; ===============================
; DPI AWARENESS (CRITICAL)
; ===============================
DllCall("SetProcessDPIAware")

; ===============================
; COORDINATE MODE
; ===============================
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; ===============================
; CONFIG
; ===============================
imgDir := "C:\zoom-images"

meetingId := "7582551033"
passcode  := "Us8ESG"

; ===============================
; WAIT FOR ZOOM TO INITIALIZE
; ===============================
Sleep, 120000   ; 2 minutes (do not reduce)

; ===============================
; BRING ZOOM TO FOREGROUND
; ===============================
WinActivate, Zoom Workplace
WinWaitActive, Zoom Workplace, , 30
Sleep, 2000

; ===============================
; JOIN FLOW
; ===============================
ClickImage(imgDir "\zoom_done_button.png")

ClickImage(imgDir "\zoom_join_meeting.png")

ClickImage(imgDir "\zoom_meeting_id_box.png")
SendInput, %meetingId%

ClickImage(imgDir "\zoom_join_button.png")

ClickImage(imgDir "\zoom_passcode_box.png")
SendInput, %passcode%

ClickImage(imgDir "\zoom_join_meeting_button.png")

ClickImage(imgDir "\zoom_final_join_button.png")

; ===============================
; DONE — EXIT AHK ONLY
; ===============================
ExitApp


; =========================================================
; FUNCTION: Image-based click with retries + tolerance
; =========================================================
ClickImage(imagePath) {
    Loop, 30 {
        ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 %imagePath%
        if (ErrorLevel = 0) {
            MouseMove, x + 10, y + 10
            Click
            Sleep, 1500
            return
        }
        Sleep, 1000
    }

    MsgBox, 16, ZOOM AUTOMATION ERROR, Failed to find image:`n%imagePath%
    ExitApp
}
