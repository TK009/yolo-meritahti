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


-- Run Core libs
--

print "Loading startup files..."

local coreFiles = fs.list(core)

for _, coreFile in coreFiles do
    local corePath = DIRS.core .. coreFile

    if not fs.isDir(corePath) then
        io.write(coreFile .. " ")
        dofile(corePath)
    end
end
print("Done.")

print("ID:" .. os.getComputerID() .. " " .. os.getComputerLabel())

