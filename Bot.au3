#include-once
#include <Nathalib.au3>
#include <ImageSearch.au3>

; SETTINGS:
; Alerts
Global $alerts = True
Global $logout = True

; Food
Global $eatfood = True
Global $food_time = 30
Global $food = "Meat"

; Runemaker
Global $runemaker = True
Global $spell = "utevo lux"
Global $spell_time = 15

; DON'T TOUCH BELOW
Global $refXY[2]
Global $my_food_time = 0
Global $my_spell_time = 0

; FUNCTIONS
Func find($image)
If _FindImage(("img\" & $image & ".png"), $refXY[0], $refXY[1]) Then
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

; DEFAULT ROUTINE
; Clean logs
Console("Creating log.txt file...")
FileOpen("log.txt", 2)
FileWriteLine("log.txt", "LOGS FROM: " & _NowDate())
FileClose("log.txt")

; Create console
Global $text = "Team Fortress Bot"
Global $sphandle = SplashTextOn("", $text, 300, 40, ((@DesktopWidth / 2) - 150), 0, $DLG_NOTITLE, "Segoe UI", 9, 300)

; Focus game window to start botting
If Not WinActivate($window_name) Then
	Console("Error, check log.txt file.")
	WriteLog("Unable to find game window, game is closed.")
	Sleep(3000)
	Exit
EndIf

While 1
	; ALERTS
	If $alerts Then
		If NOT find("battle_list") Then
			If $logout Then
				Send("^q")
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
			EndIf
		EndIf
	EndIf
	
	Sleep(1000)
	$my_food_time = $my_food_time + 1
	$my_spell_time = $my_spell_time + 1
WEnd
