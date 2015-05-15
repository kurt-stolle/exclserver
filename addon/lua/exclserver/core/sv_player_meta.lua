local PLAYER=FindMetaTable("Player")

function PLAYER:ESSetBananas( a )
	if not self:ESGetNetworkedVariable("bananas") or type(a) ~= "number" or a < 0 then return end
	self:ESSetNetworkedVariable("bananas",a)

	if a > 50000 then
		self:ESAddAchievementProgress("bananas_amount",1)
	end
end
function PLAYER:ESAddBananas( a )
	self:ESSetBananas( a + self:ESGetBananas() )

	if a > 0 then
		self:ESAddAchievementProgress("bananas_count",a)
	end
end

function PLAYER:ESTakeBananas( a )
	self:ESAddBananas( -a )
end
PLAYER.ESRemoveBananas = PLAYER.ESTakeBananas
PLAYER.ESGiveBananas = PLAYER.ESAddBananas

util.AddNetworkString("ES.Notification.Popup")
function PLAYER:ESSendNotificationPopup(title,message)
	net.Start("ES.Notification.Popup")
	net.WriteString(title)
	net.WriteString(message)
	net.Send(self)
end
function PLAYER:ESChatPrint(...)
	net.Start("ES.ChatBroadcast")
	net.WriteTable{...}
	net.Send(self)
end
