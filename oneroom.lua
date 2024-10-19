-- ***************************************************************************************
-- *  REFERENCES
-- *  Title: How to make a Platformer Game!
-- *  Date: 10/17/2024
-- *  URL: https://nerdyteachers.com/Explain/Platformer/
-- *
-- ***************************************************************************************

function _init()
    game_start()
    text = ""
end

function game_start()
    player={
        sp=1,
        spawn_x = 64,
        spawn_y = 40,
        x=64,
        y=40,
        w=4,
        h=8,
        flip=false,
        dx=0,
        dy=0,
        max_dx=2,
        max_dy=3,
        acc=0.5,
        boost=5,
        anim=0,
        running=false,
        jumping=false,
        falling=false,
        landed=false,
        gliding=false,
        antenna=0,
        running_state=0,
        jumping_state=0,
        health=3,
        score=0
    }

    heart1={
        sp=97
    }

    heart2={
        sp=97
    }

    heart3={
        sp=97
    }

    battery={
        locations_x={
            [1]=3,
            [2]=4,
            [3]=7,
            [4]=9,
            [5]=11,
            [6]=3,
            [7]=5,
            [8]=10,
            [9]=5,
            [10]=8,
            [11]=9,
            [12]=11,
            [13]=12,
            [14]=2,
            [15]=4,
            [16]=5,
            [17]=2,
            [18]=6,
            [19]=7,
            [20]=10,
            [21]=11,
            [22]=3,
            [23]=8,
            [24]=5,
            [25]=7,
            [26]=13,
            [27]=3,
            [28]=11
        },
        locations_y={
            [1]=2,
            [2]=2,
            [3]=2,
            [4]=2,
            [5]=2,
            [6]=4,
            [7]=4,
            [8]=4,
            [9]=5,
            [10]=5,
            [11]=5,
            [12]=5,
            [13]=5,
            [14]=6,
            [15]=6,
            [16]=7,
            [17]=8,
            [18]=8,
            [19]=8,
            [20]=8,
            [21]=8,
            [22]=10,
            [23]=10,
            [24]=11,
            [25]=11,
            [26]=11,
            [27]=12,
            [28]=12
        },
        sp=84,
        x=0,
        y=0,
        randomize=true,
        can_be_picked_up=false,
        previous_location=-1 
    }

    hazards={
        [1]={x1=18,x2=21,y1=34,y2=39},
        [2]={x1=42,x2=45,y1=18,y2=23},
        [3]={x1=74,x2=77,y1=10,y2=15},
        [4]={x1=98,x2=101,y1=18,y2=23},
        [5]={x1=18,x2=21,y1=98,y2=103},
        [6]={x1=50,x2=53,y1=90,y2=95},
        [7]={x1=98,x2=101,y1=66,y2=71},
        [8]={x1=8,x2=119,y1=114,y2=119}
    }

    gravity=0.4
    friction=0.7

    map_start = 8
    map_end = 128
    time_start = time()
    current_time = 0
    time_limit = 90
    game_over = false
end

function _update()
    if not game_over then
        sfx(11)
        timer_update()
        player_update()
        battery_update()
        damage_update()
        health_update()
        player_animate()
    else
        game_over_update()
    end
end

function game_over_update()
    if btn(🅾️) then
        sfx(12, 1)
        game_start()
    end
end

function timer_update()
    local new_time = flr(time() - time_start)
    if new_time > current_time then
        sfx(9)
    end
    current_time = new_time
    if current_time > time_limit then
        game_over = true
        message = "you ran out of time"
        sfx(10, 1)
    end
end

function player_update()
    player.dy += gravity
    player.dx *= friction

    if btn(⬅️) then
        player.dx -= player.acc
        player.running = true
        player.flip = true
    elseif btn(➡️) then
        player.dx += player.acc
        player.running = true
        player.flip = false
    else
        player.running = false
    end

    if btn(⬆️) and player.landed then 
        player.dy -= player.boost
        player.landed = false
        sfx(5)
    end

    if btn(⬆️) and player.falling then
        player.dy -= (gravity/1.35)
        player.gliding = true
        sfx(8)
    elseif player.gliding then
        player.gliding = false
    end

    if btnp(❎) and battery.can_be_picked_up then
        battery.randomize = true
        battery.can_be_picked_up = false
        player.score += 1
        sfx(6)
    end

    if player.dy > 0 then
        player.falling = true
        player.landed = false
        player.jumping = false
        player.dy = limit_speed(player.dy, player.max_dy)

        if collide_map(player, "down", 0) then

            player.landed = true
            player.falling = false
            player.dy = 0
            player.y -= ((player.y + player.h + 1) % 8) - 1
        end
        
    elseif player.dy < 0 then
        player.jumping = true

        if collide_map(player, "up", 1) then
            player.dy = 0
        end
    end

    if player.dx < 0 then
        player.dx = limit_speed(player.dx,player.max_dx)
        if collide_map(player, "left", 1) then
            player.dx = 0
        end
      elseif player.dx > 0 then
        player.dx = limit_speed(player.dx,player.max_dx)
        if collide_map(player, "right", 1) then
            player.dx = 0
        end
    end

    player.x+=player.dx
    player.y+=player.dy

    if player.x<map_start then
        player.x=map_start
    end
    if player.x>map_end-player.w then
        player.x=map_end-player.w
    end
end

function limit_speed(speed, max_speed)
    return mid(-max_speed, speed, max_speed)
end

function battery_update()
    if battery.randomize then
        local location = flr(rnd(28)) + 1
        while location == battery.previous_location do
            location = flr(rnd(28)) + 1
        end

        battery.x = battery.locations_x[location]
        battery.y = battery.locations_y[location]
        battery.previous_location = location
        battery.randomize = false
    end
    if battery_collision() then
        battery.can_be_picked_up = true
        battery.sp = 85
    else
        battery.can_be_picked_up = false
        battery.sp = 84
    end
end

function damage_update()
    local x = player.x
    local y = player.y
    local w = player.w
    local h = player.h

    local x1 = 0
    local x2 = 0

    if not player.flip then
        x1 = x+3
        x2 = x+w+2
    else
        x1 = x+1
        x2 = x+w
    end

    local y1 = y+1
    local y2 = y+h-1

    for i=1,8 do
        local hazard = hazards[i]
        if detect_collision(hazard, x1, y1) or detect_collision(hazard, x2, y1)  or detect_collision(hazard, x1, y2) or detect_collision(hazard, x2, y2) then
            damage()
            text="poop"
        else
            text="fart"
        end
    end
end

function detect_collision(box, x, y)
    if (box.x1 <= x and box.x2 >= x and box.y1 <= y and box.y2 >= y) then
        return true
    else
        return false
    end
end

function battery_collision()
    local x = player.x
    local y = player.y
    local w = player.w
    local h = player.h

    local x1 = x-w+1
    local x2 = x+w+7
    local y1 = y-h+3
    local y2 = y+h

    x1 /= 8
    x2 /= 8
    y1 /= 8
    y2 /= 8

    if battery.x >= x1 and battery.x <= x2 and battery.y >= y1 and battery.y <= y2  then
        return true
    else
        return false
    end
end

function health_update()
    local health = player.health
    if health == 2 then
        heart3.sp = 96
    elseif health == 1 then
        heart2.sp = 96
    elseif health == 0 then
        heart1.sp = 96
    end
end

function damage()
    sfx(3)
    player.health -= 1
    if player.health == 0 then
        game_over = true
        message = "you died"
        sfx(10, 1)
    else
        player.x = player.spawn_x
        player.y = player.spawn_y
    end
end

function player_animate()
    if time()-player.anim>.1 then
        player.anim = time()

        if player.flip then
            player.antenna = player.antenna - 1
            if player.antenna < 0 then
                player.antenna = 7
            end
        else
            player.antenna = (player.antenna + 1) % 8
        end

        if player.running then
            player.sp = 16 + (player.running_state + (player.antenna * 4))
            if player.sp > 47 then
                player.sp = player.sp % 47 + 15
            end
            player.running_state = (player.running_state + 1) % 4
        else
            player.running_state = 0
        end

        if player.jumping then
            player.jumping_state = (player.jumping_state + 1) % 2
            player.sp = 48 + player.jumping_state + (player.antenna * 2)
            if player.sp > 63 then
                player.sp = player.sp % 63 + 47
            end
        elseif player.falling then
            local glide_offset = 0
            if player.gliding then 
                glide_offset = 64
            end

            player.jumping_state = (player.jumping_state + 1) % 2
            player.sp = 64 + player.jumping_state + (player.antenna * 2) + glide_offset
            if player.sp > 79 and not player.gliding then
                player.sp = player.sp % 79 + 63
            elseif player.sp > 143 and player.gliding then
                player.sp = player.sp % 143 + 127
            end
        else
            player.jumping_state = 0
        end

        if not player.jumping and not player.falling and not player.running then
            player.sp = 1 + player.antenna
        end
    end
end

function _draw()
    if not game_over then
        cls()
        map(0,0)
        spr(player.sp, player.x, player.y,1,1,player.flip)
        spr(heart1.sp, 8, 120, 1, 1, false)
        spr(heart2.sp, 16, 120, 1, 1, false)
        spr(heart3.sp, 24, 120, 1, 1, false)
        spr(battery.sp, battery.x * 8, battery.y * 8, 1, 1, false)
        print("score: " .. player.score, 87, 122, 0)
        print("time: " .. (time_limit - current_time), 1.8, 1.8, 0)
        print("press x to grab", 64, 1.8, 0)
    else
        cls()
        print("game over...\n" .. message .. "\nyour score was: " .. player.score .. "\npress z to restart", 0, 0, 7)
    end
end

function collide_map(obj, aim, flag)
    local x = obj.x
    local y = obj.y
    local w = obj.w
    local h = obj.h

    local x1 = 0
    local x2 = 0
    local y1 = 0
    local y2 = 0

    if aim == "left" then
        x1 = x-1
        x2 = x
        y1 = y
        y2 = y+h-4
    elseif aim == "right" then
        x1 = x+w+4
        x2 = x+w+4
        y1 = y
        y2 = y+h-4
    elseif aim == "up" then
        x1 = x
        x2 = x+w
        y1 = y-3
        y2 = y
    elseif aim == "down" then
        x1 = x+2
        x2 = x+w+2
        y1 = y+h
        y2 = y+h
    end

    x1 /= 8
    x2 /= 8 
    y1 /= 8
    y2 /= 8

    

    if fget(mget(x1,y1), flag) or fget(mget(x1,y2), flag) or fget(mget(x2,y1), flag) or fget(mget(x2,y2), flag) then
        return true
    else
        return false
    end
end