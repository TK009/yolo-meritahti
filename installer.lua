
-- *
-- Small package manager
--
-- Features:
--   * Defaults to full install
--   * Directories can be changed
--   * Install packages individually

local tArgs = { ... }

local BaseURL = "http://pesutykki.mooo.com/dump/yolo-meritahti"

local PackagesPath = "/packages"

if not http.fetch then
    error "Should have http.fetch function, did you run this with the bootstrap script?"
end


---------------------------------------
-- GLOBALS

-- Directory structure
if not DIRS then
    DIRS = 
        { etc  = "/etc"
        , lib  = "/lib"
        , core = "/lib/core"
        , help = "/lib/help"
        , bin  = "/bin"
        , root = "/" -- Used for startup
        }
end

if not os.packages then
    os.packages = {}
end



---------------------------------------
-- UTIL

-- Enable string indexing: "asdf"[2] == "s"
--getmetatable('').__index =
local function ix(str,i)
    return string.sub(str,i,i)
end

-- Join two paths so there is one '/' between
local function pathJoin(a, b)
    local aSlash = ix(a,-1) == "/"
    local bSlash = ix(b, 1) == "/"
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



local function findPackage(name)
    for categoryName, categoryPkgs in pairs(os.packages) do
        for packageName, _ in pairs(categoryPkgs) do
            if name == packageName then
                return categoryName
            end
        end
    end

    return nil
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

-- Adds DIRS to startup
local function writeConf()
    print "Writing configuration"

    local file = io.open("/startupdirs" ,"w")
    file:write("DIRS = ")
    file:write(textutils.serialize(DIRS))
    file:write("\n")
    file:close()

    -- concatenate files
    fs.move("/startup", "/startup.bak")
    shell.run(DIRS.bin .. "/cat -o /startup /startupdirs /startup.bak" )
    fs.delete("/startup.bak")
    fs.delete("/startupdirs")

    print "Done."
end


-- Critical unserialize, throws an error if not successful
local function critUnserialize( s  )
    local func, etc = assert(loadstring( "return "..s, "unserialize"  ), "failed")
    setfenv( func, {}  )
    local ok, result = assert( pcall( func ) )
    return result
end




------------------------------------------
-- ACTIONS


local function installPackage(category, name)

    local package = os.packages[category][name]

    for keyInfo, values in pairs(package) do
        if DIRS[keyInfo] then
            print("Installing " .. name .. " from [" .. category .. "]")
            for destination, source in pairs(values) do
                print(".. Downloading " .. source)
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

    print ".. parsing"
    local ok, res = pcall( critUnserialize, packagesstr )
    if ok then
        hFile = io.open(PackagesPath, "w")
        hFile:write(packagesstr)
        hFile:close()
        os.packages = res
        print "Success."
    else
        error("Error, Package db not updated. " .. res)
    end
end






local function installAll()
    ask("Install all packages", "y")

    for _,dir in pairs(DIRS) do
        if not fs.exists(dir) then
            print(".. Creating directory " .. dir)
            fs.makeDir(dir)
        end
    end

    -- Download package database
    updateDB()

    backupStartup()

    for categoryName, category in pairs(os.packages) do
        print("=== Install category [" .. categoryName .. "] ===")
        for packageName, _ in pairs(category) do
            installPackage(categoryName, packageName)
        end
    end

    -- write DIRS to startup
    writeConf()

    if ask("Do additional Reboot?", "y") then
        os.reboot()
    else
        shell.run(DIRS.root .. "/startup")
    end
end



------------------------------
-- RUN


local action = tArgs[1] or "install"
local args = {}
if #tArgs > 0 then
    table.remove(tArgs, 1)
    args = tArgs
end


if action == "install" and #args == 0 then
    installAll()

elseif action == "install" and #args > 0 then
    for _,pkg in ipairs(args) do
        local cat = findPackage(pkg)
        if cat then
            installPackage(cat, pkg)
        else
            print(name .. " was not found.")
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



