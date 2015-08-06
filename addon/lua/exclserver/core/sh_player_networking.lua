ES.NetworkedVariables={}
setmetatable(ES.NetworkedVariables,{
	__index=function(tab,key)
		for k,val in ipairs(tab)do
			if k == key or val.name == key or val.CRC == key then
				return val
			end
		end
		return nil
	end
})

-- Registration
function ES.DefineNetworkedVariable(var,kind,size,shouldSave)
	if (type(size) ~= "number" and type(size) ~= "nil") or (type(shouldSave) ~= "string" and type(shouldSave) ~= "nil") then
		return ES.Error("NW_VAR_DEF_WRONG_PARAM","Couldn't register NWVar "..var..", invalid argument #3 or #4.")
	end

	local tab={
		name=var,
		CRC=tonumber(util.CRC(var)),
		type = kind,
		size = (size or nil),
		save = (shouldSave or nil),
		key=(#ES.NetworkedVariables + 1);
	}

	ES.NetworkedVariables[tab.key]=tab;
end

-- PLAYER class
local PLAYER=FindMetaTable("Player")
function PLAYER:ESGetNetworkedVariable(key,default)
	return (self._es_networked and self._es_networked[key]) or default
end

-- Some essential NWVars
ES.DefineNetworkedVariable("typing","Bit")
ES.DefineNetworkedVariable("idle","Bit")
ES.DefineNetworkedVariable("rank","String")

ES.DefineNetworkedVariable("VIP","UInt",4,"tinyint(1) unsigned not null default 0")
ES.DefineNetworkedVariable("bananas","UInt",32,"int(10) unsigned not null default 100")
ES.DefineNetworkedVariable("playtime","UInt",32,"int(16) unsigned not null default 0")

ES.DefineNetworkedVariable("active_trail","String",nil,"varchar(22)")
ES.DefineNetworkedVariable("active_aura","String",nil,"varchar(22)")
ES.DefineNetworkedVariable("active_meleeweapon","String",nil,"varchar(22)")
ES.DefineNetworkedVariable("active_model","String",nil,"varchar(255)")

-- Hooks
hook.Add("Initialize","exclserver.setup.network",function()
	hook.Call("ESDefineNetworkedVariables",GAMEMODE)
	ES.DefineNetworkedVariable = function()
		return ES.Error("NW_VAR_POST_INIT",var.." was defined post initialization")
	end
end)
