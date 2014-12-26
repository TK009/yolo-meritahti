
http.save = function (url, destination)

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

    -- Save to a file

    contents = result.readAll()

    hFile = io.open(destination, "w")
    hFile:write(contents)
    hFile:close()

end
