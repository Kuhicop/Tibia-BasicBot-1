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
Global $window_name = "Camille - WeAreTibia"

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
Global $food_time = 60
Global $foodname = "mushroom"

; Runemaker
Global $runemaker = True
Global $spell = "exevo con"
Global $spell_time = 30
Global $move_blanks = False
Global $DiscardXY[2]
; X/Y coords where the completed runes will be thrown
; To get your coords check this https://github.com/Kuhicop/Mouse-Coords
$DiscardXY[0] = 0
$DiscardXY[1] = 0
Global $safehouse = False
Global $housedirection = "{RIGHT}"
Global $househidedirection = "{LEFT}"

; Cavebot
Global $cavebot = True
Global $recording = False
Global $refillammo = True
Global $filename = "trolls_carlin.txt"
Global $trapcount = 20000
Global $pos[3]
$pos[0] = 0x98F69C
$pos[1] = 0x98F6A0
$pos[2] = 0x98F6A4

; Targeting
Global $targeting = True
Global $atkmode = "Atk" ; Atk, Bal, Def
Global $chase = False
Global $mo_amount = 2
Global $monsters[$mo_amount]
$monsters[0] = "troll"
$monsters[1] = "wasp"

; Looting
Global $looting_gold = False
Global $looting_spears = False
Global $bpgoldXY[2]
$bpgoldXY[0] = 1768
$bpgoldXY[1] = 608
Global $bpgoldXY2[2]
$bpgoldXY2[0] = 1804
$bpgoldXY2[1] = 613
Global $bpitemsXY[2]
$bpitemsXY[0] = 1765
$bpitemsXY[1] = 548
Global $lootXY[4]
$lootXY[0] = 1741
$lootXY[1] = 574
$lootXY[2] = 1918
$lootXY[3] = 1036
Global $fulllootXY[4]
$fulllootXY[0] = 1742
$fulllootXY[1] = 514
$fulllootXY[2] = 1919
$fulllootXY[3] = 1037
Global $lhand[2]
$lhand[0] = 1763
$lhand[1] = 354
Global $houseoutpos[2]

#Region setup
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
Global $aux_pos[4]
Global $file_i = 1
$my_food_time = $my_food_time*10
$my_spell_time = $my_spell_time*10
$welcome_time = $welcome_time*10
Global $total_loop = 0
Global $DiagPos[3]
Global $DiagAux[3]
Global $attacking = False
Global $myline = ""
Global $auxX = 0
Global $auxY = 0
Global $monster_name = ""
Global $mo_amount = $mo_amount - 1

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
	HotkeySet("{INSERT}","recrope")
	If Not FileExists($filename) Then
		FileOpen($filename, 2)
		FileWriteLine($filename, "[TIBIA-BASICBOT]")
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
		$secondaryfile = StringSplit($filename,".")
		$secondaryfile = $secondaryfile[1] & "wp.txt"
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
#EndRegion

; DEFAULT ROUTINE
While $botting
	While $running
		falerts()
		feat(True)
		frunemaker()
		ftargeting()
		fcavebot()

		Sleep(100)

		$my_food_time = $my_food_time + 1
		$my_spell_time = $my_spell_time + 1
		$my_welcome_time = $my_welcome_time + 1
		$total_loop = $total_loop + 1
		Console($total_loop)
	WEnd
WEnd

; FUNCTIONS ROUTINE
Func walk($direction)
	WriteLog("Destino: " & $myline & " / " & $xyz_pos[0] & "," & $xyz_pos[1] & " = " & $direction)
	Send($direction)
	Sleep(200)
EndFunc

Func player_trapped()
	Console("Player trapped!")
	WriteLog("TRAPPED: " & $xyz_pos[0] & "," & $xyz_pos[1] & "," & $xyz_pos[2] & "//" & $aux_pos[0] & "," & $aux_pos[1] & "," & $aux_pos[2])
	SoundPlay("trapped.mp3")
	Sleep(3000)
	Leave()
EndFunc

Func FindArea($areaimg, $area1, $area2, $area3, $area4)
	If _FindImageArea($areaimg, $area1, $area2, $area3, $area4, $refXY[0],$refXY[1]) Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func CleanWaypoints($line)
$result = StringSplit($line, "|")
$aux_pos[0] = $result[1]
$aux_pos[1] = $result[2]
$aux_pos[2] = $result[3]
EndFunc

Func recrope()
$aux_pos[0] = ReadMemory($pos[0])
$aux_pos[1] = ReadMemory($pos[1])
FileWriteLine($filename, $aux_pos[0] & "|" & $aux_pos[1] & "|" & "R")
EndFunc

Func thereisgold()
$goldXY = PixelSearch($lootXY[0], $lootXY[1], $lootXY[2], $lootXY[3], 0xf8c810, 1)
If Not @error Then
	If $looting_gold Then
		MouseClickDrag("left", $goldXY[0], $goldXY[1], $bpgoldXY[0], $bpgoldXY[1], 5)
		Sleep(100)
		Send("{ENTER}")
		Sleep(300)
		$goldXY = PixelSearch($lootXY[0], $lootXY[1], $lootXY[2], $lootXY[3], 0xf8c810, 1)
		If Not @error Then
			 MouseClickDrag("left", $goldXY[0], $goldXY[1], $bpgoldXY2[0], $bpgoldXY2[1], 5)
		EndIf
	EndIf
	feat(False)
	Sleep(300)
	If find("apple") Then
		MouseClickDrag("left", $refXY[0], $refXY[1], $bpitemsXY[0], $bpitemsXY[1], 5)
		Sleep(300)
	EndIf
	If $looting_spears Then
		If FindArea("spear", $lootXY[0], $lootXY[1], $lootXY[2], $lootXY[3]) Then
			MouseClickDrag("left", $refXY[0], $refXY[1], $lhand[0], $lhand[1], 5)
			Sleep(300)
		EndIf
	EndIf
	If find("bag") Then
		Sleep(100)
		MouseClick("right", $refXY[0], $refXY[1], 1, 5)
		Sleep(100)
		If $looting_spears Then
			If FindArea("spear", $lootXY[0], $lootXY[1], $lootXY[2], $lootXY[3]) Then
				MouseClickDrag("left", $refXY[0], $refXY[1], $lhand[0], $lhand[1], 5)
				Sleep(300)
			EndIf
		EndIf
		feat(False)
	EndIf
Else
	WriteLog("Can't find gold")
EndIf
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

Func pixel(ByRef $aCoord, $color)
$aCoord = PixelSearch(0, 0, 1920, 1080, $color, 1)
If Not @error Then
	Return True
Else
	Return False
EndIf
EndFunc

Func ReadMemory($addr)
$hProcess = ProcessExists($EXE_full_name)
$pBuf = DllStructCreate("int")
$iRead = 0
$hProc = _WinAPI_OpenProcess(0x1F0FFF, False, $hProcess)

_WinAPI_ReadProcessMemory($hProc, $addr, DllStructGetPtr($pBuf), DllStructGetSize($pBuf), $iRead)

Return DllStructGetData($pBuf, 1)
EndFunc

Func outhousepos()
$aux_pos[0] = ReadMemory($pos[0])
$aux_pos[1] = ReadMemory($pos[1])
$aux_pos[2] = ReadMemory($pos[2])
If ($aux_pos[0] == $houseoutpos[0]) And ($aux_pos[1] == $houseoutpos[1]) Then
	Return True
Else
	Return False
EndIf
EndFunc

Func falerts()
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
		If $safehouse Then
			While outhousepos()
				walk($househidedirection)
			WEnd
		EndIf
		While Not outhousepos()
			walk($housedirection)
		WEnd
	EndIf
EndIf
EndFunc

Func feat($checktime)
If $eatfood Then
	If ($my_food_time >= $food_time) Or (Not $checktime) Then
		If find($foodname) Then
			MouseClick("right", $refXY[0], $refXY[1], 1, 1)
			$my_food_time = 0
		EndIf
	EndIf
EndIf
EndFunc

Func frunemaker()
If $runemaker Then
	If $houseoutpos[0] == 0 Then
		$houseoutpos[0] = ReadMemory($pos[0])
		$houseoutpos[1] = ReadMemory($pos[1])
	EndIf
	If $my_spell_time >= $spell_time Then
		If NOT $move_blanks Then
			Send($spell & "{ENTER}")
			$my_spell_time = 0
		Else
			If NOT findpos("empty_hand", $HandXY[0], $HandXY[1]) Then
				MouseClickDrag("left", $HandXY[0], $HandXY[1], $DiscardXY[0], $DiscardXY[1], 1)
			EndIf
			If findpos("blank_rune", $blank_runesXY[0], $blank_runesXY[1]) AND findpos("empty_hand", $HandXY[0], $HandXY[1]) Then
				MouseClickDrag("left", $blank_runesXY[0], $blank_runesXY[1], $HandXY[0], $HandXY[1], 1)
				If NOT find("empty_hand") Then
					Send($spell & "{ENTER}")
					$my_spell_time = 0
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
EndFunc

Func ftargeting()
If $targeting Then
	While Not find("battle_list")
		$mo_i = 0
		While ($mo_i <= $mo_amount)
			$monster_name = $monsters[$mo_i]
			$mo_i = $mo_i + 1
			If $refillammo Then
				If findpos("empty_arrow", $auxX, $auxY) Then
					If FindArea("arrow", $fulllootXY[0], $fulllootXY[1], $fulllootXY[2], $fulllootXY[3]) Then
						MouseClickDrag("left", $refXY[0], $refXY[1], $auxX, $auxY, 5)
						Sleep(300)
						Send("{ENTER}")
					EndIf
				EndIf
			EndIf
			If find("\monsters\" & $monster_name) Then
				MouseClick("left", $refXY[0], $refXY[1], 1, 1)
				MouseMove($self[0], $self[1], 1)
				While find("monsters\" & $monster_name & "_attack")
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
					$pixelq = PixelSearch(($self[0]-50), ($self[1]-50), ($self[0]+50), ($self[1]+50), 0xFF0000, 1)
					If Not @error Then
						$attacking = True
						$lootXY[0] = $pixelq[0]
						$lootXY[1] = $pixelq[1]
					Else
						$attacking = False
					EndIf
				WEnd
				While $attacking
					MouseClick("right", ($pixelq[0]+30), ($pixelq[1]+30), 1, 10)
					Sleep(200)
					thereisgold()
					Sleep(50)
					$attacking = False
				WEnd
			EndIf
		WEnd	
	WEnd
	$attacking = False
EndIf
EndFunc

Func fcavebot()
If $cavebot Then
	If $refillammo Then
		If findpos("empty_arrow", $auxX, $auxY) Then
			If FindArea("arrow", $fulllootXY[0], $fulllootXY[1], $fulllootXY[2], $fulllootXY[3]) Then
				MouseClickDrag("left", $refXY[0], $refXY[1], $auxX, $auxY, 5)
				Sleep(300)
				Send("{ENTER}")
			EndIf
		EndIf
	EndIf

	$xyz_pos[0] = ReadMemory($pos[0])
	$xyz_pos[1] = ReadMemory($pos[1])
	$xyz_pos[2] = ReadMemory($pos[2])
	$myline = FileReadLine($secondaryfile, $file_i)
	If @error Then
		$file_i = 1
		CleanWaypoints(FileReadLine($secondaryfile, $file_i))
	Else
		CleanWaypoints($myline)
	EndIf

	If $aux_pos[2] == "R" Then
		If find("rope") Then
			MouseClick("right", $refXY[0], $refXY[1], 1, 5)
			MouseClick("left", $aux_pos[0], $aux_pos[1], 1, 5)
		EndIf
	Else
		; Check direction
		$testedtimes = 0
		; We are ok or move to next waypoint
		If (Abs($xyz_pos[0] - $aux_pos[0]) < 4) And (Abs($xyz_pos[1] - $aux_pos[1]) < 4) Then
			; Walking needed
			While Not (($xyz_pos[0] == $aux_pos[0]) And ($xyz_pos[1] == $aux_pos[1]) And ($xyz_pos[2] == $aux_pos[2]))
				; Don't keep looping if there's something on target
				If Not find("battle_list") Then
					ExitLoop
				EndIf

				falerts()
				feat(True)
				frunemaker()

				; Update xyz actual coords
				$xyz_pos[0] = ReadMemory($pos[0])
				$xyz_pos[1] = ReadMemory($pos[1])
				$xyz_pos[2] = ReadMemory($pos[2])
				If ($xyz_pos[0] <> $aux_pos[0]) And ($xyz_pos[1] <> $aux_pos[1]) And ($xyz_pos[2] <> $aux_pos[2]) Then
					; Teleported
					player_trapped()
				Else
					If (($xyz_pos[0] - $aux_pos[0]) <> 0) And (($xyz_pos[1] - $aux_pos[1]) <> 0) Then
						;
						; DIAGONAL MOVEMENT
						;
						If (($xyz_pos[0] - $aux_pos[0]) > 0) And (($xyz_pos[1] - $aux_pos[1]) > 0) Then
							; North-West
							If (Abs($xyz_pos[0] - $aux_pos[0])) == (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Can walk north or west
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{UP}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[1] == $DiagAux[1] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{LEFT}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[0] == $DiagAux[0] Then
										walk("{RIGHT}")
									EndIf
								EndIf
							ElseIf (Abs($xyz_pos[0] - $aux_pos[0])) > (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Shortest is Y
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{UP}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[1] == $DiagAux[1] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{LEFT}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[0] == $DiagAux[0] Then
										walk("{RIGHT}")
									EndIf
								EndIf
							ElseIf (Abs($xyz_pos[0] - $aux_pos[0])) < (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Shortest is X
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{LEFT}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[0] == $DiagAux[0] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{UP}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[1] == $DiagAux[1] Then
										walk("{DOWN}")
									EndIf
								EndIf
							Else
								Console("Lost in North-West")
								WriteLog("Lost in North-West")
							EndIf
						ElseIf (($xyz_pos[0] - $aux_pos[0]) < 0) And (($xyz_pos[0] - $aux_pos[0]) < 0) Then
							; North-East
							If (Abs($xyz_pos[0] - $aux_pos[0])) == (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Can walk north or east
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{UP}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[1] == $DiagAux[1] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{RIGHT}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[0] == $DiagAux[0] Then
										walk("{LEFT}")
									EndIf
								EndIf
							ElseIf (Abs($xyz_pos[0] - $aux_pos[0])) > (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Shortest is Y
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{UP}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[1] == $DiagAux[1] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{RIGHT}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[0] == $DiagAux[0] Then
										walk("{LEFT}")
									EndIf
								EndIf
							ElseIf (Abs($xyz_pos[0] - $aux_pos[0])) < (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Shortest is X
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{RIGHT}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[0] == $DiagAux[0] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{UP}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[1] == $DiagAux[1] Then
										walk("{DOWN}")
									EndIf
								EndIf
							Else
								Console("Lost in North-East")
								WriteLog("Lost in North-East")
							EndIf
						ElseIf	(($xyz_pos[0] - $aux_pos[0]) < 0) And (($xyz_pos[1] - $aux_pos[1]) < 0) Then
							; South-East
							If (Abs($xyz_pos[0] - $aux_pos[0])) == (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Can walk south or east
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{DOWN}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[1] == $DiagAux[1] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{LEFT}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[0] == $DiagAux[0] Then
										walk("{RIGHT}")
									EndIf
								EndIf
							ElseIf (Abs($xyz_pos[0] - $aux_pos[0])) > (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Shortest is Y
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{DOWN}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[1] == $DiagAux[1] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{LEFT}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[0] == $DiagAux[0] Then
										walk("{RIGHT}")
									EndIf
								EndIf
							ElseIf (Abs($xyz_pos[0] - $aux_pos[0])) < (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Shortest is X
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{RIGHT}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[0] == $DiagAux[0] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{DOWN}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[1] == $DiagAux[1] Then
										walk("{UP}")
									EndIf
								EndIf
							Else
								Console("Lost in South-East")
								WriteLog("Lost in South-East")
							EndIf
						Else
							; South-West
							If (Abs($xyz_pos[0] - $aux_pos[0])) == (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Can walk south or west
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{DOWN}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[1] == $DiagAux[1] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{LEFT}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[0] == $DiagAux[0] Then
										walk("{RIGHT}")
									EndIf
								EndIf
							ElseIf (Abs($xyz_pos[0] - $aux_pos[0])) > (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Shortest is Y
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{DOWN}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[1] == $DiagAux[1] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{LEFT}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[0] == $DiagAux[0] Then
										walk("{RIGHT}")
									EndIf
								EndIf
							ElseIf (Abs($xyz_pos[0] - $aux_pos[0])) < (Abs($xyz_pos[1] - $aux_pos[1])) Then
								; Shortest is X
								$DiagPos[0] = ReadMemory($pos[0])
								$DiagPos[1] = ReadMemory($pos[1])
								$DiagPos[2] = ReadMemory($pos[2])
								walk("{LEFT}")
								$DiagAux[0] = ReadMemory($pos[0])
								$DiagAux[1] = ReadMemory($pos[1])
								$DiagAux[2] = ReadMemory($pos[2])
								If $DiagPos[0] == $DiagAux[0] Then
									; Didn't move
									$DiagPos[0] = ReadMemory($pos[0])
									$DiagPos[1] = ReadMemory($pos[1])
									$DiagPos[2] = ReadMemory($pos[2])
									walk("{UP}")
									$DiagAux[0] = ReadMemory($pos[0])
									$DiagAux[1] = ReadMemory($pos[1])
									$DiagAux[2] = ReadMemory($pos[2])
									; stuck
									If $DiagPos[1] == $DiagAux[1] Then
										walk("{DOWN}")
									EndIf
								EndIf
							Else
								Console("Lost in South-West")
								WriteLog("Lost in South-West")
							EndIf
						EndIf
					Else
						;
						; STRAIGHT MOVEMENT
						;
						If (($xyz_pos[0] - $aux_pos[0]) <> 0) Then
							; There's x difference
							If (($xyz_pos[0] - $aux_pos[0]) > 0) Then
								; left
								walk("{LEFT}")
							Else
								; right
								walk("{RIGHT}")
							EndIf
						EndIf
						If (($xyz_pos[1] - $aux_pos[1]) <> 0) Then
							; There's y difference
							If (($xyz_pos[1] - $aux_pos[1]) > 0) Then
								; north
								walk("{UP}")
							Else
								; south
								walk("{DOWN}")
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
	EndIf
	$file_i = $file_i + 1
EndIf
EndFunc
