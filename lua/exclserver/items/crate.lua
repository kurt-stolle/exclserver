-- crate

local ITEM = ES:Item();
ITEM:SetName("Wooden crate");
ITEM:SetDescription("A simple wooden crate for every day purposes");
ITEM:SetModel("models/props_junk/wood_crate001a.mdl")
ITEM:SetScale(0.4);
ITEM:SetCost(200);
ITEM:SetBuyable(true);
ITEM:AddCombination("crate","largecrate")
ITEM("crate");

local ITEM = ES:Item();
ITEM:SetName("Large wooden crate");
ITEM:SetDescription("A larger wooden crate for every day purposes");
ITEM:SetModel("models/props_junk/wood_crate002a.mdl")
ITEM:SetScale(0.4);
ITEM:SetCost(400);
ITEM:SetBuyable(false);
ITEM("largecrate");

local ITEM = ES:Item();
ITEM:SetName("Cardboard box");
ITEM:SetDescription("A simple cardboard box for every day purposes");
ITEM:SetModel("models/props_junk/cardboard_box001a.mdl")
ITEM:SetScale(0.5);
ITEM:SetCost(180);
ITEM:SetBuyable(true);
ITEM("cardboard");