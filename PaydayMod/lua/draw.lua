-- Helper functions
local function get_data_from_file(file)
    -- returns the coordinate point per each line in a file in the form of a table
    if not io.file_is_readable(ModPath.."bapple/"..file) then
        return false
    end
    local coords = {}
    for line in io.lines(ModPath.."bapple/"..file) do
        local x, y = line:match("([^,]*),([^,]*)")
        table.insert(coords, { x, y })
    end
    return coords
end
local function scandir(directory)
    -- Lists all the files in a directory and puts them in a table
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('dir "'..directory..'" /b')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end
local function draw_data(coords)
    -- Draws each line, offset by 200,200 to the bottom right
    if not coords then return false end
    local map = managers.menu_component._preplanning_map
    local switch = false
    for k,point in pairs(coords) do
        if switch then
            map:custom_draw_point(point[1]+200, point[2]+200)
            map:end_drawing()
        else
            map:start_drawing()
            map:custom_draw_point(point[1]+200, point[2]+200)
        end
        switch = not switch
    end
    map:end_drawing()
    return true
end
local function get_file()
    -- Coroutine magic to return the next frame every time it's called
    local function _get_file()
        co = co or coroutine.create(function()
            for _,file in pairs(scandir(ModPath.."bapple")) do
                coroutine.yield(file)
            end
        end)
        return co
    end
    if h_get_file then
        status, file = coroutine.resume(h_get_file)
        if coroutine.status(h_get_file) == "dead" then
            h_get_file = _get_file()
            status, file = coroutine.resume(h_get_file)
        end
        return file
    else
        h_get_file = _get_file()
        status, file = coroutine.resume(h_get_file)
        return file
    end
end
-- Functional code
local function do_drawing(t, dt)
    if BadAppleTime >= 0.333333 then
        -- Play video at 3 fps (speed up later in editing)
        -- Can set to 0.0333667 if you want to play it at the original ~29.97fps
        managers.menu_component._preplanning_map:erase_drawing()
        if not draw_data(get_data_from_file(get_file())) then
            -- When we exhaust all data files, stop drawing
            Hooks:UnregisterHook("draw_bad_apple")
        end
        BadAppleTime = BadAppleTime - 0.333333
    else
        BadAppleTime = BadAppleTime + dt
    end
end
-- Driver code
if managers.menu_component._preplanning_map and managers.menu_component._preplanning_map.custom_draw_point then
    _G.BadAppleTime = 0
    Hooks:Add("draw_bad_apple", "preplan_draw_bad_apple", do_drawing)
end
