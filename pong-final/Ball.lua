Ball = Class{}
-- everything in lua is a table so now we havea class object called Ball with it's own table

function Ball:init(x, y, width, height)
    self.x = x 
    self.y = y 
    self.width = width
    self.height = height

    -- This is for keeping track of velocity on both x and y axis.
    self.dy = math.random(2) == 1 and - 100 or 100
    self.dx = math.random(-50, 50)
end

function Ball:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end 

    return true
end

-- places ball in the middle of the screen, with an initial random velocity on both axes.
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(-50, 50)
end

-- applies velocity to position and scaled by deltaTime
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-- just moving to be created the render in the ball class.
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end