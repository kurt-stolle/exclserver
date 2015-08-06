net.Receive("exclserver.nwvars.send",function(len)
	local num_players=net.ReadUInt(8)
	for o=1,num_players do
		local ply=net.ReadEntity()
		local num_keys=net.ReadUInt(8)

		if not IsValid(ply) or not ply:IsPlayer() or not num_keys or num_keys < 1 then return ES.Error("NW_VAR_RECEIVE_NO_PLAYER","Invalid player or keys") end

		if not ply._es_networked then
			ply._es_networked={}
		end

		local var,key,kind,CRC;
		for i=1,num_keys do
			CRC=net.ReadUInt(32);
			var=ES.NetworkedVariables[CRC]

			if not var then
				ES.Error("NW_VAR_RECEIVE_INVALID","Received invalid NWVar, CRC: "..CRC)
				continue
			end

			kind=var.type
			key=var.name

			if kind == "String" then
				ply._es_networked[key]=net.ReadString()
				continue
			elseif kind == "Float" then
				ply._es_networked[key]=net.ReadFloat()
				continue
			elseif kind == "Int" then
				ply._es_networked[key]=net.ReadInt(var.size)
				continue
			elseif kind == "Bit" then
				ply._es_networked[key]=net.ReadBit()
				continue
			elseif kind == "UInt" then
				ply._es_networked[key]=net.ReadUInt(var.size)
				continue
			elseif kind == "Entity" then
				ply._es_networked[key]=net.ReadEntity()
				continue
			elseif kind == "Double" then
				ply._es_networked[key]=net.ReadDouble()
				continue
			end

			ply._es_networked[key]=net.ReadData()
		end
	end
end)
