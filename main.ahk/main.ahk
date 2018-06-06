#NoEnv  ;Recommended for performance and compatibility with future AutoHotkey releases.
#InstallMouseHook
Menu, Tray, Icon

;------------------------------------------------------------
;Change the tray icon.
;------------------------------------------------------------
If(!A_IsCompiled && FileExist(A_ScriptDir . "\main.ico")) {
	Menu, Tray, Icon, %A_ScriptDir%\main.ico
}

;------------------------------------------------------------
;Tray Settings
;------------------------------------------------------------
Menu, Tray, NoStandard
Menu, Tray, Add, &Raw Paste [CTRL+B], ClipboardDisable
Menu, Tray, Add, &Center Window [ALT+Accent], CenterDisable
Menu, Tray, Add, &Change Desktop [Button 3/4], DesktopSwapDisable
Menu, Tray, Add, &Snipping Tool [PrtScrn], SnippingDisable
Menu, Tray, Add  ;separator
Menu, Tray, Add, &Caffeine (Prevent Screen Off), CaffeineToggle
Menu, Tray, Add  ;separator
Menu, Tray, Add, &Disable All Hotkeys, DisableAll
Menu, Tray, Add, &Reload This Script, MyReload
Menu, Tray, Add, &ListHotkeys Debug, MyListHotkeys
Menu, Tray, Add, &Edit This Script, MyEdit
Menu, Tray, Add  ;separator
Menu, Tray, Add, &Exit, QuitScript

;Startup Code
Menu, Tray, Check, &Raw Paste [CTRL+B]
ClipboardStatus := true
Menu, Tray, Check, &Center Window [ALT+Accent]
CenterStatus := true
Menu, Tray, Check, &Change Desktop [Button 3/4]
DesktopSwapStatus := true
Menu, Tray, Check, &Snipping Tool [PrtScrn]
SnippingStatus := true
Menu, Tray, Uncheck, &Caffeine (Prevent Screen Off)
CaffeineStatus := false
;End of Startup Code!
return

ClipboardDisable:
	ClipboardStatus := !ClipboardStatus
	Menu, Tray, ToggleCheck, &Raw Paste [CTRL+B]
Return

CenterDisable:
	CenterStatus := !CenterStatus 
	Menu, Tray, ToggleCheck, &Center Window [ALT+Accent]
Return

DesktopSwapDisable:
	DesktopSwapStatus := !DesktopSwapStatus 
	Menu, Tray, ToggleCheck, &Change Desktop [Button 3/4]
Return

SnippingDisable:
	SnippingStatus := !SnippingStatus 
	Menu, Tray, ToggleCheck, &Snipping Tool [PrtScrn]
Return

CaffeineToggle:
	If(CaffeineStatus) {
		;Suspend
		SetTimer, Caffeine, Off
		CaffeineStatus := false
		Menu, Tray, Uncheck, &Caffeine (Prevent Screen Off)
	} Else {
		;Resume
		SetTimer, Caffeine, 10000
		CaffeineStatus := true
		Menu, Tray, Check, &Caffeine (Prevent Screen Off)
	}
Return

DisableAll:
	Menu, Tray, Uncheck, &Raw Paste [CTRL+B]
	Menu, Tray, Uncheck, &Center Window [ALT+Accent]
	Menu, Tray, Uncheck, &Change Desktop [Button 3/4]
	Menu, Tray, Uncheck, &Snipping Tool [PrtScrn]
	ClipboardStatus := false
	CenterStatus := false
	DesktopSwapStatus := false
	SnippingStatus := false
Return

QuitScript: 
	ExitApp
Return

MyReload:
	Reload
Return

MyListHotkeys:
	ListHotkeys
Return

MyEdit:
    Edit
Return

;------------------------------------------------------------
;Program Code
;------------------------------------------------------------
;Show AHK Version
^!a::
	CoordMode, Mouse, Screen
	mouseGetPos,xx,yy
	msgbox % "my ahk version: " A_AhkVersion "  (" xx ", " yy ")"
Return

;General Hotkeys
^+NumLock::ScrollLock

;Media Controls (Right Control and Arrows or Right Shift)
RCtrl & RShift::
	Send {Media_Play_Pause}
return
RCtrl & Left::
	Send {Media_Prev}
return
RCtrl & Right::
	Send {Media_Next}
return
RCtrl & Up::
	Send {Volume_Up}
return
RCtrl & Down::
	Send {Volume_Down}
return
RCtrl & RWin::
	Send {Volume_Mute}
return

;Pause Key locks desktop.
Pause::DllCall("LockWorkStation")

;Text–only paste from ClipBoard OR
;Convert Sharepoint URL to Explorer Path.
;-------------------------------------------------
$^b::
	If(ClipboardStatus){
		Clip0 = %ClipBoardAll%				;Backup Clipboard
		ClipBoard = %ClipBoard%				;Convert to text
		Send ^v								;For best compatibility: SendPlay
		Sleep 50							;Don't change clipboard while it is pasted! (Sleep > 0)
		ClipBoard = %Clip0%					;Restore original ClipBoard
		;Free memory
		VarSetCapacity(Clip0, 0)
		VarSetCapacity(url, 0)
	}Else{
		Send ^b
	}
Return

;Center current window on screen (Single monitor configured)
;-------------------------------------------------
$!`::
	If(CenterStatus){
		WinGetTitle, Window, A
		WinGetPos,windowX,WindowY,WindowW,WindowH,%Window%
		OutputX:=(A_ScreenWidth-WindowW)/2
		OutputY:=(A_ScreenHeight-WindowH-40)/2
		WinMove, %Window%,,%OutputX%,%OutputY%,%WindowW%,%WindowH%
	}Else{
		Send !`
	}
Return

;Change Monitor with mouse keys.
;-------------------------------------------------
$XButton1::
If(DesktopSwapStatus){
	Send #^{Right}
	sleep 10
}else{
	Send {XButton1}
}
return
$XButton2::
If(DesktopSwapStatus){
	Send #^{Left}
	sleep 10
}else{
	Send {XButton2}
}
return

;Keep computer from going to sleep by simulating invisible mouse movements.
Caffeine:
	;60 seconds since last REAL user action.
	If(A_TimeIdlePhysical>60000){
		;Mouse pointer stays in place but sends a mouse event.
		MouseMove,0,0,0,R
	}
Return

;Print Screen to launch Snipping Tool in window select tool.
;-------------------------------------------------
$PrintScreen::
If(SnippingStatus){
	If WinExist("Snipping Tool"){
		WinActivate, Snipping Tool,
		Send !m
		Sleep, 10
		Send r
		Sleep, 10
		Send !n
	}else{
		Run, C:\Windows\System32\SnippingTool.exe
		WinWait, Snipping Tool,
		WinActivate, Snipping Tool,
		Send !m
		Sleep, 10
		Send r
		Sleep, 10
		Send !n
	}
}else{
	Send {PrintScreen}
}
return

;Ctrl+Print Screen to launch Snipping Tool in region select tool.
;-------------------------------------------------
$^PrintScreen::
If(SnippingStatus){
	If WinExist("Snipping Tool")
	{
		WinActivate, Snipping Tool,
		Send !m
		Sleep, 5
		Send w
		Sleep, 10
		Send !n
	}
	else
	{
		Run, C:\Windows\System32\SnippingTool.exe
		WinWait, Snipping Tool,
		WinActivate, Snipping Tool,
		Send !m
		Sleep, 5
		Send w
		Sleep, 10
		Send !n
	}
}else{
	Send {^PrintScreen}
}
return

;Set transparency to 80% | Hotkey is Win+Alt+1
#!1::
	WinSet, Transparent, 80, A
return

;Set transparency to 00% | Hotkey is Win+Alt+2
#!2::
	WinSet, Transparent, OFF, A 
return