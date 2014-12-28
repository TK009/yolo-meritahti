tArgs = { ... }

local saveFile = "domeq.save"

-- Imports
if not utils then error "Requires core utils library" end
local ask = utils.ask

if not ask("Warning! Not fully tested. Continue and give permission to break blocks?", "y") then
    error()
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
    print "usage: domeq <baseRadius> <height>"
    print "Builds a quarter of dome. Place turtle at z=0 at the center of quarter-change (use odd baseRadius)"
    error()
end


local actions = 
    { up =
        { dig = turtle.digUp
        , detect = turtle.detectUp
        , move = turtle.up
        }
    , down =
        { dig = turtle.digDown
        , detect = turtle.detectDown
        , move = turtle.down
        }
    , forward =
        { dig = turtle.dig
        , detect = turtle.detect
        , move = turtle.forward
        }
    }


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
    local absturns = math.abs(turns)
    io.write("(t:" .. tostring(turns) .. ")")

    if absturns == 3 then -- reverse
        turns = - turns
    end

    if absturns == 2 then
        turtle.turnRight()
        turtle.turnRight()
    elseif turns > 0 then -- +1 (%2)
        turtle.turnLeft()
    elseif turns < 0 then -- -1 (%2)
        turtle.turnRight()
    end
    return dir
end

local function selectNext()
    turtle.select((turtle.getSelectedSlot() % 16) +1)
end

local function selectBlock()
    repeat
        if not ask("Put building blocks to inventory and press Enter (or n to quit)", "y") then
            error()
        end
        blockData = turtle.getItemDetail() 

        local isFuel = turtle.refuel(0)

        if blockData and (not isFuel
            or (isFuel and ask("Selected item is fuel item, confirm selection.", "n"))
        ) then
            return blockData.name
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

local function clearWay(actionSet)
    while actionSet.detect() do
        if not actionSet.dig() then
            if not ask("Something unbreakable in front, needs manual destruction. Do you want to continue?", "y") then
                error()
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
                        error()
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
local function goActionDestructively(actionSet, n)
    assert(n > 0, "negative goForward!")
    for step = 1, n do
        clearWay(actionSet)
        while not actionSet.move() do
            if not refuelIfNeeded() then
                print "Entity or unknown thing blocking way! Retrying in 8 secs..."
                os.sleep(8)
            end
        end
    end
end

local function goForwardDestructively(n) 
    goActionDestructively(actions.forward, n)
end

local function goVerticallyDestructively(z)
    if z > 0 then
        goActionDestructively(actions.up, z)
    else
        goActionDestructively(actions.down, math.abs(z))
    end
end

local function navigateOverRelative(x, y, z, heading)
    local newHeading = heading

    -- Z
    if z ~= 0 then
        goVerticallyDestructively(z)
    end

    -- debug
    io.write(newHeading)

    -- Y
    if y ~= 0 then

        newHeading = turn(newHeading, towards(0,y))
        goForwardDestructively(math.abs(y))
    end

    -- debug
    io.write(newHeading)

    -- X
    if x ~= 0 then
        newHeading = turn(newHeading, towards(x,0))
        goForwardDestructively(math.abs(x))
    end

    -- debug
    io.write(newHeading)
    print " EOL"

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
    
    while not turtle.placeDown() do
        print "Unable to place block"
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



local function buildDomeq(baseRadius, height)

    -- ALGORITHM VARS
    --


    --local x_radius = (width - 1) / 2
    --local y_radius = (depth - 1) / 2
    local x_radius = baseRadius
    local y_radius = baseRadius
    local z_radius = height

    local tolerance = 0.1
    local thickness = 0.5

    -- local dome = {}
    local radius = math.min(x_radius, y_radius, z_radius)
    local solid
    local count = 0

    local x_ratio = x_radius / radius
    local y_ratio = y_radius / radius
    local z_ratio = z_radius / radius



    -- TURTLE VARS
    --
            
    local own = {} -- state
    own.heading = direction.east
    own.x = 0
    own.y = y_radius
    own.z = 0

    if not domeq.replay then
        own.block = selectBlock()
    else
        own.block = targetPos.block
    end



    for z = 0, z_radius do

        for y = y_radius, 1, -1 do

            for x = 0, x_radius do

                local xP = x / x_ratio
                local yP = y / y_ratio
                local zP = z / z_ratio

                local distance = math.sqrt((xP * xP) + (yP * yP) + (zP * zP))

                --if hollow
                if math.abs(distance - radius) <= thickness then
                    -- solid = true

                    deltax = x - own.x
                    deltay = y - own.y
                    deltaz = (z + 1) - own.z
                    io.write("abs: " .. x .. " " .. y .. " " .. z)
                    --print("own: " .. own.x .. " " .. own.y .. " " .. own.z)
                    print(" del: " .. deltax .. " " .. deltay .. " " .. deltaz)

                    own.heading = navigateOverRelative(
                        deltax, deltay, deltaz,
                        own.heading
                    )
                    own.x = x
                    own.y = y
                    own.z = z + 1

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

            end
        end
    end
end

local baseRadius = tArgs[1]
local height = tArgs[2]
buildDomeq(baseRadius, height)
print "Finished."

