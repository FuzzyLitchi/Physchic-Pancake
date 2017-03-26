# Psychic-Pancake

### A modular lua love2d level editor

This editor uses png pictures and RGB colors to map levels

Controls:
- Left click: place block
- Right click: remove block
- Middle click: drag grid around
- Shift + Left click: fill blocks
- Shift + Right click: remove blocks in fill area
- Scroll wheel: change block
- Ctrl + Scroll wheel: zoom
- Shift + Scroll wheel: change fill mode

Every block has an RGB value that represents it, you can then in your game, load that block based on the stored RGB value.

To add a block, simply place a square (This means that both sides are equal length) picture in the img direcory. Then add the block in the code and give it an RGB value, here is an example. `level_editor:add_tile(0, 0, 0, "banker.png")` the first 3 values are RGB and the string is the name of the picture.

The fill modes are currently line and rectangle.

To add more fill modes, program a function that fills in the desired way. Here is a square fill:
```lua
function fill (x1, y1, x2, y2, id)
  for x = smallest(x1, x2), biggest(x1, x2)do
    for y = smallest(y1, y2), biggest(y1, y2) do
      level_editor:add_block(x, y, id)
    end
  end
end
```
Your function should have the the following input:
- x1, y1 : the origin position
- x2, y2 : the second position
- id : the selected block

Your function should also have a highlight version:
```lua
function fill_highlight (x1, y1, x2, y2, id)
  local image = level_editor.tiles[id].image
  for x = smallest(x1, x2), biggest(x1, x2)do
    for y = smallest(y1, y2), biggest(y1, y2) do
      love.graphics.draw(image, x*tile_scale, y*tile_scale, nil, 8/image:getWidth(), 8/image:getWidth())
    end
  end
end
```
This function is used to highlight the area that will be filled before it is filled.

When this is done, you can then add to the editor as so:
```lua
table.insert(shapes_func, fill)
table.insert(highlight_func, fill_highlight)
```
You can then Shift + Scroll to it.
