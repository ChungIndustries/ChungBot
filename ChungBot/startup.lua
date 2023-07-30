rednet.open("left")
rednet.host("ChungIndustries", tostring(os.getComputerID()))

local requirements = "/Bots/ChungBot"

local file = io.open("requirements.txt", "r")
for line in file:lines() do
    requirements = requirements.." "..line
end

shell.run("bg update "..requirements)
