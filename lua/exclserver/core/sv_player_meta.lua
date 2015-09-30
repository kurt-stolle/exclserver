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

-- Synchronize
util.AddNetworkString("ESSynchPlayer")
function PLAYER:ESSynchPlayer()
	if not self.excl then return end
	net.Start("ESSynchPlayer")
	net.WriteTable(self.excl)
	net.Send(self)
end

-- Send a notification
function PLAYER:ESSendNotification(kind,msg)
	net.Start("ES.SendNotification")
		net.WriteString(kind)
		net.WriteString(msg)
	net.Send(self)
end

-- Do setup
function PLAYER:ESReady()
	if self._es_isReady then return end
	self._es_isReady = true

	hook.Call("ESPlayerReady",GAMEMODE,self)

	ES.BroadcastNotification("generic",self:Nick().." has joined")
end
