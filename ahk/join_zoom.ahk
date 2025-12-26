#NoEnv
#SingleInstance Force
SetTitleMatchMode, 2
SendMode Input
SetWorkingDir %A_ScriptDir%

; ===============================
; DPI AWARENESS
; ===============================
DllCall("SetProcessDPIAware")

; ===============================
; COORD MODES
; ===============================
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; ===============================
; CONFIG
; ===============================
imgDir    := "C:\zoom-images"
statusDir := "C:\zoom-status"

meetingId := "7582551033"
passcode  := "Us8ESG"

MAX_RUNTIME_MS := 600000   ; 10 minutes hard limit
startTime := A_TickCount

; ===============================
; STATUS INIT
; ===============================
FileCreateDir, %statusDir%
FileAppend, started, %statusDir%\started.txt

; ===============================
; HARD TIME GUARD
; ===============================
CheckTimeout() {
    global startTime, MAX_RUNTIME_MS, statusDir
    if (A_TickCount - startTime > MAX_RUNTIME_MS) {
        FileAppend, timeout, %statusDir%\timeout.txt
        TakeScreenshot()
        ExitApp
    }
}

; ===============================
; WAIT FOR ZOOM INIT
; ===============================
Sleep, 120000   ; 2 minutes
CheckTimeout()

; ===============================
; ACTIVATE ZOOM
; ===============================
WinActivate, Zoom Workplace
WinWaitActive, Zoom Workplace, , 30
Sleep, 2000
CheckTimeout()

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
; SUCCESS
; ===============================
FileAppend, joined, %statusDir%\joined.txt
ExitApp


; =====================================================
; IMAGE CLICK WITH TIME GUARD
; =====================================================
ClickImage(imagePath) {
    Loop, 30 {
        CheckTimeout()

        ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 %imagePath%
        if (ErrorLevel = 0) {
            MouseMove, x + 10, y + 10
            Click
            Sleep, 1500
            return
        }
        Sleep, 1000
    }

    ; ---------- IMAGE FAILURE ----------
    FileAppend, failed, %statusDir%\failed.txt
    TakeScreenshot()
    ExitApp
}

; =====================================================
; SCREENSHOT FUNCTION
; =====================================================
TakeScreenshot() {
    global statusDir
    FormatTime, ts,, yyyyMMdd-HHmmss
    Run, powershell -command "Add-Type -AssemblyName System.Windows.Forms;Add-Type -AssemblyName System.Drawing;$bmp=New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width,[System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height);$g=[System.Drawing.Graphics]::FromImage($bmp);$g.CopyFromScreen(0,0,0,0,$bmp.Size);$bmp.Save('%statusDir%\fail-%ts%.png')"
}
