local tArgs = { ... }

if not http then
    error("This program needs http")
end



local url = tArgs[1]

-- Usage
if not url or url == "-h" or url == "--help" then
    shell.run "help wget"
    return
end


local destination = tArgs[2] or
    -- Remove everything to the last "/"
    string.gsub(url, ".*/", "")


http.save(url, destination)

