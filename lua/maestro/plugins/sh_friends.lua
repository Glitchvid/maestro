if SERVER then util.AddNetworkString("maestro_friends") end
local activequeries = {}
maestro.command("friends", {"player:target"}, function(caller, targets)
    if #targets == 0 then
        return true, "Query matched no players."
    elseif #targets > 1 then
        return true, "Query matched more than one player."
    end
    activequeries[targets[1]:SteamID64()] = caller:SteamID64()
    net.Start("maestro_friends")
    net.Send(targets[1])
end, [[
Prints out a listing of the target's currently connected friends.]])
net.Receive("maestro_friends", function(len, ply)
    if CLIENT then
        local friends = {}
        for k, v in ipairs(player.GetAll()) do
            if v:GetFriendStatus() == "friend" then
                table.insert(friends, v:Nick())
            end
        end
        net.Start("maestro_friends")
        net.WriteString(util.TableToJSON(friends))
        net.SendToServer()
    end
    if SERVER then
        if activequeries[ply:SteamID64()] then
            local caller = player.GetBySteamID64(activequeries[ply:SteamID64()])
            local friends = util.JSONToTable(net.ReadString())
            caller:PrintMessage(HUD_PRINTTALK, "Connected friends of " .. ply:Nick() .. ":")
            if (not friends) or #friends < 1 then
                caller:PrintMessage(HUD_PRINTTALK, "-\t" .. "None :'(")
            else
                for k, v in ipairs(friends) do
                    caller:PrintMessage(HUD_PRINTTALK, "-\t" .. v)
                end
            end
            activequeries[ply:SteamID64()] = nil
        end
    end
end)
