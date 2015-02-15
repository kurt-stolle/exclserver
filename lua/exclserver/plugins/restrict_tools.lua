-- kick
-- kicks people

local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Tool restrict","Allows you to restrict certain tools.","Excl")
PLUGIN:AddCommand("restricttool",function(p,a)
	if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end
	if !(p:GetActiveWeapon() and IsValid(p:GetActiveWeapon()) and p:GetActiveWeapon():GetClass() == "gmod_tool") then return end

	local toolmode = p:GetWeapon("gmod_tool").Mode
	local req = tonumber(a[1]);

	ES.DBQuery("SELECT * FROM es_restrictions_tools WHERE toolmode='"..toolmode.."' LIMIT 1;",function(res)
		if res and res[1] then
			ES.DBQuery("UPDATE es_restrictions_tools SET req = "..req.." WHERE toolmode='"..toolmode.."', serverid = "..ES.ServerID..";")
		else
			ES.DBQuery("INSERT INTO es_restrictions_tools SET toolmode='"..toolmode.."', req = "..req..", serverid = "..ES.ServerID..";")
		end
	end);

	ES.ToolRestrictions[toolmode] = req;

	net.Start("exclRestrTool");
	net.WriteEntity(p);
	net.WriteString(toolmode);
	net.WriteString(req <= 4 and "VIP tier "..tostring(req) or req == 5 and "Administrator" or req == 6 and "Super Administrator" or req == 7 and "Server Operator");
	net.Broadcast();
end,60);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN();

if SERVER then 
	ES.ToolRestrictions = {};

	util.AddNetworkString("exclRestrTool");
	util.AddNetworkString("exclNoTool");

	PLUGIN:AddHook("ES.MySQLReady",function()
		if !GAMEMODE.IsSandboxDerived then ES.DebugPrint("Not loading tool restriction - we are not on a sandbox derived gamemode."); return end -- thanks garry, now we can not load this ESPlugin when we are not in a sandbox derive.

		ES.DBQuery("SELECT * FROM es_restrictions_tools WHERE serverid = "..ES.ServerID..";",function(res)
			if res then
				ES.DebugPrint("Loaded tool restrictions");
				for k,v in pairs(res) do
					ES.ToolRestrictions[v.toolmode] = tonumber(v.req);
				end
			end
		end)
	end)

	PLUGIN:AddHook("CanTool",function(p,tr,tool)
		if ES.ToolRestrictions[tool] then
			local cantool = true;
			if ES.ToolRestrictions[tool] > 4 then
				if ES.ToolRestrictions[tool] == 5 and not p:IsAdmin() then cantool=false end
				if ES.ToolRestrictions[tool] == 6 and not p:IsSuperAdmin() then cantool=false end
				if ES.ToolRestrictions[tool] == 7 and not p:ESHasPower(60) then cantool=false end
			elseif p:ESGetVIPTier() < ES.ToolRestrictions[tool] then cantool=false end

			if !cantool then
				net.Start("exclNoTool");
				net.WriteString(tool);
				net.WriteString(ES.ToolRestrictions[tool] <= 4 and "VIP tier "..tostring(ES.ToolRestrictions[tool]) or ES.ToolRestrictions[tool] == 5 and "Administrator" or ES.ToolRestrictions[tool] == 6 and "Super Administrator" or ES.ToolRestrictions[tool] == 7 and "Server Operator")
				net.Send(p);
				return false
			end
		end
	end);

	return
end
net.Receive("exclRestrTool",function()
	local p = net.ReadEntity();
	local tool = net.ReadString();
	local rank = net.ReadString();
	if not IsValid(p) then return end
	
	ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has restricted ",Color(102,255,51),exclFixCaps(tool),ES.Color.White," to "..rank..".");
end)
net.Receive("exclNoTool",function()
	local tool = net.ReadString();
	local rank = net.ReadString();
	
	ES.ChatAddText("error",COLOR_EXCLSERVER,exclFixCaps(tool),COLOR_WHITE," is restricted to ",COLOR_EXCLSERVER,rank,COLOR_WHITE,".");
end)