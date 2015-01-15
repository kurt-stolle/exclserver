local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Admin chat","Chat private to admins.","Excl")
PLUGIN:AddCommand("adminchat",function(p,a)
	if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end

	local ppl = {}
	for k,v in pairs(player.GetAll())do 
		if v:ESHasPower(20) or v == p then
			ppl[#ppl+1] = v;
		end
	end

	net.Start("exclAdminChat");
	net.WriteEntity(p);
	net.WriteString((table.concat(a," ",1) or ""));
	net.Send(ppl);
end,0);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE);


if SERVER then 
	util.AddNetworkString("exclAdminChat");

	return 
end
net.Receive("exclAdminChat",function()
	local p = net.ReadEntity();
	local msg = net.ReadString();
	if not IsValid(p) or not msg then return end

	ES.ChatAddText("medal",Color(255,255,255),"# ",exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255),": "..msg);
	chat.PlaySound()
end)
PLUGIN();