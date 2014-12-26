
local function fetch(url)
    local validUrl, urlError = http.checkURL(url)

    if not validUrl then
        error("URL Error! " .. urlError)
    end

    -- Fetch
    local result = http.get(url)
    if not result then
        error("Unknown http error!")
    end

    local responseCode = result.getResponseCode()
    if responseCode ~= 200 then
        error("Invalid url?, http response: " .. responseCode)
    end

    return result.readAll()
end


local function save(url, destination)

    contents = http.fetch(url)

    -- Save to a file
    hFile = io.open(destination, "w")
    hFile:write(contents)
    hFile:close()

end

if http then
    http.fetch = fetch
    http.save  = save
end

