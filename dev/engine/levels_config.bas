'level definition
'each array contains the values for each level, starting at 0, which is the first level

'tileset and beh number used by each level // E.g. value 1 uses: "tiles_1.spr + beh1.bin"
dim level_tileset(MAX_LEVELS-1) as ubyte => {LEVELS_TILESETS}

'enemy sprite file for each level // E.g. "enemies_1.spr"
dim level_enemsprite(MAX_LEVELS-1) as ubyte => {LEVELS_ENEMIES}

'music track number
dim level_music(MAX_LEVELS-1) as ubyte => {LEVELS_MUSICS}


