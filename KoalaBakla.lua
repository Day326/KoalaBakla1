-- Wait for the game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Load the notification library
local o = loadstring(game:HttpGet("https://paste.ee/r/E9tFZ/0"))()

-- Notification function
local function nt(n, c)
    o:MakeNotification({
        Name = n,
        Content = c,
        Image = "rbxassetid://4483345998",
        Time = 6
    })
end

-- Check if the game is "Grow a Garden"
local gagid = 126884695634066
if game.PlaceId ~= gagid then
    nt("This script is for Grow a Garden only!", "Ensure you are playing Grow a Garden!")
    return
end

-- Queue script to run on teleport
local q = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport) or function() end
local shf = [[
    repeat task.wait() until game:IsLoaded()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/M-E-N-A-C-E/Menace-Hub/refs/heads/main/Old%20Server%20Finder%20Grow%20a%20Garden", true))()
]]
q(shf)

-- Valid server versions
local validVersions = {
    [1223] = true,
    [1224] = true,
    [1231] = true,
    [1233] = true,
}

-- Server hopping function
local function sh()
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not req then
        warn("[SH]: No HTTP request support available.")
        nt("Error", "No HTTP request support. Cannot hop servers.")
        return
    end

    local hs, tp, plr = game:GetService("HttpService"), game:GetService("TeleportService"), game:GetService("Players")
    local pid, jid = game.PlaceId, game.JobId

    -- Make HTTP request to fetch public servers
    local success, res = pcall(function()
        return req({
            Url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"):format(pid),
            Method = "GET"
        })
    end)

    if not success or not res then
        warn("[SH]: HTTP request failed: " .. tostring(res))
        nt("Error", "Failed to fetch server list. Check executor compatibility.")
        return
    end

    if res.StatusCode ~= 200 then
        warn("[SH]: HTTP request failed with status code: " .. res.StatusCode)
        nt("Error", "Failed to fetch servers (Status: " .. res.StatusCode .. ").")
        return
    end

    -- Decode JSON response
    local ok, data = pcall(function() return hs:JSONDecode(res.Body) end)
    if not ok or not data or not data.data then
        warn("[SH]: JSON decode error: " .. tostring(data))
        nt("Error", "Failed to parse server data.")
        return
    end

    -- Log available servers for debugging
    print("[SH]: Found " .. #data.data .. " servers.")
    for _, v in ipairs(data.data) do
        print("[SH]: Server ID: " .. tostring(v.id) .. ", Version: " .. tostring(v.serverVersion or "N/A") .. ", Playing: " .. tostring(v.playing) .. "/" .. tostring(v.maxPlayers))
    end

    -- Find a valid server
    for _, v in ipairs(data.data) do
        if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= jid then
            if v.serverVersion and validVersions[v.serverVersion] then
                print("[SH]: Attempting to teleport to server ID: " .. v.id .. ", Version: " .. v.serverVersion)
                local teleportSuccess, teleportError = pcall(function()
                    tp:TeleportToPlaceInstance(pid, v.id, plr.LocalPlayer)
                end)
                if teleportSuccess then
                    nt("Teleporting", "Hopping to server version " .. v.serverVersion .. "...")
                    return
                else
                    warn("[SH]: Teleport failed: " .. tostring(teleportError))
                    nt("Error", "Teleport failed: " .. tostring(teleportError))
                end
            end
        end
    end

    warn("[SH]: No server with matching versions found.")
    nt("No Server Found", "No server found with versions 1223, 1224, 1231, or 1233.")
end

-- Check current server version
local currentVersion = game.PlaceVersion
if not validVersions[currentVersion] then
    nt("Not on valid version!", "Hopping to server with target version...")
    task.wait(0.1) -- Use task.wait for better performance
    sh()
else
    nt("You're on a valid server!", "Server Version: " .. currentVersion)
    setclipboard("https://discord.gg/zG5DYZqg96")
end
