WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--  Runs when the game starts up, only once though and starts the game
function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizeable = false,
        vsync = true
    })
end

-- called after updated by love, and draws anything on screen
function love.draw()
    love.graphics.printf(
        'Hello Pong!',          -- text that appears on screen
        0,                      -- starting X point of 0 for center of screen based on width
        WINDOW_HEIGHT / 2 - 6,  -- starting Y point cut in half to be halfway down screen
        WINDOW_WIDTH,           -- number of pixels to center within (the entire screen here)
        'center')               -- alignment mode, can be center, left, or right
end