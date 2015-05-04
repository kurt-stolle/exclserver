local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Version","Prints the current version of ExclServer to the chat.","Excl")

if SERVER then
	util.AddNetworkString("ES.CMD.Version")

	PLUGIN:AddCommand("version",function(p,a)
		net.Start("ES.CMD.Version"); net.Send(p);
	end,0)
elseif CLIENT then
	net.Receive("ES.CMD.Version",function()
		chat.AddText(ES.Color.White,"\nThis server is running ExclServer version "..ES.version..". Created by Excl.\n");
	end)
end

PLUGIN()
