-- push is a libary that will allow us to draw a game in a virtual resolution. Creates a retro aesthetic
push = require 'push'

WINDOW_HEIGHT = 1280
WINDOW_WIDTH = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- love.load runs when game starts up but only then
function love.load()
    -- use nearest-neighbor filtering on upscaling or downscaling to prevent blurring of text and graphics
    -- remove this function to see a difference
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- starts the virtual resolution which renders within the window no matter dimensions. replaces love.window.setMode call from pong-0
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT {
        fullscreen = false,
        resizeable = false,
        vsync = true
    })
end

-- keyboard handing called by Love each frame, passes in the key we pressed so accessible.

function love.keypressed(key)
    -- key can be acces by a string name
    if key == 'escape' then
        -- function love gives to terminate app
        love.event.quit()
    end
end

function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- condensed down to one line from pong-0
    love.graphics.printf('Hello Pong!', 0, VIRTUAL_HEIGHT / 2 -6, VIRTUAL_WIDTH, 'center')

    -- end rendering at virtual resolution
    push:apply('end')
end
