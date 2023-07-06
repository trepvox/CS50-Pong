-- push is a libary that will allow us to draw a game in a virtual resolution. Creates a retro aesthetic
push = require 'push'

WINDOW_HEIGHT = 1280
WINDOW_WIDTH = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- sets speed at which the paddles can move, multiplied by dt in update function
PADDLE_SPEED = 200

-- love.load runs when game starts up but only then
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- more classic font object we can use for any text now once file brought into folder
    smallFont = love.graphics.newFont('font.ttf', 8)

    -- larger font for score on screen
    scoreFont = love.graphics.newFont('font.ttf', 32)
    
    -- sets active font to smallFont object
    love.graphics.setFont(smallFont)

    -- starts window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT {
        fullscreen = false,
        resizeable = false,
        vsync = true
    })

    -- creates score variables, used for keeping track for the winner and on screen.
    player1Score = 0
    player2Score = 0

    -- paddle positions on the Y axis (can move up or down only)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50
end

function love.update(dt)
    --player 1 movement
    if love.keyboard.isDown('w') then
        -- add negative paddel speed to current Y scaled by detla Time
        player1Y = player1Y + -PADDLE_SPEED * dt
    elseif love.keyboard.isDown('s') then
        -- add positive paddle speed to current Y scaled by deltaTime
        player2Y = player2Y + PADDLE_SPEED * dt
    end
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
    love.graphics.setFont(smallFont)
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    -- switches font to draw before begins printing to screen
    -- draw score on left and right side of screen
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

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
