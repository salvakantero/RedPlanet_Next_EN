'player sprites
LoadSDBank ("spr/player.spr",0,0,0,32)

'loads the map into banks 90 and 91
fichero = "bin/maps/level_"+str(level_number)+"_tiles.bin"
LoadSDBank (fichero,0,0,0,90)

'loads the enemy sprites for the current sublevel
fichero = "spr/enemies_"+str(level_enemsprite(level_number))+".spr"
LoadSDBank (fichero,0,0,0,34)

'loads the tilesets
fichero = "spr/tiles_"+str(level_tileset(level_number))+".spr"
LoadSDBank (fichero,0,0,0,36)

'loads the beh files for the tileset
fichero = "bin/beh/beh"+str(level_tileset(level_number))+".bin"
LoadSD(fichero,@behs(0),128,0)

'loads enemy data into ENEMIES_BUFFER
fichero = "bin/maps/level_"+str(level_number)+"_enemies.bin"
'calculates the size of the enemy file to load based on the number of enemies per screen
size = 12*MAX_ENEMS
LoadSD(fichero, ENEMIES_BUFFER, size, 0)

reset_enems() 'resets the enemies, setting everything to type 0
total_enemies = peek(ENEMIES_BUFFER) 'reads the number of sprites on the current map
if total_enemies then enems_load () 'copies enemy data into the enemy structure in memory

reset_bullets() 'resets the bullets




