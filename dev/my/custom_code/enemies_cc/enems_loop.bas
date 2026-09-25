' This code is executed once per enemy loop (every frame).
'----------------------------------------------------------

'PRE-BUILT ENEMY STATUS'
'ENEMY_STATUS -->  0: moving / 1: damaged / 10: dying / 12: dead
'ENEMY_STATUS --> 0: moving / 1: damaged / 10: dying / 12: dead

'ENEMY LOGIC'

'ENEMY TYPES 1 and 49: Patrollers and platforms'
IF ENEMY_TYPE = 1 
    IF ENEMY_STATUS = 0         ' If in state 0 (moving)
        IF HALF_LIFE            'Runs every 2 frames to slow enemies down (QUARTER_LIFE also exists for every 4 frames)
            MOVE_ENEMY          'Move enemies along the X and Y axes
            CHECK_ENEMY_LIMITS  'Check limits and bounce when one is reached
            CHECK_ENEMY_TILES   'Check solid tiles and bounce when one is touched'
        END IF
    END IF
#ifdef ENABLE_PLATFORMS
ELSE IF ENEMY_TYPE = PLATFORM_TYPE   
    IF ENEMY_STATUS = 0         ' If in state 0 (moving)

        IF HALF_LIFE            'Runs every 2 frames to slow enemies down (QUARTER_LIFE also exists for every 4 frames)
            MOVE_ENEMY          'Move enemies along the X and Y axes
            CHECK_ENEMY_LIMITS  'Check limits and bounce when one is reached
            CHECK_ENEMY_TILES   'Check solid tiles and bounce when one is touched'
        END IF
    END IF
#endif

#ifdef FANTYS
'ENEMY TYPE 2: Chasers.
ELSE IF ENEMY_TYPE = 2  
    IF HALF_LIFE AND ENEMY_STATUS = 0       'Only moves and chases every two frames and in state 0'
        IF ABS(diferencia) < 68 AND ABS(_en_y - gpy) < 68
            MOVE_FANTY                      'Chase the player (CHASING)'
        ELSE
            'Out of range: linear return to base (RETREATING)'
            enemies_mx_fanty(enit) = 0      'Reset inertia when stopping the chase'
            enemies_my_fanty(enit) = 0
            IF _en_x1 >= _en_x - 1 AND _en_x1 <= _en_x + 1 AND _en_y1 >= _en_y - 1 AND _en_y1 <= _en_y + 1
                'Reached the base: fix position (IDLE)'
                _en_x = _en_x1
                _en_y = _en_y1
            ELSE
                'Move 1px/frame towards the base'
                IF _en_x < _en_x1
                    _en_x = _en_x + 1
                ELSEIF _en_x > _en_x1
                    _en_x = _en_x - 1
                END IF
                IF _en_y < _en_y1
                    _en_y = _en_y + 1
                ELSEIF _en_y > _en_y1
                    _en_y = _en_y - 1
                END IF
            END IF
        END IF
    END IF
#endif

#ifdef JUMPERS

'ENEMY TYPE 3: Jumpers'
ELSE IF ENEMY_TYPE = 3  
    IF ENEMY_STATUS = 0                 ' If in state 0 (moving)
        ENEMY_ADD_GRAVITY               'Apply gravity to the enemy
        MOVE_ENEMY                      'Move enemies along the X and Y axes
        CHECK_ENEMY_LIMITS              'Check limits and bounce when one is reached
        IF ENEMY_IS_TOUCHING_GROUND           'If the enemy touches the ground, bounce (or jump in this case)'
            ENEMY_BOUNCE
        END IF
        CHECK_ENEMY_TILES               'Check solid tiles and bounce when one is touched'
    END IF
#endif

#ifdef OSCILLATORS

'ENEMY TYPE 4: OSCILLATOR'
ELSE IF ENEMY_TYPE = 4 
    'Counter so the enemy fires every 100 frames (roughly 2 seconds)'
    ENEMY_COUNTER = ENEMY_COUNTER + 1
    IF ENEMY_COUNTER = 100
        ENEMY_COUNTER = 0   'Reset the counter'
        ENEMY_SHOOT (0,2)   'Fire a projectile downwards; the first parameter is X speed (VX), the second VY (in pixels/frame)'
    END IF

    IF ENEMY_STATUS = 0
        CHECK_ENEMY_LIMITS  'Check limits and bounce when one is reached
        MOVE_OSCILLATOR     'Apply vertical oscillating movement
        MOVE_ENEMY          'Move enemies along X and Y (for the oscillator, only X applies because Y moves with MOVE_OSCILLATOR)
    END IF
#endif
'...ADD YOUR CUSTOM ENEMIES, FOR EXAMPLE:
ELSE IF ENEMY_TYPE = 5
'...code for type 5...
ELSE IF ENEMY_TYPE = 6
'...code for type 5...
ELSE IF ENEMY_TYPE = 7
'...code for type 5...
#ifdef ENABLE_OBJECTS
'COLLECTIBLE OBJECT: bobs vertically to attract attention (as in the Pi version)
'Only the displayed Y is modified; the anchor (_en_y1) and X remain unchanged
ELSE IF ENEMY_TYPE = OBJECT_TYPE
    ENEMY_COUNTER = ENEMY_COUNTER + 1
    IF ENEMY_COUNTER >= OBJ_BOB_CYCLE THEN ENEMY_COUNTER = ENEMY_COUNTER - OBJ_BOB_CYCLE
    _en_y = _en_y1 - bob_offset(ENEMY_COUNTER / OBJ_BOB_FRAMES)
#endif

'DON'T REMOVE THIS "END IF"
END IF
'DON'T REMOVE THIS "END IF"





