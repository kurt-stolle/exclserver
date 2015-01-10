local protected={};
ES.NetworkedVariables={};
setmetatable(ES.NetworkedVariables,{
	__index=function(self,key)
		return protected[key] or nil;
	end,
	__newindex=function(self,key,value)
		return Error("Can not manually set networked variable. Use ES.DefineNetworkedVariable instead.");
	end
})
function ES.DefineNetworkedVariable(var,kind,size,shouldSave)
	rawset(protected,var,{
		type = kind,
		size = (size or nil),
		save = (shouldSave or false)
	});
end
hook.Add("Initialize","ES.DisallowNWVariables",function()
	hook.Call("ES.DefineNetworkedVariables");
	ES.DefineNetworkedVariable = nil;
end);

local pmeta=FindMetaTable("Player");
function pmeta:ESGetNetworkedVariable(key)
	return (ply._es_networked and ply._es_networked[key]) or nil;
end
