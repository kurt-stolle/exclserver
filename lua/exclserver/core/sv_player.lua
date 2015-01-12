-- sv_player.lua
local PLAYER = FindMetaTable("Player");


util.AddNetworkString("ESSynchPlayer");
function PLAYER:ESSynchPlayer()
	if not self.excl then return end
	net.Start("ESSynchPlayer");
	net.WriteTable(self.excl);
	net.Send(self);
end
function PLAYER:ESLoadPlayer()
	--[[

	self.excl = {};
	ES.DBQuery("SELECT * FROM `es_player` WHERE id = "..self:ESID().." LIMIT 1;",function(c)
		if c and c[1] then
			self.excl = c[1];
			self:ESDecodeInventory()
			self:ESLoadRank()
			self:ESHandleActiveItems()

			if self.excl.viptier and self.excl.viptier > 0 then 
				self:ESSetGlobalData("VIP",self.excl.viptier);
			end

			self:LoadAchievements()

			if self._es_inventory_entory then
				self:ESLoadInventory(self._es_inventory_entory)
				self._es_inventory_entory=nil;

				for i=1,2+self:ESGetVIPTier()do
					if self.excl["slot"..i] and #self.excl["slot"..i] > 10 then
						self:ESSetGlobalData("slot"..i,self.excl["slot"..i])
					end
				end
			end
		else
			ES.DBQuery("INSERT INTO es_player SET steamid = '"..self:SteamID().."', id = "..self:ESID()..";", function() end);

			--self._es_inventory_hat = {}
			self._es_inventory_trails = {}
			self._es_inventory_meleeweapons = {}
			self._es_inventory_models = {}
			self._es_inventory_taunt = {}
			self:ESLoadRank()
			self:ESHandleActiveItems()
			self:ESSetGlobalData("bananas",0)
		end
			
		ES:QueueGlobalPlayerDataSynch(self);

		self:ESSynchPlayer();
		self:ESSynchRankConfig();

	end)
]]
end

-- Send a notification 
function PLAYER:ESSendNotification(kind,msg)
	net.Start("ES.SendNotification");
		net.WriteString(kind);
		net.WriteString(msg)
	net.Send(self);
end

gameevent.Listen("player_connect")

hook.Add("player_connect", "ESHandlePlayerConnect", function(data)
	if ES:CheckBans(data.networkid,data.userid) then return end
end)
 
concommand.Add("excl_internal_load",function(p)
    p:ESLoadPlayer();
end)

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

util.AddNetworkString("ESChatPrint");
function PLAYER:ESChatPrint(icon,...)
	if not IsValid(self) then return end

	net.Start("ESChatPrint");
	net.WriteString(icon);
	net.WriteTable({...});
	net.Send(self);
end

util.AddNetworkString("ESPlayerDC");
hook.Add("PlayerDisconnected","NotifyDisconnects",function(p)
	net.Start("ESPlayerDC");
	net.WriteString(p:Nick().."("..p:SteamID()..")");
	net.Broadcast();
end)
concommand.Add("es_outfit_customize",function(p,c,a)
	if not p or not p:IsValid() then return end
	
	ES.DebugPrint("Attempting outfit customization "..p:Nick());
	local slot,item,pos,ang,scale,bone,color = tonumber(a[1]),a[2],a[3],a[4],a[5],a[6],a[7];
	if not slot or slot > (2+p:ESGetVIPTier()) then return end
	
	if not item or not ES.Items[item] then
		ES.DBQuery("UPDATE es_player SET slot"..slot.." = '' WHERE id = "..p:ESID()..";")
		ES.DebugPrint("Disabled slot "..slot.." for "..p:Nick())
		p:ESSetGlobalData("slot"..slot,'');
		return
	elseif item and ES.Items[item] and pos and ang and scale and bone and table.HasValue(ES.ItemBones,bone) and color then
		local build = ES.DBEscape(item.."|"..pos.."|"..ang.."|"..scale.."|"..bone.."|"..color);
		if !p:ESGetInventory():ContainsItem(item) then
			ES.DebugPrint(p:Nick().." tried to set his outfit to an item he doesn't have... "..item);
			return 
		end
		ES.DBQuery("UPDATE es_player SET slot"..slot.." = '"..build.."' WHERE id = "..p:ESID()..";")
		ES.DebugPrint("Set slot "..slot.." for "..p:Nick())
		p:ESSetGlobalData("slot"..slot,build);
	else
		ES.DebugPrint("ERROR!!! CAN NOT SET OUTFIT!!!");
	end
end);