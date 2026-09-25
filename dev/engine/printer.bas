' draw initial screen
sub draw_scr()
    first_row = level_floor*SCREENS_H
#ifdef TILANIMS
    detect_tilanims() ' detect animated tiles on the whole level_floor
#endif
    columna_inicial = cast(byte, x_scroll>>4)
    for y = 0 to (SCREENS_H-1)        
        tt = ancho_mapa * cast(uinteger,y+first_row) 'without the cast it becomes ubyte values
        tt = tt + columna_inicial + 2
        for x = 2  to 19 'add 2 to start from tile 0, which is hidden by the Layer 2 clip
            asm : di: nextreg $56,90 : nextreg $57,91 : end asm 
            p = peek(tt+MAP_BUFFER)
            asm : nextreg $56,0 : nextreg $57,1 : ei :end asm 
            FDoTile16(p,x,y+SCREEN_Y_OFFSET,36) 'draw tiles from bank 36
        tt=tt+1 'increment tile number
        next x
    next y 
end sub


'draw a new tile column on the right
sub draw_column_right()
    tt=0
    addx = (x_scroll>>4) + 19 'offset used to read the map, starting at the relevant column
    for y = 0 to (SCREENS_H-1)
        tt = ancho_mapa * cast(uinteger,y+first_row) 'without the cast tt becomes ubyte values
        tt = tt + cast(uinteger,addx)
        asm : di: nextreg $56,90 : nextreg $57,91 : end asm 
        p = peek(tt+MAP_BUFFER)
        asm : nextreg $56,0 : nextreg $57,1 : ei :end asm 
        FDoTile16(p,columna_anterior,y+SCREEN_Y_OFFSET,36) 'draw tiles from bank 36
        tt=tt+1 'next tile
    next y
end sub


'Draw a new tile column on the left'
sub draw_column_left()
    tt=0
    addx = (x_scroll>>4) 'offset used to read the map, starting at the relevant column
    for y = 0 to (SCREENS_H-1)
        tt = ancho_mapa * cast(uinteger,y+first_row) 'without the cast tt becomes ubyte values
        tt = tt + cast(uinteger,addx)
        asm : di: nextreg $56,90 : nextreg $57,91 : end asm 
        p = peek(tt + MAP_BUFFER)
        asm : nextreg $56,0 : nextreg $57,1 : ei :end asm 
        FDoTile16(p,columna_actual,y+SCREEN_Y_OFFSET,36) 'draw tiles from bank 36
        tt=tt+1 'next tile
    next y
end sub


'before calling this sub, pass it _x, _y (in tile coordinates) and _t (tile number in the tileset)
sub update_tile(modify_map as ubyte)
    'if it permanently modifies the current map, change the tile value in the buffer
    if modify_map = 1 
        tt = _x + (ancho_mapa * cast(uinteger,_y) )
        asm : di: nextreg $56,90 : nextreg $57,91 : end asm 
        poke(MAP_BUFFER + tt, _t) 'modify the map
        asm : nextreg $56,0 : nextreg $57,1 : ei :end asm 
    end if
    'calculate the position variation caused by scrolling
    resto_scrollx = (_x MOD 20) + 2
    if resto_scrollx > 19 
        resto_scrollx = resto_scrollx - 20
    end if
    _x = _x - (x_scroll>>4)
    _y = _y+SCREEN_Y_OFFSET-first_row
    if _x > 0 AND _x < 20 AND _y < 16
        FDoTile16(_t,resto_scrollx, _y, 36)	'draw tiles from bank 36
    end if
end sub


sub pintar_tile (x_tile as ubyte, y_tile as ubyte, num_tile as ubyte)
    _x = x_tile : _y = y_tile : _t = num_tile
    update_tile(0)
end sub


sub actualizar_tile (x_tile as ubyte, y_tile as ubyte, num_tile as ubyte)
    _x = x_tile : _y = y_tile : _t = num_tile
    update_tile(1)
end sub


#ifdef TILANIMS
'register animated tiles
sub detect_tilanims()
    tilanim_num = 0
    for y = first_row to first_row+SCREENS_H-1
        tt = ancho_mapa * cast(uinteger,y) 'without the cast, tt would become a ubyte
        for x = 0  to ancho_mapa-1 
            asm : di: nextreg $56,90 : nextreg $57,91 : end asm 
            p = peek(tt+MAP_BUFFER)
            asm : nextreg $56,0 : nextreg $57,1 : ei :end asm 
            if p >= tilanims_first AND tilanim_num < MAX_TILANIMS
                tiles_animados_x (tilanim_num) = x  'store the global X in tiles
                tiles_animados_y (tilanim_num) = y  'store the global Y in tiles
                tiles_animados_t (tilanim_num) = p
                tilanim_num = tilanim_num + 1
            end if
            tt=tt+1 'next tile
        next x
    next y 
    total_tilanims = tilanim_num
    tiles_subframe = 0
end sub


sub reset_tilanims ()
    for tile_id = 0 to MAX_TILANIMS
        tiles_animados_t(tile_id) = 255
    next tile_id
end sub
#endif


'DRAW SPRITES
sub put_sprite (bank_num as ubyte, spr_id as ubyte, image_num as ubyte, x_sprite as integer, y_sprite as ubyte, sp_facing as ubyte)
	'LOAD IMAGE IN SPRITE RAM'
    NextRegA($50,bank_num)
    NextRegA($51,bank_num+1) 
	direccion = $0000+(cast(uInteger,image_num)<<8)
    Test_SetSprites(1, direccion, 63-spr_id)
	asm : nextreg $50,$ff : nextreg $51,$ff : end asm
	'SHOW SPRITE'
	UpdateSprite(x_sprite, y_sprite, 127-spr_id, 63-spr_id, sp_facing, 0)
end sub


sub delete_sprite (spr_id as ubyte)
	RemoveSprite(127-spr_id,0)
end sub
