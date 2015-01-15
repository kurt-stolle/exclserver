-- inventory systems
ES.ITEM_TRAIL = 1;
ES.ITEM_MELEE = 2;
ES.ITEM_MODEL = 3;
ES.ITEM_AURA = 4;
ES.ITEM_PROP = 5;

-- Item object
local meta={};
function ES.Item(type)
	local obj={};
	setmetatable(obj,meta);
	meta.__index=meta;

	obj:SetName("Undefined");
	obj:SetDescription("No description given.");
	obj:SetCost(0);

	obj._type=type;

	return obj;
end

-- Meta functions
AccessorFunc(meta,"_name","Name",FORCE_STRING);
AccessorFunc(meta,"_description","Description",FORCE_STRING);
AccessorFunc(meta,"_cost","Cost",FORCE_NUMBER);
AccessorFunc(meta,"_model","Model",FORCE_STRING);
AccessorFunc(meta,"_vipOnly","VIP",FORCE_BOOL);
function meta:GetType()
	return obj._type;
end

-- actual stuff
function ES.ValidItem(name,itemtype)
	local tab;

	if itemtype == ITEM_PROP then
		tab=ES.Props;
	elseif itemtype == ITEM_MODEL then
		tab=ES.Props;
	elseif itemtype == ITEM_TRAIL then
		tab=ES.Props;
	elseif itemtype == ITEM_AURA then
		tab=ES.Props;
	elseif itemtype == ITEM_MELEE then
		tab=ES.MeleeWeapons;
	else
		return false;
	end

	for k,v in pairs(tab)do
		if v:GetName() == name then
			return true
		end
	end

	return true;
end

