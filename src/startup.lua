-- Table called DIRS will be loaded above
-- It has structure like this:
-- DIRS =
--     { etc  = "/etc"
--     , lib  = "/lib"
--     , core = "/lib/core"
--     , help = "/lib/help"
--     , bin  = "/bin"
--     , root = "/" -- Used for startup
--     }

print "Setting environment..."

-- PATH
--

local path = shell.path()

path = DIRS.bin .. ":" .. path

shell.setPath(path)



-- help Path
--

local helpPath = help.path()

helpPath = helpPath .. ":" .. DIRS.help

help.setPath(helpPath)


-- System global
--

System = {}
local file = io.open(DIRS.root .. "packages")
local packagesstr = file.readAll()
file:close()
System.packages = textutils.unserialize(packagesstr)


-- Run Core libs
--

print "Loading startup files..."

local coreFiles = fs.list(DIRS.core)

for _, coreFile in pairs(coreFiles) do
    local corePath = DIRS.core .. "/" .. coreFile

    if not fs.isDir(corePath) then
        io.write(coreFile .. " ")
        dofile(corePath)
    end
end
print("Done.")



-- Name the computer
--
local label = os.getComputerLabel()

if not label then
    print("Your computer has no label.")
    print("Give it a name: ")
    local name = io.read()
    os.setComputerLabel(name)
    label = name
end

term.clear()
term.setCursorPos(1,1)


print("Welcome, professor.")
print("ID:" .. os.getComputerID() .. " " .. label)
print("=====================")

