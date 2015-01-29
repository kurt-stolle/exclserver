ES.NetworkedVariables={};

function ES.DefineNetworkedVariable(var,kind,size,shouldSave)
	if (type(size) != "number" and type(size) != "nil") or (type(shouldSave) != "string" and type(shouldSave) != "nil") then
		return ES.DebugPrint("Couldn't register NWVar "..var..", invalid argument #3 or #4.");
	end

	rawset(ES.NetworkedVariables,var,{
		type = kind,
		size = (size or nil),
		save = (shouldSave or nil)
	});
end
local PLAYER=FindMetaTable("Player");
function PLAYER:ESGetNetworkedVariable(key,default)
	return (self._es_networked and self._es_networked[key]) or default;
end

-- Some essential NWVars;
ES.DefineNetworkedVariable("typing","Bit");

ES.DefineNetworkedVariable("rank","String");

ES.DefineNetworkedVariable("VIP","Int",4,"tinyint(1) unsigned not null default 0")
ES.DefineNetworkedVariable("bananas","Int",32,"int(10) unsigned not null default 100");

ES.DefineNetworkedVariable("active_trail","String",nil,"varchar(22)");
ES.DefineNetworkedVariable("active_aura","String",nil,"varchar(22)");
ES.DefineNetworkedVariable("active_meleeweapon","String",nil,"varchar(22)");
ES.DefineNetworkedVariable("active_model","String",nil,"varchar(255)");