'/ENTER HERE YOUR EXTRA ROUTINES WITHIN THE GAMELOOP'

' // CHEAT // Press E to force the ending (COMMENT OUT when not needed)
'if MultiKeys(KEYE) then END_GAME

'MUTE toggle (BUTTON 2 / default M)
if press_fire2 AND fire2_edge = 0
    fire2_edge = 1
    if music_muted = 0
        DisableMusic
        music_muted = 1
    else
        EnableMusic
        music_muted = 0
    end if
end if
if NOT press_fire2 then fire2_edge = 0

print_screen_name()

'Check whether the player touches a door
check_door()

'DETONATOR: activate ending if the TNT is placed (floor 0, screen 0)
if tnt_placed = 1
    IF PLAYER_IN_ZONE(1,7,1,7) 'Detonator zone on floor 0, screen 0
        END_GAME
    END IF
end if

'PLACE TNT in EXPLOSIVES STOCKPILE (floor 5)
if tnt_placed = 0 AND num_objects = 10
    IF PLAYER_IN_ZONE(66,56,70,56)
        tnt_placed = 1
        PlaySFX(5)
        add_points(200) 'reward for collecting and placing all 10 TNT
    END IF
end if

'Draw TNTs once (when placing them or returning to floor 5)
if tnt_placed = 1 AND tnt_drawn = 0 AND level_floor = 5
    for tnt_i = 0 to 4
        actualizar_tile(66 + tnt_i, 55, TNT_TILE)
        actualizar_tile(66 + tnt_i, 56, TNT_TILE)
    next tnt_i
    tnt_drawn = 1
end if

'Feedback when stepping on the placement area (floor 5)
if level_floor = 5 AND tnt_msg_shown = 0
    IF PLAYER_IN_ZONE(66,56,70,56)
        if num_objects = 10 then DIALOG 3 else DIALOG 4
        tnt_msg_shown = 1
        prev_screen = 255 'Force the screen name to be redrawn after the DIALOG
        PRINT_HUD
    END IF
end if

'Reset flags when leaving floor 5
if level_floor <> 5
    tnt_drawn = 0
    tnt_msg_shown = 0
end if




