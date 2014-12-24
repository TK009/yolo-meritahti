
local tArgs = { ... }

local usage = [[
usage: cat [files]
files are paths to readable files or "-" which is stdin,
if no files given cat loops stdin to stdout.
]]


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
            print(line)
        end
    else
        print("Error! Invalid input file: " .. inputPath)
        print(usage)
    end
end



        

