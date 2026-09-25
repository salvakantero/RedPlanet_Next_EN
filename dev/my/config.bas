/'
ENGINE CONFIGURATION, MK1 CHURRERA STYLE
- You can change the #define values to adjust parameters such as player speed,
title screen, lives, enabled enemies, HUD element positions, etc.
- Comment out defines that are not needed; for example, if the game does not jump, comment out #define PLAYER_JUMPS
'/

' ============================================================================
' General configuration
' ============================================================================
#define FIX_MUSIC_60HZ 'Makes the music sound at the same speed in 50/60 hz (needs to modify Nextlib.bas)

'#define DEBUGGING     'If defined you can go to previous/next map by pressing Z/X'

'#define CUSTOM_PALETTE 'Enable to use custom palettes. Name the files sprites.pal / tiles.pal in data/pal/'
#define SPRITES_TRANSPARENT_COLOR 227
#define GLOBAL_TRANSPARENT_COLOR 231

' Menu
#define REDEFINE_TEXT_X 11   'Coords where to print Redefine keys dialog'
#define REDEFINE_TEXT_Y 23

' CAMERA SETTINGS: define the limits from which the camera follows the player while scrolling
' Pixel values: from 8 to 296 horizontally and from 8 to 168 vertically)'
#define CAM_LEFT_LIMIT      152
#define CAM_RIGHT_LIMIT     152
'#define CAM_DOWN_LIMIT      100
'#define CAM_UP_LIMIT        80

' ============================================================================
' LEVELS CONFIGURATION (here, we consider each maps as a levels)
' ============================================================================
#define FIRST_LEVEL			    0		        ' Initial level
#define MAX_LEVELS				1		        ' # of levels in total (if you win the last level, the game ends)
#define LEVELS_TILESETS         0   	        ' Tilesets (spr) used in each level, separated by commas //Eg. Value 0 will use files: "tiles_1.spr +  beh1.bin"
#define LEVELS_ENEMIES          0   	        ' Enemies spriteset (spr) used in each level, separated by commas //Eg. Value 0 will use files: "enemies_1.spr"
#define LEVELS_MUSICS           1               ' # music used in each level, separated by commas //Eg. Value 2 will use the file "2.pt3"
#define MAX_ENEMS               125             ' Max enemies+objects+platforms per level (one level is a map)' // CUSTOM // increased from 111 for food hotspots
#define ENABLE_AUTOSCROLL      

' ============================================================================
' ANIMATED TILES'
' ============================================================================
#define TILANIMS                                ' If defined, animations in tiles is active'
#define MAX_TILANIMS               27           ' Max number of animated tiles per map (Don't use too many tiles)'
#define MAX_FRAMES_TILANIM          2           ' Number of tiles that the animations use'
#define TILANIM_FREQUENCY          12           ' Number of frames (time) to print the next tile of the animation'
#define LEVELS_FIRST_TILANIM      118	        ' First tile which is animated (to change it for a specific level, use FIRST_TILANIM = N in file "before_entering_map.bas")

' ============================================================================
' TIMER CONFIGURATION
' ============================================================================
#define TIMER_ENABLE					' Enable timer
#define TIMER_INITIAL 			99		' Initial value.
#define TIMER_LAPSE			    100		' # of frames between decrements
#define TIMER_START						' If defined, start timer from the beginning
'#define TIMER_AUTO_RESET				' If defined, timer resets after "time up"

' ============================================================================
' MISCELLANEOUS
' ============================================================================
#define EXTRA_LIFE_SCORE    1500    'Win extra life each N points'
'#define SPIKES_KILL_VERTICAL_ONLY   ' If defined, tile type 1 only damages if touched on top or bottom, horizontally is a solid block
'#define FULL_CHARSET                ' If defined, font will use also lowercase letters. If you don't need it, disable it and will save some bytes.

' ============================================================================
' PLAYER CONFIGURATION
' ============================================================================
'#define PLAYER_SPRITE_16X32                 ' The player sprite will use a size of 16x32 pixels instead of 16x16
#define MAX_FRAMES_PLAYER   4               ' Number of player sprites per animation'
#define PLAYER_FLICKERS                     ' If defined, player flickers after damaged for the number of frames defined in FLICKERING_TIME
#define FLICKERING_TIME     100             ' number of frames flickering

' Player data
#define INIT_ENERGY 				1		' Starting energy gauge (put 1 for touched = death)
#define INIT_LIVES				    10		' Max and starting lives gauge. (put 1 for just one life and use energy instead)

' Fire
#define PLAYER_CAN_FIRE			     		' If defined, player can shoot
#define BULLET_SPRITE				63		' # of sprite for the bullets in spriteset
#define MAX_BULLETS				    1		' # of sprite for the bullets in spriteset
#define STOP_WHEN_FIRE			 	        ' If defined, the player is stopped when shoots for the time defined in RATE_OF_FIRE
#define RATE_OF_FIRE			    4	    ' minimum number of frames between two shots

' Vertical movement.
#define PLAYER_GRAVITY				16		' If defined, apply gravity acceleration (value increases fall every frame until reach PLAYER_MAX_VY_FALLING) 
#define PLAYER_MAX_VY_FALLING		256 	' Max falling speed 

#define PLAYER_JUMPS                        ' If defined, player can jump
#define JUMP_POWER		            280 	' Jump initial Y speed 
#define DAMAGE_BOUNCE_POWER    		200 	' If defined, player bounces when damaged. Value is Y speed 

'#define ENABLE_UPDOWN_MOVE                 ' If defined, player can move up and down (for top view games, remember to disable gravity and jump)

'#define ENABLE_LADDERS                      ' If defined, tile type 2 are ladders.
'#define LADDER_VY                   64      ' Y speed when moving up/down on ladders.
'#define JUMP_POWER_ON_LADDER        128     ' Jump initial Y speed when player is on ladders.
'#define FALL_OFF_LADDER                     ' If defined: if the player is damaged while on the ladder, he will fall off it.


' Horizontal (side view) or general (top view) movement.
#define PLAYER_MAX_VX				128  	' Max X speed  (96/64 = 1.5 pixels/frame)
'#define INERTIA                             ' Comment this out to disable inertia'
#define PLAYER_AX					8		' Acceleration (24/64 = 0,375 pixels/frame^2)
#define PLAYER_RX					8		' Friction (32/64 = 0,5 pixels/frame^2)

' Bounding box size
' Collision with tiles, use 0 for normal 16x16 bounding box
#define BOUNDING_BOX_LEFT_OFFSET	   -1	' in pixels: negative to reduce the box, positive to increase
#define BOUNDING_BOX_RIGHT_OFFSET	   -1	' in pixels: negative to reduce the box, positive to increase
#define BOUNDING_BOX_UP_OFFSET	       -1	' in pixels: negative to reduce the box, positive to increase
#define BOUNDING_BOX_DOWN_OFFSET	   0	' in pixels: negative to reduce the box, positive to increase (If use gravity, let it 0)

' Collision with enemies and shots'
#define SMALL_COLLISION_ENEM 				' reduced bounding box for collision with enemies
'#define SMALL_COLLISION_SHOTS				' reduced bounding box for collision with enemy bullets
'#define STOMP_ENEMIES                       ' Kill enemies by stomping on them'

' ============================================================================
' ENEMIES, PLATFORMS & OBJECTS CONFIGURATION
' ============================================================================
#define ENEMY_SPRITES_16X32         ' Enemy sprites will use a size of 16x32 pixels instead of 16x16
#define MAX_SPRITES_ON_SCREEN  10   ' Maximum number of sprites on screen at once, including enemies, objects and moving platforms'

#define MAX_FRAMES_ENEMIES  2   ' Maximum number of enemy animation sprites'
#define DEFAULT_ENEM_FPS    4   ' Number of frames between enemy animation sprite changes'

#define RESPAWN_ENEMIES         ' If defined, enemies will respawn in the the place they died, when it is out of the visible area.'
'#define ENEMY_DEATH_BOUNCE  24  ' If defined, when enemies die, they bounce, and the number is the vertical speed (VY) of the bounce (default is 24)'
#define ENEMY_DYING_TIME    16  'Number of frames the dying status lasts.'
'#define WALLS_STOP_ENEMIES      ' If defined, enemies change direction when colliding with a solid tile.

#define ENABLE_PLATFORMS        ' IF defined, enemy type 49 will be a mobile platform
#define ENABLE_OBJECTS          ' IF defined, enemy type 50 will be a collectible object
#define OBJECTS_GET_SOUND   6   ' # of sound played when you get a collectible object
' vertical bobbing for objects (makes them more visible, as in the Pi version)
' they move along the Y axis following the bob_offset() table (16 steps, 4 px amplitude). Only the displayed Y is affected
' OBJ_BOB_FRAMES = frames per step: higher means slower bobbing
#define OBJ_BOB_FRAMES      2   ' frames per bobbing step (higher = slower)
#define OBJ_BOB_CYCLE       (16 * OBJ_BOB_FRAMES) ' derived: 16 bob_offset() steps (best not changed)

' Fantys
#define FANTYS                  ' Activate the pursuer enemy type (type 2)'
#define FANTYS_MAX_VEL 32 
#define FANTYS_ACELERACION 1

' Jumpers
#define JUMPERS                 ' Activate the jumping enemy type (type 3)'
#define ENEM_JUMP_POWER     42  ' Jump initial vertical speed (jump power) for type 3

' Oscillators
'#define OSCILLATORS              ' Oscillating enemy (type 4)'
 
#define ENEMY_GRAVITY       2    ' For jumpers, oscillators, or enemies that can fall
#define ENEMY_MAX_VY        96   ' For jumpers, oscillators, or enemies that can fall

' Enemy fire'
'#define ENEMY_BULLETS           ' If defined, enemies can fire
'#define MAX_ENEMY_BULLETS   3   ' max # of enemy bullets on screen
'#define ENEM_BULLET_ANIM 62,63  ' Sprites animation for enemy bullets, separated by commas (2 frames)

' ============================================================================
' HUD CONFIGURATION
' ============================================================================
#define HUD_HEIGHT 2 'how many ROWS OF TILES (16px each): Recommended 1 or 2 depends on your needs, 0 if you don't use hud. 
' IMPORTANT: There is not vertical scroll at this point, so make your maps height according to the hud used: Game area height in tiles = 18-Hud height
#define SHOW_SCORE                      ' If defined, print score points on hud
#define SCORE_X                 25       ' Score coord X on hud
#define SCORE_Y                 2       ' Score coord Y on hud
' // CUSTOM // Arcade-style "rolling" score: the displayed score increases by +SCORE_ROLL_STEP
' each frame until it reaches the actual score (it does not jump). With 1, it increases one point at a time.
' The duration is proportional to the score (at 50fps: 1 point/frame). If it is too slow, increase it to 2.
#define SCORE_ROLL_STEP         1       ' Score increase per frame
' CUSTOM Continuous rolling-score click: the FX plays each frame while the score increases
' (each shot replaces the previous one), creating a rattle that stops abruptly when the score stops.
#define SOUND_SCORE_CLICK   10      ' Rolling-score click FX
'#define SHOW_ENERGYBAR                  ' If defined, print energy bar on hud
'#define ENERGYBAR_X             0       ' Energy bar coord X on hud
'#define ENERGYBAR_Y             1       ' Energy bar coord Y on hud
#define SHOW_LIVES                      ' If defined, print # of lives on hud
#define LIVES_X                 3       ' Lives coord X on hud
#define LIVES_Y                 1       ' Lives coord Y on hud
#define SHOW_TIMER                      ' If defined, print O2 (oxygen) on hud
#define TIMER_X                 8       ' O2 coord X on hud
#define TIMER_Y                 1       ' O2 coord Y on hud
#define SHOW_OBJECTS                    ' If defined, print # of TNT on hud
#define OBJECTS_X               26      ' TNT coord X on hud
#define OBJECTS_Y               1       ' TNT coord Y on hud


' ============================================================================
' MUSIC & SOUND CONFIGURATION
' ============================================================================

'Default songs'
#define MUSIC_TITLE 0       'Title/menu screen'
#define MUSIC_GAMEOVER 2
#define MUSIC_ENDING 0
'#define MUSIC_STAGE_CLEAR 11

'Default fx sounds'
#define SOUND_ENEMY_DIE 4
#define SOUND_PLAYER_SHOOT 15
#define SOUND_JUMP 2 'sword swing'
#define SOUND_EXTRA_LIFE 8 'extra life'
#define SOUND_PLAYER_DAMAGED 0 'fall

#define SOUND_LANGUAGE_SELECTED 11
#define SOUND_KEY_DEFINED 13
#define SOUND_START_GAME 6
#define SOUND_ENEMY_DAMAGED 7
#define SOUND_ENEMY_STOMPED 12


' ============================================================================
' CONTROL CONFIGURATION
' ============================================================================

#define KEY_TO_LEFT     PRESS_LEFT
#define KEY_TO_RIGHT    PRESS_RIGHT
#define KEY_TO_UP       PRESS_UP
#define KEY_TO_DOWN     PRESS_DOWN

#define KEY_TO_FIRE     PRESS_FIRE
#define KEY_TO_JUMP     PRESS_UP
#define KEY_TO_PAUSE    PRESS_PAUSE

' ============================================================================
' TEXTS & DIALOG CONFIGURATION
' ============================================================================
#define TEXT_INK 7
#define TEXT_BRIGHT 1
#define TEXT_PAPER 0
#define FRAME_INK 7
#define FRAME_BRIGHT 1
#define FRAME_PAPER 0

' vertical position of the dialogue window (ULA character rows)
' the box (6 rows) is centred on the full SCREEN (24 rows): 9 rows above and 9 below -> rows 9..14.
' to move the box up/down, change ONLY DIALOG_TOP_ROW
' DIALOG_BOTTOM_ROW is derived: top border + 4 text lines + bottom border = +5 rows.
#define DIALOG_TOP_ROW      9                   'top border row of the box
#define DIALOG_BOTTOM_ROW   (DIALOG_TOP_ROW + 5) 'DO NOT change
