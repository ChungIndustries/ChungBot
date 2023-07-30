API_PREFIX = "https://api.github.com/repos/"

function github_http_request(url, authToken)
    return http.get(url, {Authorization="token "..authToken}).readAll()
end


function download_file(authToken, fileURL, localPath)
    local content = github_http_request(file.download_url, authToken)
    local f = fs.open(localPath..file.name, "w")
    f.write(content)
    f.close()
end

function download_files(authToken, user, repo, path, branch, localPath)
    path = path or ""
    branch = branch or "main"
    localPath = localPath or ("/downloads/"..repo.."/")

    local result = json.decode(github_http_request(API_PREFIX..user.."/"..repo.."/contents"..path.."?ref="..branch, authToken))

    for i, file in pairs(result) do
        if file.type == "file" then
            print("Downloading file: "..file.name)
            download_file(authToken, file, localPath)
        elseif file.type == "dir" then
            print("Listing directory: "..file.name)
            download_files(authToken, user, repo, path.."/"..file.name, branch, localPath..file.name.."/")
        end
    end
end


function download_repo(authToken, user, repo, branch, localPath)
    print("Connecting to Github...")
    download_file(authToken, user, repo, "", branch, localPath)
    print("Download complete!")
end


function get_latest_commit(authToken, user, repo)
    return json.decode(github_http_request(API_PREFIX..user.."/"..repo.."/commits", authToken))[1]
end


function get_current_dir()
    local runningProgram = shell.getRunningProgram()
    local programName = fs.getName(runningProgram)
    return runningProgram:sub(1, #runningProgram - #programName)
end

-- TODO
-- fix relative log file
function check_for_updates(authToken, user, repo)
    local latestCommit = get_latest_commit(authToken, user, repo)

    local logs = fs.open("/lib/Github/log.txt", "r")
    local lastUpdate = logs.readLine()
    logs.close()

    return latestCommit.commit.committer.date ~= lastUpdate
end
