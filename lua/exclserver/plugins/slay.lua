local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Slay","Allows you to slay people if you have the right rank.","Excl")
PLUGIN:AddCommand("slay",function(p,a)
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
			v:Kill();
			net.Start("exclSP");
			net.WriteEntity(p);
			net.WriteString(v:Nick());
			net.WriteString(r);
			net.Broadcast();
		else
			net.Start("exclNoSP");
			net.WriteEntity(p);
			net.WriteString(v:Nick());
			net.Broadcast();
		end
	end
end,10);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)


if SERVER then 
	util.AddNetworkString("exclNoSP");
	util.AddNetworkString("exclSP");

	return 
end
net.Receive("exclNoSP",function()
	local p = net.ReadEntity();
	local v = net.ReadString();
	if not IsValid(p) then return end
	
	ES.ChatAddText("accessdenied",Color(255,255,255),
	exclFixCaps(p:ESGetRank().name).." ",
	Color(102,255,51),p:Nick(),
	Color(255,255,255),
	" tried to slay ",
	Color(102,255,51),
	v,
	Color(255,255,255,255),
	".");
	chat.PlaySound()
end)
net.Receive("exclSP",function()
	local p = net.ReadEntity();
	local v = net.ReadString();
	local r = net.ReadString();
	if not IsValid(p) then return end
	
	if r and r != "" and r != " " then
		ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has slain ",Color(102,255,51),v,Color(255,255,255,255), " with reason: "..(r or "No reason specified.")..".");
	else
		ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has slain ",Color(102,255,51),v,Color(255,255,255,255),".");
	end
	chat.PlaySound()
end)