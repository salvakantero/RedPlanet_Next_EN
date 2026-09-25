'initialise the level enemies
sub reset_enems()
    for enit = 0 to MAX_ENEMS-1
        enemies_t (enit) = 0
        en_an_facing (enit) = 0
        obj_collected(enit) = 0 'reset collected-object tracking
    next enit
    'invalidate the floor list cache
    cached_floor = 255
    floor_enems_count = 0
end sub


'integer PRNG (16-bit LCG). Returns a value from 0..n-1.
'food_seed is seeded from human reaction time on the title screen and changes
'on every call; x_scroll is mixed in as extra entropy and the HIGH byte is used
'RANDOMIZE/RND from BORIEL is not used to avoid introducing FLOATS into the project
function rand_mod(n as ubyte) as ubyte
    food_seed = food_seed * 181 + 59 + cast(uinteger, x_scroll)
    return cast(ubyte, (food_seed >> 8) MOD n)
end function


'resolve a collected object. Roll a 0..4 die:
'0/1/2 (60%) -> random food type appears (donut/cake/burger)
'3/4 (40%) -> nothing. Equivalent to random.randint(5,9) in the Pi version
'obj_collected becomes 2 in both cases, so the object is not evaluated again.
sub convert_object_to_food(idx as ubyte)
    dim roll as ubyte = rand_mod(5) '0..4 (see rand_mod)
    obj_collected(idx) = 2
    if roll < 3 '60% -> food appears
        en_an_state(idx) = ENEM_NORMAL
        enemies_life(idx) = 1
        enemies_maxlife(idx) = 1
        if roll = 0 then enemies_spritenum(idx) = SPR_DONUT
        if roll = 1 then enemies_spritenum(idx) = SPR_CAKE
        if roll = 2 then enemies_spritenum(idx) = SPR_BURGER
    end if
    'roll 3/4 -> 40% nothing: the object becomes invisible (ENEM_NO_RESPAWN), with no food
end sub


'rebuild the enemy index list for the current floor
'called only when changing floors (not every frame) to speed up EnemiesMove
sub rebuild_floor_enem_list()
    floor_enems_count = 0
    if total_enemies = 0 then return
    for enit = 0 to total_enemies-1
        if enemies_npant(enit) = level_floor
            floor_enems_idx(floor_enems_count) = enit
            floor_enems_count = floor_enems_count + 1
        end if
    next enit
    'convert collected objects into food when re-entering the floor
    for enit = 0 to total_enemies-1
        if enemies_npant(enit) = level_floor
            if enemies_t(enit) = OBJECT_TYPE AND en_an_state(enit) = ENEM_NO_RESPAWN AND obj_collected(enit) = 1
                convert_object_to_food(enit)
            end if
        end if
    next enit
end sub


sub reset_enems_extra_vars()
    for enit = 0 to MAX_ENEMS-1
        ENEMY_VAR1 = 0
        ENEMY_VAR2 = 0
        ENEMY_VAR3 = 0
        ENEMY_VAR4 = 0
        ENEMY_VAR5 = 0
    next enit
end sub


sub enemy_start_code()
    #include "../my/custom_code/enemies_cc/enems_start.bas"
end sub


'load level enemy data and store it in the variables
sub enems_load ()
    total_enemies = peek(ENEMIES_BUFFER)
    for enit = 0 to total_enemies-1
		en_an_frame (enit) = 0
		en_an_state (enit) = ENEM_NORMAL
        enoffset = cast (uinteger, enit) * 12
        enemies_x (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset))<<4
        enemies_y (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset + 1) MOD SCREENS_H)<<4
        enemies_x1 (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset + 2))<<4
        enemies_y1 (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset + 3) MOD SCREENS_H)<<4
        enemies_x2 (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset + 4))<<4
        enemies_y2 (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset + 5) MOD SCREENS_H)<<4

        'sort the X and Y limits independently
        if enemies_x1 (enit) > enemies_x2 (enit) then
           enemies_x1 (enit) = cast (uinteger, peek(ENEMIES_DATA + enoffset + 4))<<4
           enemies_x2 (enit) = cast (uinteger, peek(ENEMIES_DATA + enoffset + 2))<<4
        end if
        if enemies_y1 (enit) > enemies_y2 (enit) then
           enemies_y1 (enit) = cast (uinteger, peek(ENEMIES_DATA + enoffset + 5) MOD SCREENS_H)<<4
           enemies_y2 (enit) = cast (uinteger, peek(ENEMIES_DATA + enoffset + 3) MOD SCREENS_H)<<4
        end if

        enemies_mx (enit) = peek(ENEMIES_DATA + enoffset + 6)'initial X speed
        enemies_mx_ini (enit) = abs(enemies_mx (enit))'absolute value of initial X speed
        enemies_my (enit) = peek(ENEMIES_DATA + enoffset + 7) 'initial Y speed
        enemies_my_ini (enit) = abs(enemies_my (enit))'absolute value of initial Y speed
        enemies_t (enit) = peek(ENEMIES_DATA + enoffset + 8) 'enemy type
        enemies_life (enit) = peek(ENEMIES_DATA + enoffset + 10) 'enemy hit points
        enemies_maxlife (enit) = enemies_life (enit) 'enemy maximum hit points
        enemies_spritenum (enit) = peek(ENEMIES_DATA + enoffset + 11) 'sprite number in sprite memory for this enemy
        enem_vy (enit) = 0 'reset jump or oscillator speed
        en_an_fps (enit) = DEFAULT_ENEM_FPS
 		en_an_num_frames (enit) = 1
        enemies_npant (enit) = peek(ENEMIES_DATA + enoffset + 1)/SCREENS_H ' floor number (level_floor) where it is'
        _en_t = enemies_t (enit)
        if _en_t = 255 'type 255 is the default player position when loading a map
            if teleport = 0 
                player_x_ini = peek(ENEMIES_DATA + enoffset)
                player_y_ini = peek(ENEMIES_DATA + enoffset + 1) MOD SCREENS_H
                level_floor = peek(ENEMIES_DATA + enoffset + 1)/SCREENS_H
            end if
            enemies_t (enit) = 0 'clear the type because this is not an enemy'
            _en_t = 0
        end if
        enemy_start_code()
	next enit
    teleport = 0
end sub


sub aplicar_gravedad_enem()
    'apply gravity'
    _en_vy = _en_vy + ENEMY_GRAVITY
    if  _en_vy > ENEMY_MAX_VY then _en_vy = ENEMY_MAX_VY
    _en_my = cast(byte, (_en_vy >> 4))
end sub


sub aplicar_gravedad_invertida_enem()
    'apply inverted gravity'
    _en_vy = _en_vy - ENEMY_GRAVITY
    if  _en_vy < -ENEMY_MAX_VY then _en_vy = -ENEMY_MAX_VY
    _en_my = cast(byte, (_en_vy >> 4))
end sub


function pisa_suelo_enem() as ubyte
    cx1 = _en_x : cx2 = cx1+15
    cy1 = _en_y + 16 : cy2 = cy1
    check_n_points(2)
    if ct1 bAND 12 OR ct2 bAND 12 then return 1
    return 0
end function


'MOVE ENEMIES'

sub EnemiesMove()
    if total_enemies = 0 then return
    enviit = 0
    on_ground = 0

#ifdef ENABLE_PLATFORMS    'reset platform data
    plataforma_vx = 0: plataforma_vy = 0
#endif

    'if the floor changes, rebuild its enemy list
    if cached_floor <> level_floor
        rebuild_floor_enem_list()
        cached_floor = level_floor
    end if

    'iterate only through enemies on the current floor
    if floor_enems_count > 0 then
    for fidx = 0 to floor_enems_count-1
        enit = floor_enems_idx(fidx)
        active = 0
        'copy data into auxiliary variables
        _en_x = enemies_x(enit)
        _en_t = enemies_t(enit)
        enem_status = en_an_state (enit)
        'skip those outside the screen or of type 0
        if _en_x > x_scroll+320 OR _en_x < x_scroll
#ifdef RESPAWN_ENEMIES
            if enem_status = ENEM_DEAD
                en_an_state (enit) = ENEM_NORMAL : enemies_life(enit) = enemies_maxlife(enit)
                enemy_start_code()
            end if
#endif
            'convert a collected object into food when it leaves the screen
            if _en_t = OBJECT_TYPE AND enem_status = ENEM_NO_RESPAWN AND obj_collected(enit) = 1
                convert_object_to_food(enit)
            end if
            CONTINUE FOR
        end if

        'also skip collected/depleted objects (state 99) on screen
        'they are invisible and do not collide, so they do not use a MAX_SPRITES_ON_SCREEN slot.
        if _en_t = 0 OR enem_status = ENEM_DEAD OR enem_status = ENEM_NO_RESPAWN then CONTINUE FOR

        'copy the remaining data into auxiliary variables
        _en_y = enemies_y(enit)
        _en_x1 = enemies_x1(enit)
        _en_y1 = enemies_y1(enit)
        _en_x2 = enemies_x2(enit)
        _en_y2 = enemies_y2(enit)
        _en_mx = enemies_mx(enit)
        _en_my = enemies_my(enit)
        _en_vy = enem_vy(enit)
        _en_facing = en_an_facing(enit)
        _en_sprnum = enemies_spritenum(enit)
        _en_life = enemies_life(enit)

        active = 0
        if  _en_t  'if the enemy type is not 0, it is active
            active = 1
            diferencia = (_en_x- x_scroll) - gpx 'calculate the X position relative to the player
#ifdef ENEMY_SPRITES_16X32
            ENEMY_EXTRA_TOP_BB = 0
#endif
            #include "../my/custom_code/enemies_cc/enems_loop.bas"
        end if

        animate_enemy()
        draw_current_enemy()

        if active = 1
            if enem_status < ENEM_DEAD 'Not dead
                'COLLISION WITH PLAYER'
                #include "collisions.bas"
            end if
        end if

        'write the updated values back to the arrays
        enemies_x(enit) = _en_x
        enemies_y(enit) = _en_y
        enemies_x1(enit) = _en_x1
        enemies_y1(enit) = _en_y1
        enemies_x2(enit) = _en_x2
        enemies_y2(enit) = _en_y2
        enemies_mx(enit) = _en_mx
        enemies_my(enit) = _en_my
        enem_vy(enit) = _en_vy
        enemies_t(enit) = _en_t
        en_an_facing(enit) = _en_facing
        enemies_spritenum(enit) = _en_sprnum
        enemies_life(enit) = _en_life
        en_an_state (enit) = enem_status

        enviit = enviit + 1
        if enviit = MAX_SPRITES_ON_SCREEN then EXIT FOR 'up to X enemies (or objects) on screen
    next fidx
    end if 'end if floor_enems_count > 0

    while enviit < MAX_SPRITES_ON_SCREEN   'up to X enemies (or objects) on screen
        RemoveSprite(ENEMIES_FIRST_SP_VRAM+enviit, 0) 
#ifdef ENEMY_SPRITES_16X32
        RemoveSprite(ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit, 0) 
#endif
        enviit = enviit + 1
    wend
end sub


sub set_enem_animation (tf as ubyte, fpi as ubyte, f0 as ubyte, f1 as ubyte = 0, f2 as ubyte =0, f3 as ubyte =0, f4 as ubyte =0, f5 as ubyte =0, f6 as ubyte =0, f7 as ubyte =0)    
    en_an_num_frames(enit) = tf 'total number of animation frames
    en_an_fps(enit) = fpi 'number of frames between enemy animation changes
    en_an_frame(enit) = 0
    en_an_subframe(enit) = 0
    'store the frame list in enem_animation
    enem_animation (enit,0) = f0
#if MAX_FRAMES_ENEMIES > 1
    enem_animation (enit,1) = f1
#endif
#if MAX_FRAMES_ENEMIES > 2
    enem_animation (enit,2) = f2
#endif
#if MAX_FRAMES_ENEMIES > 3
    enem_animation (enit,3) = f3
#endif
#if MAX_FRAMES_ENEMIES > 4
    enem_animation (enit,4) = f4
#endif
#if MAX_FRAMES_ENEMIES > 5
    enem_animation (enit,5) = f5
#endif
#if MAX_FRAMES_ENEMIES > 6
    enem_animation (enit,6) = f6
#endif
#if MAX_FRAMES_ENEMIES > 7
    enem_animation (enit,7) = f7
#endif
end sub


sub animate_enemy()
    if enem_status <> ENEM_DAMAGED
        'frame animation (enemies and platforms)
        en_an_subframe(enit) =  en_an_subframe(enit) +1
        if en_an_subframe(enit) >= en_an_fps(enit)
            en_an_subframe(enit) = 0
            en_an_frame(enit) =  en_an_frame(enit) + 1
            if  en_an_frame(enit) = en_an_num_frames(enit)
                en_an_frame(enit) = 0
            end if
        end if
        if _en_t <> PLATFORM_TYPE
            if enem_status = ENEM_DYING 'Dying state
                _en_mx = 0
#ifdef ENEMY_DEATH_BOUNCE
                aplicar_gravedad_enem()
                mover_enemigo()
#else
                enem_counter (enit) =  enem_counter (enit) -1
                if enem_counter (enit) = 0 then _en_y = 1+SCREENS_H*16
#endif
                if _en_y > SCREENS_H*16  'LEAVES THROUGH THE BOTTOM OF THE SCREEN
                    'reset enemy position and speed
                    _en_x = enemies_x1(enit)
                    _en_y = enemies_y1(enit)
                    _en_mx = enemies_mx_ini(enit)
                    _en_my = enemies_my_ini(enit)
                    _en_vy = 0
                    enem_status = ENEM_DEAD 'fully dead state
                end if
            end if
        end if
    else 'enem_status = ENEM_DAMAGED, enemy damaged
        enem_counter (enit) =  enem_counter (enit) -1
        if enem_counter (enit) = 0 
            if _en_life > 0
                enem_status = ENEM_NORMAL
                #include "../my/custom_code/enemies_cc/enems_after_hit.bas"
            else
                enem_status = ENEM_DYING
#ifdef ENEMY_DEATH_BOUNCE                    
                _en_vy = -ENEMY_DEATH_BOUNCE
#else
                enem_counter (enit) = ENEMY_DYING_TIME
#endif
                #include "../my/custom_code/enemies_cc/enems_die.bas"
                en_an_subframe(enit) = 0
                en_an_frame(enit) = 0
                PlaySFX(SOUND_ENEMY_DIE)
            end if
        end if
    end if
    spnum = enem_animation (enit, en_an_frame(enit)) + _en_sprnum
end sub


sub draw_current_enemy()
    asm : nextreg $50,34 : nextreg $51,35 : end asm  'page in banks 34 and 35
    direccion = $0000+(256*spnum)
    Test_SetSprites(1,direccion,ENEMIES_FIRST_SP_VRAM+enviit) 'load the frame at direccion into sprite 10+enviit
#ifdef ENEMY_SPRITES_16X32
    if (ENEMY_EXTRA_TOP_BB>0)
        direccion = $0000+(256*spnum-(16*256))
        Test_SetSprites(1,direccion,ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit) 'load the frame at direccion into sprite 10+MAX_SPRITES_ON_SCREEN+enviit'
    end if
#endif
    asm : nextreg $50,$ff : nextreg $51,$ff : end asm   'restore the default banks
    if _en_t <> 0 AND enem_status < ENEM_DEAD 
        _x1 = _en_x - x_scroll
        _y = _en_y + (SCREEN_Y_OFFSET<<4) 'draw sprites offset because the game area has been shifted
        UpdateSprite(_x1, _y, ENEMIES_FIRST_SP_VRAM+enviit, ENEMIES_FIRST_SP_VRAM+enviit, _en_facing, 0) 
#ifdef ENEMY_SPRITES_16X32
        if (ENEMY_EXTRA_TOP_BB>0)
            UpdateSprite(_x1, _y-16, ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit, ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit, _en_facing, 0) 'top part of the 16x32 enemy sprite
        else
            RemoveSprite(ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit, 0)  'remove inactive enemies
        end if
#endif
    else
        RemoveSprite(ENEMIES_FIRST_SP_VRAM+enviit, 0)  'remove inactive enemies
#ifdef ENEMY_SPRITES_16X32
        RemoveSprite(ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit, 0)  'remove inactive enemies
#endif
    end if
end sub


'ENEMY COLLISIONS WITH WALLS
function mons_col_sc_x() as ubyte
    if _en_mx > 0 then
        cx1 = _en_x + 15 
    else
         cx1 = _en_x
    end if
    cx2 = cx1
    cy1 = _en_y
    cy2 = _en_y + 15
    check_n_points(2)
    if _en_t <>  5
        if ct1 = 8 OR ct2 = 8
            return 1
        end if
    else
        if ct1 bAND 9 OR ct2 bAND 9
            return 1
        end if
    end if
    return 0
end function


function mons_col_sc_y() as ubyte
    if _en_my > 0 then
        cy1 = _en_y + 15 
    else
         cy1 = _en_y
    end if
    cy2 = cy1
    cx1 = _en_x
    cx2 = _en_x + 15
    check_n_points(2)
    if ct1 = 8 OR ct2 = 8
        return 1
    end if
    return 0
end function


'////// ENEMY FUNCTIONS //////
sub mover_enemigo()
    'state 0: normal / 1: damaged / 10: dying / 12: dead
    if enem_status < ENEM_DEAD
        _en_x = _en_x + _en_mx
        _en_y = _en_y + _en_my
    end if
    'set facing and base frame for animated enemies
    if _en_t <> PLATFORM_TYPE
        if _en_mx < 0                                                                                           
            _en_facing = 8
        elseif _en_mx > 0                                                                                                                                                                           
            _en_facing = 0
        elseif _en_my < 0 'vertical linear enemies face either way                                                                                      
            _en_facing = 8                                                                                      
        elseif _en_my > 0                                                                                       
            _en_facing = 0                                                                                      
        end if
    end if
end sub


#ifdef FANTYS
sub mover_fantasma()
        active = 1
        enemies_x_fanty(enit) = _en_x << 4
        enemies_y_fanty(enit) = _en_y << 4
        if diferencia < 0 
            enemies_mx_fanty(enit) = enemies_mx_fanty(enit) + FANTYS_ACELERACION
            if enemies_mx_fanty(enit) > FANTYS_MAX_VEL then enemies_mx_fanty(enit) = FANTYS_MAX_VEL
        else 
            enemies_mx_fanty(enit) = enemies_mx_fanty(enit) - FANTYS_ACELERACION
            if enemies_mx_fanty(enit) < -FANTYS_MAX_VEL then enemies_mx_fanty(enit) = -FANTYS_MAX_VEL
        end if
        diferencia = _en_y - gpy
        if diferencia < 0 
            enemies_my_fanty(enit) = enemies_my_fanty(enit) + FANTYS_ACELERACION
            if enemies_my_fanty(enit) > FANTYS_MAX_VEL then enemies_my_fanty(enit) = FANTYS_MAX_VEL
        else 
            enemies_my_fanty(enit) = enemies_my_fanty(enit) - FANTYS_ACELERACION
            if enemies_my_fanty(enit) < -FANTYS_MAX_VEL then enemies_my_fanty(enit) = -FANTYS_MAX_VEL
        end if

        _en_mx =  enemies_mx_fanty(enit)
        _en_my =  enemies_my_fanty(enit)

        enemies_x_fanty(enit) =  enemies_x_fanty(enit) + _en_mx
        enemies_y_fanty(enit) =  enemies_y_fanty(enit) + _en_my

        _en_x = enemies_x_fanty(enit) >> 4
        _en_y = enemies_y_fanty(enit) >> 4
        if _en_y < 0 then  _en_y = 0
        if _en_y > 192 then _en_y = 192
        
        'facing
        if _en_mx >= 0
            _en_facing = 0
        else 
            _en_facing = 8
        end if
end sub
#endif


sub comprobar_limites()
    if _en_x <= _en_x1 then 
        _en_mx = enemies_mx_ini(enit)
    else if _en_x >= _en_x2
        _en_mx = -enemies_mx_ini(enit)
    end if

    if _en_vy = 0
        if _en_y <= _en_y1 then 
            _en_my = enemies_my_ini(enit)
        else if _en_y >= _en_y2
            _en_my = -enemies_my_ini(enit)
        end if
    end if
end sub


sub colision_enem_tiles()
#ifdef WALLS_STOP_ENEMIES
    if mons_col_sc_x()
        _en_mx = -_en_mx
        _en_x = _en_x + 7
        _en_x = _en_x bAND 0xfff0
    end if
#endif

#ifdef WALLS_STOP_ENEMIES
    if mons_col_sc_y()
        _en_my = -_en_my
    end if
#endif
end sub


sub enem_rebote_vertical()
    if _en_vy >= 0
            _en_y = _en_y bAND 0xfff0
            _en_vy = -ENEM_JUMP_POWER
    end if
end sub


sub enem_recibe_golpe(fuerza as ubyte)
    _en_life = _en_life - fuerza
    enem_counter (enit) = 4
    enem_status = ENEM_DAMAGED 'damaged state
    enemies_mx_fanty(enit) = 0
    'PlaySFX(SOUND_ENEMY_DAMAGED)
    #include "../my/custom_code/enemies_cc/enems_before_hit.bas"
end sub


#ifdef OSCILLATORS
sub mover_sube_baja()
    if _en_y < _en_y1-16
        aplicar_gravedad_enem()
    else
        aplicar_gravedad_invertida_enem()
    end if
end sub
#endif
