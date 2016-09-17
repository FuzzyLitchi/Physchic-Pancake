Camera = {}

function Camera:make(startX, startY, startScaleX, startScaleY, startRotation)
  camera = {x = startX, y = startY, scaleX = startScaleX, scaleY = startScaleY, rotation = startRotation}

  camera.scaleX, camera.scaleY = 960/love.graphics.getWidth(),960/love.graphics.getWidth()

  function camera:set()
    love.graphics.push()
    love.graphics.rotate(-self.rotation)
    love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
    love.graphics.translate(-self.x, -self.y)
  end

  function camera:unset()
    love.graphics.pop()
  end

  function camera:windowSize()
    return love.window:getWidth() * self.scaleX, love.window.getHeight() * self.scaleY
  end

  function camera:move(dx, dy)
    self.x = self.x + (dx or 0)
    self.y = self.y + (dy or 0)
  end

  function camera:rotate(dr)
    self.rotation = self.rotation + dr
  end

  function camera:scale(sx, sy)
    sx = sx or 1
    self.scaleX = self.scaleX * sx
    self.scaleY = self.scaleY * (sy or sx)
  end

  function camera:setPosition(x, y)
    self.x = x or self.x
    self.y = y or self.y
  end

  function camera:setScale(sx, sy)
    self.scaleX = sx or self.scaleX
    self.scaleY = sy or self.scaleY
  end

  function camera:mousePosition()
    return love.mouse.getX() * self.scaleX + self.x, love.mouse.getY() * self.scaleY + self.y
  end

  function camera:mouseX()
    return love.mouse.getX() * self.scaleX + self.x
  end

  function camera:mouseY()
    return love.mouse.getY() * self.scaleY + self.y
  end

  return camera
end

return Camera
