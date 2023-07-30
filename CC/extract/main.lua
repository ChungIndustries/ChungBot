while true do
    print("Waiting for requests...")
    local clientId, message = rednet.receive("ChungIndustries")
    local ids = {rednet.lookup("ChungIndustries")}

    local computerIds = {}

    for i, id in ipairs(ids) do
        computerIds[id] = i
    end

    if computerIds[clientId] ~= nil and message:find("^download") then
        local path = "/ChungIndustries"..message:match(":(.*)")
        print("Request received for: "..path)
        shell.run("bg update_client "..clientId.." "..path)
    end

end