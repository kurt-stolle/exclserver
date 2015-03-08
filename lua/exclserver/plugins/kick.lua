
local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Kick","Allows you to kick people from your server if you have the right rank.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then
	PLUGIN:AddCommand("kick",function(p,a)
		if type(a[1]) ~= "string" then
			p:ESChatPrint("Invalid arguments passed to command <hl>kick</hl>.")
			return
		end

		local vTbl = ES.GetPlayerByName(a[1])

		if not vTbl or not vTbl[1] then
		  p:ESChatPrint("No player matching <hl>"..a[1].."</hl> could be found. Try finding the player by SteamID.")
		  return
		end

		local r
		if a[2] and a[2] ~= "" then
			r = ", reason: <hl>"..table.concat(a," ",2).."</hl>"
		else
			r = ""
		end
		for k,v in ipairs(vTbl)do
			if not v:ESIsImmuneTo(p) then
				ES.AddBan(v:SteamID(),p:SteamID(),10,true,"Kick cooldown",v:Nick(),p:Nick())
				ES.DropUser(v:UserID(), "Kicked"..r)
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> kicked <hl>"..v:Nick().."</hl>"..r..".");
			else
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> tried to kick <hl>"..v:Nick().."</hl>"..r..".")
			end
		end
	end,10)
end
PLUGIN()
