-- sh_inventory_new.lua
ES.Items = {};

local pmeta = FindMetaTable("Player");
local invmeta = {};
function invmeta:ContainsItem(name)
	if not ES.Items[name] then return false end

	for k,v in pairs(self)do
		if k and v and k == name and type(v) == "number" and v > 0 then return true end
	end
	return false;
end
function invmeta:SetItem(name,amount)
	if not ES.Items[name] then return end
	self[name] = amount;
end
function invmeta:GetItems()
	local valid = {};
	for k,v in pairs(self)do
		if ES.Items[k] and v > 0 then
			valid[k] = v;
		end
	end
	return valid;
end
function invmeta:GetAmount(name)
	if not ES.Items[name] then return 0 end

	return self[name] or 0;
end
function invmeta:AddItem(name,amount,nosynch)
	if not ES.Items[name] then return false end

	if self[name] and self[name] > 0 then 
		self[name] = self[name] + (amount or 1); 
	else
		self[name] = (amount or 1);
	end
	if SERVER then
		self:Save();

		if !nosynch then
			net.Start("ESSynchInventoryNewAdd");
			net.WriteString(name);
			net.WriteInt(amount,16);
			net.Send(self.Player);
		end

		if amount < 0 then
			local virtual = self[name];
			for i=1,2+self.Player:ESGetVIPTier() do
				if self.Player:ESGetGlobalData("slot"..i,false) then
					local tab = string.Explode("|",self.Player:ESGetGlobalData("slot"..i,false));
					if tab[1] == name then
						virtual = virtual - 1;
						if virtual < 1 then
							self.Player:ESSetGlobalData("slot"..i,"");
							ES.DBQuery("UPDATE es_player SET slot"..i.." = '' WHERE id = "..self.Player:NumSteamID()..";");
						end
					end
				end
			end
		end
	end
	return true
end
function invmeta:RemoveItem(name,amount,nosynch)
	return self:AddItem(name,-amount,nosynch);
end
if SERVER then
	util.AddNetworkString("ESSynchInventoryNewAdd");
	util.AddNetworkString("ESSynchInventoryNew");
	function invmeta:Save()
		local bits = {};
		for k,v in pairs(self.Player:ESGetInventory())do
			if k and ES.Items[k] and v and type(v) == "number" and v > 0 then
				bits[#bits+1] = k.."_"..v;
			end
		end
		bits = table.concat(bits,"|")
		ES.DBQuery("UPDATE es_player SET inventory = '"..(bits or "").."' WHERE id = "..self.Player:NumSteamID());

		ES.DebugPrint("Inventory saved");
	end
	function pmeta:ESLoadInventory(str)
		local inv = string.Explode("|",str,false);
		self.excl.inventoryitems = {};
		setmetatable(self.excl.inventoryitems,invmeta);
		invmeta.__index =  invmeta;
		for k,v in pairs(inv)do
			local temp = string.Explode("_",v);
			self.excl.inventoryitems[temp[1]] = tonumber(temp[2]);
		end
		self.excl.inventoryitems.Player = self;

		ES.DebugPrint("Inventory items loaded");
		
		--[[net.Start("ESSynchInventoryNew");
		net.WriteTable(self.excl.inventoryitems);
		net.Send(self);]]
	end
  
elseif CLIENT then
	net.Receive("ESSynchInventoryNew",function()
		ES.DebugPrint("Received inventory synch");

		for k,v in pairs(net.ReadTable() or {})do
			if ES.Items[k] and tonumber(v) > 0 then
				LocalPlayer():ESGetInventory():SetItem(k,tonumber(v));
			end
		end

		PrintTable(LocalPlayer():ESGetInventory())
	end)
	net.Receive("ESSynchInventoryNewAdd",function()
		ES.DebugPrint("Received inventory synch (added item)")
		LocalPlayer():ESGetInventory():AddItem(net.ReadString(),net.ReadInt(16));
	end)
end


function pmeta:ESGetInventory()
	if not self.excl then
		self.excl = {};
	end

	if not self.excl.inventoryitems then
		self.excl.inventoryitems = {};

		self.excl.inventoryitems.Player = self;
	end
	setmetatable(self.excl.inventoryitems,invmeta);
	invmeta.__index =  invmeta;
	return self.excl.inventoryitems;
end

function ES:GetBuyableItems()
	local build = {};
	for k,v in pairs(ES.Items)do
		if v:GetBuyable() then
			build[#build+1] = v;
		end
	end
	return build
end


ES.ItemBones = {
	"ValveBiped.Bip01_Pelvis",
"ValveBiped.Bip01_Spine",
"ValveBiped.Bip01_Spine1",
"ValveBiped.Bip01_Spine2",
"ValveBiped.Bip01_Spine4",
"ValveBiped.Bip01_Neck1",
"ValveBiped.Bip01_Head1",
"ValveBiped.Bip01_R_Clavicle",
"ValveBiped.Bip01_R_UpperArm",
"ValveBiped.Bip01_R_Forearm",
"ValveBiped.Bip01_R_Hand",
"ValveBiped.Bip01_L_Clavicle",
"ValveBiped.Bip01_L_UpperArm",
"ValveBiped.Bip01_L_Forearm",
"ValveBiped.Bip01_L_Hand",
"ValveBiped.Bip01_R_Clavicle",
"ValveBiped.Bip01_R_Thigh",
"ValveBiped.Bip01_R_Calf",
"ValveBiped.Bip01_R_Foot",
"ValveBiped.Bip01_R_Toe0",
"ValveBiped.Bip01_L_Thigh",
"ValveBiped.Bip01_L_Calf",
"ValveBiped.Bip01_L_Foot",
"ValveBiped.Bip01_L_Toe0"
}

local itemmeta = {};
AccessorFunc(itemmeta,"name","Name",FORCE_STRING);
AccessorFunc(itemmeta,"descr","Description",FORCE_STRING);
AccessorFunc(itemmeta,"cost","Cost",FORCE_NUMBER);
AccessorFunc(itemmeta,"viponly","VIPOnly",FORCE_BOOL);
AccessorFunc(itemmeta,"buyable","Buyable",FORCE_BOOL);
AccessorFunc(itemmeta,"scale","Scale",FORCE_NUMBER);
function ES.Item()
	local item = {};
	setmetatable(item,itemmeta);
	itemmeta.__index =  itemmeta;

	item.combinations = {};
	if CLIENT then
		item.cMdl = NULL;
	end
	item.model = "";
	item:SetScale(1);

	return item;
end

function itemmeta.__call(self,id)
	ES.Items[id] = self;
	self.id = id;

	ES.DebugPrint("Registered item: "..id)
end

function itemmeta:AddCombination(take,give)
	self.combinations[take] = give;
end

function itemmeta:Combine(take)
	return self.combinations[take] or false;
end

function itemmeta:SetModel(model)
	self.model = model;
	if CLIENT then
		if file.Exists( model, "GAME" ) then
			self.cMdl = ClientsideModel(model,RENDERGROUP_BOTH);
			self.cMdl:SetNoDraw(true);
		else
			print("[EXCLSERVER] Error: Model "..model.." is missing!");
		end
	end
end
function itemmeta:GetModel()
	return self.model;
end