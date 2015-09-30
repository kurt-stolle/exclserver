local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Respawn","Respawn people.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)


if SERVER then
	util.AddNetworkString("exclNoRP")
	util.AddNetworkString("exclRP")

	PLUGIN:AddCommand("respawn",function(p,a)
		if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end
		local vTbl = ES.GetPlayerByName(a[1])
		if not vTbl or not vTbl[1] then
		  p:ESChatPrint("No player matching <hl>"..a[1].."</hl> could be found. Try finding the player by SteamID.")
		end

		local r
		if a[2] and a[2] ~= "" then
			r = ", reason: <hl>"..table.concat(a," ",2).."</hl>"
		else
			r = ""
		end

		for k,v in ipairs(vTbl)do
			if not v:ESIsImmuneTo(p) then
				v:Spawn()
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> respawned <hl>"..v:Nick().."</hl>"..r..".")
			else
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> tried to respawn <hl>"..v:Nick().."</hl>"..r..".")
			end
		end
	end,10)
end

PLUGIN()
