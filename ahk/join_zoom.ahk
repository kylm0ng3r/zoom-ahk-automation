#NoEnv
#SingleInstance Force
SetTitleMatchMode, 2
SendMode Input
SetWorkingDir %A_ScriptDir%

DllCall("SetProcessDPIAware")

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

imgDir    := "C:\zoom-images"
statusDir := "C:\zoom-status"

meetingId := "7582551033"
passcode  := "Us8ESG"

MAX_RUNTIME_MS := 600000
startTime := A_TickCount

FileCreateDir, %statusDir%
FileAppend, started, %statusDir%\started.txt

CheckTimeout() {
    global startTime, MAX_RUNTIME_MS, statusDir
    if (A_TickCount - startTime > MAX_RUNTIME_MS) {
        FileAppend, timeout, %statusDir%\timeout.txt
        TakeScreenshot()
        ExitApp
    }
}

; ===============================
; LAUNCH ZOOM (CORRECT PATH)
; ===============================
zoomExe := "C:\Users\azureuser\AppData\Roaming\Zoom\bin\Zoom.exe"
if FileExist(zoomExe) {
    Run, %zoomExe%
} else {
    FailAndExit("Zoom executable not found")
}

; ===============================
; WAIT + FORCE ZOOM FOREGROUND
; ===============================
Loop, 120 {
    CheckTimeout()
    if WinExist("ahk_exe Zoom.exe") {
        WinActivate
        WinWaitActive, ahk_exe Zoom.exe, , 5
        WinMaximize, ahk_exe Zoom.exe
        break
    }
    Sleep, 1000
}

Sleep, 3000
CheckTimeout()

; ===============================
; JOIN-FIRST STRATEGY
; ===============================
if (!TryClick(imgDir "\zoom_join_meeting.png")) {

    TryClick(imgDir "\zoom_done_button.png")
    Sleep, 2000
    CheckTimeout()

    if (!TryClick(imgDir "\zoom_join_meeting.png")) {
        FailAndExit("Could not access Join Meeting screen")
    }
}

ClickImage(imgDir "\zoom_meeting_id_box.png")
SendInput, %meetingId%

ClickImage(imgDir "\zoom_join_button.png")

ClickImage(imgDir "\zoom_passcode_box.png")
SendInput, %passcode%

ClickImage(imgDir "\zoom_join_meeting_button.png")
Sleep, 2000
TryClick(imgDir "\zoom_final_join_button.png")

FileAppend, joined, %statusDir%\joined.txt
ExitApp

; ===============================
; HELPERS
; ===============================
TryClick(imagePath) {
    Loop, 8 {
        CheckTimeout()
        ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *100 %imagePath%
        if (ErrorLevel = 0) {
            MouseMove, x+10, y+10
            Click
            Sleep, 1500
            return true
        }
        Sleep, 1000
    }
    return false
}

ClickImage(imagePath) {
    Loop, 40 {
        CheckTimeout()
        ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *100 %imagePath%
        if (ErrorLevel = 0) {
            MouseMove, x+10, y+10
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

TakeScreenshot() {
    global statusDir
    FormatTime, ts,, yyyyMMdd-HHmmss
    RunWait, powershell -NoProfile -Command ^
    "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; `
    $b=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds; `
    $bmp=New-Object Drawing.Bitmap $b.Width,$b.Height; `
    $g=[Drawing.Graphics]::FromImage($bmp); `
    $g.CopyFromScreen($b.Location,[Drawing.Point]::Empty,$b.Size); `
    $bmp.Save('C:\zoom-status\fail-%ts%.png')"
}
