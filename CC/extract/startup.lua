function load_apis(path)
    for _, file in ipairs(fs.list(path)) do
        if not fs.isDir(path..file) then
            os.loadAPI(path..file)
        else
            load_apis(path..file.."/")
        end
    end
end

load_apis("/lib/apis/")

rednet.open("back")
rednet.host("ChungIndustries", "server")
rednet.broadcast("update", "ChungIndustries")

shell.run("bg update")
shell.run("fg main")