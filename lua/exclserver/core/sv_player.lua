-- sv_player.lua

local PLAYER = FindMetaTable("Player");


util.AddNetworkString("ES.PlayerReady");
net.Receive("ES.PlayerReady",function(len,ply)
	hook.Call("ESPlayerReady",GAMEMODE,ply);
end);


-- Synchronize the player
util.AddNetworkString("ESSynchPlayer");
function PLAYER:ESSynchPlayer()
	if not self.excl then return end
	net.Start("ESSynchPlayer");
	net.WriteTable(self.excl);
	net.Send(self);
end

-- Occasionally hand out bananas
timer.Create("ESHandOutBananas",900,0,function()
	for k,v in pairs(player.GetAll())do
		timer.Simple(math.random(0,120),function()
			if IsValid(v) and v.excl and v:ESGetGlobalData("bananas",false) then
				v:ESGiveBananas(math.random(2,8));
			end
		end);
	end
end);

-- Send a notification 
function PLAYER:ESSendNotification(kind,msg)
	net.Start("ES.SendNotification");
		net.WriteString(kind);
		net.WriteString(msg)
	net.Send(self);
end

-- Make sure banned people stay out
gameevent.Listen("player_connect")
hook.Add("player_connect", "ESHandlePlayerConnect", function(data)
	if ES.CheckBans(data.networkid,data.userid) then return end
end)

-- Allow admins to pick up players
hook.Add( "PhysgunPickup", "ESHandlePlayerPickup", function( p, e )
	if e:GetClass() == "player" and p:ESHasPower(20) and not e:ESIsImmuneTo(p) then
		e:SetMoveType( MOVETYPE_NONE )
		return true
	end
end);
hook.Add( "PhysgunDrop", "ESHandlePlayerDrop", function(p,e)
	if e:GetClass() == "player" then
		e:SetMoveType( MOVETYPE_WALK )
	end
end)

-- ChatPrint
util.AddNetworkString("ESChatPrint");
function PLAYER:ESChatPrint(...)
	if not IsValid(self) then return end

	net.Start("ESChatPrint");
	net.WriteTable({...});
	net.Send(self);
end
