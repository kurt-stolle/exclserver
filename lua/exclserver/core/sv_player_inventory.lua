util.AddNetworkString("ESSynchInventory");
util.AddNetworkString("ESSynchInvAdd");
util.AddNetworkString("ESSynchInvRemove");

local PLAYER=FindMetaTable("Player");

function PLAYER:ESActivateItem(name,itemtype,NoSynch)
	if not self:ESHasItem(name,itemtype) then return false end

	if itemtype == ITEM_TRAIL and self._es_inventory_trails then
		self:ESSetNetworkedVariable("active_trail",name);
		self:ESHandleActiveItems()
	elseif itemtype == ITEM_MODEL and self._es_inventory_models then
		self:ESSetNetworkedVariable("active_model",name)
		self:ESSetModelToActive();
	elseif itemtype == ITEM_AURA and self._es_inventory_auras then
		self:ESSetNetworkedVariable("active_aura",name)
		self:ESHandleActiveItems()
	elseif itemtype == ITEM_MELEE and self._es_inventory_meleeweapons then
		self:ESSetNetworkedVariable("active_meleeweapon",name)
		timer.Simple(0,function()
			if IsValid(self) then
				self:ESReplaceMelee();
			end
		end)
	end 

	if !NoSynch then
		net.Start("ESSynchInvActivate");
		net.WriteString(name);
		net.WriteInt(itemtype,8)
		net.Send(self);
	end

	return true;
end
function PLAYER:ESDeactivateItem(itemtype)
	if itemtype == ITEM_TRAIL and self._es_inventory_trails and self:ESGetNetworkedVariable("active_trail") then
		self:ESSetNetworkedVariable("active_trail","")
		self:ESHandleActiveItems()
	elseif itemtype == ITEM_AURA and self._es_inventory_auras and self:ESGetNetworkedVariable("active_aura") then
		self:ESSetNetworkedVariable("active_aura","")
	elseif itemtype == ITEM_MODEL and self._es_inventory_models and self:ESGetNetworkedVariable("active_model") then
		self:ESSetNetworkedVariable("active_model","")
		self:ESSetModelToActive();
	elseif itemtype == ITEM_MELEE and self._es_inventory_meleeweapons and self:ESGetNetworkedVariable("active_meleeweapon") then
		self:ESSetNetworkedVariable("active_meleeweapon","")
		timer.Simple(0,function()
			if IsValid(self) then
				self:ESReplaceMelee();
			end
		end)
	end

	return true;
end
function PLAYER:ESSaveInventory()
	local invtrail = ES.EncodeInventory(self._es_inventory_trails or {});
	local invmelee = ES.EncodeInventory(self._es_inventory_meleeweapons or {});
	local invmodel = ES.EncodeInventory(self._es_inventory_models or {});
	local invaura = ES.EncodeInventory(self._es_inventory_auras or {});

	ES.DBQuery("UPDATE es_player SET `trails` = '"..invtrail.."', `meleeweapons` = '"..invmelee.."', `models` = '"..invmodel.."', `auras` = '"..invaura.."' WHERE id = "..self:ESID()..";");
end
function PLAYER:ESGiveItem(name,itemtype,nosynch)
	if self:ESHasItem(name,itemtype) then return false end

	if itemtype == ITEM_TRAIL and self._es_inventory_trails then
		table.insert(self._es_inventory_trails,name);
	elseif itemtype == ITEM_MELEE and self._es_inventory_meleeweapons then
		table.insert(self._es_inventory_meleeweapons,name);
	elseif itemtype == ITEM_MODEL and self._es_inventory_models then
		table.insert(self._es_inventory_models,name);
	elseif itemtype == ITEM_AURA and self._es_inventory_auras then
		table.insert(self._es_inventory_auras,name);
	end

	self:ESSaveInventory()

	net.Start("ESSynchInvAdd");
	net.WriteString(name);
	net.WriteInt(itemtype,8)
	net.Send(self);
	
	return true;
end
function PLAYER:ESRemoveItem(name,itemtype)
	if not self.excl or !self:ESHasItem(name,itemtype) then return end
	
	if itemtype == ITEM_TRAIL and self._es_inventory_trails then
		for k,v in pairs(self._es_inventory_trails)do
			if v == name then
				table.remove(self._es_inventory_trails,k); 
			end
		end
	elseif itemtype == ITEM_MELEE and self._es_inventory_meleeweapons then
		for k,v in pairs(self._es_inventory_meleeweapons)do
			if v == name then
				table.remove(self._es_inventory_meleeweapons,k);
			end
		end
	elseif itemtype == ITEM_MODEL and self._es_inventory_models then
		for k,v in pairs(self._es_inventory_models)do
			if v == name then
				table.remove(self._es_inventory_models,k);
			end
		end
	elseif itemtype == ITEM_AURA and self._es_inventory_auras then
		for k,v in pairs(self._es_inventory_auras)do
			if v == name then
				table.remove(self._es_inventory_auras,k);
			end
		end
	end
	
	self:ESSaveInventory()

	net.Start("ESSynchInvRemove");
	net.WriteString(name);
	net.WriteString(itemtype)
	net.Send(self);
end
function PLAYER:ESHandleActiveItems()
	if self:GetObserverMode() == OBS_MODE_NONE and self.excl then			
		local trail=self:ESGetNetworkedVariable("active_trail");
		if trail and ES:ValidItem(trail,ITEM_TRAIL) then
			if self.trail and IsValid(self.trail) then
				self.trail:Remove();
				self.trail = nil;
			end
			local len = 1.5;
			local size = 16;
			if self:ESGetVIPTier() > 3 then
				len = 3;
				size = 20;
			elseif self:ESGetVIPTier() > 1 then
				len = 3;
			end
			self.trail = util.SpriteTrail(self, 0, (ES.TrailsBuy[trail].color or Color(255,255,255)), false, size, 1, len, 1/(size+1)*0.5, string.gsub(ES.TrailsBuy[self:ESGetNetworkedVariable("active_trail")].text,"materials/",""));
		elseif self.trail and IsValid(self.trail) then
				self.trail:Remove();
				self.trail = nil;
		end
	else
		if self.trail and IsValid(self.trail) then
			self.trail:Remove();
			self.trail = nil;
		end
	end
end
function PLAYER:ESSetModelToActive()
	local model=self:ESGetNetworkedVariable("active_model");
	if not model or not ES.ModelsBuy[model] then
		self:SetModel(table.Random(ES.DefaultModels));
	else
		self:SetModel(ES.ModelsBuy[model].model);
	end
end
hook.Add("PlayerLoadout","ESHandleActiveItems",function(p)
	timer.Simple(0,function()
		if not IsValid(p) then return end
		p:ESHandleActiveItems();
	end);
end);
hook.Add("PlayerDeath","ESHandleTrailRemovalOnDeath",function(p)
	if p.trail and IsValid(p.trail) then
		p.trail:Remove();
		p.trail = nil;
	end
end);
hook.Add("PlayerInitialSpawn","ES.Inventory.LoadInitial",function(ply)
	ES.DBQuery("SELECT `trails`,`auras`,`models`,`meleeweapons` FROM `es_player` WHERE `id`="..ply:ESID().." LIMIT 1;",function(data)
		if not data[1] then return end
		
		ES.DebugPrint("Loaded inventory of "..ply:Nick());

		data=data[1];

		data.tails=ES.DecodeInventory(data.tails) or {};
		data.auras=ES.DecodeInventory(data.auras) or {};
		data.models=ES.DecodeInventory(data.models) or {};
		data.meleeweapons=ES.DecodeInventory(data.meleeweapons) or {};

		ply._es_inventory_trails 			= data.trails;
		ply._es_inventory_auras 			= data.auras;
		ply._es_inventory_models 			= data.models;
		ply._es_inventory_meleeweapons 		= data.meleeweapons;


		net.Start("ESSynchInventory");
		net.WriteTable(data);
		net.Send(ply);
	end);
end);