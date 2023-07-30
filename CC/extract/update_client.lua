local tArgs = {...}
local clientId, localFilePath = table.unpack(tArgs)
clientId = tonumber(clientId)

function get_files(path)
    local files = {}

    print(path)

    for _, file in ipairs(fs.list(path)) do
        if fs.isDir(path.."/"..file) then
            get_files(path.."/"..file)
        else
            files[#files + 1] = path.."/"..file
        end
    end

    return files
end


local files = get_files(localFilePath)

if localFilePath:find("^/ChungIndustries/Bots") ~= nil then
    rednet.send(clientId, #files + 1, "ChungIndustries")
    sleep(1)

    local file = fs.open("/ChungIndustries/Bots/update.lua", "r")
    local fileContent = file.readAll()
    file.close()

    rednet.send(clientId, {localFilePath.."/update.lua", fileContent}, "ChungIndustries")
else
    rednet.send(clientId, #files, "ChungIndustries")
    sleep(1)
end


for i=1, #files do
    local filePath = files[i]
    local file = fs.open(filePath, "r")
    local fileContent = file.readAll()
    file.close()

    rednet.send(clientId, {filePath, fileContent}, "ChungIndustries")
end
