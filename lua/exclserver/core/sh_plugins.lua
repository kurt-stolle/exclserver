-- sh_plugins.lua
EXCL_PLUGIN_FLAG_NODEFAULTDISABLED = 2;
EXCL_PLUGIN_FLAG_NOCANDISABLE = 4;

local m = {} -- functions applied to all tables on creation.

ES.Plugins = {} -- table to store all plugins

function ES:Plugin()
	local obj = {}
	setmetatable(obj,m);
	m.__index = m;
	
	obj.name = "Undefined";
	obj.descr = "Undefined";
	obj.author = "Undefined";
	obj.minrank = "user";
	obj.hooks = {};
	obj.commands = {};
	obj.flags = {}
	obj.id = "Unregisteredplugin" -- might be useful sometime, I guess.
	obj.aborted = false;
	obj.disabled = false;
	
	return obj;
end
function m:__call(n)
	if self.aborted then return end

	self.id = n;
	
	ES.Plugins[n] = self;
	//ES.DebugPrint("Registered plugin: "..n);
	
end
function m:Abort() -- stops it from registering
	self.aborted = true;
end
function m:Load()
	//ES.DebugPrint("Loaded plugin: "..self.id);

	self.disabled = false;
	for k,v in pairs(self.commands)do
		ES:AddCommand(k,v.func,v.rank)
	end
end
function m:UnLoad()
	//ES.DebugPrint("Unloaded plugin: "..self.id);

	self.disabled = true;
	for k,v in pairs(self.commands)do
		ES:RemoveCommand(k.func)
	end
end
function m:SetRank(r)
	self.minrank = (r or "user");
end
function m:AddFlag(n)
	self.flags[#self.flags+1] = n;
end
function m:SetInfo(n,d,a)
	self.name = n or self.name;
	self.descr = d or self.descr;
	self.author = a or self.author;
end
function m:AddHook(n,f)
	self.hooks[string.lower(n)] = f;
	hook.Add(n,self.name..n,function(...)
		if not self.disabled then
			f(...);
		end
	end);
end
function m:AddCommand(n,f,rank)
	self.commands[string.lower(n)] = {func = f, rank = rank};
end

hook.Add("ExclServerLoaded","ExclPluginsLoad",function()
	ES.DebugPrint("Loading plugins");
	for k,v in pairs(ES.Plugins) do
		v:Load();
	end
end)