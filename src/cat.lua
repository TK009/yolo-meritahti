
local tArgs = { ... }

local usage = [[
usage: cat [-o outputfile] [files]
files are paths to readable files or "-" which is stdin,
if no files given cat loops stdin to stdout.
-o outputfile   write to a file instead of stdout
]]

local output = io.output()
local usingFileoutput = false

if tArgs[1] == "-o" then
    output = io.open(tArgs[2], "w")
    usingFileoutput = true
    table.remove(tArgs, 2)
    table.remove(tArgs, 1)
end


for _, inputPath in ipairs(tArgs) do
    local inputFile
    local usingFileinput = false

    if inputPath == "-" then
        inputFile = io.input()
    else
        inputFile = io.open(inputPath)
        usingFileinput = true
    end

    -- Safety checks
    if inputFile ~= nil then
        for line in inputFile:lines() do
            output:write(line .. "\n")
        end

        if usingfileinput then
            inputFile:close()
        end

    else
        print("Error! Invalid input file: " .. inputPath)
        print(usage)
        error()
    end
end

if usingFileoutput then
    output:close()
end


