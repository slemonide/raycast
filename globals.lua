------------------------------------------------------------------------
-- This is the only place where global variables should be defined
-- Feel free to add anything here that is used often enough
------------------------------------------------------------------------

-- Load third-party libraries
Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
suit = require 'lib.suit'
moonshine = require 'lib.moonshine'

-- Load global objects
states = {}
states.menu = {}
states.menu.main =     require "menu.main"
states.menu.single =   require "menu.single"
states.menu.online =   require "menu.online"
states.menu.settings = require "menu.settings"

states.game_over = require "game_over"
states.game =      require "game"
current_game = nil

CONFIG = {
    NODE_SIZE = 30,
    SHADOW_SIZE = 500,
    WORLD_SIZE = 20,
    PLAYER_SPEED = 5,
    JUMP_SPEED = 200,
    GRAV_ACC = -200,

    RAYTRACER_STEP = 0.01,
    RAYTRACER_MAX = 100000,

    -- 4 * math.pi
    FOV = math.pi/2,
    FOV_TRIANGLE_SIZE = 40,
    FOV_SPEED = 100 / 180 * math.pi,
    FISH_EYE_CORRECTION = false,
    FISH_EYE_FACTOR = 0.88,

    FLUKE_SPEED = 5,--5,--100,
    FLUKE_STRENGTH = 0.00006---0.1--0.3 --0.1
}
