PLUGIN:SetInfo("Announce","Announce messages to all players.","Excl")
PLUGIN:AddCommand("announce",function(p,a)
	if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end

	net.Start("exclAnnouce");
	net.WriteEntity(p);
	net.WriteString((table.concat(a," ",1) or ""));
	net.Broadcast();
end,10);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE);


if SERVER then 
	util.AddNetworkString("exclAnnouce");

	return 
end
net.Receive("exclAnnouce",function()
	local p = net.ReadEntity();
	local m = net.ReadString();
	if not IsValid(p) then return end

	ES:ChatAddText("announce",Color(255,255,255),"(ANNOUNCEMENT) "..exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255),": "..m);
	chat.PlaySound()
end)