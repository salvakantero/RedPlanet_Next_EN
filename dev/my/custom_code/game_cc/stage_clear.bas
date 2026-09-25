'INSERT HERE CODE FOR STAGE CLEAR STUFF'
'INSERT YOUR OWN CODE HERE FOR THINGS YOU WANT TO HAPPEN AFTER COMPLETING A LEVEL'

' // CUSTOM // Red Planet uses MAX_LEVELS=1, so stage_clear() is never executed.
'The example is commented out to avoid using memory in the binary.

'EXAMPLE CODE:'

'HIDE_SPRITES                'Hide all sprites'
'MODE256                     'Switch to 256x192 mode'
'CLS256(0)                   'Clear Layer 2'
'CLS                         'Clear the ULA layer'
'FULL_ULA                    'Set the ULA layer to full screen'
'TEXT(10,10,7,"STAGE CLEAR!") 'Print some text'
'MUSIC = MUSIC_STAGE_CLEAR   'Play music'
'PAUSA(250)                  'Pause for 5 seconds'
'CLS                         'Clear the ULA layer'
'CROP_ULA                    'Clip the ULA to the score area only'
'MODE320                     'Switch to 320x256 mode'
