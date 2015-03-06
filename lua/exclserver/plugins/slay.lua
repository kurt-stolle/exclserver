local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Slay","Allows you to slay people if you have the right rank.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then
	PLUGIN:AddCommand("slay",function(p,a)
		if type(a[1]) ~= "string" then
			p:ESChatPrint("Invalid arguments passed to command <hl>slay</hl>.")
			return
		end

		local vTbl = ES.GetPlayerByName(a[1])

		if not vTbl then
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
				v:Kill()
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> slew <hl>"..v:Nick().."</hl>"..r..".")
			else
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> tried to slay <hl>"..v:Nick().."</hl>"..r..".")
			end
		end
	end,10)
end
PLUGIN();
