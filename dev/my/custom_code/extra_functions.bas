' ENTER YOUR CUSTOM FUNCTIONS OR SUBS HERE. You can call them from other custom code files.

'collectible object types
#define OBJ_TNT     0
#define OBJ_OXYGEN  1
#define OBJ_AMMO    2
#define OBJ_KEY     3
#define MAX_AMMO    50

'Food hotspots (bonus points, as in Red Planet Pi)
'identified by their sprite number (_en_sprnum), not by position.
'free slots in enemies_0.spr (row 1, unused by enemies/objects)
'RESERVED! Sprites 16/17/18 MUST NOT be assigned to any enemy/object in the
'map editor: enems_collisions.bas treats any sprite 16/17/18 as food
'(adds points and bypasses the obj_table effect)
#define SPR_BURGER  16
#define SPR_CAKE    17
#define SPR_DONUT   18

#define PTS_BURGER  100
#define PTS_CAKE    80
#define PTS_DONUT   60

'Player variables
dim player_ammo as ubyte
dim player_keys as ubyte
dim hiscore as ulong 'ulong (32-bit), alongside score, prevents overflow
LoadSD("bin/hiscore.bin", @hiscore, 4, 0)
' Migration: the old file was 2 bytes and may leave garbage in the two high bytes.
' If the value exceeds the maximum displayable value (6 digits), reset it to 0.
if hiscore > 999999 then hiscore = 0

'30-byte table: object type by zone (5 zones x 6 floors)
'Index = level_floor * 5 + zone    (zone = tile_x / 15)
dim obj_table(29) as ubyte => { _
    OBJ_AMMO,   OBJ_TNT, OBJ_OXYGEN, OBJ_TNT,  OBJ_KEY,    _
    OBJ_KEY,    OBJ_TNT, OBJ_OXYGEN, OBJ_AMMO, OBJ_TNT,    _
    OBJ_KEY,    OBJ_TNT, OBJ_OXYGEN, OBJ_AMMO, OBJ_OXYGEN, _
    OBJ_KEY,    OBJ_AMMO, OBJ_KEY,   OBJ_OXYGEN, OBJ_TNT,  _
    OBJ_OXYGEN, OBJ_KEY,  OBJ_TNT,   OBJ_AMMO,   OBJ_TNT,  _
    OBJ_OXYGEN, OBJ_TNT,  OBJ_AMMO,  OBJ_TNT,    OBJ_OXYGEN _
}

'Screen names & visited tracking
dim current_screen, prev_screen as ubyte
#define SCREEN_WIDTH_PX 240
#define TOTAL_SCREENS 30
dim visited(TOTAL_SCREENS - 1) as ubyte
dim visited_count as ubyte
dim new_hiscore as ubyte
dim expl_round as ubyte
dim expl_i as ubyte
dim expl_seed as uinteger

dim scr_names(TOTAL_SCREENS - 1) as string
scr_names(0)  = "CONTROL CENTRE"
scr_names(1)  = "SUPPLY DEPOT"
scr_names(2)  = "CENTRAL HALL"
scr_names(3)  = "TOXIC WASTE STORAGE"
scr_names(4)  = "TOXIC WASTE STORAGE"
scr_names(5)  = "WEST CORRIDOR"
scr_names(6)  = "ACCESS TO WEST CORRIDORS"
scr_names(7)  = "CENTRAL HALL"
scr_names(8)  = "ACCESS TO DUNGEONS"
scr_names(9)  = "DUNGEONS"
scr_names(10) = "WEST CORRIDOR"
scr_names(11) = "SUPPLY DEPOT"
scr_names(12) = "CENTRAL HALL"
scr_names(13) = "ACCESS TO SOUTHEAST EXIT"
scr_names(14) = "EXIT TO UNDERGROUND"
scr_names(15) = "PELUSOIDS LAIR"
scr_names(16) = "ALVARITOS GROTTO"
scr_names(17) = "ALVARITOS GROTTO"
scr_names(18) = "TOXIC WASTE STORAGE"
scr_names(19) = "UNDERGROUND TUNNEL"
scr_names(20) = "SIDE HALL"
scr_names(21) = "ARACNOVIRUS LAIR"
scr_names(22) = "UNSTABLE CORRIDORS"
scr_names(23) = "UNSTABLE CORRIDORS"
scr_names(24) = "TOXIC WASTE STORAGE"
scr_names(25) = "SIDE HALL"
scr_names(26) = "ABANDONED MINE"
scr_names(27) = "ABANDONED MINE"
scr_names(28) = "ABANDONED MINE"
scr_names(29) = "EXPLOSIVES STOCKPILE"


sub print_screen_name()
    dim scr_name as string
    dim name_x as ubyte
    dim scr_idx as ubyte

    current_screen = cast(ubyte, cast(uinteger, gpx + x_scroll) / SCREEN_WIDTH_PX)
'single map: 30 screens = 5 horizontal sections x 6 floors
    scr_idx = level_floor * 5 + current_screen

    if scr_idx = prev_screen then
        return
    end if

    prev_screen = scr_idx

'mark screen as visited
    if visited(scr_idx) = 0
        visited(scr_idx) = 1
        visited_count = visited_count + 1
    end if

    scr_name = scr_names(scr_idx)

'screen title centred at the top of the ULA screen (Layer 2)
'+ line surrounding the title
    PRINT AT 3,3;PAPER 0;INK TEXT_INK;BRIGHT 0;"__________________________"
    if scr_name <> ""
        scr_name = " " + scr_name + " "
        name_x = (32 - len(scr_name)) >> 1
        PRINT AT 3,name_x;PAPER 0;INK TEXT_INK;BRIGHT 0;scr_name
    end if
end sub

'Custom HUD: ammo and keys
#define AMMO_X  13
#define AMMO_Y  1
#define KEYS_X  21
#define KEYS_Y  1


sub print_ammo()
'red if ammo <= 5, green otherwise
    dim ammo_ink as ubyte
    if player_ammo <= 5 then ammo_ink = 2 else ammo_ink = 4
    if player_ammo < 10
        PRINT AT AMMO_Y,AMMO_X;INK ammo_ink;BRIGHT 1;"0"+str(player_ammo);INK 4;"/50"
    else
        PRINT AT AMMO_Y,AMMO_X;INK ammo_ink;BRIGHT 1;str(player_ammo);INK 4;"/50"
    end if
end sub


sub print_keys()
'red if there are no keys, green otherwise
    if player_keys = 0
        PRINT AT KEYS_Y,KEYS_X;INK 2;BRIGHT 1;"0"+str(player_keys)
    else
        PRINT AT KEYS_Y,KEYS_X;INK 4;BRIGHT 1;"0"+str(player_keys)
    end if
end sub


sub print_hiscore()
'6 digits (hiscore is ulong). Field in columns 8..13 (after "RECORD:")
    dim s as string = str(hiscore)
    dim hx as ubyte = 6 + 6 - LEN(s) '6 = base column; 6 = field width; right-aligned
    print INK 4;BRIGHT 1;at SCORE_Y,6;"000000"
    print INK 4;BRIGHT 1;at SCORE_Y,hx; s
end sub


sub update_hiscore()
    new_hiscore = 0
    if score > hiscore then
        hiscore = score
        SaveSD("bin/hiscore.bin", @hiscore, 4) '4 bytes (ulong)
        new_hiscore = 1
    end if
end sub


sub print_stats(title as string, msg as string)
    dim pct as ubyte
    dim val_x as ubyte
    dim val_str as string

    'Ending = 100%; otherwise: exploration 40% + TNTs 40% (max 80%)
    if title = "MISSION COMPLETE!" then
        pct = 100
    else
        pct = cast(ubyte, (cast(uinteger, visited_count) * 40) / TOTAL_SCREENS) + cast(ubyte, (cast(uinteger, num_objects) * 40) / 10)
    end if

    borra_cadena()

    'Line 1: Centred title
    val_x = cast(ubyte, (32 - len(title)) >> 1)
    PRINT AT DIALOG_TOP_ROW+1,val_x;PAPER 0;INK 7;BRIGHT 1;title

'Line 2: screens explored
    PRINT AT DIALOG_TOP_ROW+2,7;PAPER 0;INK 5;BRIGHT 1;"EXPLORED"
    if title = "MISSION COMPLETE!" then
        val_str = "30/30"
    else
        val_str = str(visited_count) + "/30"
    end if
    val_x = cast(ubyte, 24 - len(val_str))
    PRINT AT DIALOG_TOP_ROW+2,val_x;PAPER 0;INK 4;BRIGHT 1;val_str

'Line 3: exploration percentage
    PRINT AT DIALOG_TOP_ROW+3,7;PAPER 0;INK 5;BRIGHT 1;"COMPLETED"
    val_str = str(pct) + "%"
    val_x = cast(ubyte, 24 - len(val_str))
    PRINT AT DIALOG_TOP_ROW+3,val_x;PAPER 0;INK 4;BRIGHT 1;val_str

    'Line 4: NEW RECORD or alternative message
    if new_hiscore = 1
        PRINT AT DIALOG_TOP_ROW+4,7;PAPER 0;INK 6;BRIGHT 1;"**NEW RECORD!**"
    else
        val_x = cast(ubyte, (32 - len(msg)) >> 1)
        PRINT AT DIALOG_TOP_ROW+4,val_x;PAPER 0;INK 7;BRIGHT 1;msg
    end if

    WaitForNoKey()
    WaitKey()
    DELETE_TEXT_AREA
end sub


'Door tiles
#define DOOR_TILE    26
#define DOOR_REPLACE 2

dim door_tx as ubyte
dim door_ty as ubyte
dim door_locked_snd as ubyte


sub check_door()
'if there are no keys, check whether the player touches a door to play the "locked" sound
    if player_keys = 0
        if player_facing = FACING_RIGHT
            door_tx = cast(ubyte, (gpx + 16 + x_scroll) >> 4)
        else
            door_tx = cast(ubyte, (gpx - 1 + x_scroll) >> 4)
        end if
        door_ty = cast(ubyte, (gpy + 8) >> 4)
        qtile(cast(uinteger, door_tx), cast(uinteger, door_ty))
        if aux2 = DOOR_TILE
            if door_locked_snd = 0
                PlaySFX(10)
                door_locked_snd = 1
            end if
        else
            door_locked_snd = 0
        end if
        return
    end if
'calculate the X tile in front of the player according to their direction
    if player_facing = FACING_RIGHT
        door_tx = cast(ubyte, (gpx + 16 + x_scroll) >> 4)
    else
        door_tx = cast(ubyte, (gpx - 1 + x_scroll) >> 4)
    end if
'check at the player\'s upper height
    door_ty = cast(ubyte, (gpy + 3) >> 4)
    qtile(cast(uinteger, door_tx), cast(uinteger, door_ty))
'if there is no door above, check at the lower height
    if aux2 <> DOOR_TILE
        door_ty = cast(ubyte, (gpy + 15) >> 4)
        qtile(cast(uinteger, door_tx), cast(uinteger, door_ty))
    end if
'if a door is found, open it
    if aux2 = DOOR_TILE
        player_keys = player_keys - 1
        print_keys()
        actualizar_tile(door_tx, door_ty + first_row, DOOR_REPLACE)
        PlaySFX(7) 'remolino'
        add_points(50)
    end if
end sub

'TNT placement
#define TNT_TILE 27
dim tnt_placed as ubyte
dim tnt_drawn as ubyte
dim tnt_i as ubyte
dim tnt_msg_shown as ubyte

'Music/mute
dim music_muted as ubyte
dim fire2_edge as ubyte
