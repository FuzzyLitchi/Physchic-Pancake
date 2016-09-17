local Camera = require "camera"
local utf8 = require("utf8")

level_editor =
{boxes = {},
tiles = {},
oldX=0, oldY=0,
is_loading_map = false,
map_name = ""
}

max_scale = 10
min_scale = 0.1

local sel_tile = 1
local tile_scale = 8

local map = {}
local rectangle = {x, y, active}

function love.load(main)
  camera = Camera:make(0, 0, 960 / love.graphics.getWidth(), 640 / love.graphics.getHeight(), 0)

  love.graphics.setDefaultFilter("nearest", "nearest")
  love.keyboard.setKeyRepeat(true)

  --load tiles
  level_editor:add_tile(0, 0, 0, "banker.png")
  level_editor:add_tile(255, 255, 0, "julian.png")
end

function love.update()
  if not rectangle.active then
    if love.mouse.isDown(1) then
      if love.mouse.getY() > tile_scale and camera:mouseX()>0 and camera:mouseY()>0 then
        temp_x, temp_y = camera:mousePosition()
        temp_x = (temp_x-temp_x%tile_scale)
        temp_y = (temp_y-temp_y%tile_scale)
        level_editor:add_block(convert(camera:mouseX()), convert(camera:mouseY()), sel_tile)
      end
    elseif love.mouse.isDown(2) then
      if love.mouse.getY() > tile_scale and camera:mouseX()>0 and camera:mouseY()>0 then
        temp_x, temp_y = camera:mousePosition()
        temp_x = (temp_x-temp_x%tile_scale)
        temp_y = (temp_y-temp_y%tile_scale)
        level_editor:add_block(convert(camera:mouseX()), convert(camera:mouseY()), nil)
      end
    elseif love.mouse.isDown(3) then
      camera:move((level_editor.oldX-love.mouse.getX()) * camera.scaleX, (level_editor.oldY-love.mouse.getY()) * camera.scaleY)
    end
  end
  level_editor.oldX = love.mouse.getX()
  level_editor.oldY = love.mouse.getY()
end

function love.draw()
  camera:set()
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setColor(0, 0, 0, 122)

  for i=0, love.graphics.getWidth()*camera.scaleX+camera.x, tile_scale do
    love.graphics.line(i, camera.y, i, love.graphics.getHeight()*camera.scaleY+camera.y)
  end

  for i=0, love.graphics.getHeight()*camera.scaleY+camera.y, tile_scale do
    love.graphics.line(camera.x, i, love.graphics.getWidth()*camera.scaleX+camera.x, i)
  end

  love.graphics.setColor(255, 255, 255, 255)

  for x, xv in pairs(map) do
    for y, v in pairs(xv) do
      love.graphics.draw(level_editor.tiles[v].image, x*tile_scale-tile_scale, y*tile_scale-tile_scale)
    end
  end

  love.graphics.setColor(255, 0, 255, 200)
  if rectangle.active then
    for x = smallest(convert(rectangle.x), convert(camera:mouseX())), biggest(convert(rectangle.x), convert(camera:mouseX())) do
      for y = smallest(convert(rectangle.y), convert(camera:mouseY())), biggest(convert(rectangle.y), convert(camera:mouseY())) do
        love.graphics.draw(level_editor.tiles[sel_tile].image, x*tile_scale, y*tile_scale)
      end
    end
  else
    love.graphics.draw(level_editor.tiles[sel_tile].image, camera:mouseX()-camera:mouseX()%tile_scale, camera:mouseY()-camera:mouseY()%tile_scale)
  end

  camera:unset()

  love.graphics.setColor(255, 0, 100)
  love.graphics.printf(level_editor.map_name, 0, 0, love.graphics.getWidth())
end

function love.mousepressed(x, y, button, isTouch)
  if love.keyboard.isDown("lshift") and (button==1 or button==2) then
    rectangle.x = camera:mouseX()
    rectangle.y = camera:mouseY()
    rectangle.active = true
  end
end

function love.mousereleased(x, y, button, isTouch)
  if love.keyboard.isDown("lshift") and button==1 and rectangle.active then
    level_editor:fill(convert(rectangle.x), convert(rectangle.y), convert(camera:mouseX()), convert(camera:mouseY()), sel_tile)
  elseif love.keyboard.isDown("lshift") and button==2  and rectangle.active then
    level_editor:fill(convert(rectangle.x), convert(rectangle.y), convert(camera:mouseX()), convert(camera:mouseY()), nil)
  end
  rectangle.active = false
end

function love.wheelmoved(x, y)
  current_scale = 1
  if love.keyboard.isDown("lctrl") then
    --zoom camera
    if y > 0 then
      current_scale = current_scale - 0.04
    elseif y < 0 then
      current_scale = current_scale + 0.04
    end

    if current_scale > max_scale then
      current_scale = max_scale
    end
    if current_scale < min_scale then
      current_scale = min_scale
    end

    camera:scale(current_scale, current_scale)
  else
    if y > 0 then
      sel_tile = sel_tile - 1
    elseif y < 0 then
      sel_tile = sel_tile + 1
    end
    sel_tile = (sel_tile + 9) % #level_editor.tiles + 1
  end
end

function love.textinput(t)
  if level_editor.is_loading_map and not first_time then
    level_editor.map_name = level_editor.map_name .. t
  end
  first_time = false
end

function love.keypressed(key, scancode, isrepeat)
  if key == "s" and not isrepeat then
    level_editor:save_map()
  elseif key == "o" and not isrepeat and not level_editor.is_loading_map then
    level_editor.is_loading_map = true
    first_time = true
  elseif key == "return" then
    if love.filesystem.exists("maps/" .. level_editor.map_name) then
      level_editor:load_map(love.graphics.newImage("maps/" .. level_editor.map_name):getData())
    else
      print("WTF YOU TRYING TO READ MATE")
    end
    level_editor.map_name = ""
    level_editor.is_loading_map = false
  elseif key == "escape" then
    level_editor.map_name = ""
    level_editor.is_loading_map = false
  end

  if level_editor.is_loading_map then
    if key == "backspace" then
      -- get the byte offset to the last UTF-8 character in the string.
      local byteoffset = utf8.offset(level_editor.map_name, -1)

      if byteoffset then
        -- remove the last UTF-8 character.
        -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(level_editor.map_name, 1, -2).
        level_editor.map_name = string.sub(level_editor.map_name, 1, byteoffset - 1)
      end
    end
  end
end

function convert(v)
  return (v-v%tile_scale)/tile_scale
end

function smallest (v1, v2)
  if v1 <= v2 then
    return v1
  end
  return v2
end

function biggest (v1, v2)
  if v1 >= v2 then
    return v1
  end
  return v2
end

function level_editor:add_tile(r, g, b, image)
  local temp_image = love.graphics.newImage("src/" .. image)
  table.insert(level_editor.tiles, {r=r, g=g, b=b, image = temp_image, width = tile_scale, height = tile_scale})
end

function level_editor:add_block(x, y, id)
  x = x+1
  y = y+1
  if not map[x] then
    map[x] = {}
  end
  map[x][y] = id
end

function level_editor:fill (x1, y1, x2, y2, id)
  for x = smallest(x1, x2), biggest(x1, x2)do
    for y = smallest(y1, y2), biggest(y1, y2) do
      level_editor:add_block(x, y, id)
    end
  end
end

function level_editor:save_map()
  maxX, maxY = 1, 1
  for x, xv in pairs(map) do
    for y, v in pairs(xv) do
      if x>maxX then
        maxX = x
      end
      if y>maxY then
        maxY = y
      end
    end
  end
  tempLevel = love.image.newImageData(maxX, maxY)
  for x = 1, maxX do
    for y = 1, maxY do
      tempLevel:setPixel(x-1, y-1, 255, 255, 255)
    end
  end
  for x, xv in pairs(map) do
    for y, v in pairs(xv) do
      tempLevel:setPixel(x-1, y-1, level_editor.tiles[v].r, level_editor.tiles[v].g, level_editor.tiles[v].b)
    end
  end
  if not love.filesystem.exists("maps") then
    love.filesystem.createDirectory("maps")
  end

  tempLevel:encode("png", "maps/map_".. os.time() .. ".png")
end

function level_editor:load_map(image_data)
  map = {}
  for x=1,image_data:getWidth() do
    for y=1,image_data:getHeight() do
      for i=1, table.getn(level_editor.tiles) do
        r, g, b, a = image_data:getPixel(x-1, y-1)
        if r == level_editor.tiles[i].r and g == level_editor.tiles[i].g and b == level_editor.tiles[i].b then
          level_editor:add_block(x-1, y-1, i)
        end
      end
    end
  end
end
