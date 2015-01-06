-- kick
-- kicks people

PLUGIN:SetInfo("Kick","Allows you to kick people from your server if you have the right rank.","Excl")
PLUGIN:AddCommand("kick",function(p,a)
	if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end
	local vTbl = exclPlayerByName(a[1])
	if not vTbl then return end
	local r;
	if a[2] and a[2] != "" then
		r = table.concat(a," ",2)
	else
		r = "";
	end
	for k,v in pairs(vTbl)do
		if !v:ESIsImmuneTo(p) or v == p then 

			ES:AddBan(v:SteamID(),p:SteamID(),10,true,"Kicked off ("..(r or "No reason given")..")",v:Nick(),p:Nick())

			exclDropUser(v:UserID(), "You were kicked off the server.\n"..(r or "No reason given"));
			net.Start("exclKP");
			net.WriteEntity(p);
			net.WriteString(v:Nick());
			net.WriteString(r);
			net.Broadcast();
		else
			ES:SendMessagePlayerTried(p,v:Nick(),"kick")
		end
	end
end,10);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then 
	util.AddNetworkString("exclKP");

	return 
end
net.Receive("exclKP",function()
	local p = net.ReadEntity();
	local v = net.ReadString();
	local r = net.ReadString();
	if not IsValid(p) then return end
	
	if r and r != "" and r != " " then
		ES:ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has kicked ",Color(102,255,51),v,Color(255,255,255,255), " with reason: "..(r or "No reason specified.")..".");
	else
		ES:ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has kicked ",Color(102,255,51),v,Color(255,255,255,255),".");
	end
	chat.PlaySound()
end)