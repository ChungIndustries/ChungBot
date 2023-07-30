local credentials = {"REDACTED", "chrille0313", "ChungIndustries", "/CC"}

function log_update(authToken, user, repo, destination)
    destination = destination or github.get_current_dir()
    local latestCommitDate = github.get_latest_commit(authToken, user, repo).commit.committer.date

    local f = fs.open(destination.."/log.txt", "w")
    f.write(latestCommitDate)
    f.close()
end

-- TODO
-- Don't download whole repository (idiot)
function update()
    print("Downloading update...")
    github.download_repo(table.unpack(credentials))
    print("Download complete!")

    print("Refactoring system..")
    shell.run("delete main.lua")
    shell.run("delete startup.lua")
    shell.run("delete update.lua")
    shell.run("delete update_client.lua")
    shell.run("delete lib")
    shell.run("delete ChungIndustries")

    shell.run("move /downloads/ChungIndustries/extract/* /")
    shell.run("delete /downloads/ChungIndustries/extract")
    shell.run("move /downloads/* /")
    shell.run("delete /downloads")

    shell.run("reboot")
end


log_update("REDACTED", "chrille0313", "ChungIndustries", "/lib/Github")

while true do
    print("Checking for updates...")
    if github.check_for_updates(table.unpack(credentials)) then
        print("Update found!")
        update()
    end

    sleep(10)
end
