-- The utilities contains some useful basic lua functions

local function ask(msg, default)
    local defLow = string.lower(default)
    assert(defLow == "y" or defLow == "n")

    local oth
    if defLow == "n" then
        oth = "y"
    else
        oth = "n"
    end

    local answer = ""
    while true do
        print(msg .. " [" .. string.upper(default) .. oth .. "]")
        answer = string.lower(io.read())
        
        if answer == "" then
            answer = defLow
        end

        if answer == "n" then
            return false
        elseif answer == "y" then
            return true
        end
    end
end
-- returns true on success
local function writeFile(path, string)
    local file = io.open(path, "w")
    if file then
        file:write(string)
        file:close()
        return true
    else
        return false
    end
end

local function readFile(path)
    local file = io.open(path, "r")
    if file then
        local string = file:read()
        file:close()
        return string
    else
        return nil
    end
end

local function saveData(path, data)
    return writeFile(path, textutils.serialize(data))
end
local function loadData(path)
    return readFile(path)
end


if not utils then
    utils = {}
end

utils.writeFile = writeFile
utils.readFile  = readFile
utils.saveData = saveData
utils.loadData = loadData
utils.ask = ask


