-- sv_player.lua

local PLAYER = FindMetaTable("Player")

local dbReady=false
local ReadyQueue={}
hook.Add("ESDatabaseReady","exclserver.player.db.ready",function()
	dbReady=true

	timer.Simple(0,function()
		for _,ply in ipairs(ReadyQueue)do
			if IsValid(ply) then
				ply:ESReady()
			end
		end
	end)
end)
concommand.Add("excl_ready",function(ply)
	if not dbReady then
		table.insert(ReadyQueue,ply)
	else
		ply:ESReady()
	end
end)

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

	ES.DBQuery("SELECT id,ip,port,dns,name FROM `es_servers` WHERE NOT ip = '127.0.0.1';",function(res)
		local tab={}
		for k,v in ipairs(res) do
			if v.name then
				table.insert(tab,v)
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
timer.Create("ESHandOutBananas",300,0,function()
	for k,v in ipairs(player.GetAll())do
		if not v:ESGetNetworkedVariable("idle",false) then
			v:ESAddBananas(10+v:ESGetVIPTier())
		end
	end
end)
timer.Create("ESAddPlaytime",60,0,function()
	for k,v in ipairs(player.GetAll())do
		local time=tonumber(v:ESGetNetworkedVariable("playtime",0)+1)

		if (time % 60) == 0 then
			v:ESChatPrint("You have now played <hl>"..math.Round(time/60).."</hl> hours on this server!")
			v:ESAddBananas(15)
		end

		v:ESSetNetworkedVariable("playtime",time);
	end
end)
