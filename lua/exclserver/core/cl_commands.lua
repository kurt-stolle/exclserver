-- cl_commands

ES.Commands= {}
function ES.AddCommand(n,c,power)
	table.insert(ES.Commands,{name = n, power = power});
end
function ES.RemoveCommand(n)
	for k,v in pairs(ES.Commands)do
		if v == n then
			table.remove(ES.Commands,k);
			break;
		end
	end
end

net.Receive("ES.SyncCommands",function(len)
	ES.Commands=net.ReadTable() or {};
end);