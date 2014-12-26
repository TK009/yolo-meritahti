
-- Simple bootstrap, this is inteded to be uploaded to pastebin for easy retrieval.
-- Usage: pastebin run <the code of this file>

local baseURL = "http://pesutykki.mooo.com/dump/yolo-meritahti"

if not http then
    error "This installer requires http. How did you even get this?"
end

local programs = { ["tmp"] = "/lib/core/http.lua"
                 , ["/installer"] = "/installer.lua"}

for destination, remote in pairs(programs) do
    local url = baseURL .. remote
    local result = http.get(url)

    if result and result.responseCode == 200 then
        local contents = result.readAll()
        local hFile = io.open(destination, "w")
        hFile:write(contents)
        hFile:close()
        shell.run(destination)
        fs.delete(destination)
    else
        error("http error")
    end
end
