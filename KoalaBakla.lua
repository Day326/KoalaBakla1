if not game:IsLoaded() then
    game.Loaded:Wait()
end

local o = loadstring(game:HttpGet("https://paste.ee/r/E9tFZ/0"))()
function nt(n, c)
    o:MakeNotification({
        Name = n,
        Content = c,
        Image = "rbxassetid://4483345998",
        Time = 6
    })
end

local gagid = 126884695634066
if game.PlaceId ~= gagid then
    nt("This script is for Grow a Garden only!", "Ensure you are playing Grow a Garden!")
    return
end

local q = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport) or function() end
local shf = [[ repeat task.wait() until game:IsLoaded() loadstring(game:HttpGet("https://raw.githubusercontent.com/M-E-N-A-C-E/Menace-Hub/refs/heads/main/Old%20Server%20Finder%20Grow%20a%20Garden", true))() ]]
q(shf)

local validVersions = {
    [1223] = true,
    [1224] = true,
    [1231] = true,
    [1233] = true,
}

local function sh()
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not req then return warn("[SH]: No request support.") end

    local hs, tp, plr = game:GetService("HttpService"), game:GetService("TeleportService"), game:GetService("Players")
    local pid, jid = game.PlaceId, game.JobId

    local res = req({
        Url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"):format(pid)
    })

    if res.StatusCode ~= 200 then return warn("[SH]: Failed to fetch servers.") end

    local ok, data = pcall(function() return hs:JSONDecode(res.Body) end)
    if not ok or not data or not data.data then return warn("[SH]: JSON error.") end

    for _, v in next, data.data do
        if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= jid then
            if v.serverVersion and validVersions[v.serverVersion] then
                tp:TeleportToPlaceInstance(pid, v.id, plr.LocalPlayer)
                return
            end
        end
    end

    warn("[SH]: No server with matching versions found.")
    nt("No Server Found", "No server found with versions 1223, 1224, 1231, or 1233.")
end

local currentVersion = game.PlaceVersion
if not validVersions[currentVersion] then
    nt("Not on valid version!", "Hopping to server with target version...")
    wait(0.1)
    sh()
else
    nt("You're on a valid server!", "Server Version: " .. currentVersion)
    setclipboard("https://discord.gg/zG5DYZqg96")
end
