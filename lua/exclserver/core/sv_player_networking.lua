util.AddNetworkString("ES.NwPlayerVar");

hook.Add("Initialize","ES.InitializeSavedNetworkedVariables",function()
	hook.Call("ES.DefineNetworkedVariables");
	ES.DefineNetworkedVariable = nil;

	for k,v in pairs(ES.NetworkedVariables)do
		if v.save then
			ES.DBQuery("ALTER TABLE `es_player` ADD "..ES.DBEscape(k).." "..v.save..";",function() ES.DebugPrint("Added column."); end,function() ES.DebugPrint("Column already exists."); end);
			ES.DBWait();
		end
	end
end);

hook.Add("PlayerInitialSpawn","ES.NetworkVars.LoadPlayerData",function(ply)
	local select={};
	for k,v in pairs(ES.NetworkedVariables)do
		if v.save then
			table.insert(select,"`"..k.."`");
		end
	end
	ES.DebugPrint("Loading networked variables from database for "..ply:Nick().." ...");
	if select[1] then
		select=table.concat(select,", ");

		ES.DBQuery(string.format("SELECT %s FROM `es_player` WHERE `id`=%s LIMIT 1;",select,tostring(ply:ESID())),function(data)
			ES.DebugPrint("Loaded networked variables saved from "..ply:Nick());

			if not data[1] then 
				ES.DBQuery("INSERT INTO `es_player` (id,steamid) VALUES("..ply:ESID()..",'"..ply:SteamID().."');");
				ply:ESSetNetworkedVariable("bananas",100,true);
				return 
			end

			for k,v in pairs(data[1])do
				ply:ESSetNetworkedVariable(k,v,true);
			end

			ES.DebugPrint("Successfully loaded networked variables for "..ply:Nick());
		end);
	else
		ES.DebugPrint("Nothing to load.")
	end	

	local queue={};
	for k,v in pairs(player.GetAll())do
		if v._es_networked then
			queue[v] = v._es_networked;
		end
	end

	local cnt=table.Count(queue);
	if cnt < 1 then return end

	net.Start("ES.NwPlayerVar");
	net.WriteUInt(cnt,8);
	for k,tab in pairs(queue)do
		net.WriteEntity(k);
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
	net.Send(ply);
end);

local queue={};
local PLAYER=FindMetaTable("Player");
function PLAYER:ESSetNetworkedVariable(key,value,noSave)
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

	if not self._es_networked then
		self._es_networked={};
	end
	self._es_networked[key]=value;

	if not queue[self] then
		queue[self]={};
	else
		for k,v in ipairs(queue[self])do
			if v.key==key then
				table.remove(queue[self],k);
				break;
			end
		end
	end
	table.insert(queue[self],{key=key,value=value,noSave=noSave});
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
local cnt;
timer.Create("ES.NetworkPlayers",.2,0,function()


	cnt=table.Count(queue);
	if not queue or cnt < 1 then return end
	
	ES.DebugPrint("Dispatched networked variable's queue.");

	net.Start("ES.NwPlayerVar");
	net.WriteUInt(cnt,8);
	for ply,tab in pairs(queue)do
		net.WriteEntity(ply);
		net.WriteUInt(#tab,8);
		for _,v in ipairs(tab)do

			if ES.NetworkedVariables[v.key].save and not tab.noSave then
				if kind=="String" then
					v.value="'"..v.value.."'";
				end
				ES.DBQuery("UPDATE `es_player` SET `"..v.key.."`="..ES.DBEscape(tostring(v.value)).." WHERE `id`="..ply:ESID()..";");

				ES.DebugPrint("Synchronized networked variable "..v.key.." with clients and database for "..ply:Nick());
			else
				ES.DebugPrint("Synchronized networked variable "..v.key.." with clients for "..ply:Nick());
			end

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
	net.Broadcast();

	queue={};
end);