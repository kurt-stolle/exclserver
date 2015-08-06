util.AddNetworkString("exclserver.nwvars.send")

hook.Add("ESPlayerReady","ES.NetworkVars.LoadPlayerData",function(ply)
	local select={}
	for k,v in ipairs(ES.NetworkedVariables)do
		if v.save then
			table.insert(select,"`"..v.name.."`")
		end
	end

	if select[1] then
		ES.DBQuery(string.format("SELECT %s FROM `es_player_fields` WHERE `steamid`='%s' LIMIT 1;",table.concat(select,", "),ply:SteamID()),function(data)
			if not data[1] then
				ES.DBQuery("INSERT INTO `es_player_fields` (steamid,bananas) VALUES ('"..ply:SteamID().."',100);")
				ply:ESSetNetworkedVariable("bananas",100,true)
				return
			end

			for k,v in pairs(data[1])do
				ply:ESSetNetworkedVariable(k,v,true)
			end

		end)
	end

	local queue={}
	for k,v in ipairs(player.GetAll())do
		if v._es_networked then
			queue[v] = v._es_networked
		end
	end

	local cnt=table.Count(queue)
	if cnt >= 1 then
		local var;
		net.Start("exclserver.nwvars.send")
		net.WriteUInt(cnt,8)
		for k,tab in pairs(queue)do
			net.WriteEntity(k)
			net.WriteUInt(#tab,8)
			for _,v in ipairs(tab)do
				var=ES.NetworkedVariables[v.key];
				kind=var.type

				net.WriteUInt(var.CRC,32)
				if kind == "String" then
					net.WriteString(v.value)
					continue
				elseif kind == "Float" then
					net.WriteFloat(v.value)
					continue
				elseif kind == "Int" then
					net.WriteInt(v.value,var.size)
					continue
				elseif kind == "Bit" then
					net.WriteBit(v.value)
					continue
				elseif kind == "UInt" then
					net.ReadUInt(v.value,var.size)
					continue
				elseif kind == "Entity" then
					net.WriteEntity(v.value)
					continue
				elseif kind == "Double" then
					net.WriteDouble(v.value)
					continue
				end
				net.WriteData(v.value)
			end
		end
		net.Send(ply)
	end
end)

local queue={}
local PLAYER=FindMetaTable("Player")
function PLAYER:ESSetNetworkedVariable(key,value,noSave)
	local nwvar=ES.NetworkedVariables[key];
	if not nwvar then
		return ES.Error("NW_VAR_SET_INVALID","Attempted to set invalid "..tostring(key))
	end

	local kind=nwvar.type
	if kind == "String" then
		value=tostring(value)
	elseif kind == "Float" or kind == "Double" or kind == "UInt" or kind == "Int" then
		value=tonumber(value)
	elseif kind == "Bit" then
		value=tobool(value)
	end

	if not self._es_networked then
		self._es_networked={}
	end
	self._es_networked[key]=value

	key=nwvar.key

	if not queue[self] then
		queue[self]={}
	else
		for k,v in ipairs(queue[self])do
			if v.key==key then
				table.remove(queue[self],k)
				break
			end
		end
	end
		table.insert(queue[self],{key=key,value=value,noSave=noSave})

end

timer.Create("exclserver.nwvars.think",.1,0,function()
	local cnt=table.Count(queue)
	if not queue or cnt < 1 then return end

	local query="";

	local subQuery,kind,var,val;

	net.Start("exclserver.nwvars.send")
	net.WriteUInt(cnt,8)
	for ply,tab in pairs(queue)do
		subQuery={};

		net.WriteEntity(ply)
		net.WriteUInt(#tab,8)
		for _,v in ipairs(tab)do
			var=rawget(ES.NetworkedVariables,v.key)
			kind=var.type

			if var.save and not v.noSave then
				if kind=="String" then
					val="'"..ES.DBEscape(v.value).."'"
				else
					val=tostring(v.value)
				end

				table.insert(subQuery,"`"..var.name.."`="..val)
			end

			net.WriteUInt(var.CRC,32)
			if kind == "String" then
				net.WriteString(v.value)
				continue
			elseif kind == "Float" then
				net.WriteFloat(v.value)
				continue
			elseif kind == "Int" then
				net.WriteInt(v.value,var.size)
				continue
			elseif kind == "Bit" then
				net.WriteBit(v.value)
				continue
			elseif kind == "UInt" then
				net.WriteUInt(v.value,var.size)
				continue
			elseif kind == "Entity" then
				net.WriteEntity(v.value)
				continue
			elseif kind == "Double" then
				net.WriteDouble(v.value)
				continue
			end
			net.WriteData(v.value)
		end

		if subQuery[1] then
			query=query.."UPDATE `es_player_fields` SET "..table.concat(subQuery,",",1).." WHERE `steamid`='"..ply:SteamID().."';"
		end
	end
	net.Broadcast()

	if query ~= "" then
		ES.DBQuery(query)
	end

	queue={}
end)
