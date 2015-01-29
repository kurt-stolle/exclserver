net.Receive("ES.NwPlayerVar",function(len)
	local num_players=net.ReadUInt(8)
	for o=1,num_players do
		local ply=net.ReadEntity();
		local num_keys=net.ReadUInt(8);

		if not IsValid(ply) or not ply:IsPlayer() or not num_keys or num_keys < 1 then return end

		if not ply._es_networked then
			ply._es_networked={};
		end

		local key,kind; 
		for i=1,num_keys do
			key=net.ReadString();
			if not ES.NetworkedVariables[key] then
				ply._es_networked[key]=net.ReadData();
				continue;
			end

			kind=ES.NetworkedVariables[key].type;
			if kind == "String" then
				ply._es_networked[key]=net.ReadString();
				continue;
			elseif kind == "Float" then
				ply._es_networked[key]=net.ReadFloat();
				continue;
			elseif kind == "Int" then
				ply._es_networked[key]=net.ReadInt(ES.NetworkedVariables[key].size);
				continue;
			elseif kind == "Bit" then
				ply._es_networked[key]=net.ReadBit();
				continue;
			elseif kind == "UInt" then
				ply._es_networked[key]=net.ReadUInt(ES.NetworkedVariables[key].size);
				continue;
			elseif kind == "Entity" then
				ply._es_networked[key]=net.ReadEntity();
				continue;
			elseif kind == "Double" then
				ply._es_networked[key]=net.ReadDouble();
				continue;
			end
			ply._es_networked[key]=net.ReadData();
		end
	end
end)

hook.Add("Initialize","ES.InitNetworkedVariables.Sync",function()
	hook.Call("ES.DefineNetworkedVariables");
	ES.DefineNetworkedVariable = nil;

	net.Start("ES.NwPlayerVar");
	net.SendToServer();
end);