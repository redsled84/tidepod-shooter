local gameScore = 0

local player = {
  x = 100,
  y = 100,
  rot = 0,
  moveSpeed = 400,
  rotSpeed = 5,
  rot = 0,
  image = love.graphics.newImage("player.png"),
  friction = 10,
  decelerator = 1,
  bullets = {},
  hit = false,
  hitTimer = .4,
  maxHitTimer = .4
}
player.width = player.image:getWidth()
player.height = player.image:getHeight()

local tidepodImage = love.graphics.newImage("tidepod.png")
local tidepods = {}
local tidepodSpeeds = {
  150,
  250,
  150,
  220,
  270,
  145,
  50,
  168
}

function player:shoot(key)
  if key == "space" and not self.hit then
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
  if self.hit then return end

  if love.keyboard.isDown("right") then
    self.rot = self.rot + self.rotSpeed * dt
  elseif love.keyboard.isDown("left") then
    self.rot = self.rot - self.rotSpeed * dt
  end

  if love.keyboard.isDown("up") then
    self.x = self.x + self.moveSpeed * dt * math.cos(self.rot)
    self.y = self.y + self.moveSpeed * dt * math.sin(self.rot)

    self.decelerator = 1
  elseif not player.hit then
    self.x = self.x + self.moveSpeed * (1/self.decelerator) * dt * math.cos(self.rot) 
    self.y = self.y + self.moveSpeed * (1/self.decelerator) * dt * math.sin(self.rot) 

    if self.decelerator < 3 then
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

function player:updateHitTimer(dt)
  if self.hit then
    self.hitTimer = self.hitTimer - dt

    self.x = self.x + self.moveSpeed * dt * math.cos(self.rot)
    self.y = self.y + self.moveSpeed * dt * math.sin(self.rot)

    if self.hitTimer < 0 then
      self.hitTimer = self.maxHitTimer
      self.hit = false
    end
  end
end

function player:keepInWindow()
  player.x = player.x % love.graphics.getWidth()
  player.y = player.y % love.graphics.getHeight()
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
    size = math.random(1, 2)
  }

  -- left
  if side == 1 then
    tide.x = -300
    tide.y = love.graphics.getHeight() / 2
    tide.rot = math.random(1000 * -math.pi / 5, 1000 * math.pi / 5) / 1000
  -- top
  elseif side == 2 then
    tide.x = love.graphics.getWidth() / 2
    tide.y = -300
    tide.rot = math.random(1000 * math.pi / 5, 1000 * 3 * math.pi / 5) / 1000
  -- right
  elseif side == 3 then
    tide.x = love.graphics.getWidth() + 300
    tide.y = love.graphics.getHeight() / 2
    tide.rot = math.random(1000 * 3 * math.pi / 5, 1000 * 7 * math.pi / 5) / 1000
  -- bottom
  elseif side == 4 then
    tide.x = love.graphics.getWidth() / 2
    tide.y = love.graphics.getHeight() + 300
    tide.rot = math.random(1000 * 5 * math.pi / 4, 1000 * 7 * math.pi / 4) / 1000
  end

  tidepods[#tidepods+1] = tide
end

function updateTidepods(dt)
  for i = #tidepods, 1, -1 do
    local tidepod = tidepods[i]

    -- update position
    tidepod.x = math.floor(tidepod.x + tidepod.moveSpeed * math.cos(tidepod.rot) * dt)
    tidepod.y = math.floor(tidepod.y + tidepod.moveSpeed * math.sin(tidepod.rot) * dt)

    local scale = tidepod.size == 1 and 1 or .5
    local width = tidepodImage:getWidth() * scale
    local height = tidepodImage:getHeight() * scale

    -- check if collides with player bullets, remove if true
    for j = #player.bullets, 1, -1 do
      local bul = player.bullets[j]

      -- need to account for drawing offset of tidepods
      if bul.x + bul.radius > tidepod.x - width * (1/2) * scale
      and bul.x < tidepod.x + width * (1/2) * scale
      and bul.y + bul.radius > tidepod.y - height * (1/2) * scale
      and bul.y < tidepod.y + height * (1/2) * scale then
        if tidepod.size == 1 then
          tidepods[#tidepods+1] = {
            x = tidepod.x,
            y = tidepod.y,
            size = 2,
            moveSpeed = tidepod.moveSpeed,
            rot = tidepod.rot - math.random(1000 * -math.pi / 3, 1000 * -math.pi / 12) / 1000
          }
          tidepods[#tidepods+1] = {
            x = tidepod.x,
            y = tidepod.y,
            size = 2,
            moveSpeed = tidepod.moveSpeed,
            rot = tidepod.rot - math.random(1000 * math.pi / 12, 1000 * math.pi / 3) / 1000
          }
        end

        table.remove(tidepods, i)
        table.remove(player.bullets, j)

        gameScore = gameScore + 1
      end
    end

    -- check if player and tidepod are colliding
    -- need to account for drawing offset of player and tidepods
    if player.x + player.width * (1/2) > tidepod.x - width * (1/2) * scale
    and player.x - player.width * (1/2) < tidepod.x + width * (1/2) * scale
    and player.y + player.height * (1/2) > tidepod.y - height * (1/2) * scale
    and player.y - player.height * (1/2) < tidepod.y + height * (1/2) * scale
    and not player.hit then
      table.remove(tidepods, i)

      local dx = tidepod.x - player.x
      local dy = tidepod.y - player.y
      local rot = math.atan2(dy, dx)

      player.rot = rot * -1
      player.hit = true

      gameScore = gameScore - 1
    end

    -- remove a tidepod whose left the screen
    if math.sqrt((tidepod.x - love.graphics.getWidth()/2) ^ 2
    + (tidepod.y - love.graphics.getHeight()/2)^2) > 1000 then
      table.remove(tidepods, i)
    end
  end
end

function drawTidepods()
  for i = 1, #tidepods do
    local tidepod = tidepods[i]
    local rot = (tidepod.side == 1 or tidepod.side == 3)
      and tidepod.x / 100 or tidepod.y / 100
    local scale = (tidepod.size == 1) and 1 or .5

    love.graphics.setColor(255,255,255)
    love.graphics.draw(tidepodImage, tidepod.x, tidepod.y, rot,
      scale, scale, tidepodImage:getWidth()/2, tidepodImage:getHeight()/2)

    -- tidepod outline
    -- love.graphics.setColor(255,0,0)
    -- love.graphics.rectangle("line",
    --   tidepod.x-tidepodImage:getWidth()*(1/2)*scale,
    --   tidepod.y-tidepodImage:getHeight()*(1/2)*scale,
    --   tidepodImage:getWidth()*scale,
    --   tidepodImage:getHeight()*scale
    -- )
  end
end

function love.load()
  maxTidepods = 20
end

local maxTime = .25
local timer = maxTime

function love.update(dt)
  player:move(dt)
  player:moveBullets(dt)
  player:keepInWindow(dt)
  player:updateHitTimer(dt)

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

local tileSize = 20
local colors = {
  {255, 0, 0},
  {255, 127, 0},
  {255, 255, 0},
  {0, 255, 0},
  {0, 0, 255},
  {139, 0, 255}
}

function drawCancer()
  for i = 1, love.graphics.getWidth()/tileSize do
    for j = 1, love.graphics.getHeight()/tileSize do
      love.graphics.setColor(unpack(colors[math.random(1, #colors)]))
      love.graphics.rectangle("fill", (i-1) * tileSize, (j-1) * tileSize, tileSize, tileSize)

      love.graphics.setColor(0,0,0,200)
      love.graphics.rectangle("fill", (i-1) * tileSize, (j-1) * tileSize, tileSize, tileSize)
    end
  end
end

function love.draw()
  drawCancer()
  player:draw()
  drawTidepods()

  love.graphics.setColor(255,255,255)
  love.graphics.rectangle("fill", 0, 0, 100 + 8 * string.len(tostring(gameScore)), 30)

  -- draw game score
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("Your Score: " .. tostring(gameScore), 10, 10)
end

function love.keypressed(key)
  player:shoot(key)

  if key == "escape" then
    love.event.quit()
  end
  if key == "r" then
    love.event.quit("restart")
  end
end