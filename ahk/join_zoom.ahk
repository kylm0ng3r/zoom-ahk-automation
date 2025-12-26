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

MAX_RUNTIME_MS := 600000   ; 10 minutes
startTime := A_TickCount

; ===============================
; STATUS INIT
; ===============================
FileCreateDir, %statusDir%
FileAppend, started, %statusDir%\started.txt

; ===============================
; TIME GUARD
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
; LAUNCH ZOOM EXPLICITLY
; ===============================
if FileExist("C:\Zoom\bin\Zoom.exe") {
    Run, C:\Zoom\bin\Zoom.exe
} else if FileExist("C:\Zoom64.exe") {
    Run, C:\Zoom64.exe
}

; ===============================
; WAIT FOR ZOOM WINDOW (NON-BLOCKING)
; ===============================
Loop, 120 {   ; wait up to 2 minutes
    CheckTimeout()
    if WinExist("Zoom") {
        WinActivate
        break
    }
    Sleep, 1000
}

Sleep, 2000
CheckTimeout()

; =====================================================
; JOIN-FIRST STRATEGY
; =====================================================

; --- Attempt Join directly ---
if (!TryClick(imgDir "\zoom_join_meeting.png")) {

    ; --- If Join not clickable, clear Done ---
    TryClick(imgDir "\zoom_done_button.png")
    Sleep, 2000
    CheckTimeout()

    ; --- Retry Join ---
    if (!TryClick(imgDir "\zoom_join_meeting.png")) {
        FailAndExit("Could not access Join Meeting screen")
    }
}

; ===============================
; MEETING DETAILS
; ===============================
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
; CLICK HELPERS
; =====================================================

TryClick(imagePath) {
    Loop, 5 {
        CheckTimeout()
        ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 %imagePath%
        if (ErrorLevel = 0) {
            MouseMove, x + 10, y + 10
            Click
            Sleep, 1500
            return true
        }
        Sleep, 1000
    }
    return false
}

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
    FailAndExit("Image not found: " imagePath)
}

FailAndExit(reason) {
    global statusDir
    FileAppend, failed`n%reason%, %statusDir%\failed.txt
    TakeScreenshot()
    ExitApp
}

; =====================================================
; SCREENSHOT
; =====================================================
TakeScreenshot() {
    global statusDir
    FormatTime, ts,, yyyyMMdd-HHmmss
    Run, powershell -command "Add-Type -AssemblyName System.Windows.Forms;Add-Type -AssemblyName System.Drawing;$bmp=New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width,[System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height);$g=[System.Drawing.Graphics]::FromImage($bmp);$g.CopyFromScreen(0,0,0,0,$bmp.Size);$bmp.Save('%statusDir%\fail-%ts%.png')"
}
