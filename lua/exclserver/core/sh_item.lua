-- inventory systems
ES.ITEM_TRAIL = 1;
ES.ITEM_MELEE = 2;
ES.ITEM_MODEL = 3;
ES.ITEM_AURA = 4;
ES.ITEM_PROP = 5;

-- Item object
local meta={};
function ES.Item(_type)
	if type(_type) ~= "number" or (_type <= 0 and _type >= 6) then return Error("Invalid type passed to Item constructor."); end

	local obj={};
	setmetatable(obj,meta);
	meta.__index=meta;

	obj:SetName("Undefined");
	obj:SetDescription("No description given.");
	obj:SetCost(0);

	obj._type=_type;

	return obj;
end

-- Meta functions
AccessorFunc(meta,"_name","Name",FORCE_STRING);
AccessorFunc(meta,"_description","Description",FORCE_STRING);
AccessorFunc(meta,"_cost","Cost",FORCE_NUMBER);
AccessorFunc(meta,"_model","Model",FORCE_STRING);
AccessorFunc(meta,"_vipOnly","VIP",FORCE_BOOL);
function meta:GetType()
	return self._type;
end

-- actual stuff
function ES.ValidItem(name,itemtype)
	local tab=ES.GetItemTable(enum);
	if not tab then return false end

	for k,v in pairs(tab)do
		if v:GetName() == name then
			return true
		end
	end

	return true;
end

function ES.GetItemTable(enum)
	if enum == ES.ITEM_PROP then
		return ES.Props;
	elseif enum == ES.ITEM_MODEL then
		return ES.Props;
	elseif enum == ES.ITEM_TRAIL then
		return ES.Props;
	elseif enum == ES.ITEM_AURA then
		return ES.Props;
	elseif enum == ES.ITEM_MELEE then
		return ES.MeleeWeapons;
	else
		return nil;
	end
end