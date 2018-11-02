local game = {}

function game:init()
    --effect = moonshine(moonshine.effects.vignette)
    --effect.vignette.radius = 0.8
    --effect.vignette.softness = 0.9
    --effect.vignette.opacity = 0.4

    --effect = moonshine(moonshine.effects.desaturate)
    --effect = moonshine(moonshine.effects.posterize)
    --effect = moonshine(moonshine.effects.pixelate)
    --effect = moonshine(moonshine.effects.godsray)

    -- 10x10 world
    -- 0 is floor
    -- 1 is wall
    game.world = {
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,0,0,0,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,1,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    }

    -- player's state
    -- position, in pixel coordinates
    -- rotation, in radians, 0 is +x
    game.player = {
        x = 2, --* CONFIG.NODE_SIZE,
        y = 2, --* CONFIG.NODE_SIZE,
        z = 0,
        vz = 0, -- speed in the z direction
        rot = 0
    }
    game.fluke = {}

    math.randomseed(os.time())

    game.fluke.x = math.random() * CONFIG.WORLD_SIZE -- * CONFIG.NODE_SIZE * CONFIG.WORLD_SIZE
    game.fluke.y = math.random() * CONFIG.WORLD_SIZE -- * CONFIG.NODE_SIZE * CONFIG.WORLD_SIZE

    angle = math.random() * math.pi * 2
    game.fluke.vx = CONFIG.FLUKE_SPEED * math.cos(angle)
    game.fluke.vy = CONFIG.FLUKE_SPEED * math.sin(angle)

    game.staticBurst = love.audio.newSource(love.sound.newSoundData(math.floor(.2 * 44100), 44100, 16, 1))

    game.renderModes = {"3d", "3d_curved", "map", "map_curved"}
    game.renderMode = 1
end

function game:update(dt)
    local t1 = os.clock()
    -- music
    if not game.staticBurst:isPlaying() then
        local samples = math.floor(dt*2 * 44100)
        local data = love.sound.newSoundData(samples, 44100, 16, 1)

        dist = math.sqrt((game.player.x - game.fluke.x)^2 + (game.player.y - game.fluke.y)^2)
        for i = 1,samples-1 do
            --[[
            data:setSample(i, game.player.x/(CONFIG.NODE_SIZE * CONFIG.WORLD_SIZE)*math.sin(0.5*i*game.player.y/(CONFIG.NODE_SIZE * CONFIG.WORLD_SIZE))
                + game.player.y/(CONFIG.NODE_SIZE * CONFIG.WORLD_SIZE)*math.sin(0.25*i*game.player.x/(CONFIG.NODE_SIZE * CONFIG.WORLD_SIZE)))
            --]]
            --data:setSample(i, math.sin(1000/dist*i))
            data:setSample(i, math.sin(math.pi/2*i)/dist^2*1000)

        end
        game.staticBurst = love.audio.newSource(data)
        --love.audio.play(game.staticBurst)
    end

    -- fluke
    game.fluke.x = game.fluke.x + game.fluke.vx * dt
    game.fluke.y = game.fluke.y + game.fluke.vy * dt

    if game.fluke.x < 0 or game.fluke.x > CONFIG.WORLD_SIZE then
        game.fluke.vx = -game.fluke.vx
        game.fluke.x = game.fluke.x + game.fluke.vx * dt
    end
    if game.fluke.y < 0 or game.fluke.y > CONFIG.WORLD_SIZE then
        game.fluke.vy = -game.fluke.vy
        game.fluke.y = game.fluke.y + game.fluke.vy * dt
    end

    -- player
    local last_pos = {
        x = game.player.x,
        y = game.player.y
    }

    if love.keyboard.isDown("w") then
        game.player.x = game.player.x + math.cos(game.player.rot) * CONFIG.PLAYER_SPEED * dt
        game.player.y = game.player.y + math.sin(game.player.rot) * CONFIG.PLAYER_SPEED * dt
    end
    if love.keyboard.isDown("e") then
        game.player.x = game.player.x + math.cos(game.player.rot + math.pi/2) * CONFIG.PLAYER_SPEED * dt
        game.player.y = game.player.y + math.sin(game.player.rot + math.pi/2) * CONFIG.PLAYER_SPEED * dt
    end
    if love.keyboard.isDown("s") then
        game.player.x = game.player.x - math.cos(game.player.rot) * CONFIG.PLAYER_SPEED * dt
        game.player.y = game.player.y - math.sin(game.player.rot) * CONFIG.PLAYER_SPEED * dt
    end
    if love.keyboard.isDown("q") then
        game.player.x = game.player.x + math.cos(game.player.rot - math.pi/2) * CONFIG.PLAYER_SPEED * dt
        game.player.y = game.player.y + math.sin(game.player.rot - math.pi/2) * CONFIG.PLAYER_SPEED * dt
    end

    -- collision detection
    if game:isWall(game.player) then
        game.player.x = last_pos.x
        game.player.y = last_pos.y
    end

    if love.keyboard.isDown("a") then
        game.player.rot = game.player.rot - CONFIG.FOV_SPEED * dt
    end
    if love.keyboard.isDown("d") then
        game.player.rot = game.player.rot + CONFIG.FOV_SPEED * dt
    end
    if love.keyboard.isDown("space") then
        if game.player.z == 0 then
            game.player.vz = CONFIG.JUMP_SPEED
            game.player.z = game.player.z + game.player.vz * dt
        end
    end

    -- jump
    if game.player.z <= 0 then
        game.player.vz = 0
        game.player.z = 0
    else
        game.player.z = game.player.z + game.player.vz * dt
        game.player.vz = game.player.vz + CONFIG.GRAV_ACC * dt
    end
end

function game:draw()
    local t1 = os.clock()
    function sine(f,t)
        return (math.sin(f*t/500)+1)/2
        --return (math.sin(f*t/100)+1)/2
    end

    --effect.vignette.color = {255*sine(math.sqrt(31),t1*50),255*sine(math.sqrt(21),t1*50),255*sine(math.sqrt(5),t1*50)}

    --effect(function()

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if game.renderModes[game.renderMode] == "3d" or game.renderModes[game.renderMode] == "3d_curved" then

        -- draw floor & ceiling
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle('fill', 0, h/2 + game.player.z, w, h)
        love.graphics.setColor(0.2,0.1,0.9)
        love.graphics.rectangle('fill', 0, 0, w, h/2 + game.player.z)
        love.graphics.setLineWidth(2)

        -- draw walls

        -- render scene
        for i=1,w do
            local rot = game.player.rot + (i - w/2) * CONFIG.FOV/w

            local dist, side = game:getDistanceToObstacle(rot, game.renderModes[game.renderMode] == "3d_curved")
            local shadow = math.min(dist/CONFIG.SHADOW_SIZE,0.5)
            --[[if side == "x" then
                love.graphics.setColor(0.6-shadow,0.6-shadow,0.6-shadow)
            elseif side == "y" then
                love.graphics.setColor(0.55-shadow, 0.55-shadow,0.55-shadow)
            end
            --]]
            --[[
            if side == "x" then
                if i*math.floor(t1*100) % 10 <= 5 then
                    love.graphics.setColor(0,0,1-math.min(dist/350,1))
                else--if i % 3 == 1 then
                    love.graphics.setColor(1-math.min(dist/350,1),0,0)
                end
            elseif side == "y" then
                if i*math.floor(t1*200) % 10 <= 5 then
                    love.graphics.setColor(0,0,math.min(dist/350,1))
                else--if i % 3 == 1 then
                    love.graphics.setColor(math.min(dist/350,1),0,0)
                end
                --love.graphics.setColor(0, 1-math.min(dist/350,1),0)
            end
            --]]
            --[[
            if side == "x" then
                if i*math.floor(t1*5) % 10 <= 5 then
                    love.graphics.setColor((0.6-shadow)*sine(math.sqrt(2),t1),(0.6-shadow)*sine(math.exp(1),t1),1-math.min(dist/350,1))
                else--if i % 3 == 1 then
                    love.graphics.setColor(1-math.min(dist/350,1),(0.6-shadow)*sine(math.sqrt(7),t1),(0.6-shadow)*sine(math.exp(13),t1))
                end
            elseif side == "y" then
                if i*math.floor(t1*3) % 10 <= 5 then
                    love.graphics.setColor((0.6-shadow)*sine(math.sqrt(32),t1),(0.6-shadow)*sine(math.exp(31),t1),math.min(dist/350,1))
                else--if i % 3 == 1 then
                    love.graphics.setColor(math.min(dist/350,1),(0.6-shadow)*sine(math.sqrt(5),t1),(0.6-shadow)*sine(math.exp(11),t1))
                end
                --love.graphics.setColor(0, 1-math.min(dist/350,1),0)
            end
            --]]
            --[[
            if side == "x" then
                love.graphics.setColor((0.6-shadow)*sine(math.sqrt(2),t1),(0.6-shadow)*sine(math.exp(1),t1),(0.6-shadow)*sine(math.sqrt(13),t1))
            elseif side == "y" then
                love.graphics.setColor((0.55-shadow)*sine(7,t1), (0.55-shadow)*sine(math.pi*2,t1),(0.55-shadow)*sine(13,t1))
            end
            --]]
            --[[
            if side == "x" then
                love.graphics.setColor((0.6-shadow)*sine(math.sqrt(2),game.player.x)*sine(math.sqrt(5),t1),
                    (0.6-shadow)*sine(math.exp(1)*sine(math.sqrt(7),t1),game.player.y),
                    (0.6-shadow)*sine(math.sqrt(13)*sine(math.sqrt(11),t1),game.player.x))
            elseif side == "y" then
                love.graphics.setColor((0.55-shadow)*sine(7,game.player.y)*sine(math.sqrt(31),t1),
                    (0.55-shadow)*sine(math.pi*2,game.player.x)*sine(math.sqrt(13),t1),
                    (0.55-shadow)*sine(13,game.player.y)*sine(math.sqrt(math.pi),t1))
            end
            --]]
            ----[[
            shadow = shadow*4
            if side == "x" then
                love.graphics.setColor(math.exp(-shadow)*sine(math.sqrt(2),game.player.x)*sine(math.sqrt(5),t1),
                    math.exp(-shadow)*sine(math.exp(1)*sine(math.sqrt(7),t1),game.player.y),
                    math.exp(-shadow)*sine(math.sqrt(13)*sine(math.sqrt(11),t1),game.player.x))
            elseif side == "y" then
                love.graphics.setColor(math.exp(-shadow)*sine(7,game.player.y)*sine(math.sqrt(31),t1),
                    math.exp(-shadow)*sine(math.pi*2,game.player.x)*sine(math.sqrt(13),t1),
                    math.exp(-shadow)*sine(13,game.player.y)*sine(math.sqrt(math.pi),t1))
            end
            --]]
            love.graphics.line(i, game.player.z + h/2 - 500/dist, i, game.player.z + h/2 + 500/dist)
            --[[
            for z=math.floor(game.player.z + h/2 - 10000/dist), math.floor(game.player.z + h/2 + 10000/dist) do
                shadow = shadow
                shadow = math.sqrt((shadow/100)^2 + (z/300)^2)
                if side == "x" then
                    love.graphics.setColor(math.exp(-shadow)*sine(math.sqrt(2),game.player.x)*sine(math.sqrt(5),t1),
                        math.exp(-shadow)*sine(math.exp(1)*sine(math.sqrt(7),t1),game.player.y),
                        math.exp(-shadow)*sine(math.sqrt(13)*sine(math.sqrt(11),t1),game.player.x))
                elseif side == "y" then
                    love.graphics.setColor(math.exp(-shadow)*sine(7,game.player.y)*sine(math.sqrt(31),t1),
                        math.exp(-shadow)*sine(math.pi*2,game.player.x)*sine(math.sqrt(13),t1),
                        math.exp(-shadow)*sine(13,game.player.y)*sine(math.sqrt(math.pi),t1))
                end

                love.graphics.points(i, z)
            end
            --]]
        end

    -- render map
    elseif game.renderModes[game.renderMode] == "map" or game.renderModes[game.renderMode] == "map_curved" then
        local n_w = w / CONFIG.NODE_SIZE
        local n_h = h / CONFIG.NODE_SIZE

        for i,v in ipairs(game.world) do
            x = ((i - 1) % CONFIG.WORLD_SIZE) * n_w
            y = (math.floor((i - 1) / CONFIG.WORLD_SIZE)) * n_h
            if v == 1 then
                love.graphics.setColor(0.70, 0.63, 0.05)
                love.graphics.rectangle("fill", x, y, n_w, n_h)
            end
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", x, y, n_w, n_h)
        end

        --[[
        love.graphics.setColor(1, 0.42, 0.64)
        love.graphics.arc("fill", game.player.x, game.player.y,
            CONFIG.FOV_TRIANGLE_SIZE,
            game.player.rot + CONFIG.FOV/2,
            game.player.rot - CONFIG.FOV/2)
        --]]
        love.graphics.setColor(0.42, 0.63, 0.05)
        love.graphics.circle("fill", game.player.x * n_w, game.player.y * n_h, CONFIG.NODE_SIZE/4)

        love.graphics.setColor(0, 1, 0)
        for i=-50,50 do
            local rot = game.player.rot + i * CONFIG.FOV/100

            dist, side, points = game:getDistanceToObstacle(rot, game.renderModes[game.renderMode] == "map_curved", n_w, n_h)
            love.graphics.line(points)
            --[[
            love.graphics.line(game.player.x, game.player.y,
                game.player.x + math.cos(rot) * dist,
                game.player.y + math.sin(rot) * dist)
            --]]
        end

        love.graphics.setColor(0.82, 0.63, 0.05)
        love.graphics.circle("fill", game.fluke.x * n_w, game.fluke.y * n_h, CONFIG.NODE_SIZE/4)

        --]]
        local t2 = os.clock()
        local fps = string.format("FPS: %.0f", 1/(t2 - t1))
        love.graphics.print(fps, w - 100, 10)
    end
    --end)
end

function game:getDistanceToObstacle(angle,bend, n_w, n_h)
    if not n_w then
        n_w = 1
    end
    if not n_h then
        n_h = 1
    end

    local distance_so_far = 0

    local points = {}

    local current_pos = {
        x = game.player.x,
        y = game.player.y
    }

    table.insert(points, current_pos.x * n_w)
    table.insert(points, current_pos.y * n_h)

    local step = 0.1
    local dp = {
        x = step * math.cos(angle),
        y = step * math.sin(angle)
    }

    for i=1,250 do
            local isWall, ind = game:isWall(current_pos)
        if isWall then
            local wallY = math.floor(ind / CONFIG.WORLD_SIZE)
            local wallX = (ind % CONFIG.WORLD_SIZE)
            local dx = current_pos.x - wallX + 1/2
            local dy = current_pos.y - wallY - 1/2
           
            local angle_in = math.atan(dy/dx) + math.pi/4
 
            if CONFIG.FISH_EYE_CORRECTION then
                if math.tan(angle_in) > 0 then
                    return distance_so_far * math.cos((angle - game.player.rot) * CONFIG.FISH_EYE_FACTOR), "x", points
                else
                    return distance_so_far * math.cos((angle - game.player.rot) * CONFIG.FISH_EYE_FACTOR), "y", points
                end
            else
                if math.tan(angle_in) > 0 then
                    return distance_so_far, "x", points
                else
                    return distance_so_far, "y", points
                end
            end
        else
            inv_fac = math.sqrt((game.fluke.x - current_pos.x)^2 + (game.fluke.y - current_pos.y)^2)

            a = {
                x = CONFIG.FLUKE_STRENGTH * (game.fluke.x - current_pos.x)/inv_fac,
                y = CONFIG.FLUKE_STRENGTH * (game.fluke.x - current_pos.x)/inv_fac
            }

            if bend then
                dp.x = dp.x + a.x * 0.1
                dp.y = dp.y + a.y * 0.1
            end

            mag = math.sqrt(dp.x^2 + dp.y^2)

            dp.x = dp.x / mag * step
            dp.y = dp.y / mag * step

            current_pos.x = current_pos.x + dp.x * 0.8
            current_pos.y = current_pos.y + dp.y * 0.8
            distance_so_far = distance_so_far + step * 0.8

            table.insert(points, current_pos.x * n_w)
            table.insert(points, current_pos.y * n_h)
        end
    end

    return distance_so_far, "x", points
end

function game:isWall(pos)
    i = math.ceil(pos.x) + math.floor(pos.y) * CONFIG.WORLD_SIZE
    if game.world[i] == 1 then
        return true, i
    else
        return false, i
    end
end

function game:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "tab" then
        game.renderMode = (game.renderMode + 1) % (#game.renderModes + 1)
        if game.renderMode == 0 then
            game.renderMode = 1
        end
    end
    if key == "1" then
        game.renderMode = 1
    elseif key == "2" then
        game.renderMode = 2
    elseif key == "3" then
        game.renderMode = 3
    elseif key == "4" then
        game.renderMode = 4
    end
end

return game
