local downloadDirectories = {...}
local serverId


function get_server_id(protocol)
    return rednet.lookup(protocol, "server")
end


function get_server_message(serverId)
    local id, message

    while id ~= serverId do
        id, message = rednet.receive("ChungIndustries", 10)
    end

    return message
end


function request_file(serverId, filePath)
    rednet.send(serverId, "download:"..filePath, "ChungIndustries")

    return tonumber(get_server_message(serverId))
end


while serverId == nil do
    print("Getting server id...")
    serverId = get_server_id("ChungIndustries")
end


while true do
    print("Checking for updates...")

    local message = get_server_message(serverId)

    if message == "update" then
        print("Update found!")
        
        for _, dir in downloadDirectories do
            local fileCount = request_file(serverId, dir)

            print("Getting "..fileCount.." files...")

            for i=1, fileCount do
                local filePath, fileContent = table.unpack(get_server_message(serverId))
                print("Downloading "..filePath)
                local file = fs.open(filePath, "w")
                file.write(fileContent)
                file.close()
            end
        end

        shell.run("delete startup.lua")
        shell.run("delete update.lua")
        shell.run("delete chung_bot.lua")
        shell.run("delete requirements.txt")

        shell.run("mv /ChungIndustries/Bots/ChungBot/* /*")
        shell.run("delete /ChungIndustries")

        print("Refactoring System")
        sleep(1)
        os.reboot()
    end

end