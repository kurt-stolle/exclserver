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
  return
end
		local r = ""
		if table.concat(a," ",2) and table.concat(a," ",2) ~= "" then
			r = table.concat(a," ",2)
		end
		for k,v in pairs(vTbl)do
			if v:ESIsImmuneTo(p) then
				net.Start("exclNoRP")
				net.WriteEntity(p)
				net.WriteEntity(v)
				net.Broadcast()
			else
				--let's just add compatibility for some gamemodes
				if GAMEMODE and GAMEMODE.Name == "Deathrun" and TEAM_GOODIE then --excl's deathrun gamemode (casualbananas.com)
					v:SetTeam(TEAM_GOODIE)
					v:Spawn()
				else
					v:Spawn()
				end
				net.Start("exclRP")
				net.WriteEntity(p)
				net.WriteEntity(v)
				net.WriteString(r)
				net.Broadcast()
			end
		end
	end,20)

	return
end
net.Receive("exclNoRP",function()
	local p = net.ReadEntity()
	local v = net.ReadEntity()
	if not IsValid(p) or not IsValid(v) then return end

	chat.AddText("accessdenied",Color(255,255,255),
	exclFixCaps(p:ESGetRank().name).." ",
	Color(102,255,51),p:Nick(),
	Color(255,255,255),
	" tried to respawn ",
	Color(102,255,51),
	v:Nick(),
	ES.Color.White,
	".")
	chat.PlaySound()
end)
net.Receive("exclRP",function()
	local p = net.ReadEntity()
	local v = net.ReadEntity()
	local r = net.ReadString()
	if not IsValid(p) or not IsValid(v) then return end

	if r and r ~= "" and r ~= " " then
		chat.AddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has respawned ",Color(102,255,51),v:Nick(),ES.Color.White, " with reason: "..(r or "No reason specified.")..".")
	else
		chat.AddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has respawned ",Color(102,255,51),v:Nick(),ES.Color.White,".")
	end
	chat.PlaySound()
end)

PLUGIN()
