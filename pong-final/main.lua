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

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

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
    --adding in between size font
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    
    love.graphics.setFont(smallFont)

    -- set up sound effects, although later can index it and call each entry to play.
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    -- starts window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        -- now means you can adjust the, but need to make the resize function
        resizable = true,
        vsync = true,
        canvas = false
    })
    
    -- paddle positions on the Y axis (can move up or down only)
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    
    -- Score variables, used for tracking score and seeing winner
    player1Score = 0
    player2Score = 0

    -- either going to be 1 or 2, whoever scored on gets the serve next
    servingPlayer = 1

    winningPlayer = 0



    -- game state variabnle used to transition between different parts of the game
    -- (use this for beginning, menus, main game, high score lists, and more)
    -- we will use this to determine behavior during the render and updates
    gameState = 'start'
end

-- the resize function with push
function love.resize(w, h)
    push:resize(w, h)
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
            ball.x = player1.x + 4

            -- keep velocity going in same direction but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else 
                ball.dy = math.random(10, 150)
            end 

            -- play the paddle hit sound every time the ball collides with the paddle
            sounds['paddle_hit']:play()
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

            -- play the paddle hit sound every time the ball collides with the paddle
            sounds['paddle_hit']:play()
        end

        -- looks out for upper and lower screen borders
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            -- plays the wall hit sound effect
            sounds['wall_hit']:play()
        end

        -- the -4 is there to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then 
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end 

    -- if the ball reaches the left or right edge of the screen, update score of other player, reset the ball, and start next round
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            -- if player 2 has score of 10, their declaredd the winner.
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

-- player 1
    if player1:moveDown(ball) then
        player1.dy = -PADDLE_SPEED
    elseif player1:moveUp(ball) then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end
    
    -- player 2
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
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
            gameState = 'serve'
        -- added the elseif to allow for serving and then continue to play afterwards
        elseif gameState == 'serve' then 
            gameState = 'play'
        elseif gameState == 'done' then
            -- game is simply in a restart phase, but set the serving player to the loser instead of random or winner.
            gameState = 'serve'

            ball:reset()

            --reset scores
            player1Score = 0
            player2Score = 0

            -- and decide on who's serving first
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    -- begin rendering at virtual resolution
    push:start()

    -- clear the screen with set color, in this case it's to be similar to original pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    
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
    elseif gameState == 'done' then
        --UI message here for winner and instructions how to play again
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to play again!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- show score first so ball will move over the score freely.
    displayScore()

    --render paddles from their class render method
    player1:render()
    player2:render()
    ball:render()

    -- new function just to demonstrate how to see FPS in Love.
    displayFPS()
 
    -- end rendering at virtual resolution
    push:finish()
end

-- for rendering current FPS
function displayFPS()
    -- simple FPS display across all states of the application
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    -- draw score on left and right side of screen for  each players
    -- make sure to change fonts first before printing though
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
    VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, 
    VIRTUAL_HEIGHT / 3)
end