

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


-- Run Core libs
--

local coreFiles = fs.list(core)

for _, coreFile in coreFiles do
    local corePath = DIRS.core .. coreFile

    if not fs.isDir(corePath) then
        dofile(corePath)
    end
end



-- PATH
--

local path = shell.getPath()

path = DIRS.bin .. ":" .. path

shell.setPath(path)



-- help Path
--

local helpPath = help.getPath()

helpPath = helpPath .. ":" .. DIRS.help

help.setPath(helpPath)



