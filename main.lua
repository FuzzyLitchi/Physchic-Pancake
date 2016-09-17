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

function love.load(main)
  camera = Camera:make(0, 0, 960 / love.graphics.getWidth(), 640 / love.graphics.getHeight(), 0)

  love.graphics.setDefaultFilter("nearest", "nearest")
  love.keyboard.setKeyRepeat(true)

  --load tiles
  level_editor:add_tile(0, 0, 0, "banker.png")
  level_editor:add_tile(255, 255, 0, "julian.png")
end

function love.update()
  if love.mouse.isDown(1) then
    if love.mouse.getY() > tile_scale and camera:mouseX()>0 and camera:mouseY()>0 then
      temp_x, temp_y = camera:mousePosition()
      temp_x = (temp_x-temp_x%tile_scale)
      temp_y = (temp_y-temp_y%tile_scale)
      for i, v in ipairs(level_editor.boxes) do
        if temp_x == v.x and temp_y == v.y then
          table.remove(level_editor.boxes, i)
        end
      end
      level_editor:add_block(camera:mouseX()-camera:mouseX()%tile_scale, camera:mouseY()-camera:mouseY()%tile_scale, sel_tile)
    end
  elseif love.mouse.isDown(2) then
    if love.mouse.getY() > tile_scale and camera:mouseX()>0 and camera:mouseY()>0 then
      temp_x, temp_y = camera:mousePosition()
      temp_x = (temp_x-temp_x%tile_scale)
      temp_y = (temp_y-temp_y%tile_scale)
      for i, v in ipairs(level_editor.boxes) do
        if temp_x == v.x and temp_y == v.y then
          table.remove(level_editor.boxes, i)
        end
      end
    end
  elseif love.mouse.isDown(3) then
    camera:move((level_editor.oldX-love.mouse.getX()) * camera.scaleX, (level_editor.oldY-love.mouse.getY()) * camera.scaleY)
  end
  level_editor.oldX = love.mouse.getX()
  level_editor.oldY = love.mouse.getY()
end

function love.draw()
  love.graphics.setColor(255, 0, 100)
  love.graphics.printf(level_editor.map_name, 0, 0, love.graphics.getWidth())

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

  for i, v in ipairs(level_editor.boxes) do
    love.graphics.draw(v.image, v.x, v.y)
  end

  love.graphics.setColor(255, 0, 255, 80)
  love.graphics.rectangle("fill", camera:mouseX()-camera:mouseX()%tile_scale, camera:mouseY()-camera:mouseY()%tile_scale, tile_scale, tile_scale)

  camera:unset()
end

function love.wheelmoved(x, y)
  current_scale = 1
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
    level_editor:load_map(love.graphics.newImage("maps/" .. level_editor.map_name):getData())
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

function level_editor:add_tile(r, g, b, image)
  local temp_image = love.graphics.newImage("src/" .. image)
  table.insert(level_editor.tiles, {r=r, g=g, b=b, image = temp_image, width = tile_scale, height = tile_scale})
end

function level_editor:add_block(x, y, id)
  table.insert(level_editor.boxes, {image = level_editor.tiles[id].image, x = x, y = y, width = level_editor.tiles[id].width, height = level_editor.tiles[id].height, r=level_editor.tiles[id].r, g=level_editor.tiles[id].g, b=level_editor.tiles[id].b})
end

function level_editor:save_map()
  maxX, maxY = 1,1
  for i,v in ipairs(level_editor.boxes) do
    if v.x/tile_scale>maxX then
      maxX = v.x/tile_scale
    end
    if v.y/tile_scale>maxY then
      maxY = v.y/tile_scale
    end
  end
  tempLevel = love.image.newImageData(maxX+1, maxY+1)
  for x = 1, maxX do
    for y = 1, maxY do
      tempLevel:setPixel(x, y, 255, 255, 255)
    end
  end
  for i,v in ipairs(level_editor.boxes) do
    tempLevel:setPixel(v.x/tile_scale, v.y/tile_scale, v.r, v.g, v.b, v.a)
  end
  if not love.filesystem.exists("maps") then
    love.filesystem.createDirectory("maps")
  end

  tempLevel:encode("png", "maps/map_".. os.time() .. ".png")
end

function level_editor:load_map(image_data)
  temp_boxes = {}
  for x=1,image_data:getWidth() do
    for y=1,image_data:getHeight() do
      for i=1, table.getn(level_editor.tiles) do
        r, g, b, a = image_data:getPixel(x-1, y-1)
        if r == level_editor.tiles[i].r and g == level_editor.tiles[i].g and b == level_editor.tiles[i].b then
          print(b)
          table.insert(temp_boxes, {image = level_editor.tiles[i].image, x = x*tile_scale-tile_scale, y = y*tile_scale-tile_scale, width = tile_scale, height = tile_scale, r=r, g=g, b=b, a=a})
        end
      end
    end
  end
  level_editor.boxes = temp_boxes
end

return level_editor
