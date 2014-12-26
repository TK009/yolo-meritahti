
-- *
-- Small package manager
--
-- Features:
--   * Defaults to full install
--   * Directories can be changed
--   * Install packages individually

local tArgs = { ... }

local BaseURL = "http://pesutykki.mooo.com/dump/yolo-meritahti"

-- Directory structure
local DIRS = 
    { etc  = "/etc"
    , lib  = "/lib"
    , core = "/lib/core"
    , help = "/lib/help"
    , bin  = "/bin"
    }

local PackagesPath = "/packages"

if not http.fetch then
    error "Should have http.fetch function, did you run this with the bootstrap script?"
end



-- UTIL

-- enable string indexing: "aoeu"[2] == "o"
getmetatable('').__index = function(str,i)
    return string.sub(str,i,i)
end

-- Join two paths so there is one '/' between
local function pathJoin(a, b)
    local aSlash = a[-1] == "/"
    local bSlash = b[1] == "/"
    if (aSlash and not bSlash) or (not aSlash and bSlash) then
        return a .. b
    elseif aSlash and bSlash then
        return a .. b:sub(2)
    elseif not aSlash and not bSlash then
        return a .. '/' .. b
    else
        error "Bug in pathJoin!"
    end
end

local function ask(msg, default)
    local defLow = default:lower()
    assert(defLow == "y" or defLow == "n")
    if defLow == "n" then
        local oth = "y"
    else
        local oth = "n"
    end

    local answer
    while true do
        print(msg .. " [" .. default:upper() .. oth .. "]")
        answer = io.read():lower()
        
        if answer == "n" then
            return false
        elseif answer == "y" then
            return true
        end
    end
end



local function findPackage(name)
    for categoryName, categoryPkgs in ipairs(os.packages) do
        for packageName, _ in ipairs(categoryPkgs) do
            if name == packageName then
                return categoryName
            end
        end
    end

    return nil
end

-- ACTIONS


local function installPackage(category, name)

    local package = os.packages[category][name]

    for keyInfo, values in package do
        if DIRS[keyInfo] then
            print("Installing " .. name .. " from [" .. category .. "]")
            for destination, source in values do
                print("Downloading " .. source)
                http.save( pathJoin(BaseURL, source)
                         , pathJoin(DIRS[keyInfo], destination)
                         )
            end
            print("Installed " .. name)
        else
            print "Error!"
            print(name .. " was not found in [" .. category .. "]")
        end
    end
end



local function updateDB()
    print "Fetching official package database..."
    local packagesstr = http.fetch(BaseURL .. PackagesPath)

    print "parsing"
    local res = textutils.unserialize(packagesstr)
    if res then
        hFile = io.open(packagesPath, "w")
        hFile:write(packagesstr)
        hFile:close()
        os.packages = res
        print "Success."
    else
        print "Error! Package db not updated"
    end
end



local function backupStartup()
    print("Checking for startup")
    if fs.exists("startup") then
        print("Startup found")
        if fs.exists("startup.old") then
            fs.delete("startup.old")
            print("Renaming startup to startup.old...")
            fs.copy("startup", "startup.old")
            fs.delete("startup")
        else
            print("Renaming startup to startup.old...")
            fs.copy("startup", "startup.old")
            fs.delete("startup")
        end
    end
end



local function installAll()
    ask("Install all packages", "y")

    for _,dir in ipairs(DIRS) do
        if not fs.exists(dir) then
            print("Creating directory " .. dir)
            fs.makeDir(dir)
        end
    end

    -- Download package database
    updateDB()

    backupStartup()

    for categoryName, category in ipairs(packages) do
        print("=== Install category [" .. categoryName .. "] ===")
        for packageName, _ in ipairs(category) do
            installPackage(categoryName, packageName)
        end
    end

    print "Reboot!"
    os.sleep(2)
end




-- RUN
local action = tArgs[1] or "install"
local args = table.unpack(tArgs, 2)

if action == "install" and #args == 0 then
    installAll()

elseif action == "install" and #args > 0 then
    for pkg in pairs(args) do
        local cat = findPackage(pkg)
        if cat then
            installPackage(cat, pkg)
        else
            print(name .. " was not found in [" .. category .. "]")
        end
    end

elseif action == "search" and #args == 1 then
    print("Searching for " .. args[1])
    local res = findPackage(args[1])
    if res then
        print(args[1] .. " was found in [" .. res .. "]")
    else
        print(name .. " was not found in [" .. category .. "]")
    end

elseif action == "update" and #args == 0 then
    updateDB()
else
    shell.run "help installer"
end



