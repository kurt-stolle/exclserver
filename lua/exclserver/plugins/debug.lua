-- debug commands
local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Debug","Debug commands, useless if you're not a dev.","Excl")
PLUGIN:AddCommand("listusers",function(p,a)
	if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end
	
	net.Start("exclDebugListUsers");
	net.WriteTable(exclPlayerByName(a[1]))
	net.Broadcast();
end,20);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)
PLUGIN();

if SERVER then 
	util.AddNetworkString("exclDebugListUsers");

	return 
end
net.Receive("exclDebugListUsers",function()
	local tbl = net.ReadTable();
	
	for k,v in pairs(tbl)do
		ES.ChatAddText("error",Color(255,255,255),v:Nick());
	end
end)