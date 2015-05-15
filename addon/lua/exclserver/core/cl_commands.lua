-- cl_commands

ES.Commands= {}
net.Receive("ES.SyncCommands",function(len)
	ES.Commands=net.ReadTable() or {}
end)