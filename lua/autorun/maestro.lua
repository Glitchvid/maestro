local version = "2.4.2"
maestro = {}
print("╔══════════════════════════════════╗")
print("╟ Maestro " .. version .. string.rep(" ", 25 - #version) .. "╢")
print("╟     (it's pronounced \"my strow\") ╢")
print("╟ (c) 2015 Ott(STEAM_0:0:36527860) ╢")
print("╠══════════════════════════════════╣")
hook.Call("maestro_preload")
local files, folders = file.Find("maestro/*.lua", "LUA")
table.sort(files, function(a, b)
	local suba = string.sub(a, 1, 3)
	local subb = string.sub(b, 1, 3)
	if table.HasValue({"sv_", "sh_", "cl_"}, suba) and table.HasValue({"sv_", "sh_", "cl_"}, subb) then
		return string.sub(a, 4, -5) < string.sub(b, 4, -5)
	end
	return a < b
end)
for k, v in pairs(files) do
	print("║ " .. v .. string.rep(" ", 33 - #v) .. "║")
	if string.sub(v, 1, 3) == "cl_" then
		if SERVER then
			AddCSLuaFile("maestro/" .. v)
		end
		if CLIENT then
			include("maestro/" .. v)
		end
	elseif string.sub(v, 1, 3) == "sh_" then
		if SERVER then
			AddCSLuaFile("maestro/" .. v)
		end
		include("maestro/" .. v)
	elseif string.sub(v, 1, 3) == "sv_" then
		if SERVER then
			include("maestro/" .. v)
		end
	end
end
print("╟──────────────────────────────────╢")
hook.Add("maestro_pluginload", "maestro", function()
	hook.Call("maestro_prepluginload")
	local files, folders = file.Find("maestro/plugins/*.lua", "LUA")
	table.sort(files, function(a, b)
		local suba = string.sub(a, 1, 3)
		local subb = string.sub(b, 1, 3)
		if table.HasValue({"sv_", "sh_", "cl_"}, suba) and table.HasValue({"sv_", "sh_", "cl_"}, subb) then
			return string.sub(a, 4, -5) < string.sub(b, 4, -5)
		end
		return a < b
	end)
	for k, v in pairs(files) do
		print("║ " .. v .. string.rep(" ", 33 - #v) .. "║")
		if string.sub(v, 1, 3) == "cl_" then
			if SERVER then
				AddCSLuaFile("maestro/plugins/" .. v)
			end
			if CLIENT then
				include("maestro/plugins/" .. v)
			end
		elseif string.sub(v, 1, 3) == "sh_" then
			if SERVER then
				AddCSLuaFile("maestro/plugins/" .. v)
			end
			include("maestro/plugins/" .. v)
		elseif string.sub(v, 1, 3) == "sv_" then
			if SERVER then
				include("maestro/plugins/" .. v)
			end
		end
	end
	hook.Call("maestro_postpluginload")
	print("╚══════════════════════════════════╝")
end)
hook.Call("maestro_postload")
if CLIENT then
	hook.Call("maestro_pluginload")
end

hook.Add("InitPostEntity", "maestro_updatecheck", function()
	timer.Simple(0, function()
		http.Fetch("https://raw.githubusercontent.com/DaaOtt/maestro/master/lua/autorun/maestro.lua", function(body)
			local str = string.match(body, "[^\n]+")
			local ver = str:sub(18, -2)
			local major, minor, patch = ver:match("(%d+)%.(%d+)%.(%d+)")
			major = tonumber(major) or 0
			minor = tonumber(minor) or 0
			patch = tonumber(patch) or 0
			local curmajor, curminor, curpatch = version:match("(%d+)%.(%d+)%.(%d+)")
			curmajor = tonumber(curmajor) or 0
			curminor = tonumber(curminor) or 0
			curpatch = tonumber(curpatch) or 0
			local msg
			if major > curmajor then
--3456789012345678901234567890123
				msg = [[
A new major version of Maestro is
available (%%%%%%%%). Note that
new major versions break
compatibility with previous major
versions.
]]
			elseif minor > curminor then
				msg = [[
A new minor version of Maestro
is available (%%%%%%%%). Minor
versions add a new feature or
mechanismsm.
]]
			elseif patch > curpatch then
				msg = [[
A new patch is available for
Maestro (%%%%%%%%). Patches offer
fixes for bugs and errors.
]]
			end
			if msg then
				msg = string.gsub(msg, "%%+", ver)
				print("╔══════════════════════════════════╗")
				for w in string.gmatch(msg, "[^\n]+") do
					print("\186 " .. w .. string.rep(" ", 32 - #w) .. " \186")
				end
				print("╚══════════════════════════════════╝")
			end
		end)
	end)
end)
