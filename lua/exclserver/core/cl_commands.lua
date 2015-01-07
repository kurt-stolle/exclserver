-- cl_commands

hook.Add("InitPostEntity","ES.FixLadders",function()
	RunConsoleCommand("cl_pred_optimize","1");
end)

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