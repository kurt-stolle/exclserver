local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Verify","Verify your identity.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then
  local fn=function(p,a)
		if not IsValid(p) then return end

		ES.ChatBroadcast(ES.Color.Highlight,p:Nick(),ES.Color.White," ("..p:SteamID()..") has the rank ",ES.Color.Highlight,p:ESGetRank():GetPrettyName(),ES.Color.White,".")
	end
  PLUGIN:AddCommand("verify",fn,1)
end
PLUGIN()
