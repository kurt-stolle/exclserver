-- sh_models.lua
-- gets a player's desired model.
ES.ModelsBuy = {}

function ES:AddModel(n,d,p,model,bVip)
	ES.ModelsBuy[string.lower(n)] = {name = n, descr = d, cost = p, model = Model(model), VIPOnly = (bVip or false)}; 
end

local defaultModels = {
	Model("models/player/Group01/Male_01.mdl"),
	Model("models/player/Group01/Male_02.mdl"),
	Model("models/player/Group01/Male_03.mdl"),
	Model("models/player/Group01/Male_04.mdl"),
	Model("models/player/Group01/Male_05.mdl"),
	Model("models/player/Group01/Male_06.mdl"),
	Model("models/player/Group01/Male_07.mdl"),
	Model("models/player/Group01/Male_08.mdl"),
	Model("models/player/Group01/Male_09.mdl"),
	Model("models/player/group01/female_06.mdl"),
	Model("models/player/group01/female_04.mdl"),
	Model("models/player/group01/female_02.mdl"),
	Model("models/player/group01/female_01.mdl"),
}
local pmeta = FindMetaTable("Player");
function pmeta:ESGetActiveModel()
	if not self.excl or not self.excl.activemodel or not ES.ModelsBuy[self.excl.activemodel] then
		return table.Random(defaultModels);
	end

	return ES.ModelsBuy[self.excl.activemodel].model;
end
function pmeta:ESSetModelToActive()
	if not self.excl or not self.excl.activemodel or not ES.ModelsBuy[self.excl.activemodel] then
		self:SetModel(table.Random(defaultModels));
	else
		self:SetModel(ES.ModelsBuy[self.excl.activemodel].model);
	end
end