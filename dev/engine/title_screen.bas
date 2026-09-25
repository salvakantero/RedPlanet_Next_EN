'title screen, menu, etc.
DisableMusic
MODE256
HIDE_SPRITES
ScrollLayer(0,0)
PAPER 3: BRIGHT 1: CLS
LoadSDBank("gfx/title.bin",0,0,0,18)
ClipLayer2(0,255,0,191)
ClipULA(0,255,0,191)
ShowLayer2(1)
contador = 0
track = MUSIC_TITLE : play_music()
EnableMusic
border 0
contador = 149
dim titulo_idx as ubyte = 0
menu:
control = 1

do
	WaitRetrace(1)
	v = in(31)
	'entropy for the food PRNG: advances each frame while waiting for START to be pressed
	food_seed = food_seed * 181 + 59

	'1: keyboard control'
	if MultiKeys(KEY1)
		control = 0
		EXIT DO
	end if

	'2: joystick control'
	if MultiKeys(KEY2)
		control = 1
		EXIT DO
	end if

	'3: redefine keys'
	if MultiKeys(KEY3)
		redefine_keys()
		'on return, restart the carousel so the menu options are shown immediately
		titulo_idx = 0
		contador = 149
	end if

	'text carousel
	contador = contador + 1
	if contador = 150
		contador = 0
		if titulo_idx = 0 then PRINT AT 23,0; INK 4; BRIGHT 1; PAPER 0; "1:KEYS  2:JOYSTICK  3:REDEFINE ";
		if titulo_idx = 1 then PRINT AT 23,0; INK 4; BRIGHT 1; PAPER 0; "    PROGRAM BY SALVAKANTERO    ";
		if titulo_idx = 2 then PRINT AT 23,0; INK 4; BRIGHT 1; PAPER 0; "    GRAPHICS BY SALVAKANTERO   ";
		if titulo_idx = 3 then PRINT AT 23,0; INK 4; BRIGHT 1; PAPER 0; "        MUSIC BY TACHA         ";
		if titulo_idx = 4 then PRINT AT 23,0; INK 4; BRIGHT 1; PAPER 0; "    MADE WITH NEXT MS ENGINE   ";
		titulo_idx = titulo_idx + 1
		if titulo_idx = 5 then titulo_idx = 0
	end if
loop

'Debounce only ONCE, on exit: inside the loop it consumed key presses (it runs
'for the entire press, so MultiKeys never sees it and the option is ignored
'until the key is pressed again or held). redefine_keys() already ends with its
'propio WaitForNoKey().
WaitForNoKey()

'the start transition (SOUND_START_GAME jingle, hiding Layer 2, clearing and SHOW_DIALOG)
'is now performed at the end of before_game.bas, after the second title screen
'(title2). Here title1 (Layer 2) remains visible and the music keeps playing to chain into title2
'without flicker on the ULA, and so the start sound plays when actually entering the game
