#include-once
#include <Nathalib.au3>
#include <ImageSearch.au3>
#include <AutoItConstants.au3>
#include <Date.au3>

; SETTINGS:
; Game
Global $EXE_full_name = "WATclient-DX9.exe"
Global $window_name = "Camille - WeAreTibia"

; Alerts
Global $alerts = True
Global $logout = True
Global $welcome = True
Global $welcome_time = 300

; Food
Global $eatfood = True
Global $food_time = 30
Global $food = "Meat"

; Runemaker
Global $runemaker = True
Global $spell = "utevo lux"
Global $spell_time = 15
Global $DiscardXY[2]
; X/Y coords where the completed runes will be thrown
; To get your coords check this https://github.com/Kuhicop/Mouse-Coords
$DiscardXY[0] = 0
$DiscardXY[1] = 0

; DON'T TOUCH BELOW
HotkeySet("{END}", "Leave")
HotkeySet("{HOME}", "StartBotting")
Global $running = False
Global $botting = True
Global $refXY[2]
Global $HandXY[2]
Global $blank_runesXY[2]
Global $my_food_time = 0
Global $my_spell_time = 0
Global $my_welcome_time = 9999
Global $welcome_msg[5]
$welcome_msg[0] = ":P"
$welcome_msg[1] = ":)"
$welcome_msg[2] = "xd"
$welcome_msg[3] = "^^"
$welcome_msg[4] = ":D"

; DEFAULT ROUTINE
; Create console
Global $text = "Tibia Classic Bot"
Global $sphandle = SplashTextOn("", $text, 300, 40, ((@DesktopWidth / 2) - 150), 0, $DLG_NOTITLE, "Segoe UI", 9, 300)

; Clean logs
Console("Creating log.txt file...")
FileOpen("log.txt", 2)
FileWriteLine("log.txt", "LOGS FROM: " & _NowDate())
FileClose("log.txt")

; Focus game window to start botting
If Not WinActivate($window_name) Then
	Console("Error, check log.txt file.")
	WriteLog("Unable to find game window, game is closed.")
	Sleep(3000)
	Exit
EndIf

While $botting
	While $running
		; ALERTS
		If $alerts Then
			If NOT find("battle_list") Then
				If $logout Then
					Send("^q")
				EndIf
				If $welcome Then
					If $my_welcome_time >= $welcome_time Then
						$msg_num = Random(0, 4, 1)
						Send($welcome_msg[$msg_num])
						$my_welcome_time = 0
					EndIf
				EndIf
			EndIf
		EndIf

		; EAT FOOD
		If $eatfood Then
			If $my_food_time == $food_time Then
				If find($food) Then
					MouseClick("right", $refXY[0], $refXY[1], 1, 10)
					$my_food_time = 0
				EndIf
			EndIf
		EndIf

		; RUNEMAKER
		If $runemaker Then
			If $my_spell_time == $spell_time Then
				If NOT $move_blanks Then
					Send($spell & "{ENTER}")
				Else
					If NOT findpos("empty_hand", $HandXY[0], $HandXY[1]) Then
						MouseClickDrag("left", $HandXY[0], $HandXY[1], $DiscardXY[0], $DiscardXY[1])
					EndIf
					If findpos("blank_rune", $blank_runesXY[0], $blank_runesXY[1]) AND findpos("empty_hand", $HandXY[0], $HandXY[1]) Then
						MouseClickDrag("left", $blank_runesXY[0], $blank_runesXY[1], $HandXY[0], $HandXY[1])
						If NOT find("empty_hand") Then
							Send($spell & "{ENTER}")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		Sleep(1000)
		$my_food_time = $my_food_time + 1
		$my_spell_time = $my_spell_time + 1
		$my_welcome_time = $my_welcome_time + 1
	WEnd
WEnd





; FUNCTIONS
Func find($image)
If _FindImage(("img\" & $image & ".png"), $refXY[0], $refXY[1]) Then
	return True
Else
	return False
EndIf
EndFunc
Func findpos($image, ByRef $X, ByRef $Y)
If _FindImage(("img\" & $image & ".png"), $X, $Y) Then
	return True
Else
	return False
EndIf
EndFunc

Func Console($text2)
ControlSetText($sphandle, $text, 'Static1', $text2)
$text = $text2
EndFunc

Func WriteLog($text)
FileOpen("log.txt", 1)
FileWriteLine("log.txt", _NowTime() & " -- " & $text)
FileClose("log.txt")
EndFunc

Func StartBotting()
running = True
EndFunc

Func Leave()
Exit
EndFunc
