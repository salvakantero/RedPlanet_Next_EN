' CUSTOM HUD LABELS

LoadSD("gfx/hud.scr",$4000,6912,0)
'hud.scr fills the whole screen, and its rows below the HUD are opaque black.
'Clear them to transparent (paper 3) as far as the bottom edge of the dialogue box,
'so the game is visible in the area above the centred box (not just where the text is).
delete_hud(HUD_HEIGHT*2)
CROP_ULA

ink 7
bright 0
paper 0

print at SCORE_Y,1;"HIGH:"
print at SCORE_Y,SCORE_X-6;"SCORE:"

print_ammo()
print_keys()
