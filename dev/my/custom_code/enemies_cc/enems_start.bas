'******************'
'ENEMIES START CODE'
'******************'
'THIS CODE RUNS WHEN THE ENEMY IS FIRST CREATED AND WHEN IT RESPAWNS'

'SET INITIAL ANIMATION'
IF ENEMY_TYPE = 1 THEN                   'PATROLLERS'
    ENEMY_ANIMATION(2,8,    0,1) 'value 1: number of frames, value 2: frame interval, remainder: image sequence
ELSEIF ENEMY_TYPE = 2 THEN               'FANTYS'
    ENEMY_ANIMATION(2,6,    0,1)
ELSEIF ENEMY_TYPE = 3 THEN               'JUMPERS'
    ENEMY_ANIMATION(2,4,    0,1)
ELSEIF ENEMY_TYPE = 4 THEN               'OSCILLATORS'
    ENEMY_ANIMATION(2,4,    0,1)
ELSEIF ENEMY_TYPE = PLATFORM_TYPE THEN   'PLATFORMS'
    ENEMY_ANIMATION(2,8,    0,1)
#ifdef ENABLE_OBJECTS
ELSEIF ENEMY_TYPE = OBJECT_TYPE THEN     'COLLECTIBLE OBJECTS (vertical bobbing)'
    enemies_y1(enit) = enemies_y(enit)   'bobbing anchor = object rest position'
    enem_counter2(enit) = enit AND 15    'different initial phase per object (desynchronises the bobbing)'
#endif
END IF
