'collision detection with the player
if player_status < DYING_ST
    cx2 = _en_x - x_scroll
    cy2 = _en_y
    no_kill = 0 'by default the collision kills the player (overridden for collectible objects)

    'enemy-bullet and player-enemy collisions
#ifdef ENABLE_PLATFORMS    
        if _en_t <> PLATFORM_TYPE 'does not affect platforms
#endif
            if enem_status < ENEM_DAMAGED 'only affects states other than damaged or dying

        'SHOTS
#ifdef ENABLE_OBJECTS
        if _en_t <> OBJECT_TYPE
#endif

#ifdef PLAYER_CAN_FIRE
            'player bullet versus enemy collision loop
            for i = 0 to MAX_BULLETS-1
                if estado_bala(i) = 1 
                    cx1 = x_bala(i)
                    cy1 = y_bala(i)
                    if cx1 > (cx2-12) AND cx1 < (cx2+14) AND cy1 >= cy2-8 - ENEMY_EXTRA_TOP_BB AND cy1 <= (cy2+4)
                        enem_recibe_golpe(1)
                        estado_bala(i) = 0
                    end if
                end if
            next i
#endif           

#ifdef STOMP_ENEMIES
            'player collision when stomping enemies
            if p_vy > 0
                cx1 = gpx + 8
                cy1 = gpy + 15
        
                if cx1 >= cx2 AND cx1 <= (cx2+15) AND cy1 >= cy2 - ENEMY_EXTRA_TOP_BB AND cy1 <= (cy2+8)
                    PlaySFX(SOUND_ENEMY_STOMPED)
                    enem_recibe_golpe(1)
                    brinco = 1
                end if
            end if
#endif

#ifdef ENABLE_OBJECTS    
        end if
#endif
            if enit bAND 1 = half_life 'process only half of the enemies each cycle
#include "../my/custom_code/enemies_cc/enems_killable.bas"
                if enem_status < ENEM_DYING
                    if collide() = 1
#ifdef ENABLE_OBJECTS
                        'collectible object code
                        IF ENEMY_TYPE = OBJECT_TYPE
                            NO_KILL                     'the collision does not kill the player
                            KILL_SPRITE_NO_RESPAWN      'remove the object and disable respawning
                        END IF
#endif
                        #include "../my/custom_code/enemies_cc/enems_collisions.bas"
                        if no_kill = 0 AND player_status < FLICKERING_ST
                            player_damaged = 1
                            PlaySFX(SOUND_PLAYER_DAMAGED)
                        end if
                    end if
                end if
            end if
        end if

#ifdef ENABLE_PLATFORMS    

    else
    'MOVING PLATFORMS'
        if gpx > cx2 - 15
        if gpx < cx2 + 15                
        if gpy >= cy2 - 17 - ABS(_en_my) 'widen the detection window to compensate for the platform vertical movement
        if gpy < cy2 - 10
            on_ground = 1
            plataforma_vx = 0: plataforma_vy = 0
            'apply the platform speed to the player
            if half_life = 0
                plataforma_vx = _en_mx << 6
            end if
            'and "stick" the player to the top of the platform
            gpy = cy2 - 16
            p_y = gpy << 6
        end if
        end if
        end if
        end if
#endif
    end if
end if
