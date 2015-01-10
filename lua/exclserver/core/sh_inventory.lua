-- inventory systems
ITEM_HAT = 1;
ITEM_TRAIL = 2;
ITEM_MELEE = 3;
ITEM_MODEL = 4;
ITEM_TAUNT = 5;
ITEM_AURA = 6;
ITEM_PROP = 7;

local function decodeInventory(str)
	if not str or type(str) != "string" or str == "" or str == " " or str == "|" or str == "nil" then return {}; end
	return string.Explode("|",string.lower(str));
end
local function encodeInventory(tbl)
	if not tbl or type(tbl) != "table" then return ""; end
	return table.concat(tbl,"|");
end

-- actual stuff
function ES:GetItemPrice(name,itemtype)
	if not ES:ValidItem(name,itemtype) then return 0 end
	
	if itemtype == ITEM_HAT then
		return tonumber(ES.Hats[name].cost);
	elseif itemtype == ITEM_TRAIL then
		return tonumber(ES.TrailsBuy[name].cost);
	elseif itemtype == ITEM_MELEE then
		return tonumber(ES.MeleeBuy[name].cost);
	elseif itemtype == ITEM_MODEL then
		return tonumber(ES.ModelsBuy[name].cost);
	elseif itemtype == ITEM_AURA then
		return tonumber(ES.AurasBuy[name].cost)
	elseif itemtype == ITEM_TAUNT then
		return 0 --table.HasValue(self.excl.invtaunt,name);
	end
	return 0;
end
function ES:ValidItem(name,itemtype)
	if itemtype == ITEM_HAT then
		return !(not ES.Hats[name]);
	elseif itemtype == ITEM_TRAIL then
		return !(not ES.TrailsBuy[name]);
	elseif itemtype == ITEM_MELEE then
		return !(not ES.MeleeBuy[name]);
	elseif itemtype == ITEM_MODEL then
		return !(not ES.ModelsBuy[name]);
	elseif itemtype == ITEM_AURA then
		return !(not ES.AurasBuy[name]);
	elseif itemtype == ITEM_TAUNT then
		return false --table.HasValue(self.excl.invtaunt,name);
	end
	return false;
end
local pmeta = FindMetaTable("Player");
function pmeta:ESHasItem(name,itemtype)
	if not self.excl or type(self.excl.invtrail) != "table" then return false end
	
	--[[if itemtype == ITEM_HAT and self.excl.invhat then
		return table.HasValue(self.excl.invhat,name);]]
	if itemtype == ITEM_TRAIL and self.excl.invtrail then
		return table.HasValue(self.excl.invtrail,name);
	elseif itemtype == ITEM_MELEE and self.excl.invmelee then
		return table.HasValue(self.excl.invmelee,name);
	elseif itemtype == ITEM_MODEL and self.excl.invmodel then
		return table.HasValue(self.excl.invmodel,name);
	elseif itemtype == ITEM_AURA and self.excl.invaura then
		return table.HasValue(self.excl.invaura,name);
	elseif itemtype == ITEM_TAUNT and self.excl.invtaunt then
		return table.HasValue(self.excl.invtaunt,name);
	end
	return false;
end
if SERVER then
	util.AddNetworkString("ESSynchInventory");
	util.AddNetworkString("ESSynchInvAdd");
	util.AddNetworkString("ESSynchInvRemove");
	util.AddNetworkString("ESSynchInvActivate");

	function pmeta:ESSynchInventory()
		if not self.excl then return end

		local t = {};
		t.activehat = self.excl.activehat;
		t.activemelee = self.excl.activemelee;
		t.activetrail = self.excl.activetrail;
		--t.invhat = encodeInventory(self.excl.invhat);
		t.invtrail = encodeInventory(self.excl.invtrail);
		t.invmelee = encodeInventory(self.excl.invmelee);
		t.invmodel = encodeInventory(self.excl.invmodel);
		t.invtaunt = encodeInventory(self.excl.invtaunt);
		t.invaura = encodeInventory(self.excl.invaura);

		net.Start("ESSynchInventory");
		net.WriteTable(t);
		net.Send(self);
	end

	function pmeta:ESActivateItem(name,itemtype,nosynch,synchfull)
		if not self.excl or !self:ESHasItem(name,itemtype) then return false end

		--[[if itemtype == ITEM_HAT and self.excl.invhat then
			ES:AddPlayerData(self,"activehat",name)
			self:ESHandleActiveItems()
			self:PushHatCustomization(Vector(0,0,0),Angle(0,0,0),Vector(0,0,0));]]
		if itemtype == ITEM_TRAIL and self.excl.invtrail then
			ES:AddPlayerData(self,"activetrail",name)
			self:ESHandleActiveItems()
		elseif itemtype == ITEM_MODEL and self.excl.invmodel then
			ES:AddPlayerData(self,"activemodel",name)
			self:ESSetModelToActive();
		elseif itemtype == ITEM_AURA and self.excl.invaura then
			ES:AddPlayerData(self,"activeaura",name)
			self:ESHandleActiveItems()
		elseif itemtype == ITEM_MELEE and self.excl.invmelee then
			ES:AddPlayerData(self,"activemelee",name)
			timer.Simple(0,function()
				if IsValid(self) then
					self:ESReplaceMelee();
				end
			end)
		end 

		if !nosynch then
			net.Start("ESSynchInvActivate");
			net.WriteString(name);
			net.WriteInt(itemtype,8)
			net.Send(self);
		end

		if synchfull then
			self:ESSynchInventory()
		end

		return true;
	end
	function pmeta:ESDeactivateItem(itemtype,synch)
		if not self.excl then return false end

		--[[if itemtype == ITEM_HAT and self.excl.invhat and self.excl.activehat then
			ES:AddPlayerData(self,"activehat","")
			self:ESHandleActiveItems()
			self:PushHatCustomization(Vector(0,0,0),Angle(0,0,0),Vector(0,0,0));]]
		if itemtype == ITEM_TRAIL and self.excl.invtrail and self.excl.activetrail then
			ES:AddPlayerData(self,"activetrail","")
			self:ESHandleActiveItems()
		elseif itemtype == ITEM_AURA and self.excl.invaura and self.excl.activeaura then
			ES:AddPlayerData(self,"activeaura","")
		elseif itemtype == ITEM_MODEL and self.excl.invmodel then
			ES:AddPlayerData(self,"activemodel","")
			self:ESSetModelToActive();
			

		elseif itemtype == ITEM_MELEE and self.excl.invmelee and self.excl.activemelee then
			ES:AddPlayerData(self,"activemelee","")
			timer.Simple(0,function()
				if IsValid(self) then
					self:ESReplaceMelee();
				end
			end)
		end

		net.Start("ESSynchInvActivate");
		net.WriteString("");
		net.WriteInt(itemtype,8)
		net.Send(self);

		if synch then
			self:ESSynchInventory()		
		end
		return true;
	end
	function pmeta:ESSaveInventory(bSynch)
		if not self.excl or type(self.excl.invtrail) != "table" then return; end

		--local invhat = encodeInventory(self.excl.invhat);
		local invtrail = encodeInventory(self.excl.invtrail);
		local invmelee = encodeInventory(self.excl.invmelee);
		local invmodel = encodeInventory(self.excl.invmodel);
		--local invtaunt = encodeInventory(self.excl.invtaunt);
		local invaura = encodeInventory(self.excl.invaura);

		--if bSynch then
		--	self:ESSynchInventory();
		--end

		ES.DBQuery("UPDATE es_player SET invtrail = '"..invtrail.."', invmelee = '"..invmelee.."', invmodel = '"..invmodel.."', invaura = '"..invaura.."' WHERE id = "..self:ESID()..";", function() end);
	end
	function pmeta:ESGiveItem(name,itemtype,nosynch)
		if not self.excl or self:ESHasItem(name,itemtype) then return false end

		--[[if itemtype == ITEM_HAT and self.excl.invhat then
			table.insert(self.excl.invhat,name);]]
		if itemtype == ITEM_TRAIL and self.excl.invtrail then
			table.insert(self.excl.invtrail,name);
		elseif itemtype == ITEM_MELEE and self.excl.invmelee then
			table.insert(self.excl.invmelee,name);
		elseif itemtype == ITEM_MODEL and self.excl.invmodel then
			table.insert(self.excl.invmodel,name);
		elseif itemtype == ITEM_AURA and self.excl.invaura then
			table.insert(self.excl.invaura,name);
		end
		self:ESSaveInventory()

		if !nosynch then
			net.Start("ESSynchInvAdd");
			net.WriteString(name);
			net.WriteInt(itemtype,8)
			net.Send(self);
		end
		
		return true;
	end
	function pmeta:ESRemoveItem(name,itemtype)
		if not self.excl or !self:ESHasItem(name,itemtype) then return end
		
		--[[if itemtype == ITEM_HAT and self.excl.invhat then
			for k,v in pairs(self.excl.invhat)do
				if v == name then
					table.remove(self.excl.invhat,k);
				end
			end]]
		if itemtype == ITEM_TRAIL and self.excl.invtrail then
			for k,v in pairs(self.excl.invtrail)do
				if v == name then
					table.remove(self.excl.invtrail,k); 
				end
			end
		elseif itemtype == ITEM_MELEE and self.excl.invmelee then
			for k,v in pairs(self.excl.invmelee)do
				if v == name then
					table.remove(self.excl.invmelee,k);
				end
			end
		elseif itemtype == ITEM_MODEL and self.excl.invmodel then
			for k,v in pairs(self.excl.invmodel)do
				if v == name then
					table.remove(self.excl.invmodel,k);
				end
			end
		elseif itemtype == ITEM_AURA and self.excl.invaura then
			for k,v in pairs(self.excl.invaura)do
				if v == name then
					table.remove(self.excl.invaura,k);
				end
			end
		end
		
		self:ESSaveInventory()

		net.Start("ESSynchInvRemove");
		net.WriteString(name);
		net.WriteString(itemtype)
		net.Send(self);
	end
	function pmeta:ESHandleActiveItems()
		if self:GetObserverMode() == OBS_MODE_NONE and self.excl then
			--[[if self.excl.activehat and ES:ValidItem(self.excl.activehat,ITEM_HAT) then
				self:SetNWString("hat",self.excl.activehat);
			elseif self.excl.activehat then
				self:SetNWString("hat","");
			end]]
			
			if self.excl.activeaura and ES:ValidItem(self.excl.activeaura,ITEM_AURA) then
				self:SetNWString("aura",self.excl.activeaura);
			elseif self.excl.activeaura then
				self:SetNWString("aura","");
			end


			if self.excl.activetrail and ES:ValidItem(self.excl.activetrail,ITEM_TRAIL) then
				if self.trail and IsValid(self.trail) then
					self.trail:Remove();
					self.trail = nil;
				end
				local len = 1;
				local size = 16;
				if self:ESGetVIPTier() > 3 then
					len = 3;
					size = 32;
				elseif self:ESGetVIPTier() > 1 then
					len = 3;
				end
				self.trail = util.SpriteTrail(self, 0, (ES.TrailsBuy[self.excl.activetrail].color or Color(255,255,255)), false, size, 1, len, 1/(size+1)*0.5, string.gsub(ES.TrailsBuy[self.excl.activetrail].text,"materials/",""));
			elseif self.trail and IsValid(self.trail) then
					self.trail:Remove();
					self.trail = nil;
			end
			if self.excl.activemelee and ES:ValidItem(self.excl.activemelee,ITEM_MELEE) then
				-- nothing
			end
		else
			if self.trail and IsValid(self.trail) then
				self.trail:Remove();
				self.trail = nil;
			end
		end

		ES.DebugPrint("Handled items "..self:Nick())
	end
	hook.Add("PlayerLoadout","ESHandleActiveItems",function(p)
		timer.Simple(0,function()
			if not p or not p:IsValid() then return end
			p:ESHandleActiveItems();
		end);
	end);
	hook.Add("PlayerDeath","ESHandleTrailRemovalOnDeath",function(p)
		if p.trail and IsValid(p.trail) then
			p.trail:Remove();
			p.trail = nil;
		end
	end);
end


function pmeta:ESDecodeInventory()
	if not self.excl then
		return
	end

	--self.excl.invhat = decodeInventory(tostring(self.excl.invhat));
	self.excl.invtrail = decodeInventory(tostring(self.excl.invtrail))
	self.excl.invmelee = decodeInventory(tostring(self.excl.invmelee))
	self.excl.invmodel = decodeInventory(tostring(self.excl.invmodel));
	self.excl.invtaunt = decodeInventory(tostring(self.excl.invtaunt));
	self.excl.invaura = decodeInventory(tostring(self.excl.invaura));
end
