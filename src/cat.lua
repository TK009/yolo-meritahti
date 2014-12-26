
local tArgs = { ... }

local usage = [[
usage: cat [-o path] [files]
files are paths to readable files or "-" which is stdin,
if no files given cat loops stdin to stdout.
-o path   write to a file instead of stdout
]]

local output = io.output()
local fileoutput = false
if tArgs[1] == "-o" then
    output = io.open(tArgs[2], "w")
    fileoutput = true
    table.remove(tArgs, 2)
    table.remove(tArgs, 1)
end


for _, inputPath in ipairs(tArgs) do
    local inputFile
    if inputPath == "-" then
        inputFile = io.input()
    else
        inputFile = io.open(inputPath)
    end

    -- Safety checks
    if inputFile ~= nil then
        for line in inputFile:lines() do
            output:write(line .. "\n")
        end

        io.close(inputFile)

    else
        print("Error! Invalid input file: " .. inputPath)
        print(usage)
        error()
    end
end

if fileoutput then
    output:close()
end


