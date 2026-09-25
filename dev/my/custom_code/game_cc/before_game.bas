'Write your custom code here before starting the game (when leaving the menu).

'Show the second title screen (title2: information/help) until a key is pressed.
'title_screen leaves title1 (Layer 2) visible with the music playing; load title2 here over
'the SAME bank 18 without hiding the layer, replacing the image without ULA flicker.
'Before switching, clear the ULA to the TRANSPARENT colour (paper 3 = magenta) to erase
'the carousel credits, printed on paper 0 (OPAQUE black), which would remain "frozen"
'over title2. NOTE: title2's black background is part of the Layer 2 image itself; the ULA must be
'in the transparent colour so Layer 2 remains visible. Clearing to black would make it opaque and cover everything.
PAPER 3: CLS
LoadSDBank("gfx/title2.bin",0,0,0,18)
ClipLayer2(0,255,0,191)
ClipULA(0,255,0,191)
ShowLayer2(1)
'blinking text on line 23 (same style as the title carousel), centred.
'It alternates between showing it for ~0.5s (paper 0) and erasing it for ~0.5s with transparent spaces
'(paper 3) so the Layer 2 image underneath remains visible.
dim blink_c as ubyte = 0
dim blink_on as ubyte = 1
PRINT AT 23,0; INK 4; BRIGHT 1; PAPER 0; "          PRESS ANY KEY        ";
do
    WaitRetrace(1)
    v = in(31)
    blink_c = blink_c + 1
    if blink_c = 25
        blink_c = 0
        blink_on = 1 - blink_on
        if blink_on = 1
            PRINT AT 23,0; INK 4; BRIGHT 1; PAPER 0; "          PRESS ANY KEY        ";
        else
            PAPER 3: PRINT AT 23,0; "                               ";
        end if
    end if
loop until GetKeyScanCode <> 0 OR v <> 0
WaitForNoKey()

'Game start transition (moved from title_screen.bas): the start jingle plays,
'when actually entering the game, hide Layer 2 and clip the ULA for the score display.
DisableMusic
PlaySFX(SOUND_START_GAME)
pausa(50)
CLS
ShowLayer2(0)
CLS256(0)
SHOW_DIALOG 'Clips the ULA to the score/dialogue area for the game

'Initialise inventory
player_ammo = 5
player_keys = 0 'Keys to open doors

'Initialise visited-screen tracking
for i = 0 to TOTAL_SCREENS - 1
    visited(i) = 0
next i
visited_count = 0 'Visited-screen counter
new_hiscore = 0
tnt_placed = 0 'TNT already placed (to activate the detonator)
tnt_drawn = 0 'TNT already drawn (to avoid redrawing every frame)
tnt_msg_shown = 0 'TNT message already shown (to avoid showing it every frame)
music_muted = 0
fire2_edge = 0 'Tracks button 2 presses for muting music
dialog_shown = 0 'Controls whether to show the help at the start of the game'
