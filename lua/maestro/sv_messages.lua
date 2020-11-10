local function CommitPlayerJoinTime(steam64, newtime)
	local q = mysql:Select(maestro.config.tables.joins)
		q:Where("steam64", steam64)
		q:Callback(function(res, status)
			if type(res) == "table" and #res > 0 then
				local q = mysql:Update(maestro.config.tables.joins)
					q:Update("time", newtime or os.time())
					q:Where("steam64", steam64)
				q:Execute()
			else
				local q = mysql:Insert(maestro.config.tables.joins)
					q:Insert("steam64", steam64)
					q:Insert("time", newtime or os.time())
				q:Execute()
			end
		end)
	q:Execute()
end
maestro.hook("CheckPassword", "maestro_messages", function(id64, ip, sv, cl, name)
	local id = util.SteamIDFrom64(id64)
	local ban = maestro.bans and maestro.bans[id] or false
	if ban and ban.unban > os.time() then
		return
	end
	if sv ~= "" and sv ~= cl then
		maestro.chat(false, Color(255, 255, 255), "Player ", Color(78, 196, 255), name, Color(255, 255, 255), " (", Color(78, 196, 255), util.SteamIDFrom64(id64), Color(255, 255, 255), ") tried to connect to the server with incorrect password \"", cl, "\".")
	else
		maestro.chat(nil, Color(255, 255, 255), "Player ", Color(78, 196, 255), name, Color(255, 255, 255), " (", Color(78, 196, 255), util.SteamIDFrom64(id64), Color(255, 255, 255), ") has connected to the server.")
	end
end)
maestro.hook("PlayerInitialSpawn", "maestro_messages", function(ply)
	local joinstring = {"has joined ", Color(255, 108, 69), "for the first time", Color(255, 255, 255), "."}
	local id64 = ply:SteamID64()
	local q = mysql:Select(maestro.config.tables.joins)
	q:Where("steam64", id64)
	q:Callback(function(res, status)
			if type(res) == "table" and #res > 0 then
				local entry = res[1]
				joinstring = {"last joined ", Color(255, 108, 69), string.NiceTime(os.time() - entry.time) .. " ago", Color(255, 255, 255), "."}
			end
			CommitPlayerJoinTime(id64)
			maestro.chat(nil, Color(255, 255, 255), "Player ", Color(78, 196, 255), ply:Nick(), Color(255, 255, 255), " (", Color(78, 196, 255), ply:SteamID(), Color(255, 255, 255), ") ", unpack(joinstring))
		end)
	q:Execute()
end)
maestro.hook("PlayerDisconnected", "maestro_messages", function(ply)
	maestro.chat(nil, Color(255, 255, 255), "Player ", Color(78, 196, 255), ply:Nick(), Color(255, 255, 255), " (", Color(78, 196, 255), ply:SteamID(), Color(255, 255, 255), ") has left the game.")
	CommitPlayerJoinTime(ply:SteamID64())
end)
maestro.hook("DatabaseConnected", "maestro_jointime", function()
	local q = mysql:Create(maestro.config.tables.joins)
		q:Create("id", "INT NOT NULL AUTO_INCREMENT")
		q:Create("steam64", "VARCHAR(17) NOT NULL")
		q:Create("time", "BIGINT NOT NULL")
		q:PrimaryKey("id")
	q:Execute()
end)