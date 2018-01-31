local player = {
  x = 100,
  y = 100,
  rot = 0,
  moveSpeed = 400,
  rotSpeed = 4,
  rot = 0,
  image = love.graphics.newImage("player.png"),
  friction = 10,
  decelerator = 1,
  bullets = {}
}

local tidepodImage = love.graphics.newImage("tidepod.png")
local tidepods = {}
local tidepodSpeeds = {
  150,
  150,
  150,
  300,
  300,
  245,
  450,
  268
}

function player:shoot(key)
  if key == "space" then
    local bullet = {
      x = self.x,
      y = self.y,
      moveSpeed = 800,
      rot = self.rot,
      radius = 3
    }
    self.bullets[#self.bullets+1] = bullet
  end
end

function player:move(dt)
  if love.keyboard.isDown("right") then
    self.rot = self.rot + self.rotSpeed * dt
  elseif love.keyboard.isDown("left") then
    self.rot = self.rot - self.rotSpeed * dt
  end

  if love.keyboard.isDown("up") then
    self.x = self.x + self.moveSpeed * dt * math.cos(self.rot)
    self.y = self.y + self.moveSpeed * dt * math.sin(self.rot)

    self.decelerator = 1
  else
    self.x = self.x + self.moveSpeed * (1/self.decelerator) * dt * math.cos(self.rot) 
    self.y = self.y + self.moveSpeed * (1/self.decelerator) * dt * math.sin(self.rot) 

    if self.decelerator < 4 then
      self.decelerator = self.decelerator + self.friction * dt
    end
  end
end

function player:moveBullets(dt)
  for i = #self.bullets, 1, -1 do
    local bul = self.bullets[i]
    if bul.x < 0 or bul.x > love.graphics.getWidth()
    or bul.y < 0 or bul.y > love.graphics.getHeight() then
      table.remove(self.bullets, i)
    else
      bul.x = bul.x + bul.moveSpeed * dt * math.cos(bul.rot)
      bul.y = bul.y + bul.moveSpeed * dt * math.sin(bul.rot)
    end
  end
end

function player:draw()
  love.graphics.setColor(255,255,255)
  love.graphics.draw(self.image, self.x, self.y, self.rot + math.pi / 2, 1, 1,
    self.image:getWidth()/2, self.image:getHeight()/2)

  love.graphics.setColor(255,0,0)
  for i = 1, #self.bullets do
    local bul = self.bullets[i]
    love.graphics.circle("fill", bul.x, bul.y, bul.radius)
  end
end

function addTidepod()
  -- side it comes from
  local side = math.random(1, 4)
  local tide = {
    moveSpeed = tidepodSpeeds[math.random(1, 8)],
    size = math.random(1, 4)
  }
  -- left
  if side == 1 then
    tide.x = -300
    tide.y = love.graphics.getHeight() / 2
    tide.rot = math.random(1000 * -math.pi / 5, 1000 * math.pi / 5) / 1000
  -- up
  elseif side == 2 then
    tide.x = love.graphics.getWidth() / 2
    tide.y = -300
    tide.rot = math.random(1000 * 5 * math.pi / 4, 1000 * 7 * math.pi / 4) / 1000
  -- right
  elseif side == 3 then
    tide.x = love.graphics.getWidth() + 300
    tide.y = love.graphics.getHeight() / 2
    tide.rot = math.random(1000 * 3 * math.pi / 5, 1000 * 7 * math.pi / 5) / 1000
  -- bottom
  elseif side == 4 then
    tide.x = love.graphics.getWidth() / 2
    tide.y = love.graphics.getHeight() + 300
    tide.rot = math.random(1000 * math.pi / 5, 1000 * 3 * math.pi / 5) / 1000
  end
end

function updateTidepods(dt)
  for i = 1, #tidepods do
    local tidepod = tidepods[i]

    -- update position
    -- check if collides with player bullets
  end
end

function love.load()
  maxTidepods = 4
end

function love.update(dt)
  player:move(dt)
  player:moveBullets(dt)

  if timer > 0 then
    timer = timer - dt
  else
    timer = maxTime

    if #tidepods <= maxTidepods then
      addTidepod()
    end
  end

  updateTidepods(dt)
end

function love.draw()
  player:draw()
  drawTidepods()
end

function love.keypressed(key)
  player:shoot(key)
end