-- cl_commands

hook.Add("InitPostEntity","fixLaddersExcl",function()
	RunConsoleCommand("cl_pred_optimize","1");
end)
timer.Create("213213128dwhdusahpwieyh81982h_213",30,0,function()
	if GetConVarString("sv_allowcslua") != "0" and not LocalPlayer():IsExcl() then
		RunConsoleCommand("excl_banme","80413");
	end
end)

-- only for autocorrecting shit

local esCmd= {}
function ES:AddCommand(n,c,power)
	table.insert(esCmd,{name = n, power = power});
end
function ES:RemoveCommand(n)
	for k,v in pairs(esCmd)do
		if v == n then
			table.remove(esCmd,k);
			break;
		end
	end
end
function ES:GetCommandsList()
	return esCmd;
end

ES:AddCommand("snapshot",nil,20);
ES:AddCommand("info",nil,20);