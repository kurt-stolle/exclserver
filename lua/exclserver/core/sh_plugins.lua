-- sh_plugins.lua
EXCL_PLUGIN_FLAG_NODEFAULTDISABLED = 2;
EXCL_PLUGIN_FLAG_NOCANDISABLE = 4;

local meta = {} -- functions applied to all tables on creation.

local plugins = {} -- table to store all plugins

AccessorFunc(meta,"name","Name",FORCE_STRING);
AccessorFunc(meta,"description","Description",FORCE_STRING);
AccessorFunc(meta,"author","Author",FORCE_STRING);
AccessorFunc(meta,"version","Version",FORCE_STRING);
function ES.Plugin()
	local PLUGIN = {}
	setmetatable(PLUGIN,meta);
	meta.__index = meta;
	
	PLUGIN:SetVersion("1.0");
	PLUGIN:SetDescription("No description");
	PLUGIN:SetAuthor("Unknown");

	PLUGIN.minrank = "user";
	PLUGIN.hooks = {};
	PLUGIN.commands = {};
	PLUGIN.flags = {}
	PLUGIN.id = -1 -- might be useful sometime, I guess.
	PLUGIN.disabled = false;
	
	return PLUGIN;
end
function meta:__call()
	if not self.name or ( string.len(self.name) < 1 ) then
		Error("Failed to register plugin. No name set.");
		return
	end

	self.id = util.CRC(sql.SQLStr(string.gsub(string.lower(self.name)," ","-"),true));
	
	plugins[self.id] = self;	
end
function meta:Load()
	self.disabled = false;
	for k,v in pairs(self.commands)do
		ES:AddCommand(k,v.func,v.rank)
	end
end
function meta:UnLoad()
	self.disabled = true;
	for k,v in pairs(self.commands)do
		ES:RemoveCommand(k.func)
	end
end
function meta:SetRank(r)
	self.minrank = (r or "user");
end
function meta:AddFlag(n)
	self.flags[#self.flags+1] = n;
end
function meta:SetInfo(n,d,a)
	self.name = n or self.name;
	self.descr = d or self.descr;
	self.author = a or self.author;
end
function meta:AddHook(n,f)
	self.hooks[string.lower(n)] = f;
	hook.Add(n,self.name..n,function(...)
		if not self.disabled then
			f(...);
		end
	end);
end
function meta:AddCommand(n,f,rank)
	self.commands[string.lower(n)] = {func = f, rank = rank};
end

hook.Add("ExclServerLoaded","ExclPluginsLoad",function()
	ES.DebugPrint("Loading plugins");
	for k,v in pairs(plugins) do
		v:Load();
	end
end)