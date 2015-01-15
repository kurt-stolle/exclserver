local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Map","Changes the map.","Excl")

PLUGIN:AddCommand("map",function(p,a)
	if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end

	net.Start("exclChMap");
	net.WriteEntity(p);
	net.WriteString(a[1]);
	net.Broadcast();
	
	timer.Simple(5,function()
		RunConsoleCommand("changelevel",a[1]);
	end);
end,20);
PLUGIN:AddCommand("mapvote",function(p,a)
	if not p or not p:IsValid() then return end

	ES.StartMapVote();
end,10);
PLUGIN:AddCommand("addmap",function(p,a)
	if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end

	ES.DBQuery("INSERT INTO es_mapvote SET map = '"..a[1].."', serverid = "..ES.ServerID..", enabled = 1;")
	p:ChatPrint("Map added to mapvote")
end,60);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE);
PLUGIN();

if SERVER then 
	util.AddNetworkString("exclChMap");

	return 
end
net.Receive("exclChMap",function()
	local p = net.ReadEntity();
	local m = net.ReadString();
	if not IsValid(p) then return end

	ES.ChatAddText("global",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p,Color(255,255,255)," has changed the map to ",Color(102,255,51),m);
	chat.PlaySound()
end)