local muted = {}

local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Voice mute","Allows you to mute people if you have the right rank.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)


if SERVER then 
	util.AddNetworkString("exclNoVMuP")
	util.AddNetworkString("exclVMuP")
	
	PLUGIN:AddCommand("voicemute",function(p,a)
		if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end
		local vTbl = ES.GetPlayerByName(a[1])
		if not vTbl then
  p:ESChatPrint("No player matching <hl>"..a[1].."</hl> could be found. Try finding the player by SteamID.")
  return
end
		local r
		if a[2] and a[2] ~= "" then
			r = table.concat(a," ",2)
		else
			r = ""
		end
		for k,v in pairs(vTbl)do
			if !v:ESIsImmuneTo(p) or v == p then 
				muted[v:SteamID()] = true
				net.Start("exclVMuP")
				net.WriteEntity(p)
				net.WriteString(v:Nick())
				net.WriteString(r)
				net.WriteBit(true)
				net.Broadcast()
			else
				net.Start("exclNoVMuP")
				net.WriteEntity(p)
				net.WriteString(v:Nick())
				net.Broadcast()
			end
		end
	end,10)
	PLUGIN:AddCommand("unvoicemute",function(p,a)
		if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end
		local vTbl = ES.GetPlayerByName(a[1])
		if not vTbl then
  p:ESChatPrint("No player matching <hl>"..a[1].."</hl> could be found. Try finding the player by SteamID.")
  return
end
		local r
		if a[2] and a[2] ~= "" then
			r = table.concat(a," ",2)
		else
			r = ""
		end
		for k,v in pairs(vTbl)do
			if !v:ESIsImmuneTo(p) or v == p then 
				muted[v:SteamID()] = false
				net.Start("exclVMuP")
				net.WriteEntity(p)
				net.WriteString(v:Nick())
				net.WriteString(r)
				net.WriteBit(false)
				net.Broadcast()
			else
				net.Start("exclNoVMuP")
				net.WriteEntity(p)
				net.WriteString(v:Nick())
				net.Broadcast()
			end
		end
	end,10)


	hook.Add("PlayerCanHearPlayersVoice","ESHandleVoiceMutes",function(listener,talker)
		if muted[talker:SteamID()] then
			return false, false
		end
	end)
	
	return 
end
net.Receive("exclNoVMuP",function()
	local p = net.ReadEntity()
	local v = net.ReadString()
	if not IsValid(p) then return end
	
	chat.AddText("accessdenied",Color(255,255,255),
	exclFixCaps(p:ESGetRank().name).." ",
	Color(102,255,51),p:Nick(),
	Color(255,255,255),
	" tried to voice mute ",
	Color(102,255,51),
	v,
	ES.Color.White,
	".")
	chat.PlaySound()
end)
net.Receive("exclVMuP",function()
	local p = net.ReadEntity()
	local v = net.ReadString()
	local r = net.ReadString()
	local mute = tobool(net.ReadBit())
	if not IsValid(p) then return end
	
	if mute then
		if r and r ~= "" and r ~= " " then
			chat.AddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has voice muted ",Color(102,255,51),v,ES.Color.White, " with reason: "..(r or "No reason specified.")..".")
		else
			chat.AddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has voice muted ",Color(102,255,51),v,ES.Color.White,".")
		end
	else
		if r and r ~= "" and r ~= " " then
			chat.AddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has voice unmuted ",Color(102,255,51),v,ES.Color.White, " with reason: "..(r or "No reason specified.")..".")
		else
			chat.AddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has voice unmuted ",Color(102,255,51),v,ES.Color.White,".")
		end
	end
	chat.PlaySound()
end)

PLUGIN()