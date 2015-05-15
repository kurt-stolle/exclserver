local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Cexec","Run commands on players.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then
	PLUGIN:AddCommand("clua",function(p,a)
		if type(a[1]) ~= "string" or type(a[2]) ~= "string" or a[2] == "" then
			p:ESChatPrint("Invalid arguments passed to command <hl>cexec</hl>.")
			return
		end

		local vTbl = ES.GetPlayerByName(a[1])

		if not vTbl or not vTbl[1] then
			p:ESChatPrint("No player matching <hl>"..a[1].."</hl> could be found. Try finding the player by SteamID.")
			return
		end

		local cmd = table.concat(a," ",2)

		for k,v in ipairs(vTbl)do
			if not v:ESIsImmuneTo(p) then
				v:SendLua(cmd)
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> ran lua <hl>"..cmd.."</hl> on <hl>"..v:Nick().."</hl>.")
			else
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> tried run lua <hl>"..cmd.."</hl> on <hl>"..v:Nick().."</hl>.")
			end
		end
	end,60)

	PLUGIN:AddCommand("cexec",function(p,a)
		if type(a[1]) ~= "string" or type(a[2]) ~= "string" or a[2] == "" then
			p:ESChatPrint("Invalid arguments passed to command <hl>cexec</hl>.")
			return
		end

		local vTbl = ES.GetPlayerByName(a[1])

		if not vTbl or not vTbl[1] then
			p:ESChatPrint("No player matching <hl>"..a[1].."</hl> could be found. Try finding the player by SteamID.")
			return
		end

		local cmd = table.concat(a," ",2)

		for k,v in ipairs(vTbl)do
			if not v:ESIsImmuneTo(p) then
				v:ConCommand(cmd)
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> ran concommand <hl>"..cmd.."</hl> on <hl>"..v:Nick().."</hl>.")
			else
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> tried run concommand <hl>"..cmd.."</hl> on <hl>"..v:Nick().."</hl>.")
			end
		end
	end,40)
end
PLUGIN();
