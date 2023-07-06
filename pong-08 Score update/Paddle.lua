Paddle = Class{}

-- going to take an x and y for positions along with width and heigh for dimensions.
-- self references this object specifically, but can be done because it's similarly encased like structs in C
function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y 
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:update(dt)
    --math.max is used to be greater than players current calculated y position when pressing UP so doesn't go into the negatives. 
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else 
        -- min is used to make sure we don't go below the bottom of screen minus paddles height (since position is based on top left corner)
        self.y =math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

-- to be callled by love.draw in main, 
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end