tArgs = { ... }

local saveFile = "domeq.save"

-- Imports
if not utils then error "Requires core utils library" end
local ask = utils.ask

if not ask("Warning! Not yet tested. Continue?", "y") then
    exit()
end

-- Globals
domeq = {replay = false}

-- Args
if #tArgs == 0 and fs.exists(saveFile) then
    if ask("Continue from save?", "y") then
       targetPos = utils.loadData(saveFile) 
   else
       fs.delete(saveFile)
   end

elseif #tArgs ~= 2 then
    print "usage domeq <baseRadius> <height>"
    error()
end



local direction = 
    { south = 0
    , west  = 1
    , north = 2
    , east  = 3
    }

local function towards(x,y) -- probably not according to mc
    assert(x == 0 or y == 0, "not a cardinal direction")
    if     y > 0 then return direction.south
    elseif y < 0 then return direction.north
    elseif x > 0 then return direction.east
    elseif x < 0 then return direction.west
    end
end
local function rightwards(dir) return (dir + 1) % 4 end
local function leftwards(dir) return (dir - 1) % 4 end

-- turn me to dir, returns the dir
local function turn(me, dir)
    local turns = (me - dir)
    if turns == 2 or turns == -2 then
        turtle.turnRight()
        turtle.turnRight()
    elseif turns % 2 > 0 then
        turtle.turnLeft()
    elseif turns % 2 < 0 then
        turtle.turnRight()
    end
    return dir
end

local function selectNext()
    turtle.select((turtle.getSelectedSlot() % 16) +1)
end

local function selectBlock()
    repeat
        blockData = turtle.getItemDetail() 
        if not ask("Put building blocks to inventory and press Enter (or n to quit)", "y") then
            exit()
        end

        local isFuel = turtle.refuel(0)

        if blockData and (not isFuel
            or (isFuel and ask("Selected item is fuel item, confirm selection.", "n"))
        ) then
            return blockData.name
        else
            selectNext()
        end

    until false 
end

-- check and select <block>, returns true if found and item is selected
-- <block> is qualified name "modname:blockname" or "fuel"
local function checkBlocks(block)
    local searchFuel = block == "fuel"
    for slotTry = 1, 16 do
        if turtle.getItemCount() > 0 
        and ( turtle.getItemDetail().name == block 
              or (searchFuel and turtle.refuel(0))
            ) then
            return true
        else
            selectNext()
        end
    end
    return false
end

local function clearWay(destroyAction)
    while turtle.detect() do
        if not destroyAction() then
            if not ask("Something unbreakable in front, needs manual destruction. Do you want to continue?", "y") then
                exit()
            end
        end
    end
    return true
end

-- return true if refueled
local function refuelIfNeeded()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel < 50 then
        local maxLevel = turtle.getFuelLimit()
        local targetLevel = math.floor(maxLevel*0.75)
        
        repeat
            if checkBlocks("fuel") then
                local half = math.ceil(turtle.getItemCount()/2)
                turtle.refuel(half)
            else
                print "No fuel items. Put some in the inventory."
                if turtle.getFuelLevel() > fuelLevel then
                    if not ask("Some refueling done, refuel more?") then
                        return true
                    end
                else
                    if not ask("Refuel items from inventory? Press Enter to continue or n to quit") then
                        exit()
                    end
                end
            end
        until turtle.getFuelLevel >= targetLevel
        return true
    else
        return false
    end
end

-- go up if blocked
-- mine when coming down
local function goActionDestructively(action, destroyAction, n)
    assert(n > 0, "negative goForward!")
    for step = 1, n do
        clearWay(destroyAction)
        while not action() do
            if not refuelIfNeeded() then
                print "Entity or unknown thing blocking way! Retrying in 3 secs..."
                os.sleep(3)
            end
        end
    end
end

local function goForwardDestructively(n) 
    goActionDestructively(turtle.forward, turtle.dig, n)
end

local function goVerticallyDestructively(z)
    if z > 0 then
        goActionDestructively(turtle.up, turtle.digUp, z)
    else
        goActionDestructively(turtle.down, turtle.digDown, math.abs(z))
    end
end

local function navigateOverRelative(x, y, z, heading)
    local newHeading = heading

    -- Z
    if z ~= 0 then
        goVerticallyDestructively(z)
    end
    -- Y
    if y ~= 0 then
        newHeading = turn(towards(0,y))
        goForwardDestructively(math.abs(y))
    end
    -- X
    if x ~= 0 then
        newHeading = turn(towards(x,0))
        goForwardDestructively(math.abs(x))
    end

    return newHeading
end


local function placeBelow(block)
    checkBlocks(block)
    if turtle.detectDown() then
        if turtle.compareDown() then 
            return true
        end
        if not turtle.digDown() then
            error "Can't dig down"
        end
    end

    if not turtle.placeDown() then
        error "Unable to place block"
    end
    return true
end

local function comparePos(me, other)
    if  me.x == other.x
    and me.y == other.y
    and me.z == other.z then
        if me.heading == other.heading then
            return true
        else
            turn(other.heading)
            return true
        end
    else
        return false
    end
end



local function domeq(baseRadius, height)

    -- ALGORITHM VARS
    --

    local width = baseRadius
    local depth = baseRadius

    local x_radius = (width - 1) / 2
    local y_radius = (depth - 1) / 2
    local z_radius = height

    local tolerance = 0.1
    local thickness = 0.5

    local dome = {}
    local radius = math.min(x_radius, y_radius, z_radius)
    local solid
    local count = 0

    local x_ratio = x_radius / radius
    local y_ratio = y_radius / radius
    local z_ratio = z_radius / radius



    -- TURTLE VARS
    --
            
    local own = {} -- state
    own.heading = direction.south
    own.x = 0
    own.y = y_radius
    own.z = 0

    if not domeq.replay then
        own.block = selectBlock()
    else
        own.block = targetPos.block
    end



    for z = 0, z_radius-1 do
        --if not dome[z] then dome[z] = {} end


        --for (var y = -y_radius, _y = 0; y <= y_radius; y++, _y++) {
        for y = y_radius, 0, -1 do
            --if not dome[z][y] then dome[z][y] = {} end

            --for (var x = -x_radius, _x = 0; x <= x_radius; x++, _x++) {
            for x = 0, x_radius do
                --if not dome[z][y][x] then dome[z][y][x] = {} end

                local xP = x / x_ratio
                local yP = y / y_ratio
                local zP = z / z_ratio

                local distance = math.sqrt((xP * xP) + (yP * yP) + (zP * zP))

                --if hollow
                if math.abs(distance - radius) <= thickness then
                    -- solid = true
                    own.heading = navigateOverRelative(
                        own.x - x,
                        own.y - y,
                        own.z - z + 1,
                        own.heading
                    )
                    if domeq.replay then
                        comparePos(own, targetPos)
                    else
                        placeBelow(own.block)
                        utils.saveData(saveFile, own) 
                    end
                end
                --else
                --  solid = (distance - tolerance) < radius
                --end

                --dome[z][y][x] = solid
            end
        end
    end
end

local baseRadius = tArgs[1]
local height = tArgs[2]
domeq(baseRadius, height)

