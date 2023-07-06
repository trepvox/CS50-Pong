-- push is a libary that will allow us to draw a game in a virtual resolution. Creates a retro aesthetic
push = require 'push'

WINDOW_HEIGHT = 1280
WINDOW_WIDTH = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- love.load runs when game starts up but only then
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- more classic font object we can use for any text now once file brought into folder
    smallFont = love.graphics.newFont('font.ttf', 8)
    
    -- sets active font to smallFont object
    love.graphics.setFont(smallFont)

    -- starts window with virtual resolution
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

    -- clear the screen with set color, in this case it's to be similar to original pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- draw welcome text toward the top of screen
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    -- paddles are simply rectangle we draw at certain point, so is the ball
    -- left side paddle
    love.graphics.rectangle('fill', 10, 30, 5, 20)

    --right side paddel
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

    -- ball
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- end rendering at virtual resolution
    push:apply('end')
end
