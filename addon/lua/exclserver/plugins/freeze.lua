-- kick
-- kicks people

local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Freeze","Freeze ppl lel.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then
	util.AddNetworkString("exclFP")
	util.AddNetworkString("exclUFP")

	PLUGIN:AddCommand("freeze",function(p,a)
		if type(a[1]) ~= "string" then
			p:ESChatPrint("Invalid arguments passed to command <hl>freeze</hl>.")
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

		for k,v in pairs(vTbl)do
			if not v:ESIsImmuneTo(p) then
				v:Freeze(true)
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> froze <hl>"..v:Nick().."</hl>"..r..".")
			else
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> tried to freeze <hl>"..v:Nick().."</hl>"..r..".")
			end
		end
	end,10)

	PLUGIN:AddCommand("unfreeze",function(p,a)
		if type(a[1]) ~= "string" then
			p:ESChatPrint("Invalid arguments passed to command <hl>freeze</hl>.")
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

		for k,v in pairs(vTbl)do
			if not v:ESIsImmuneTo(p) then
				v:Freeze(false)
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> unfroze <hl>"..v:Nick().."</hl>"..r..".")
			else
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> tried to unfreeze <hl>"..v:Nick().."</hl>"..r..".")
			end
		end
	end,10)
end
PLUGIN()
