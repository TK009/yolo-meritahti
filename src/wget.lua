local tArgs = { ... }

if not http then
    error("This program needs http")
end

local usage = [[
usage: wget <url> [filepath | filename]
Fetches a file specified by the url and writes to the given filepath or to the current working directory.
If no filename was given, it is taken from the last url component.
Overwrites any existing file!
]]


local url = tArgs[1]

-- Usage
if not url or url == "-h" or url == "--help" then
    print(usage)
    exit()
end


local validUrl, urlError = http.checkURL(url)

if not validUrl then
    error("Error! " .. urlError)
end


local destination = tArgs[2] or
    -- Remove everything to the last "/"
    string.gsub(url, ".*/", "")


-- Fetch
local result = http.get(url)
if not result then
  error("Unknown http error")
end

local responseCode = result.getResponseCode()
if responseCode ~= 200 then
    error("Invalid url, http response: " .. responseCode)
end

-- Save to a file

contents = result.readAll()

hFile = io.open(destination, "w")
hFile:write(contents)
hFile:close()

