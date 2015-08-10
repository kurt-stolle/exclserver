-- sh_plugins.lua
EXCL_PLUGIN_FLAG_NODEFAULTDISABLED = 1
EXCL_PLUGIN_FLAG_NOCANDISABLE = 2

local meta = {} -- functions applied to all tables on creation.

ES.Plugins = {} -- table to store all ES.Plugins
setmetatable(ES.Plugins,{
	__index=function(self,key)
		for k,v in ipairs(self)do
			if key == k or key == v:GetName() then
				return v
			end
		end
		return nil;
	end
})

AccessorFunc(meta,"name","Name",FORCE_STRING)
AccessorFunc(meta,"description","Description",FORCE_STRING)
AccessorFunc(meta,"author","Author",FORCE_STRING)
AccessorFunc(meta,"version","Version",FORCE_STRING)
function ES.Plugin()
	local PLUGIN = {}
	setmetatable(PLUGIN,meta)
	meta.__index = meta

	PLUGIN:SetVersion("1.0")
	PLUGIN:SetDescription("No description")
	PLUGIN:SetAuthor("Unknown")

	PLUGIN.minrank = "user"
	PLUGIN.hooks = {}
	PLUGIN.commands = {}
	PLUGIN.flags = 0
	PLUGIN.id = -1
	PLUGIN.disabled = false

	return PLUGIN
end
function meta:__call()
	if not self.name or ( string.len(self.name) < 1 ) then
		Error("Failed to register plugin. No name set.")
		return
	end

	self.id = #ES.Plugins+1;

	ES.Plugins[self.id] = self

	if CLIENT then return end

	ES.CreateSetting("PLUGIN:"..self:GetName()..".Enabled",bit.band(self.flags,EXCL_PLUGIN_FLAG_NODEFAULTDISABLED) > 0)
end
function meta:Load()
	self.disabled = false
	if SERVER then
		for k,v in pairs(self.commands)do
			ES.AddCommand(k,v.func,v.rank)
		end
	end
end
function meta:UnLoad()
	self.disabled = true
	for k,v in pairs(self.commands)do
		ES.RemoveCommand(k.func)
	end
end
function meta:SetRank(r)
	self.minrank = (r or "user")
end
function meta:AddFlag(n)
	self.flags=self.flags + n
end
function meta:SetInfo(n,d,a)
	self.name = n or self.name
	self.description = d or self.description
	self.author = a or self.author
end
function meta:AddHook(n,f)
	self.hooks[string.lower(n)] = f
	hook.Add(n,self.name.."-->"..n,function(...)
		if not self.disabled then
			local ret=f(...)
			if ret ~= nil then
				return ret;
			end
		end
	end)
end
if SERVER then
	function meta:AddCommand(n,f,rank)
		self.commands[string.lower(n)] = {func = f, rank = rank}
	end
end

hook.Add("Initialize","ExclPluginsLoad",function()
	for k,v in pairs(ES.Plugins) do
		v:Load()
	end
end)
