local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Respawn","Respawn people.","Excl")
PLUGIN:AddCommand("respawn",function(p,a)
	if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end
	local vTbl = exclPlayerByName(a[1])
	if not vTbl then return end
	local r = "";
	if table.concat(a," ",2) and table.concat(a," ",2) != "" then
		r = table.concat(a," ",2)
	end
	for k,v in pairs(vTbl)do
		if ( v==p and !p:IsSuperAdmin() ) or (v:ESIsImmuneTo(p) and v != p) then 
			net.Start("exclNoRP");
			net.WriteEntity(p);
			net.WriteEntity(v);
			net.Broadcast();
		else
			--let's just add compatibility for some gamemodes
			if GAMEMODE and GAMEMODE.Name == "Deathrun" and TEAM_GOODIE then --excl's deathrun gamemode (casualbananas.com)
				v:SetTeam(TEAM_GOODIE);
				v:Spawn();
			else
				v:Spawn();
			end
			net.Start("exclRP");
			net.WriteEntity(p);
			net.WriteEntity(v);
			net.WriteString(r);
			net.Broadcast();
		end
	end
end,20);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN();

if SERVER then 
	util.AddNetworkString("exclNoRP");
	util.AddNetworkString("exclRP");

	return 
end
net.Receive("exclNoRP",function()
	local p = net.ReadEntity();
	local v = net.ReadEntity();
	if not IsValid(p) or not IsValid(v) then return end
	
	ES.ChatAddText("accessdenied",Color(255,255,255),
	exclFixCaps(p:ESGetRank().name).." ",
	Color(102,255,51),p:Nick(),
	Color(255,255,255),
	" tried to respawn ",
	Color(102,255,51),
	v:Nick(),
	Color(255,255,255,255),
	".");
	chat.PlaySound()
end)
net.Receive("exclRP",function()
	local p = net.ReadEntity();
	local v = net.ReadEntity();
	local r = net.ReadString();
	if not IsValid(p) or not IsValid(v) then return end
	
	if r and r != "" and r != " " then
		ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has respawned ",Color(102,255,51),v:Nick(),Color(255,255,255,255), " with reason: "..(r or "No reason specified.")..".");
	else
		ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has respawned ",Color(102,255,51),v:Nick(),Color(255,255,255,255),".");
	end
	chat.PlaySound()
end)