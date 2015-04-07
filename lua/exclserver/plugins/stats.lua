local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Stats","Print your stats to chat.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)


if SERVER then
	PLUGIN:AddCommand("stats",function(p,a)
    p:ESChatPrint(ES.Color.White,"You have <hl>"..p:ESGetBananas().."</hl> bananas and <hl>"..p:ESGetNetworkedVariable("playtime",0).."</hl> minutes playtime.")
  end,0)
end

PLUGIN()
