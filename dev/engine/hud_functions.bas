#ifdef SHOW_OBJECTS
sub print_objs()
#if OBJECTS_X < 32
    'red if < 10, green when all 10 TNT have been collected
    if num_objects < 10
        PRINT AT OBJECTS_Y,OBJECTS_X;INK 2;BRIGHT 1;"0"+str(num_objects);INK 4;"/10"
    else
        PRINT AT OBJECTS_Y,OBJECTS_X;INK 4;BRIGHT 1;str(num_objects);INK 4;"/10"
    end if
#endif
end sub
#endif


#ifdef TIMER_ENABLE
#ifdef SHOW_TIMER
sub print_time()
       'red if oxygen <= 15, green otherwise
       if timer_t <= 20
           PRINT AT TIMER_Y,TIMER_X;INK 2;BRIGHT 1;str(timer_t)+" "
       else
           PRINT AT TIMER_Y,TIMER_X;INK 4;BRIGHT 1;str(timer_t)+" "
       end if
end sub
#endif
#endif


#ifdef SHOW_LIVES
sub print_number_of_lives()
       'red if < 2 lives, green otherwise
       if lives < 2
           PRINT AT LIVES_Y,LIVES_X;INK 2;BRIGHT 1;str(lives)+" "
       else
           PRINT AT LIVES_Y,LIVES_X;INK 4;BRIGHT 1;str(lives)+" "
       end if
end sub
#endif


#ifdef SHOW_SCORE
sub print_score()
    dim s as string = str(score_shown)          'call str() only once
    dim x_score as ubyte = SCORE_X + 6 - LEN(s) '6 = field width; right-aligned
    dim zi as ubyte
    'leading zeroes (without clearing first: the number only grows and leaves no remnants)
    if x_score > SCORE_X then
        for zi = SCORE_X to x_score - 1
            print INK 4;BRIGHT 1;at SCORE_Y,zi;"0"
        next zi
    end if
    print INK 4;BRIGHT 1;at SCORE_Y,x_score; s

	if score_shown > next_extra_life
        next_extra_life = next_extra_life + EXTRA_LIFE_SCORE
        PLAYER_LIVES = PLAYER_LIVES + 1
        #ifdef SHOW_LIVES
            print_number_of_lives() 'refresh the HUD when an extra life is earned
        #endif
        PlaySFX (SOUND_EXTRA_LIFE)
	end if
end sub
#endif


#ifdef SHOW_ENERGYBAR
sub print_energy() 
    if player_energy = 0 
        PRINT AT ENERGYBAR_Y,ENERGYBAR_X;"     "
    else
        for uit = 0 to player_energy-1
            PRINT AT ENERGYBAR_Y, uit + ENERGYBAR_X;ink 2;BRIGHT 1;"# "
        next uit
    end if	
end sub
#endif


sub print_hud()
#include "../my/custom_code/game_cc/hud.bas"
#ifdef SHOW_SCORE
    'print_score displays score_shown, so redrawing the HUD when
    'changing floors does NOT jump to the total; the roll continues
    print_hiscore()
    print_score ()
#endif

#ifdef SHOW_ENERGYBAR
    print_energy()
#endif

#ifdef SHOW_LIVES
    print_number_of_lives()
#endif

#ifdef TIMER_ENABLE
#ifdef SHOW_TIMER
    print_time()
#endif
#endif

#ifdef SHOW_OBJECTS
    print_objs()
#endif
end sub


sub add_points (points as uinteger) 'uinteger for scores > 255 (food)
    score = score + points
#ifdef SHOW_SCORE
    print_score()
#endif
end sub


sub update_score_roll()
    'rolling score: +SCORE_ROLL_STEP per frame until it reaches score (does not block the game).
    if score_shown < score
        score_shown = score_shown + SCORE_ROLL_STEP
        if score_shown > score then score_shown = score
        print_score()
        'click every other frame
        'each shot replaces the previous one and stops abruptly when the score stops
        roll_click = 1 - roll_click
        if roll_click = 0 then PlaySFX(SOUND_SCORE_CLICK)
    end if
end sub


sub delete_hud(start_y as ubyte)
    PAPER 3: BRIGHT 1
    for i=start_y to DIALOG_BOTTOM_ROW
        for j=0 to 31
            PRINT AT i,j;" "
        next j
    next i'
end sub

