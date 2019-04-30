#include-once
#include <Nathalib.au3>
#include <ImageSearch.au3>
#include <AutoItConstants.au3>
#include <Date.au3>
#include <WinAPIMem.au3>
#include <WinAPIProc.au3>
#include <File.au3>

; SETTINGS:
$resolutionX = 1920
$resolutionY = 1080

; Game
Global $EXE_full_name = "WATclient-DX9.exe"
Global $window_name = "Khazix - WeAreTibia"

; Coords
Global $self[2]
$self[0] = 875
$self[1] = 485
Global $NW[2]
$NW[0] = 792
$NW[1] = 405
Global $NE[2]
$NE[0] = 950
$NE[1] = 405
Global $SW[2]
$SW[0] = 790
$SW[1] = 555
Global $SE[2]
$SE[0] = 948
$SE[1] = 555

; Alerts
Global $alerts = False
Global $logout = False
Global $welcome = True
Global $welcome_time = 30

; Food
Global $eatfood = True
Global $food_time = 15
Global $food = "Meat"

; Runemaker
Global $runemaker = True
Global $spell = "utevo lux"
Global $spell_time = 15
Global $move_blanks = False
Global $DiscardXY[2]
; X/Y coords where the completed runes will be thrown
; To get your coords check this https://github.com/Kuhicop/Mouse-Coords
$DiscardXY[0] = 0
$DiscardXY[1] = 0

; Cavebot
Global $cavebot = True
Global $recording = False
Global $filename = "trolls_carlin.txt"
Global $trapcount = 20000
Global $pos[3]
$pos[0] = 0x98F69C
$pos[1] = 0x98F6A0
$pos[2] = 0x98F6A4

; Targeting
Global $targeting = True
Global $atkmode = "Atk" ; Atk, Bal, Def
Global $chase = True

; Looting
Global $bpgoldXY[2]
$bpgoldXY[0] = 1768
$bpgoldXY[1] = 548

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
Global $xyz_pos[3]
Global $aux_pos[3]
Global $file_i = 1
$welcome_time = $welcome_time*10
Global $total_loop = 0

; INITIAL ROUTINE
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

; Check if recording
If $recording Then
	If Not FileExists($filename) Then
		FileOpen($filename, 2)
		FileWriteLine($filename, "[MONSTERS]")
		FileWriteLine($filename, "img\monsters\rat.png")
		FileWriteLine($filename, "[LOOT]")
		FileWriteLine($filename, "img\loot\gold.png")
		FileWriteLine($filename, "[WAYPOINTS]")
		$xyz_pos[0] = ReadMemory($pos[0])
		$xyz_pos[1] = ReadMemory($pos[1])
		$xyz_pos[2] = ReadMemory($pos[2])
		Console("Recording ready.")
		While $recording
			$aux_pos[0] = ReadMemory($pos[0])
			$aux_pos[1] = ReadMemory($pos[1])
			$aux_pos[2] = ReadMemory($pos[2])
			If ($aux_pos[0] <> $xyz_pos[0]) Or ($aux_pos[1] <> $xyz_pos[1]) Or ($aux_pos[2] <> $xyz_pos[2]) Then
				Console("Write: " & $aux_pos[0] & "|" & $aux_pos[1] & "|" & $aux_pos[2])
				FileWriteLine($filename, $aux_pos[0] & "|" & $aux_pos[1] & "|" & $aux_pos[2])
				$xyz_pos[0] = $aux_pos[0]
				$xyz_pos[1] = $aux_pos[1]
				$xyz_pos[2] = $aux_pos[2]
			EndIf
		WEnd
	Else
		MsgBox(16, "ERROR", "File already exists: " & $filename)
	EndIf
EndIf

; Check if script exists if want to bot
If $cavebot Then
	If Not FileExists($filename) Then
		MsgBox(16, "ERROR", "Unable to find: " & $filename)
	Else
		Console("Cutting files")
		WriteLog("Cutting files")
		$secondaryfile = StringSplit($filename,".")
		$secondaryfile = $secondaryfile[0] & "wp.txt"
		FileOpen($secondaryfile, 2)
		FileOpen($filename, 0)
		$found = False
		$find = "[WAYPOINTS]"
		$i = 1
		While Not $found
			$result = FileReadLine($filename, $i)
			If $find == $result Then
				$found = True
			EndIf
			$i = $i + 1
		WEnd
		$linesdone = False
		$wplines = 0
		While Not $linesdone
			$readline = FileReadLine($filename, $i)
			If ("[END]" <> $readline) Then
				FileWriteLine($secondaryfile, $readline)
			Else
				$linesdone = True
				FileClose($secondaryfile)
				FileClose($filename)
				FileOpen($filename, 0)
			EndIf
			$i = $i + 1
		WEnd
	EndIf
EndIf

Console("Ready, Keys: END(quit) & HOME(Start bot).")

; DEFAULT ROUTINE
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
						Send($welcome_msg[$msg_num] & "{ENTER}")
						$my_welcome_time = 0
					EndIf
				EndIf
			EndIf
		EndIf

		; EAT FOOD
		If $eatfood Then
			If $my_food_time >= $food_time Then
				If find($food) Then
					Console("Found food.")
					MouseMove($refXY[0], $refXY[1], 1)
					MouseClick("right", $refXY[0], $refXY[1], 1, 1)
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
						MouseClickDrag("left", $HandXY[0], $HandXY[1], $DiscardXY[0], $DiscardXY[1], 1)
					EndIf
					If findpos("blank_rune", $blank_runesXY[0], $blank_runesXY[1]) AND findpos("empty_hand", $HandXY[0], $HandXY[1]) Then
						MouseClickDrag("left", $blank_runesXY[0], $blank_runesXY[1], $HandXY[0], $HandXY[1], 1)
						If NOT find("empty_hand") Then
							Send($spell & "{ENTER}")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		; TARGETING
		If $targeting Then
			If $atkmode = "Atk" Then
				If find("atk") Then
					MouseClick("left", $refXY[0], $refXY[1], 1, 1)
				EndIf
			ElseIf $atkmode = "Bal" Then
				If find("bal") Then
					MouseClick("left", $refXY[0], $refXY[1], 1, 1)
				EndIf
			ElseIf $atkmode = "Def" Then
				If find("def") Then
					MouseClick("left", $refXY[0], $refXY[1], 1, 1)
				EndIf
			EndIf

			If $chase Then
				If find("chase") Then
					MouseClick("left", $refXY[0], $refXY[1], 1, 1)
				EndIf
			Else
				If find("stay") Then
					MouseClick("left", $refXY[0], $refXY[1], 1, 1)
				EndIf
			EndIf

			$looped = False
			While Not find("battle_list")
				; Monsters
				If find("\monsters\troll") Then
					WriteLog("Attacking target")
					Console("Attacking target")
					MouseClick("left", $refXY[0], $refXY[1], 1, 1)
					MouseMove($self[0], $self[1], 1)
					While ((Not find("battle_list")) And (find("\monsters\troll_attack")))
						MouseMove($self[0], $self[1], 1)
					WEnd
				Else
					Console("Something on screen")
				EndIf
				; End of monster
			WEnd
			If find("battle_list") Then
				If $looped Then
					; LOOTING
					Console("Looting")
					If find("blood") Then
						MouseClick("right", $refXY[0], $refXY[1], 1, 1)
						$loot = PixelSearch(1741, 573, 1919, 1036, 0xffe047)
						If Not @error Then
							MouseClickDrag("left", $loot[0], $loot[1], $bpgoldXY[0], $bpgoldXY[1], 1)
							Send("{ENTER}")
						EndIf
					EndIf
					$looped = False
				EndIf
			EndIf
		EndIf

		; CAVEBOT
		If $cavebot Then
			$xyz_pos[0] = ReadMemory($pos[0])
			$xyz_pos[1] = ReadMemory($pos[1])
			$xyz_pos[2] = ReadMemory($pos[2])
			$myline = FileReadLine($secondaryfile, $file_i)
			If @error Then
				WriteLog("Setting i to 1")
				$file_i = 1
				CleanWaypoints(FileReadLine($secondaryfile, $file_i))
			Else
				CleanWaypoints($myline)
			EndIf

			; Check direction
			$testedtimes = 0
			Console("Checking direction")
			If (($xyz_pos[0] == $aux_pos[0]) And ($xyz_pos[1] == $aux_pos[1]) And ($xyz_pos[2] == $aux_pos[2])) Then
				$file_i = $file_i + 1
			EndIf
			While Not (($xyz_pos[0] == $aux_pos[0]) And ($xyz_pos[1] == $aux_pos[1]) And ($xyz_pos[2] == $aux_pos[2]))
				If Not find("battle_list") Then
					ExitLoop
				EndIf
				WriteLog("WHILE: " & $xyz_pos[0] & "," & $xyz_pos[1] & "," & $xyz_pos[2] & " / " & $aux_pos[0] & "," & $aux_pos[1] & "," & $aux_pos[2])
				$xyz_pos[0] = ReadMemory($pos[0])
				$xyz_pos[1] = ReadMemory($pos[1])
				$xyz_pos[2] = ReadMemory($pos[2])
				If ($xyz_pos[0] <> $aux_pos[0]) And ($xyz_pos[1] <> $aux_pos[1]) And ($xyz_pos[2] <> $aux_pos[2]) Then
					; Teleported
					player_trapped()
				Else
					;
					; STRAIGHT MOVEMENT
					;
					If (($xyz_pos[0] - $aux_pos[0]) <> 0) Then
						; There's x difference
						If (($xyz_pos[0] - $aux_pos[0]) > 0) Then
							; left
							WriteLog("L: " & $xyz_pos[0] & "," & $xyz_pos[1] & "," & $xyz_pos[2] & " / " & $aux_pos[0] & "," & $aux_pos[1] & "," & $aux_pos[2])
							walk("{LEFT}")
							$refresh_X = ReadMemory($pos[0])
							$refresh_Y = ReadMemory($pos[1])
							$refresh_Z = ReadMemory($pos[2])
							If $refresh_X == $aux_pos[0] And $refresh_Y == $aux_pos[1] And $refresh_Z == $aux_pos[2] Then
								$file_i = $file_i + 1
							EndIf
						Else
							; right
							WriteLog("R: " & $xyz_pos[0] & "," & $xyz_pos[1] & "," & $xyz_pos[2] & " / " & $aux_pos[0] & "," & $aux_pos[1] & "," & $aux_pos[2])
							walk("{RIGHT}")
							$refresh_X = ReadMemory($pos[0])
							$refresh_Y = ReadMemory($pos[1])
							$refresh_Z = ReadMemory($pos[2])
							If $refresh_X == $aux_pos[0] And $refresh_Y == $aux_pos[1] And $refresh_Z == $aux_pos[2] Then
								$file_i = $file_i + 1
							EndIf
						EndIf
					EndIf
					If (($xyz_pos[1] - $aux_pos[1]) <> 0) Then
						; There's y difference
						If (($xyz_pos[1] - $aux_pos[1]) > 0) Then
							; north
							WriteLog("N: " & $xyz_pos[0] & "," & $xyz_pos[1] & "," & $xyz_pos[2] & " / " & $aux_pos[0] & "," & $aux_pos[1] & "," & $aux_pos[2])
							walk("{UP}")
							$refresh_X = ReadMemory($pos[0])
							$refresh_Y = ReadMemory($pos[1])
							$refresh_Z = ReadMemory($pos[2])
							If $refresh_X == $aux_pos[0] And $refresh_Y == $aux_pos[1] And $refresh_Z == $aux_pos[2] Then
								$file_i = $file_i + 1
							EndIf
						Else
							; south
							WriteLog("S: " & $xyz_pos[0] & "," & $xyz_pos[1] & "," & $xyz_pos[2] & " / " & $aux_pos[0] & "," & $aux_pos[1] & "," & $aux_pos[2])
							walk("{DOWN}")
							$refresh_X = ReadMemory($pos[0])
							$refresh_Y = ReadMemory($pos[1])
							$refresh_Z = ReadMemory($pos[2])
							If $refresh_X == $aux_pos[0] And $refresh_Y == $aux_pos[1] And $refresh_Z == $aux_pos[2] Then
								$file_i = $file_i + 1
							EndIf
						EndIf
					EndIf
					$testedtimes = $testedtimes + 1
					If $testedtimes > $trapcount Then
						player_trapped()
					EndIf
				EndIf
			WEnd
		EndIf

		If Not $cavebot Then
			Sleep(100)
		EndIf
		$my_food_time = $my_food_time + 1
		$my_spell_time = $my_spell_time + 1
		$my_welcome_time = $my_welcome_time + 1
		$total_loop = $total_loop + 1
		Console($total_loop)
	WEnd
WEnd





; FUNCTIONS ROUTINE
Func walk($direction)
	Send($direction)
	Sleep(50)
EndFunc

Func player_trapped()
	Console("Player trapped!")
	WriteLog("TRAPPED: " & $xyz_pos[0] & "," & $xyz_pos[1] & "," & $xyz_pos[2] & "//" & $aux_pos[0] & "," & $aux_pos[1] & "," & $aux_pos[2])
	SoundPlay("trapped.mp3")
	Sleep(3000)
	Leave()
EndFunc

Func CleanWaypoints($line)
WriteLog("Cleaning line: " & $line)
$result = StringSplit($line, "|")
WriteLog("CLEANING: " & $result[1] & "," & $result[2] & "," & $result[3] & "(" & $aux_pos[0] & "," & $aux_pos[1] & "," & $aux_pos[2] & ")")
$aux_pos[0] = $result[1]
$aux_pos[1] = $result[2]
$aux_pos[2] = $result[3]
EndFunc

Func find($image)
$image = "img\" & $image & ".png"
If _FindImage($image, $refXY[0], $refXY[1]) Then
	return True
	;Console("Found: " & $image)
Else
	;Console("Unable to find: " & $image)
	return False
EndIf
EndFunc
Func findpos($image, ByRef $X, ByRef $Y)
If _FindImage(("img\" & $image & ".png"), $X, $Y) Then
	return True
Else
	Console("Unable to find: " & $food)
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
$running = True
Console("Bot started!")
EndFunc

Func Leave()
If $recording Then
	FileWriteLine($filename, "[END]")
	FileClose($filename)
EndIf
If $cavebot Then
	FileClose($filename)
	FileClose($secondaryfile)
EndIf
Exit
EndFunc

Func ReadMemory($addr)
$hProcess = ProcessExists($EXE_full_name)
$pBuf = DllStructCreate("int")
$iRead = 0
$hProc = _WinAPI_OpenProcess(0x1F0FFF, False, $hProcess)

_WinAPI_ReadProcessMemory($hProc, $addr, DllStructGetPtr($pBuf), DllStructGetSize($pBuf), $iRead)

Return DllStructGetData($pBuf, 1)
EndFunc