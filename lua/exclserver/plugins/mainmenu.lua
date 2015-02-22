-- A bunch of command aliases to open up the main menu. Nothing special here.
if SERVER then
	util.AddNetworkString("ESToggleMenu")
end

local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Menu shortcuts","Opens the ExclServer main menu via chat commands.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then
	PLUGIN:AddCommand("shop",function(p,a)
		net.Start("ESToggleMenu") net.Send(p)
	end)
	PLUGIN:AddCommand("mainmenu",function(p,a)
		net.Start("ESToggleMenu") net.Send(p)
	end)
	PLUGIN:AddCommand("menu",function(p,a)
		net.Start("ESToggleMenu") net.Send(p)
	end)
	PLUGIN:AddCommand("excl",function(p,a)
		net.Start("ESToggleMenu") net.Send(p)
	end)
	PLUGIN:AddCommand("exclserver",function(p,a)
		net.Start("ESToggleMenu") net.Send(p)
	end)
	PLUGIN:AddCommand("store",function(p,a)
		net.Start("ESToggleMenu") net.Send(p)
	end)
	PLUGIN:AddCommand("motd",function(p,a)
		p:SendLua("ES.OpenMOTD()")
	end)
	PLUGIN:AddCommand("rules",function(p,a)
		p:SendLua("ES.OpenMOTD()")
	end)
end

PLUGIN()