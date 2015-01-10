-- sv_player.lua
local pmeta = FindMetaTable("Player");


util.AddNetworkString("ESSynchPlayer");
function pmeta:ESSynchPlayer()
	if not self.excl then return end
	net.Start("ESSynchPlayer");
	net.WriteTable(self.excl);
	net.Send(self);
end
function pmeta:ESLoadPlayer()
	if self.excl then return end

	self.excl = {};
	ES.DBQuery("SELECT * FROM `es_player` WHERE id = "..self:ESID().." LIMIT 1;",function(c)
		if c and c[1] then
			self.excl = c[1];
			self:ESDecodeInventory()
			self:ESLoadRank()
			self:ESHandleActiveItems()
			self:ESSetGlobalData("bananas",c[1].bananas or 0)
			if self.excl.viptier and self.excl.viptier > 0 then 
				self:ESSetGlobalData("VIP",self.excl.viptier);
			end

			self:LoadAchievements()

			if self.excl.inventory then
				self:ESLoadInventory(self.excl.inventory)
				self.excl.inventory=nil;

				for i=1,2+self:ESGetVIPTier()do
					if self.excl["slot"..i] and #self.excl["slot"..i] > 10 then
						self:ESSetGlobalData("slot"..i,self.excl["slot"..i])
					end
				end
			end
		else
			ES.DBQuery("INSERT INTO es_player SET bananas = 0, steamid = '"..self:SteamID().."', id = "..self:ESID()..";", function() end);

			--self.excl.invhat = {}
			self.excl.invtrail = {}
			self.excl.invmelee = {}
			self.excl.invmodel = {}
			self.excl.invtaunt = {}
			self:ESLoadRank()
			self:ESHandleActiveItems()
			self:ESSetGlobalData("bananas",0)
		end
			
		ES:QueueGlobalPlayerDataSynch(self);

		self:ESSynchPlayer();
		self:ESSynchRankConfig();

	end)

end

util.AddNetworkString("ESSynchGlobalPlayerData");
util.AddNetworkString("ESSynchGlobalPlayerDataSingle")

local queuedSynch = false;
local peopleSynch = {};
function ES:QueueGlobalPlayerDataSynch(p)

	ES.DebugPrint("Queueing global player data synch for "..p:Nick());

	if !table.HasValue(peopleSynch,p) then
		peopleSynch[#peopleSynch + 1] = p;
	end
	if queuedSynch then return end

	queuedSynch = true;
	timer.Simple(5,function()
		for k,v in pairs(peopleSynch)do
			v.exclMadeGlobalSynch = true;
		end

		ES:PreformGlobalPlayerDataSynch(peopleSynch);

		queuedSynch = false;
		peopleSynch = nil;
		peopleSynch = {};
	end)
end
function ES:PreformGlobalPlayerDataSynch(p)

	ES.DebugPrint("Performing global player data synch")

	local tbl = {}
	for k,v in pairs(player.GetAll())do
		if v.exclGlobal then
			tbl[v] = {}
			for a,b in pairs(v.exclGlobal)do
				tbl[v][a] = b;
			end
		end
	end

	net.Start("ESSynchGlobalPlayerData");
	net.WriteTable(tbl);
	net.WriteInt(ES.SynchronizationKey,32);
	if p then
		net.Send(p)
		return
	end
	net.Broadcast();
end
function pmeta:ESSetGlobalData(name,var)
	if not self.exclGlobal then self.exclGlobal = {} end
	if not self.exclSynchTable then self.exclSynchTable = {} end
	
	ES.DebugPrint("Added global variable for "..self:Nick()..": "..name.." = "..tostring(var));

	self.exclGlobal[name] = var;
	self.exclSynchTable[name] = var;

	if self.exclIsSynching then return end

	ES.DebugPrint("Created new globaldata synch timer for "..self:Nick());

	self.exclIsSynching = true;

	timer.Simple(0.5,function()
		if not self or not IsValid(self) or not self.exclSynchTable then return end

		ES:GenerateSynchKey();

		net.Start("ESSynchGlobalPlayerDataSingle");
		net.WriteEntity(self);
		net.WriteTable(self.exclSynchTable);
		net.WriteInt(ES.SynchronizationKey,32);
		net.Broadcast();

		self.exclIsSynching = false;

		ES.DebugPrint("Synched "..self:Nick());
	end)
end

-- Send a notification 
function pmeta:ESSendNotification(kind,msg)
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
function pmeta:ESChatPrint(icon,...)
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