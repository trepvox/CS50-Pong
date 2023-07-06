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

    -- "seed" the RNG so that it is always calling random
    -- uses current time, since it will be different every time you start the program-
    math.randomseed(os.time())

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
    

    -- paddle positions on the Y axis (can move up or down only)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50

    --veloci ty and position for ball at the start
    ballX = VIRTUAL_WIDTH / 2 - 2
    ballY = VIRTUAL_WIDTH / 2 - 2 

    -- math.random returns a random value between the left and right number
    ballDX = math.random(2) == 1 and 100 or -100
    ballDY = math.random(-50, 50)  

    -- game state variabnle used to transition between different parts of the game
    -- (use this for beginning, menus, main game, high score lists, and more)
    -- we will use this to determine behavior during the render and updates
    gameState = 'start'
end


function love.update(dt)
    --player 1 movement
    if love.keyboard.isDown('w') then
        -- add negative paddel speed to current Y scaled by detla Time
        --math.max returns the greater values and ensure that we don't go above the top edge
        player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('s') then
        -- add positive paddle speed to current Y scaled by deltaTime
        --math.min reutnrs lesser valuees and stops the ball at the bottom edge of the screen.
        player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        -- add negative paddle speed to current Y scaled by deltaTime
        player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('down') then
        -- add positive paddle speed to current Y scaled by deltaTime
        player2Y = match.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
    end

    -- updates ball based on it's DX and DY speed only when in play
    -- scale the velocity by dt so movement is independent of the framerate.
    if gameState == 'play' then
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
    end
end

-- keyboard handing called by Love each frame, passes in the key we pressed so accessible.

function love.keypressed(key)
    -- key can be acces by a string name
    if key == 'escape' then
        -- function love gives to terminate app
        love.event.quit()
    
    -- pressing enter during start phase will begin the play mode
    -- when in play the ball will begin to move in a random direction
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else 
            gameState = 'start'

            --start ball position on screen
            ballX = VIRTUAL_WIDTH / 2 - 2
            ballY = VIRTUAL_HEIGHT / 2 - 2

            -- give ball x and y speed a random starting value
            -- the and/pr is Lua's way of accomplishing ternary operations like in programming language C
            ballDX = math.random(2) == 1 and 100 or -100
            ballDY = math.random(-50, 50) * 1.5
        end
    end
end

function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- clear the screen with set color, in this case it's to be similar to original pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- draw welcome text toward the top of screen
    love.graphics.setFont(smallFont)
    
    if gameState == 'start' then 
        love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Hello Play State!', 0, 20, VIRTUAL_WIDTH, 'center')
    end

    -- paddles are simply rectangle we draw at certain point, so is the ball
    -- left side paddle
    love.graphics.rectangle('fill', 10, 30, 5, 20)

    --right side paddel
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

    -- ball renders in center
    -- replaced the numbers from before with ballX and ballY
    love.graphics.rectangle('fill', ballX, ballY, 4, 4)

    -- end rendering at virtual resolution
    push:apply('end')
end
