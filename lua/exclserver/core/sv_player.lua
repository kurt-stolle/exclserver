-- sv_player.lua

local PLAYER = FindMetaTable("Player")


util.AddNetworkString("ES.PlayerReady")
net.Receive("ES.PlayerReady",function(len,ply)
	hook.Call("ESPlayerReady",GAMEMODE,ply)
end)


-- Synchronize the player
util.AddNetworkString("ESSynchPlayer")
function PLAYER:ESSynchPlayer()
	if not self.excl then return end
	net.Start("ESSynchPlayer")
	net.WriteTable(self.excl)
	net.Send(self)
end

-- Occasionally hand out bananas
timer.Create("ESHandOutBananas",600,0,function()
	for k,v in pairs(player.GetAll())do
		timer.Simple(math.random(0,120),function()
			if IsValid(v) and v.excl and v:ESGetGlobalData("bananas",false) then
				v:ESGiveBananas(math.random(2,8))
			end
		end)
	end
end)

-- Send a notification
function PLAYER:ESSendNotification(kind,msg)
	net.Start("ES.SendNotification")
		net.WriteString(kind)
		net.WriteString(msg)
	net.Send(self)
end

-- Allow admins to pick up players
hook.Add( "PhysgunPickup", "ESHandlePlayerPickup", function( p, e )
	if e:GetClass() == "player" and p:ESHasPower(20) and not e:ESIsImmuneTo(p) then
		e:SetMoveType( MOVETYPE_NONE )
		return true
	end
end)
hook.Add( "PhysgunDrop", "ESHandlePlayerDrop", function(p,e)
	if e:GetClass() == "player" then
		e:SetMoveType( MOVETYPE_WALK )
	end
end)

-- ChatPrint
util.AddNetworkString("ESChatPrint")
function PLAYER:ESChatPrint(...)
	if not IsValid(self) then return end

	net.Start("ESChatPrint")
	net.WriteTable({...})
	net.Send(self)
end

-- Buy VIP
util.AddNetworkString("ES.BuyVIP")
net.Receive("ES.BuyVIP",function(len,ply)
	local tier=net.ReadUInt(4)

	if not tier or not IsValid(ply) or tier <= ply:ESGetVIPTier() or tier > 4 then return end

	local cost=(tier-ply:ESGetVIPTier())*5000

	if ply:ESGetBananas() >= cost then
		ply:ESTakeBananas(cost)
		ply:ESSetNetworkedVariable("VIP",tier)
		ply:ESSendNotificationPopup("Success","You have successfully upgraded your VIP status.\nThank you for your purchase!")
	else
		ply:ESSendNotificationPopup("Error","You do not have enough bananas to make this purchase.")
	end
end)

-- Get all community servers
util.AddNetworkString("ES.GetServerList")
net.Receive("ES.GetServerList",function(len,ply)
	if not IsValid(ply) or (ply._es_cmdTimeout and ply._es_cmdTimeout > CurTime()) then return end

	ply._es_cmdTimeout=CurTime()+.5;

	ES.DBQuery("SELECT ip FROM `es_servers`;",function(res)
		local tab={}
		for k,v in ipairs(res)do
			if v.ip then
				table.insert(tab,v.ip)
			end
		end

		net.Start("ES.GetServerList")
		net.WriteTable(tab)
		net.Send(ply)
	end)
end)

-- Chat broadcast
util.AddNetworkString("ES.ChatBroadcast")
function ES.ChatBroadcast(...)
	net.Start("ES.ChatBroadcast")
	net.WriteTable{...}
	net.Broadcast()
end
