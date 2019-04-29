#include-once
#include <Nathalib.au3>
#include <ImageSearch.au3>

Global $food_time = 60
Global $food = "Meat"

; DON'T TOUCH BELOW
Global $refXY[2]

Func find($image)
If _FindImage($image, $refXY[0], $refXY[1]) Then
	return True
Else
	return False
EndIf
EndFunc

While 1
	$my_food_time = 0
	If $my_food_time == $food_time Then
		If find("img\" & $food & ".png") Then
			MouseClick("right", $refXY[0], $refXY[1], 1, 10)
		EndIf
	Else
		Sleep(1000)
		$my_food_time = $my_food_time + 1
	EndIf
WEnd