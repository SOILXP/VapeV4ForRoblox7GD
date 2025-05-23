repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

if identifyexecutor then
    if table.find({ "Argon", "Wave" }, ({ identifyexecutor() })[1]) then
        getgenv().setthreadidentity = nil
    end
end

local vape
local loadstring = function(...)
    local res, err = loadstring(...)
    if err and vape then
        vape:CreateNotification("Vape", "Failed to load: " .. err, 30, "alert")
    end
    return res
end

local isfile = isfile or function(file)
    local suc, res = pcall(function() return readfile(file) end)
    return suc and res ~= nil and res ~= ""
end

local queue_on_teleport = queue_on_teleport or function() end
local playersService = game:GetService("Players")

local function downloadFile(path, func)
    local base = "https://raw.githubusercontent.com/SOILXP/VapeV4ForRoblox7GD/main/"
    if not isfile(path) then
        local suc, res = pcall(function()
            return game:HttpGet(base .. path, true)
        end)
        if not suc or res == "404: Not Found" then
            error(res)
        end
        if path:find(".lua") then
            res = "--This watermark is used to delete the file if its cached.
" .. res
        end
        writefile(path, res)
    end
    return (func or readfile)(path)
end

local function finishLoading()
    vape.Init = nil
    vape:Load()
    task.spawn(function()
        repeat
            vape:Save()
            task.wait(10)
        until not vape.Loaded
    end)

    local teleported = false
    vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
        if not teleported and not shared.VapeIndependent then
            teleported = true
            local teleportScript = [[
                shared.vapereload = true
                loadstring(game:HttpGet("https://raw.githubusercontent.com/SOILXP/VapeV4ForRoblox7GD/main/loader.lua", true))()
            ]]
            if shared.VapeDeveloper then
                teleportScript = "shared.VapeDeveloper = true\n" .. teleportScript
            end
            if shared.VapeCustomProfile then
                teleportScript = 'shared.VapeCustomProfile = "' .. shared.VapeCustomProfile .. '"\n' .. teleportScript
            end
            vape:Save()
            queue_on_teleport(teleportScript)
        end
    end))

    if not shared.vapereload then
        if not vape.Categories then return end
        if vape.Categories.Main.Options["GUI bind indicator"].Enabled then
            vape:CreateNotification("Finished Loading", vape.VapeButton and "Press the button in the top right to open GUI" or "Press " .. table.concat(vape.Keybind, " + "):upper() .. " to open GUI", 5)
        end
    end
end

if not isfile("newvape/profiles/gui.txt") then
    writefile("newvape/profiles/gui.txt", "new")
end

local gui = readfile("newvape/profiles/gui.txt")

if not isfolder("newvape/assets/" .. gui) then
    makefolder("newvape/assets/" .. gui)
end

vape = loadstring(downloadFile("newvape/guis/" .. gui .. ".lua"), "gui")()
shared.vape = vape

if not shared.VapeIndependent then
    loadstring(downloadFile("newvape/games/universal.lua"), "universal")()

    local placeScript = "newvape/games/" .. game.PlaceId .. ".lua"
    if isfile(placeScript) then
        loadstring(readfile(placeScript), tostring(game.PlaceId))()
    else
        local suc, res = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/SOILXP/VapeV4ForRoblox7GD/main/" .. placeScript, true)
        end)
        if suc and res ~= "404: Not Found" then
            loadstring(downloadFile(placeScript), tostring(game.PlaceId))()
        end
    end

    finishLoading()
else
    vape.Init = finishLoading
    return vape
end
