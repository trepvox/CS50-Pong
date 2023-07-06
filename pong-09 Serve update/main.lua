-- push is a libary that will allow us to draw a game in a virtual resolution. Creates a retro aesthetic
-- https://github.com/Ulydev/push
push = require 'push'

-- class library allows us to represent anything in game as code, rather than tracking many different variables and methods.
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- Paddle class that stores position and dimension for each paddle and logic for rendering them
require 'Paddle'

-- Ball class functions similarly to paddle class but mechanically functions very differently.
require 'Ball'

WINDOW_HEIGHT = 1280
WINDOW_WIDTH = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- sets speed at which the paddles can move, multiplied by dt in update function
PADDLE_SPEED = 200

-- love.load runs when game starts up but only then
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')


    -- "seed" the RNG so that it is always calling random
    -- uses current time, since it will be different every time you start the program-
    math.randomseed(os.time())

    -- more classic font object we can use for any text now once file brought into folder
    smallFont = love.graphics.newFont('font.ttf', 8)

    scoreFont = love.graphics.newFont('font.ttf', 32)
    
    -- sets active font to smallFont object
    love.graphics.setFont(smallFont)

    -- starts window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT {
        fullscreen = false,
        resizeable = false,
        vsync = true
    })
    
    -- Score variables, used for tracking score and seeing winner
    player1Score = 0
    player2Score = 0

    -- either going to be 1 or 2, whoever scored on gets the serve next
    servingPlayer = 1

    -- paddle positions on the Y axis (can move up or down only)
    player1Y = Paddle(10, 30, 5, 20)
    player2Y = Paddle(VIRTUAL_HEIGHT - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- game state variabnle used to transition between different parts of the game
    -- (use this for beginning, menus, main game, high score lists, and more)
    -- we will use this to determine behavior during the render and updates
    gameState = 'start'
end


function love.update(dt)
    -- needed to create a situation for serving off of either players side before play can begin.
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else 
            ball.dx = -math.random(140, 200)
        end

    elseif gameState == 'play' then
        --detect the ball collision with paddles, reversing dx if tru and slightly increasing it, then alter dy based on position of collision
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            -- keep velocity going in same direction but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else 
                ball.dy = math.random(10, 150)
            end 
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
        
            -- keep velocity going in same direction but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else 
                ball.dy = math.random(10, 150)
            end 
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then 
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end 
    end

    -- if the ball reaches the left or right edge of the screen, update score of other player, reset the ball, and start next round
    if ball.x < 0 then
        servingPlayer = 1
        player2Score = player2Score + 1
        ball:reset()
        gameState = 'serve'
    end

    if ball.x > VIRTUAL_WIDTH then
        servingPlayer = 2
        player1Score = player1Score + 1
        ball:reset()
        gameState = 'serve'
    end

    --player 1 movement
    if love.keyboard.isDown('w') then
        player1Y.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1Y.dy = PADDLE_SPEED
    else 
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
       player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2Y.dy = PADDLE_SPEED
    else 
        player2.dy = 0
    end

    -- updates ball based on it's DX and DY speed only when in play
    -- scale the velocity by dt so movement is independent of the framerate.
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
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
        -- added the elseif to allow for serving and then continue to play afterwards
        elseif gameState == 'serve' then 
            gameState = 'play'
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
    
    -- if game starts, then print welcome to pong followed by press enter to begin
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    -- else state of the game is serve and so print the serving player's turn to serve
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    end

    --render paddles from their class render method
    player1:render()
    player2:render()
    ball:render()

    -- new function just to demonstrate how to see FPS in Love.
    displayFPS()

    -- end rendering at virtual resolution
    push:apply('end')
end

-- for rendering current FPS
function displayFPS()
    -- simple FPS display across all states of the application
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    -- draw score on left and right side of screen for  each players
    -- make sure to change fonts first before printing though
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
end