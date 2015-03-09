

local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Voice mute","Allows you to mute people if you have the right rank.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)


if SERVER then
	local muted = {}

	util.AddNetworkString("exclNoVMuP")
	util.AddNetworkString("exclVMuP")

	PLUGIN:AddCommand("voicemute",function(p,a)
		if type(a[1]) ~= "string" then
			p:ESChatPrint("Invalid arguments passed to command <hl>voicemute</hl>.")
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
				muted[v:SteamID()]=true
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> voicemuted <hl>"..v:Nick().."</hl>"..r..".")
			else
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> tried to voicemute <hl>"..v:Nick().."</hl>"..r..".")
			end
		end
	end,10)
	PLUGIN:AddCommand("unvoicemute",function(p,a)
		if type(a[1]) ~= "string" then
			p:ESChatPrint("Invalid arguments passed to command <hl>unvoicemute</hl>.")
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
				muted[v:SteamID()]=false
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> unvoicemuted <hl>"..v:Nick().."</hl>"..r..".")
			else
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> tried to unvoicemute <hl>"..v:Nick().."</hl>"..r..".")
			end
		end
	end,10)


	hook.Add("PlayerCanHearPlayersVoice","ESHandleVoiceMutes",function(listener,talker)
		if muted[talker:SteamID()] then
			return false, false
		end
	end)
end

PLUGIN()
