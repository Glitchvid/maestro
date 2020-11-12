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
		maestro.chat(false, maestro.colors.white, "Player ", maestro.colors.blue, name, maestro.colors.white, " (", maestro.colors.blue, util.SteamIDFrom64(id64), maestro.colors.white, ") tried to connect to the server with incorrect password \"", cl, "\".")
	else
		maestro.chat(nil, maestro.colors.white, "Player ", maestro.colors.blue, name, maestro.colors.white, " (", maestro.colors.blue, util.SteamIDFrom64(id64), maestro.colors.white, ") has connected to the server.")
	end
end)
maestro.hook("PlayerInitialSpawn", "maestro_messages", function(ply)
	local joinstring = {"has joined ", maestro.colors.red, "for the first time", maestro.colors.white, "."}
	local id64 = ply:SteamID64()
	local q = mysql:Select(maestro.config.tables.joins)
	q:Where("steam64", id64)
	q:Callback(function(res, status)
			if type(res) == "table" and #res > 0 then
				local entry = res[1]
				joinstring = {"last joined ", maestro.colors.red, string.NiceTime(os.time() - entry.time) .. " ago", maestro.colors.white, "."}
			end
			CommitPlayerJoinTime(id64)
			maestro.chat(nil, maestro.colors.white, "Player ", maestro.colors.blue, ply:Nick(), maestro.colors.white, " (", maestro.colors.blue, ply:SteamID(), maestro.colors.white, ") ", unpack(joinstring))
		end)
	q:Execute()
end)
maestro.hook("PlayerDisconnected", "maestro_messages", function(ply)
	maestro.chat(nil, maestro.colors.white, "Player ", maestro.colors.blue, ply:Nick(), maestro.colors.white, " (", maestro.colors.blue, ply:SteamID(), maestro.colors.white, ") has left the game.")
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