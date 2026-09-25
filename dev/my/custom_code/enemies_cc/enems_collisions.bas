'CUSTOM COLLISION CODE - Collectible objects by type

#ifdef ENABLE_OBJECTS
IF ENEMY_TYPE = OBJECT_TYPE

    'FOOD HOTSPOTS (bonus points). Identified by sprite, not by position
    IF _en_sprnum = SPR_BURGER
        SOUND(OBJECTS_GET_SOUND)
        SCORE_ADD(PTS_BURGER)
    ELSEIF _en_sprnum = SPR_CAKE
        SOUND(OBJECTS_GET_SOUND)
        SCORE_ADD(PTS_CAKE)
    ELSEIF _en_sprnum = SPR_DONUT
        SOUND(OBJECTS_GET_SOUND)
        SCORE_ADD(PTS_DONUT)
    ELSE
    'Calculate zone (0-4) from the object X position in tiles.
    'each zone is 15 tiles (240 pixels) wide, and the tile offset is obtained with _en_x >> 4'
    dim obj_zone as ubyte = cast(ubyte, (_en_x >> 4) / 15)
    'Table index: floor * 5 + zone
    dim obj_idx as ubyte = level_floor * 5 + obj_zone
    'Look up the object type in the extra_functions.bas table
    dim obj_type as ubyte = obj_table(obj_idx)
    IF obj_type = OBJ_TNT
        SOUND(OBJECTS_GET_SOUND)
        OBJECTS_NUMBER = OBJECTS_NUMBER + 1
        SCORE_ADD(20)
        #ifdef SHOW_OBJECTS
            print_objs()
        #endif
        obj_collected(enit) = 1
    ELSEIF obj_type = OBJ_OXYGEN
        SOUND(OBJECTS_GET_SOUND)
        timer_t = TIMER_INITIAL
        SCORE_ADD(40)
        #ifdef SHOW_TIMER
            print_time()
        #endif
        obj_collected(enit) = 1
    ELSEIF obj_type = OBJ_AMMO
        SOUND(OBJECTS_GET_SOUND)
        player_ammo = player_ammo + 20
        if player_ammo > MAX_AMMO then player_ammo = MAX_AMMO
        SCORE_ADD(30)
        print_ammo()
        obj_collected(enit) = 1
    ELSEIF obj_type = OBJ_KEY
        SOUND(OBJECTS_GET_SOUND)
        player_keys = player_keys + 1
        SCORE_ADD(50)
        print_keys()
        obj_collected(enit) = 1
    END IF
        END IF 'end food / obj_table
END IF
#endif
