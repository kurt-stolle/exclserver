-- kick
-- kicks people

local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Freeze","Freeze ppl lel.","Excl")
PLUGIN:AddCommand("freeze",function(p,a)
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
			v:Freeze(true);
			net.Start("exclFP");
			net.WriteEntity(p);
			net.WriteString(v:Nick());
			net.WriteString(r);
			net.Broadcast();
		else
			ES.SendMessagePlayerTried(p,v:Nick(),"freeze")
		end
	end
end,10);
PLUGIN:AddCommand("unfreeze",function(p,a)
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
			v:Freeze(false);
			net.Start("exclUFP");
			net.WriteEntity(p);
			net.WriteString(v:Nick());
			net.WriteString(r);
			net.Broadcast();
		else
			ES.SendMessagePlayerTried(p,v:Nick(),"unfreeze")
		end
	end
end,10);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)
PLUGIN();

if SERVER then 
	util.AddNetworkString("exclFP");
	util.AddNetworkString("exclUFP");

	return 
end
net.Receive("exclUFP",function()
	local p = net.ReadEntity();
	local v = net.ReadString();
	local r = net.ReadString();
	if not IsValid(p) then return end
	
	if r and r != "" and r != " " then
		ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has unfrozen ",Color(102,255,51),v,Color(255,255,255,255), " with reason: "..(r or "No reason specified.")..".");
	else
		ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has unfrozen ",Color(102,255,51),v,Color(255,255,255,255),".");
	end
	chat.PlaySound()
end)
net.Receive("exclFP",function()
	local p = net.ReadEntity();
	local v = net.ReadString();
	local r = net.ReadString();
	if not IsValid(p) then return end
	
	if r and r != "" and r != " " then
		ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has frozen ",Color(102,255,51),v,Color(255,255,255,255), " with reason: "..(r or "No reason specified.")..".");
	else
		ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has frozen ",Color(102,255,51),v,Color(255,255,255,255),".");
	end
	chat.PlaySound()
end)