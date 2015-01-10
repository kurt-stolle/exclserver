util.AddNetworkString("ES.NwPlayerVar");

hook.Add("Initialize","ES.InitializeSavedNetworkedVariables",function()
	for k,v in pairs(ES.NetworkedVariables)do
		if v.save then
			ES.DebugPrint("Checking es_player database for the existance of column '"..k.."'");
			local kind="TINYTEXT";
			if v.type == "Float" then
				kind="FLOAT";
			elseif v.type == "Int" then
				kind="INT";
			elseif v.type == "Bit" then
				kind="tinyint";
			elseif v.type == "UInt" then
				kind="UNSIGNED INT";
			elseif v.type == "Entity" then
				ES.DebugPrint("Can not save datatype Entity");
				continue;
			elseif v.type == "Double" then
				kind="DOUBLE";
			end
			ES.DBQuery("ALTER TABLE `es_player` ADD "..ES.DBEscape(k).." "..kind..";",function() ES.DebugPrint("Added column."); end,function() ES.DebugPrint("Column already exists."); end);
			ES.DBWait();
		end
	end
end);

local queue={};
local pmeta=FindMetaTable("Player");
function pmeta:ESSetNetworkedVariable(key,value)
	if not ES.NetworkedVariables[key] then
		ES.DebugPrint("Attempted to set invalid NetworkedVariable "..key);
		return;
	end

	local kind=ES.NetworkedVariables[key].type;
	if kind == "String" then
		value=tostring(value);
	elseif kind == "Float" or kind == "Double" or kind == "UInt" or kind == "Int" then
		value=tonumber(value);
	elseif kind == "Bit" then
		value=tobool(value);
	end

	if not ply._es_networked then
		ply._es_networked={};
	end
	ply._es_networked[key]=value;

	if not queue[ply] then
		queue[ply]={};
	else
		for k,v in ipairs(queue[ply])do
			if v.key==key then
				table.remove(queue[ply],k);
				break;
			end
		end
	end
	table.insert(queue[ply],{key=key,value=value});
end

local kind;
net.Receive("ES.NwPlayerVar",function(len,requester)
	if requester._es_networked_initialized then return end
	requester._es_networked_initialized=true;

	local syncholders={};
	local amount=0;
	for k,v in pairs(player.GetAll())do
		if v._es_networked then
			amount=amount+1;
			syncholders[v]=v._es_networked;
		end
	end

	net.Start("ES.NwPlayerVar");
	net.WriteUInt(amount,8);
	for ply,tab in pairs(syncholders)do
		net.WriteEntity(ply);
		net.WriteUInt(#tab,8);
		for _,v in ipairs(tab)do
			net.WriteString(v.key);
			kind=ES.NetworkedVariables[v.key].type;
			if kind == "String" then
				net.WriteString(v.value);
				continue;
			elseif kind == "Float" then
				net.WriteFloat(v.value);
				continue;
			elseif kind == "Int" then
				net.WriteInt(v.value,ES.NetworkedVariables[v.key].size);
				continue;
			elseif kind == "Bit" then
				net.WriteBit(v.value);
				continue;
			elseif kind == "UInt" then
				net.ReadUInt(v.value,ES.NetworkedVariables[v.key].size);
				continue;
			elseif kind == "Entity" then
				net.WriteEntity(v.value);
				continue;
			elseif kind == "Double" then
				net.WriteDouble(v.value);
				continue;
			end
			net.WriteData(v.value);
		end
	end
	net.Send(requester);
end);
timer.Create("ES.NetworkPlayers",.5,0,function()
	if not queue then return end
	
	net.Start("ES.NwPlayerVar");
	net.WriteUInt(table.Count(queue));
	for ply,tab in pairs(queue)do
		net.WriteEntity(ply);
		net.WriteUInt(#tab,8);
		for _,v in ipairs(tab)do
			net.WriteString(v.key);
			kind=ES.NetworkedVariables[v.key].type;
			if kind == "String" then
				net.WriteString(v.value);
				continue;
			elseif kind == "Float" then
				net.WriteFloat(v.value);
				continue;
			elseif kind == "Int" then
				net.WriteInt(v.value,ES.NetworkedVariables[v.key].size);
				continue;
			elseif kind == "Bit" then
				net.WriteBit(v.value);
				continue;
			elseif kind == "UInt" then
				net.ReadUInt(v.value,ES.NetworkedVariables[v.key].size);
				continue;
			elseif kind == "Entity" then
				net.WriteEntity(v.value);
				continue;
			elseif kind == "Double" then
				net.WriteDouble(v.value);
				continue;
			end
			net.WriteData(v.value);

			if ES.NetworkedVariables[v.key].save then
				if kind=="String" then
					v.value="'"..v.value.."'";
				end
				ES.DBQuery("UPDATE `es_player` WHERE id="..ply:ESID().." SET "..ES.DBEscape(v.key).." = "..ES.DBEscape(v.value)..";");
			end
		end
	end
	net.Broadcast();

	queue={};
end);