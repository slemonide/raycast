require("globals")

function love.load()
    love.graphics.setFont(love.graphics.newFont("assets/unifont-11.0.01.ttf"))

    Gamestate.registerEvents()
--    Gamestate.switch(states.menu.main) -- for development only
    Gamestate.switch(states.game)
end
