'main game loop; ends when the playing variable is 0
    
'initialise game variables
game_init ()

#include "../my/custom_code/game_cc/before_game_loop.bas"

do 'game loop 
#ifdef DEBUGGING 'allows changing level by pressing Z/X
    if MultiKeys(KEYX) then level_number = level_number +1
    if MultiKeys(KEYZ) then level_number = level_number -1
#endif
    if press_pause
        SHOW_DIALOG 'ensures that the central strip is visible
        PAPER 0: INK 6
        print at DIALOG_TOP_ROW+1,13;"       "
        print at DIALOG_TOP_ROW+2,13;" PAUSE "
        print at DIALOG_TOP_ROW+3,13;"       "
        WaitForNoKey()
        do
            control_vars()
            if press_pause then EXIT DO
        loop
        WaitForNoKey()
        DELETE_TEXT_AREA
    end if

    if level_completed 
        stage_clear()
        level_number = level_number + 1
        level_completed = 0
        'EXIT THE LOOP IF WE WIN THE GAME'
        if level_number = MAX_LEVELS 'if the last level is somehow passed, end the game
            success = 1: playing = 0
            EXIT DO
        end if
    end if

    if current_level <> level_number
        ClipLayer2(0,0,0,0)
        ShowLayer2(0)
        ' DisableSFX
        #include "../engine/level_screen.bas"
        #include "../my/custom_code/game_cc/before_entering_map.bas" 
        SHOW_SPRITES 'enables the sprite play area

        current_level = level_number
         
        if level_music(level_number) <> track AND NOT changing_floor
            track = level_music(level_number)
        end if
        
        if track <> old_track
            old_track = track
            play_music ()
            if NOT music_muted
                EnableMusic
            end if
        end if
        
#ifdef TILANIMS
        reset_tilanims ()
#endif
        draw_scr() 'draws the screen
        coloca_scroll()
        player_locate()

    ClipLayer2(16,143,SCREEN_Y_OFFSET*16,SCREEN_Y_OFFSET*16+SCREENS_H*16-1) 'x1=16 to align with pixel 32 of the 320x256 buffer
        ShowLayer2(1)
        
        if dialog_shown = 0 then DIALOG 5: dialog_shown = 1   
    end if

#ifdef TIMER_ENABLE
    if player_status < DYING_ST then run_timer() 'runs the timer while the player is not dying
#endif

    'HALF TIME AND QUARTER TIME
    half_life = NOT half_life
    if half_life
        half_life2 = NOT half_life2
    end if

    'tile animation
#ifdef TILANIMS
    AnimateTiles()
#endif

    WaitRetrace(1) 'waits for the next frame or interrupt
    
    if haz_scroll then do_x_scroll()
    haz_scroll = 0
    'skip one frame out of every six in 60Hz mode to maintain the original game speed
    if contador_frecuencia60 = 6 AND VarFrec = 60 : WaitRetrace(1): end if

    'enemy functions
    EnemiesMove()

    'projectile functions
#ifdef PLAYER_CAN_FIRE
    BulletsPlayerMove()
#endif
#ifdef ENEMY_BULLETS
    EnemyBulletsMove()
#endif

    'player functions
    PlayerMove() 
    PlayerAnimation()
    UpdatePlayer()
    check_death() 'checks whether the death animation has finished

    #include "../my/custom_code/game_cc/ingame_routines.bas"
    
    update_score_roll() 'animates the rolling score every frame

    fin_playing_loop:
    loop until playing = 0

    PAPER 3: BRIGHT 1
    CLS

    if success = 1 
        fin()
    else
        game_over ()
    end if
