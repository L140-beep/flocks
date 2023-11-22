Boid = {}
Boid.__index = Boid

function Boid:create(x, y)
    local boid = {}
    setmetatable(boid, Boid)
    boid.position = Vector:create(x, y)
    boid.velocity = Vector:create(math.random(-10, 10) / 10, math.random(-10, 10) / 10)
    boid.acceleration = Vector:create(0, 0)
    boid.r = 5
    boid.vertices = {0, - boid.r * 2, -boid.r, boid.r * 2, boid.r, 2 * boid.r}
    boid.maxSpeed = 4
    boid.maxForce = 0.1
    boid.red = 1
    boid.g = 1
    boid.b = 1
    return boid
end

function Boid:update(boids)
    if isSep then
        local sep = self:separate(boids)
        -- sep:mul(4)
        self:applyForce(sep)
    end

    if isAlign then
        local align = self:align(boids)

        self:applyForce(align)

    end

    if isCoh then
        local coh = self:coh(boids)
        self:applyForce(coh)
    end

    self.velocity:add(self.acceleration)
    self.velocity:limit(self.maxSpeed)
    self.position:add(self.velocity)
    self.acceleration:mul(0)
    self:borders()
end

function Boid:applyForce(force)
    self.acceleration:add(force)
end

function Boid:seek(target)
    local desired = target - self.position
    desired:norm()
    desired:mul(self.maxSpeed)
    local steer = desired - self.velocity
    steer:limit(self.maxForce)
    return steer
end

function Boid:coh(boids)
    -- print(self.position)
    local alignDist = 50.
    local steer = Vector:create(0, 0)
    local count = 0
    for i = 0, #boids do
        local boid = boids[i]
        -- local d = self.position:distTo(boid.position)
        
        -- if d > 0 and d < alignDist then
        local pos = boid.position
        -- vel:norm()
        -- vel:div(d)
        steer:add(pos)
        count = count + 1
        -- end
    end
    
    if count > 0 then
        steer:div(count)
    end

    -- if steer:mag() > 0 then
        -- steer:norm()
        -- steer:mul(self.maxSpeed)
        -- print(steer, self.velocity, steer - self.velocity)
        -- steer:sub(self.velocity)
        -- steer:limit(self.maxForce)
    steer = self:seek(steer)
    -- end

    self.red = math.min(255, count/2)
    self.g = math.min(255, count*4)
    self.b = math.min(255, count/2)
    return steer
end

function Boid:align(boids)
    local alignDist = 50.
    local steer = Vector:create(0, 0)
    local count = 0
    steer:add(self.velocity)
    for i = 0, #boids do
        local boid = boids[i]
        local d = self.position:distTo(boid.position)
        
        if d > 0 and d < alignDist then
            local vel = boid.velocity
            -- vel:norm()
            -- vel:div(d)
            steer:add(vel)
            count = count + 1
        end
    end
    
    if count > 0 then
        steer:div(count)
    end

    if steer:mag() > 0 then
        steer:norm()
        steer:mul(self.maxSpeed)
        -- print(steer, self.velocity, steer - self.velocity)
        steer:sub(self.velocity)
        steer:limit(self.maxForce)
    end
    
    self.red = math.min(255, count*2)
    self.g = math.min(255, count*2)
    self.b = math.min(255, count*4)
    return steer
end

function Boid:separate(boids)
    local separation = 25.
    local steer = Vector:create(0, 0)

    local count = 0

    for i = 0, #boids do
        local boid = boids[i]
        local d = self.position:distTo(boid.position)
        
        if d > 0 and d < separation then
            local diff = self.position - boid.position
            diff:norm()
            diff:div(d)
            steer:add(diff)
            count = count + 1
        end

    end

    -- if count > 0 then
        -- steer:div(count)
    -- end

    if steer:mag() > 0 then
        steer:norm()
        steer:mul(self.maxSpeed)
        steer:sub(self.velocity)
        steer:limit(self.maxForce)
    end

    self.red = math.min(255, count*8)
    self.g = math.min(255, count*4)
    self.b = math.min(255, count*4)
    
    return steer
end

function Boid:borders()
    if self.position.x < -self.r then
        self.position.x = width - self.r
    end

    if self.position.x > width + self.r then
        self.position.x = self.r
    end

    if self.position.y < -self.r then
        self.position.y = height - self.r
    end

    if self.position.y > height + self.r then
        self.position.y = self.r
    end
end


function Boid:draw()
    r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(self.red/255, self.g/255, self.b/255)
    local theta = self.velocity:heading() + math.pi / 2
    love.graphics.push()
    love.graphics.translate(self.position.x, self.position.y)
    love.graphics.rotate(theta)
    love.graphics.polygon("fill", self.vertices)
    love.graphics.pop()

    love.graphics.setColor(r, g, b, a)
end

