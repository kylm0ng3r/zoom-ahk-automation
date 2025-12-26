#NoEnv
#SingleInstance Force
SetTitleMatchMode, 2
SendMode Input
SetWorkingDir %A_ScriptDir%

; --- DPI FIX (CRITICAL) ---
DllCall("SetProcessDPIAware")

; --- COORD MODE ---
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

imgDir := "C:\zoom-images"

; --- WAIT FOR ZOOM TO FULLY INITIALIZE ---
Sleep, 120000   ; 2 minutes (do NOT reduce)

; --- BRING ZOOM TO FRONT ---
WinActivate, Zoom Workplace
WinWaitActive, Zoom Workplace, , 20

; ---------- CLICK DONE ----------
ClickImage(imgDir "\zoom_done_button.png")

; ---------- JOIN MEETING ----------
ClickImage(imgDir "\zoom_join_meeting.png")

ClickImage(imgDir "\zoom_meeting_id_box.png")
SendInput, 7582551033

ClickImage(imgDir "\zoom_join_button.png")

ClickImage(imgDir "\zoom_passcode_box.png")
SendInput, Us8ESG

ClickImage(imgDir "\zoom_join_meeting_button.png")

ClickImage(imgDir "\zoom_final_join_button.png")

ExitApp


; =========================
; IMAGE CLICK FUNCTION
; =========================
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
    ; Fail hard if image not found
    MsgBox, 16, ERROR, Failed to find image:`n%imagePath%
    ExitApp
}
