local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Client execute","Allows you to run console commands on clients.","Excl")

local function cexec(p,a,broadcast)
	if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end
	local vTbl = exclPlayerByName(a[1])
	if not vTbl then return end
	local r;
	if a[2] and a[2] != "" then
		r = table.concat(a," ",2)
	else
		r = "";
	end
	if not r then return end
	for k,v in pairs(vTbl)do
		if !v:ESIsImmuneTo(p) or v == p then 
			v:ConCommand(r);
			
			if broadcast then
				net.Start("exclCEXP");
				net.WriteEntity(p);
				net.WriteString(v:Nick());
				net.WriteString(r);
				net.Broadcast();
			end
		
		else
			net.Start("exclNoCEXP");
			net.WriteEntity(p);
			net.WriteString(v:Nick());
			net.Broadcast();
		end
	end
end
PLUGIN:AddCommand("cexec",function(p,a)
	cexec(p,a,true)
end,40);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)
PLUGIN();

if SERVER then 
	util.AddNetworkString("exclNoCEXP");
	util.AddNetworkString("exclCEXP");

	return 
end
net.Receive("exclNoCEXP",function()
	local p = net.ReadEntity();
	local v = net.ReadString();
	if not IsValid(p) then return end
	
	ES.ChatAddText("accessdenied",Color(255,255,255),
	exclFixCaps(p:ESGetRank().name).." ",
	Color(102,255,51),p:Nick(),
	Color(255,255,255),
	" tried to run a console command ",
	Color(102,255,51),
	v,
	Color(255,255,255,255),
	".");
	chat.PlaySound()
end)
net.Receive("exclCEXP",function()
	local p = net.ReadEntity();
	local v = net.ReadString();
	local r = net.ReadString();
	if not IsValid(p) then return end
	
	ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has ran ",Color(102,255,51),r,Color(255,255,255,255), " on ",Color(102,255,51),v,Color(255,255,255),".");
	chat.PlaySound()
end)