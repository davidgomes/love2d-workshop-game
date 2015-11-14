-- Verifica se dois retangulos colidem
function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
    x2 < x1 + w1 and
    y1 < y2 + h2 and
    y2 < y1 + h1
end

-- Funcao que inicializa as variaveis do jogo
function startGame()
  player = { x=300, y=400, score=0, speed=200, bulletSpeed=750, canShoot=true }
  bullets = {}
  enemies = {}
  enemySpeed = 70
  currentState = "game"
end

function love.load()
  startGame()

  playerImage = love.graphics.newImage("nave.png")
  backgroundImage = love.graphics.newImage("background.jpg")
  bulletImage = love.graphics.newImage("bullet.png")
  enemyImage = love.graphics.newImage("enemy.png")

  coolFont = love.graphics.newFont("ProggySquareTT.ttf", 50)
  love.graphics.setFont(coolFont)
end

function love.update(dt)
  if currentState == "game" then
    if love.keyboard.isDown("w") and player.y > 0 then
      player.y = player.y - player.speed * dt
    end

    if love.keyboard.isDown("a") and player.x > 0 then
      player.x = player.x - player.speed * dt
    end

    if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
      player.y = player.y + player.speed * dt
    end

    if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
      player.x = player.x + player.speed * dt
    end

    if love.mouse.isDown("l") then
      if player.canShoot == true then
        local shootSound = love.audio.newSource("shoot.wav", "static")
        shootSound:play()

        newBullet = { x=player.x, y=player.y }

        local angle = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)

        newBullet.dirX = player.bulletSpeed * math.cos(angle)
        newBullet.dirY = player.bulletSpeed * math.sin(angle)

        table.insert(bullets, newBullet)

        player.canShoot = false
      end
    else
      player.canShoot = true
    end

    if math.random() < 0.05 then
      local newEnemy = { x= math.random() * 800,
                         y= -50}
      table.insert(enemies, newEnemy)
    end

    for i=#enemies, 1, -1 do
      if checkCollision(enemies[i].x, enemies[i].y, enemyImage:getWidth(), enemyImage:getHeight(), player.x, player.y, playerImage:getWidth(), playerImage:getHeight()) then
        currentState = "gameover"
      end
    end

    for i, bullet in ipairs(bullets) do
      bullet.x = bullet.x + bullet.dirX * dt
      bullet.y = bullet.y + bullet.dirY * dt

      for u=#enemies, 1, -1 do
        if checkCollision(bullet.x, bullet.y,
                          bulletImage:getWidth(), bulletImage:getHeight(), enemies[u].x, enemies[u].y, enemyImage:getWidth(), enemyImage:getHeight()) == true then
          player.score = player.score + 1

          local explosionSound = love.audio.newSource("explosion.wav", "static")
          explosionSound:play()
          
          table.remove(enemies, u)
        end
      end
    end

    for i=1, #enemies do
      if enemies[i].x < player.x then
        enemies[i].x = enemies[i].x + enemySpeed * dt
      elseif enemies[i].x > player.x then
        enemies[i].x = enemies[i].x - enemySpeed * dt
      end

      if enemies[i].y < player.y then
        enemies[i].y = enemies[i].y + enemySpeed * dt
      elseif enemies[i].y > player.y then
        enemies[i].y = enemies[i].y - enemySpeed * dt
      end
    end
  elseif currentState == "gameover" then
    if love.keyboard.isDown("k") then
      startGame()
    end
  end
end

function love.draw()
  if currentState == "game" then
    love.graphics.draw(backgroundImage, 0, 0)
    love.graphics.draw(playerImage, player.x, player.y,
                       math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x), 1, 1, playerImage:getWidth() / 2, playerImage:getHeight() / 2)

    for i=1, #bullets do
      love.graphics.draw(bulletImage, bullets[i].x, bullets[i].y)
    end

    for i=1, #enemies do
      love.graphics.draw(enemyImage, enemies[i].x, enemies[i].y, math.atan2(player.y - enemies[i].y, player.x - enemies[i].x) + math.pi)
    end

    love.graphics.print(player.score, 20, 20)
  elseif currentState == "gameover" then
    love.graphics.print("Game Over, press K to start again.", 20, 20)
    love.graphics.print("Your score was: " .. player.score, 20, 100)
  end
end
