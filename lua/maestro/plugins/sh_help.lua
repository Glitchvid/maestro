local function toSequence(tab)
	local ret = {}
	for k in pairs(tab) do
		ret[#ret + 1] = k
	end
	return ret
end
maestro.command("help", {"command:optional"}, function(caller, cmd)
	if cmd and not maestro.commands[cmd] then
		return true, "Invalid command!"
	end
	if caller then
		maestro.chat(caller, maestro.colors.white, "Help text has been printed to your console.")
		if not cmd then
			maestro.chat(caller, maestro.colors.white, "Use \"help <command>\" for per-command help.")
		end
		caller:SendLua("maestro.help(" .. (cmd and "\"" .. cmd .. "\"" or "") .. ")")
	else
		return maestro.help(cmd)
	end
end, [[
Displays this menu.]])
function maestro.help(cmd)
	if cmd then
		cmd = maestro.commandaliases[cmd] or cmd
		local col = maestro.colors.blue
		if LocalPlayer and not maestro.rankget(maestro.userrank(LocalPlayer())).perms[cmd] then
			col = maestro.colors.orange
		end
		local args = maestro.commands[cmd].args
		local ret = {maestro.colors.white}
		for j = 1, #args do
			table.insert(ret, maestro.colors.white)
			table.insert(ret, " <")
			table.insert(ret, maestro.colors.blue)
			local t = args[j]:match("%w+")
			table.insert(ret, t)
			table.insert(ret, maestro.colors.white)
			if args[j]:find(":") then
				table.insert(ret, args[j]:match(":.+"))
			end
			table.insert(ret, ">")
		end
		table.insert(ret, "\n")
		MsgC(maestro.colors.white, "ms ", col, cmd, maestro.colors.white, unpack(ret))
		if maestro.commands[cmd].help then
			for w in string.gmatch(maestro.commands[cmd].help, "[^\n]+") do
				MsgC("\t", maestro.colors.white, w, "\n")
			end
		end
	else
		MsgC(maestro.colors.white, "Available commands:\n")
		local names = toSequence(maestro.commands)
		table.sort(names)
		for i = 1, #names do
			local col = maestro.colors.blue
			if LocalPlayer and not maestro.rankget(maestro.userrank(LocalPlayer())).perms[names[i]] then
				col = maestro.colors.orange
			end
			local args = maestro.commands[names[i]].args
			local ret = {maestro.colors.white}
			for j = 1, #args do
				table.insert(ret, maestro.colors.white)
				table.insert(ret, " <")
				table.insert(ret, maestro.colors.blue)
				local t = args[j]:match("%w+")
				table.insert(ret, t)
				table.insert(ret, maestro.colors.white)
				if args[j]:find(":") then
					table.insert(ret, args[j]:match(":.+"))
				end
				table.insert(ret, ">")
			end
			table.insert(ret, "\n")
			MsgC(maestro.colors.white, "\tms ", col, names[i], maestro.colors.white, string.rep(" ", 26 - #names[i]), unpack(ret))
		end
	end
end
