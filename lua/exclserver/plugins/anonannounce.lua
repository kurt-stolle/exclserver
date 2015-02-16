local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Anonymous Announce","Announce messages to all players anounymously.","Excl")
PLUGIN:AddCommand("anonannounce",function(p,a)
	if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end

	net.Start("exclAnnouceAnon")
	net.WriteString((table.concat(a," ",1) or ""))
	net.Broadcast()
end,20)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)


if SERVER then 
	util.AddNetworkString("exclAnnouceAnon")

	return 
end
net.Receive("exclAnnouceAnon",function()
	local m = net.ReadString()
	ES.ChatAddText("announce",Color(255,255,255),"(ANNOUNCEMENT) "..m)
	chat.PlaySound()
end)
PLUGIN()