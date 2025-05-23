local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
	writefile(file, '')
end

local BASE_URL = "https://raw.githubusercontent.com/SOILXP/VapeV4ForRoblox7GD/main/"

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet(BASE_URL .. path, true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('%.lua$') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:lower():find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached')) == 1 then
			delfile(file)
		end
	end
end

-- 📂 Ensure required folders exist
for _, folder in { 'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis' } do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local commit = "main"
	if (not isfile("newvape/profiles/commit.txt")) or readfile("newvape/profiles/commit.txt") ~= commit then
		wipeFolder("newvape")
		wipeFolder("newvape/games")
		wipeFolder("newvape/guis")
		wipeFolder("newvape/libraries")
	end
	writefile("newvape/profiles/commit.txt", commit)
end

return loadstring(downloadFile("newvape/main.lua"), "main")()
