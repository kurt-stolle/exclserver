local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Observer","Observes stuff.","Excl")
PLUGIN:AddCommand("observer",function(p,a)
	if not p or not p:IsValid() then return end

	if p:GetObserverMode() != OBS_MODE_ROAMING then
		p:SetMoveType(MOVETYPE_OBSERVER)
		p:SetObserverMode(OBS_MODE_ROAMING)
		p:Spectate( OBS_MODE_ROAMING )

		net.Start("exclObsAnn")
		net.WriteEntity(p)
		net.Broadcast()
	else
		p:KillSilent()
	end
end,20)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)
PLUGIN()

if SERVER then 
	util.AddNetworkString("exclObsAnn")

	return 
end
net.Receive("exclObsAnn",function()
	local p = net.ReadEntity()
	if not IsValid(p) then return end

	ES.ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has been put into observer mode.")
	chat.PlaySound()
end)