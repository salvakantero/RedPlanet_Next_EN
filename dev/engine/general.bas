'GENERAL SUBS AND FUNCTIONS

Sub Test_SetSprites(byVal Total as ubyte, spraddress as uinteger, byval firstSprite as ubyte)
  ' uploads sprites from a memory address to sprite memory
  ' Total = number of sprites, spraddress = memory address
  ' works with 8-bit and 4-bit sprites
  ASM 
    ld d,(IX+5)
    ;select slot 0
    ;xor a        
        ld a,(ix+9)
    ld bc, $303b
    out (c), a

    ld b,d                ; number of sprites to send

    ld l, (IX+6)
    ld h, (IX+7)
sploop:
    push bc
    ld bc,$005b          
    otir
    pop bc 
    djnz sploop
  end asm 
end sub

' QTILE: aux1 returns the tile type (beh) at the x_punto,y_punto tile coordinates
'        aux2 returns the tile number in the tileset (position 0 to 127)
sub qtile(byval x_punto as uinteger, byval y_punto as uinteger)
  tilenum = x_punto + (ancho_mapa *cast(uinteger,y_punto+first_row)) 'without the cast it becomes ubyte values
  ' calculate the screen tile position x_punto + y_punto*H
  ' (H = number of tiles per row in the play area)
  asm : di: nextreg $56,90 : nextreg $57,91 : end asm 
  p = peek(tilenum + MAP_BUFFER) 'read the tile number at that position
  asm : nextreg $56,0 : nextreg $57,1 : ei :end asm 
  aux1 = behs(p) 'read and store the tile type from the behs array
  aux2 = p
end sub


'CHECK_N_POINTS: returns the behaviour (beh) of the tile at two points (ct1 and ct2)
'defined by their x,y pixel coordinates: cx1,cy1 for ct1 and cx2,cy2 for ct2
sub check_n_points (num_points as ubyte)
    ' Point ct1
    qtile(cx1 >> 4, cy1 >> 4)
    ct1 = aux1

    if num_points > 1
      ' Point ct2
      qtile(cx2 >> 4, cy2 >> 4)
      ct2 = aux1
    end if

    if num_points > 2
      ' Point ct3
      qtile(cx3 >> 4, cy3 >> 4)
      ct3 = aux1
    end if
end sub


sub pausa(tiempo as uinteger) 'thanks to Duefectu
    while tiempo > 0
      asm 
        push bc
        ld b,117
  pausa_Bucle1:        
          push bc
          ld b,255
  pausa_Bucle2:
            nop
            djnz pausa_Bucle2
          pop bc
          djnz pausa_Bucle1
        pop bc
      end asm
      tiempo = tiempo - 1
    wend
end sub


'MUSIC AND SOUND

'initialise sound and music players
sub init_sound()
  ' MUSIC
  LoadSDBank("music/0.pt3",0,0,0,51) 'load music.pt3 into bank 51
  LoadSDBank("music/vt24000.bin",0,0,0,50) 'load the music player into bank 50
  LoadSDBank("music/fx.afb",0,0,0,52) 'load the SFX afb file into bank 52
  ' SFX
  InitSFX(52) 'initialise the SFX engine
  'AY1 (SFX) in mono, AY0 (music) in stereo
  ' NextReg $09 bits 7,6,5 = AY2/AY1/AY0 mono respectively.
  NextReg($09, $40)
  InitMusic(50,51,0000) 'initialises the music engine: 50 contains the player, 51 the PT3, 0000 the offset in bank 51
  SetUpIM() 'initialise the IM2 code
  EnableSFX 'enable AYFX; use DisableSFX to stop
  DisableMusic
end sub


'play a song from the beginning (track = song number). Save songs as 1.pt3, 2.pt3, etc.'
sub play_music ()
	LoadSDBank("music/"+ str(track) +".pt3",0,0,0,51)
	InitMusic(50,51,0000)
end sub


' read the vertical refresh frequency
sub get_frecuency()
    contador_frecuencia60 = 6
    v=GetReg($05) bAND %100
    if v=0 then
      VarFrec=50  ' 50Hz
    else
      VarFrec=60  ' 60Hz
    end if
end sub


sub NoOptimizar()
    print VarFrec
    print contador_frecuencia60
end sub


'force Kempston MD1 3/6-button joystick
sub set_joystick()
v = GetReg($05)
v = v bAND %101
v = v bOR %01001000 
NextRegA($05,v)
end sub

'configure the Next registers
sub set_registers()
  NextReg($7,$3) 'set 28MHz
  NextReg($15,%01110011) 'configure sprites, L2 and ULA
  NextReg(GLOBAL_TRANSPARENCY_NR_14, GLOBAL_TRANSPARENT_COLOR) 'global transparent colour (including 8-bit tiles)
  NextReg(SPRITE_TRANSPARENCY_I_NR_4B, SPRITES_TRANSPARENT_COLOR) 'transparent colour for sprites
  NextReg(LAYER2_RAM_BANK_NR_12,9)
end sub


'load the custom palette'
sub load_palettes()
  LoadSD("pal/sprites.pal",PALETTE_BUFFER,512,0)
  NextReg($43,%00100000)
  PalUpload(PALETTE_BUFFER,0,0)
  LoadSD("pal/tiles.pal",PALETTE_BUFFER,512,0)
  NextReg($43,%00010000)
  PalUpload(PALETTE_BUFFER,0,0)
end sub


'level completed
sub stage_clear ()
#include "../my/custom_code/game_cc/stage_clear.bas"
  CROP_ULA 'restore the ULA to its normal state (show the HUD only)
end sub
 

'remove all sprites
sub clear_sprites()
  for i = 0 to 96
    RemoveSprite(i,0)
  next i
end sub


'detect collision between the player and enemies
function collide () as ubyte
	#ifdef SMALL_COLLISION_ENEM
    if (gpx + 10 >= cx2 AND gpx <= cx2 + 10 AND gpy + 10 >= cy2 - ENEMY_EXTRA_TOP_BB AND gpy - PLAYER_EXTRA_TOP_BB <= cy2 + 10)
	#else
		if (gpx + 13 >= cx2 AND gpx <= cx2 + 13 AND gpy + 13 >= cy2 - ENEMY_EXTRA_TOP_BB AND gpy - PLAYER_EXTRA_TOP_BB  <= cy2 + 13)
	#endif
      return 1
    else 
      return 0
  end if
end function


' detects collision between a point and the player (for example, enemy bullets)
function point_collide () as ubyte
	#ifdef SMALL_COLLISION_SHOTS
		if (cx2 > gpx  AND cx2 < gpx+12 AND cy2 > gpy + 4- PLAYER_EXTRA_TOP_BB AND cy2 < gpy+12)
	#else
		if (cx2 > gpx  AND cx2 < gpx+15 AND cy2 > gpy- PLAYER_EXTRA_TOP_BB AND cy2 < gpy+15)
	#endif
      return 1
    else 
      return 0
  end if
end function


'ANIMATED TILES
#ifdef TILANIMS
  sub AnimateTiles()
    tiles_subframe = tiles_subframe + 1
    if tiles_subframe = TILANIM_FREQUENCY 'change tile every n frames
      tiles_subframe = 0
      tiles_frame = tiles_frame + 1
      if tiles_frame = MAX_FRAMES_TILANIM 
          tiles_frame = 0
      end if

      for tile_id = 0 to MAX_TILANIMS
        _t = tiles_animados_t (tile_id) 
        if _t = 255 then EXIT FOR
        _x = tiles_animados_x (tile_id)
        _y = tiles_animados_y (tile_id)
        _t = _t + tiles_frame 
        update_tile(0)
      next tile_id
    end if
  end sub
#endif


sub game_over ()
    'replace the gameover.bin image with DIALOG
    update_hiscore()
    clear_sprites()
    PRINT_HUD
    track = MUSIC_GAMEOVER : play_music()
    EnableMusic 'MUTE only silences in-game music, not game over
    'statistics screen instead of the standard DIALOG
    print_stats("*** GAME OVER ***", "TRY AGAIN!")
end sub


sub fin()
#include "../my/custom_code/game_cc/game_ending.bas"
end sub


sub ResetScroll320()
  asm
  nextreg $16,0 ;this register moves Layer 2 from 0 to 255 pixels
  nextreg $71,0 ;this register uses bit 0 to move it up to 319 in 320x256 mode
  end asm
end sub


#ifdef TIMER_ENABLE
sub time_over ()
#include "../my/custom_code/game_cc/time_up.bas"
end sub


sub run_timer()
    if timer_zero 
        time_over ()
        timer_zero = 0
        #ifdef TIMER_AUTO_RESET 			
            timer_t = TIMER_INITIAL
        #endif 
    end if
    ' Timer
    if timer_on AND timer_t
        timer_count = timer_count + 1
        if timer_count = timer_frames
            timer_count = 0
            timer_t = timer_t-1
            print_time()
            if timer_t = 0 : timer_zero = 1 : end if
        end if
    end if
end sub

#endif


sub new_page()
  WaitForNoKey()
  WaitKey()
  borra_cadena() 
  xc = 1 : yc = DIALOG_TOP_ROW + 1
end sub


sub print_cadena(salto_linea as ubyte)
    borra_cadena()
    'SHOW_DIALOG
    xc = 1 : yc = DIALOG_TOP_ROW + 1 : contador_cadena = 0
    do
      caracter = CHR(peek(TXT_BUFFER + contador_cadena))
      if caracter = "*" OR contador_cadena = 512
        EXIT DO
      end if
      if caracter = "%" 
        xc = 1
        yc = yc + salto_linea
        if yc > DIALOG_BOTTOM_ROW - 1 then new_page()
      else
        if xc = 31 then xc = 1 : yc = yc + salto_linea
        if yc > DIALOG_BOTTOM_ROW - 1 then new_page()
        PRINT AT yc,xc;PAPER TEXT_PAPER;INK TEXT_INK;BRIGHT TEXT_BRIGHT;caracter$
        xc = xc + 1
      end if
      pause 1
      contador_cadena = contador_cadena + 1
    loop
    WaitKey()
    ' CROP_ULA
    DELETE_TEXT_AREA
end sub


sub borra_cadena()
    'ensure the screen-name row is ready before drawing the frame
    prev_screen = 255
    print_screen_name()
    INK FRAME_INK: PAPER FRAME_PAPER: bright FRAME_BRIGHT
    print at DIALOG_TOP_ROW,0;"<^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^>"
    print at DIALOG_BOTTOM_ROW,0;"[______________________________]"
     _y = DIALOG_TOP_ROW + 1
    while _y < DIALOG_BOTTOM_ROW
        PRINT AT _y,0;chr(92)
        PRINT AT _y,31;chr(64)
        for _x = 1 to 30
          PRINT AT _y,_x;" "
        next _x
        _y = _y + 1
    wend
    SHOW_DIALOG
end sub


sub WaitForNoKey()
do
  v = in(31)
  if GetKeyScanCode = 0 AND v = 0 then EXIT DO
loop
end sub


'REDEFINE KEYS'

'checks whether a key was already defined while redefining keys'
function already_defined(codigo as uinteger) as ubyte
    for i = 0 to tecla
      if codigo = keys_to_play(i)
        return 1
      end if
    next i
    return 0
end function


sub redefine_keys()
    Print at REDEFINE_TEXT_Y,0;"                                "
    let teclas_redef(0) = "LEFT"
    let teclas_redef(1) = "RIGHT"
    let teclas_redef(2) = "UP"
    let teclas_redef(3) = "DOWN"
    let teclas_redef(4) = "FIRE"
    let teclas_redef(5) = "MUTE"
    let teclas_redef(6) = "PAUSE"
    cadena1 = "PRESS"

    'reset keys'
    for i = 0 to 6
      keys_to_play(i) = 0
    next i

    j = 0
    Print ink 4;at REDEFINE_TEXT_Y,REDEFINE_TEXT_X;cadena1$
    tecla = 0
    while tecla < 7
        'skip DOWN (key 3); it is not used in this game'
        if tecla = 3 then tecla = tecla + 1
        Print ink 6;at REDEFINE_TEXT_Y,REDEFINE_TEXT_X+6;teclas_redef(tecla)+"   "
        WaitForNoKey()
        WaitKey()
        if GetKeyScanCode <> KEYR AND GetKeyScanCode <> KEYJ
          if tecla = 0 OR already_defined(GetKeyScanCode) = 0
            if tecla = 0 then key_left = GetKeyScanCode
            if tecla = 1 then key_right = GetKeyScanCode
            if tecla = 2 then key_up = GetKeyScanCode
            if tecla = 3 then key_down = GetKeyScanCode
            if tecla = 4 then key_fire = GetKeyScanCode
            if tecla = 5 then key_fire2 = GetKeyScanCode
            if tecla = 6 then key_pause = GetKeyScanCode
            keys_to_play(tecla) = GetKeyScanCode
            PlaySFX(SOUND_KEY_DEFINED)
            tecla = tecla + 1
          end if
        end if
    wend

    WaitForNoKey()
    CLS
    WaitRetrace(60)
    SaveSD("bin/keys.bin",@keys_to_play(0), 14)
end sub


sub control_vars() 
     if control = 1 'Kempston 3-button control
        v=in(31) 'read Kempston port 1
        press_up = v bAND %1000 
        press_down = v bAND %100
        press_left = v bAND %10
        press_right = v bAND %1
        press_fire = v bAND %10000
        press_fire2 = (v bAND %100000) OR MultiKeys(key_fire2)
        press_pause = (v bAND %10000000) OR MultiKeys(key_pause)
     else 'keyboard control
        press_up = MultiKeys(key_up) 
        press_down = MultiKeys(key_down)
        press_left = MultiKeys(key_left) 
        press_right = MultiKeys(key_right)
        press_fire = MultiKeys(key_fire)
        press_fire2 = MultiKeys(key_fire2)
        press_pause = MultiKeys(key_pause)
    end if
end sub


'SCROLL ROUTINES
sub process_right_scroll() 
      columna_actual = x_scroll_temp>>4
       if x_scroll_temp_6 >= 20480 'equivalent to 320<<6'
          x_scroll_temp_6 = x_scroll_temp_6 - 20480
          x_scroll_temp = cast(integer, (x_scroll_temp_6 >> 6))
          columna_actual = 0
      end if
      if columna_actual <> columna_anterior
          draw_column_right()
          columna_anterior = columna_actual 
      end if  
end sub


sub process_left_scroll() 
    columna_actual = x_scroll_temp>>4
    if x_scroll_temp_6 < 0
        x_scroll_temp_6 = 20480 + x_scroll_temp_6
        x_scroll_temp = cast(integer, (x_scroll_temp_6 >> 6))
        columna_actual = 0
    end if
    if columna_actual <> columna_anterior
        draw_column_left()
        columna_anterior = columna_actual 
    end if  
end sub


sub do_x_scroll()
  asm
  ld hl, (_x_scroll_temp)
  ld a,l
  nextreg $16,a ;this register moves Layer 2 from 0 to 255 pixels
  ld a,h 
  nextreg $71,a ;this register uses bit 0 to move it up to 319 in 320x256 mode
  end asm
end sub


sub calculos_vx_scroll()
#ifdef ENABLE_AUTOSCROLL
  if NOT autoscroll_on
    x_scroll_6 = x_scroll_6 + cast(long, total_vx)
    x_scroll_temp_6 = x_scroll_temp_6 + cast(long, total_vx)
  else
    x_scroll_6 = x_scroll_6 + cast(long, autoscroll_vel)
    x_scroll_temp_6 = x_scroll_temp_6 + cast(long, autoscroll_vel)
  end if
  x_scroll = cast(integer, (x_scroll_6 >> 6))
  x_scroll_temp = cast(integer, (x_scroll_temp_6 >> 6))
#else
  x_scroll_6 = x_scroll_6 + cast(long, total_vx)
  x_scroll = cast(integer, (x_scroll_6 >> 6))
  x_scroll_temp_6 = x_scroll_temp_6 + cast(long, total_vx)
  x_scroll_temp = cast(integer, (x_scroll_temp_6 >> 6))
#endif
end sub


function ScrollToLeft() as ubyte
  if x_scroll > -32
          calculos_vx_scroll()
          process_left_scroll()
           'scroll on X'
          haz_scroll = 1
          return 1
  else
#ifdef ENABLE_AUTOSCROLL
    autoscroll_vel = 0
#endif
    return 0
  end if
end function


function ScrollToRight() as ubyte
  if x_scroll < x_fin_mapa
          calculos_vx_scroll()
          process_right_scroll()
           'scroll on X'
          haz_scroll = 1
          return 1
  else
#ifdef ENABLE_AUTOSCROLL
    autoscroll_vel = 0
#endif
    return 0
  end if
end function


sub coloca_scroll()
  colocando_scroll = 1
  posicion_x_inicial = (cast(uinteger, player_x_ini) << 4) - CAM_RIGHT_LIMIT
  if changing_floor
    total_vx = 64 'advance 1 px (ensures the player position when changing floors)
  else
    total_vx = 512 'advance 4 px (ensures the columns are drawn)
  end if
   'removed duplicate call to calculos_vx_scroll() which doubled the scroll movement
  while x_scroll < posicion_x_inicial AND x_scroll < x_fin_mapa
    ScrollToRight()
  wend
  total_vx = 0
  colocando_scroll = 0
  do_x_scroll()
end sub


'player shooting functions and subs
sub shoot()
    for i = 0 to MAX_BULLETS-1
        if estado_bala(i) = 0
            'adjust the bullet starting position so it exits from the correct side
            'depending on which way the player is facing
            if player_facing = FACING_LEFT then 
              x_bala(i) = gpx - 8
            else 
              x_bala(i) = gpx + 8
            end if
            y_bala(i) = gpy + 0
            estado_bala(i) = 1
            v_bala(i) = 4 - player_facing
            facing_bala(i) = player_facing
            PlaySFX(SOUND_PLAYER_SHOOT)
            EXIT FOR
        end if
    next i
end sub


sub BulletsPlayerMove()
    'select the shooting frame
    dim sprite_bala as ubyte = BULLET_SPRITE
    asm : nextreg $50,32 : nextreg $51,33 : end asm 'page in banks 32 and 33'
    direccion = $0000+(256*sprite_bala)
    Test_SetSprites(1,direccion,PLAYER_BULLET_FIRST_SP_VRAM)
    asm : nextreg $50,$ff : nextreg $51,$ff : end asm 'restore the default banks

    for i = 0 to 2
      if estado_bala(i) = 1 
        x_bala(i) =  x_bala(i) + v_bala(i)
        _x1 = x_bala(i) + 4 + x_scroll
        _y = y_bala(i)+4
        qtile(_x1 >> 4, _y >> 4) 'read the tile type touched by the bullet; it is returned in aux1
        if x_bala(i) > 310 OR aux1 = 8 then estado_bala(i) = 0 'remove it if it leaves the screen or the tile is solid
        UpdateSprite(x_bala(i), y_bala(i) + (SCREEN_Y_OFFSET<<4),PLAYER_BULLET_FIRST_SP_VRAM+i,PLAYER_BULLET_FIRST_SP_VRAM,facing_bala(i),0)
      else 
        RemoveSprite(PLAYER_BULLET_FIRST_SP_VRAM+i,0)
      end if
  next i
end sub


sub reset_bullets() 'reset all player and enemy bullets
#ifdef PLAYER_CAN_FIRE
    for i = 0 to MAX_BULLETS-1
        estado_bala(i) = 0
    next i
#endif
#ifdef ENEMY_BULLETS
    for i = 0 to MAX_ENEMY_BULLETS-1
        estado_enemyBullet(i) = 0 
    next i
#endif
end sub


#ifdef ENEMY_BULLETS
'enemy bullets
sub shoot_enemyBullet(vx as byte, vy as byte)
    for i = 0 to MAX_ENEMY_BULLETS-1
        if estado_enemyBullet(i) = 0 
            estado_enemyBullet(i) = 1
            x_enemyBullet(i) = _en_x + 4
            if _en_facing = 8 then x_enemyBullet(i) = _en_x - 4
            y_enemyBullet(i) = _en_y
            vx_enemyBullet(i) = vx
            vy_enemyBullet(i) = vy
            EXIT FOR
        end if
    next i
end sub


sub EnemyBulletsMove() 
    for i = 0 to MAX_ENEMY_BULLETS-1
        if estado_enemyBullet(i) = 1 
            spnum = sprite_enemyBullet(frame_enemyBullet)
            asm : nextreg $50,34 : nextreg $51,35 : end asm 
                direccion = $0000+(256*spnum)
                Test_SetSprites(1,direccion,ENEMBULLET_FIRST_SP_VRAM)
            asm : nextreg $50,$ff : nextreg $51,$ff : end asm  
            x_enemyBullet(i) =  x_enemyBullet(i) + vx_enemyBullet(i)
            y_enemyBullet(i) =  y_enemyBullet(i) + vy_enemyBullet(i)
            _x1 = x_enemyBullet(i) + 4
            _y = y_enemyBullet(i)+4
            qtile(_x1 >> 4, _y >> 4) 'read the tile type touched by the bullet; it is returned in aux1
            'remove it if it leaves the screen or the tile is solid
            if (x_enemyBullet(i) - x_scroll) > 310 OR (x_enemyBullet(i) - x_scroll) < 10 then 
                estado_enemyBullet(i) = 0 
            elseif y_enemyBullet(i) > 160 OR  y_enemyBullet(i) < 0 then 
                estado_enemyBullet(i) = 0
            end if
            
            if aux1 = 8 
               estado_enemyBullet(i) = 0
            end if

            UpdateSprite(x_enemyBullet(i)- x_scroll, y_enemyBullet(i) + (SCREEN_Y_OFFSET<<4),ENEMBULLET_FIRST_SP_VRAM+i,ENEMBULLET_FIRST_SP_VRAM,0,0)

            'collision with the player
            if i bAND 1 = half_life 'process only half of the bullets each cycle
              if player_status < FLICKERING_ST
                  cx2 = x_enemyBullet(i) + 8 - x_scroll
                  cy2 = y_enemyBullet(i) + 8
                  if point_collide() = 1
                      estado_enemyBullet(i) = 0
                      player_damaged = 1
                      PlaySFX(SOUND_PLAYER_DAMAGED)
                  end if
              end if
            end if
        else 
            RemoveSprite(ENEMBULLET_FIRST_SP_VRAM+i,0)
        end if
    next i
    if half_life then frame_enemyBullet = frame_enemyBullet + 1
    if frame_enemyBullet > 1 then frame_enemyBullet = 0
end sub
#endif


'load text'
sub load_text(num_txt as uinteger)
  fichero = "txt/"+ str(num_txt) +".txt"
  LoadSD(fichero,TXT_BUFFER,512,0)
  print_cadena(1)
end sub
