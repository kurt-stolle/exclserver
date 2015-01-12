-- inventory systems
ITEM_HAT = 1;
ITEM_TRAIL = 2;
ITEM_MELEE = 3;
ITEM_MODEL = 4;
ITEM_TAUNT = 5;
ITEM_AURA = 6;
ITEM_PROP = 7;

function ES.DecodeInventory(str)
	if not str or type(str) != "string" or str == "" or str == " " or str == "|" or str == "nil" then return {}; end
	return string.Explode("|",string.lower(str));
end
function ES.EncodeInventory(tbl)
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
		return 0 --table.HasValue(self._es_inventory_taunt,name);
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
		return false --table.HasValue(self._es_inventory_taunt,name);
	end
	return false;
end
local PLAYER = FindMetaTable("Player");
function PLAYER:ESHasItem(name,itemtype)
	if not self.excl or type(self._es_inventory_trails) != "table" then return false end
	
	--[[if itemtype == ITEM_HAT and self._es_inventory_hat then
		return table.HasValue(self._es_inventory_hat,name);]]
	if itemtype == ITEM_TRAIL and self._es_inventory_trails then
		return table.HasValue(self._es_inventory_trails,name);
	elseif itemtype == ITEM_MELEE and self._es_inventory_meleeweapons then
		return table.HasValue(self._es_inventory_meleeweapons,name);
	elseif itemtype == ITEM_MODEL and self._es_inventory_models then
		return table.HasValue(self._es_inventory_models,name);
	elseif itemtype == ITEM_AURA and self._es_inventory_auras then
		return table.HasValue(self._es_inventory_auras,name);
	elseif itemtype == ITEM_TAUNT and self._es_inventory_taunt then
		return table.HasValue(self._es_inventory_taunt,name);
	end
	return false;
end
