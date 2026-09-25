'INSERT HERE CODE FOR GAME ENDING'

update_hiscore()
'Explosion sequence
PRINT_HUD
expl_seed = 137
for expl_round = 0 to 23
    ' Load explosion frame (alternate 10/11)
    asm : nextreg $50,34 : nextreg $51,35 : end asm
    direccion = (10 + (expl_round MOD 2)) * 256
    for expl_i = 0 to 4
        Test_SetSprites(1, direccion, expl_i)
    next expl_i
    asm : nextreg $50,$ff : nextreg $51,$ff : end asm
    ' Position 5 simultaneous explosions
    for expl_i = 0 to 4
        expl_seed = expl_seed * 181 + 59
        _x1 = 48 + (expl_seed MOD 192)
        expl_seed = expl_seed * 181 + 59
        _y = 72 + (expl_seed MOD 128)
        UpdateSprite(_x1, _y, expl_i, expl_i, 0, 0)
    next expl_i
    PlaySFX(16) 'trueno'
    pause 6
next expl_round
' Hide explosion sprites
for expl_i = 0 to 4
    RemoveSprite(expl_i, 0)
next expl_i

clear_sprites()
PRINT_HUD
track = MUSIC_ENDING : play_music()
EnableMusic 'MUTE only silences the in-game music, not the ending
'Statistics screen instead of the standard DIALOG
print_stats("MISSION COMPLETE!", "TIME TO RETURN HOME!")


