net.Receive("ESSynchInvAdd",function()
	local name = net.ReadString();
	local itemtype = net.ReadInt(8);
	local tab_inventory;
	local tab_items;

	if itemtype == ES.ITEM_TRAIL then
		tab_inventory=LocalPlayer()._es_inventory_trails;
		tab_items=ES.Trails;
	elseif itemtype == ES.ITEM_MODEL then
		tab_inventory=LocalPlayer()._es_inventory_models;
		tab_items=ES.Models;
	elseif itemtype == ES.ITEM_MELEE then
		tab_inventory=LocalPlayer()._es_inventory_meleeweapons;
		tab_items=ES.MeleeWeapons;
	elseif itemtype == ES.ITEM_AURA then
		tab_inventory=LocalPlayer()._es_inventory_auras;
		tab_items=ES.Auras;
	elseif itemtype == ES.ITEM_PROP then
		tab_inventory=LocalPlayer()._es_inventory_props;
		tab_items=ES.Props;
	end  

	if type(tab) != "table" or not tab_items then return end


	table.insert(tab_inventory,1,tab_items[name]);
end)
net.Receive("ESSynchInvRemove",function()
	local name = net.ReadString();
	local itemtype = net.ReadInt(8);
	local tab;

	if itemtype == ES.ITEM_TRAIL then
		tab=LocalPlayer()._es_inventory_trails;
	elseif itemtype == ES.ITEM_MODEL then
		tab=LocalPlayer()._es_inventory_models;
	elseif itemtype == ES.ITEM_MELEE then
		tab=LocalPlayer()._es_inventory_meleeweapons;
	elseif itemtype == ES.ITEM_AURA then
		tab=LocalPlayer()._es_inventory_auras;
	elseif itemtype == ES.ITEM_PROP then
		tab=LocalPlayer()._es_inventory_props;
	end  

	if type(tab) != "table" then return end

	for k,v in ipairs(tab)do
		if v == name then
			table.remove(tab,k);
			break;
		end
	end
end)
net.Receive("ESSynchInventory",function()
	local t = net.ReadTable();

	if not t.models or not t.trails or not t.meleeweapons or not t.auras or not t.props then 
		ES.DebugPrint("Received invalid inventory synchronization. Data may be lost.");
	end

	for itemtype,items in pairs(t) do
		local temp={};
		for k,v in ipairs(items)do
			local tab_items;
			if itemtype=="models" then
				tab_items=ES.Models;
			elseif itemtype=="trails" then
				tab_items=ES.Trails;
			elseif itemtype=="meleeweapons"then
				tab_items=ES.MeleeWeapons;
			elseif itemtype=="auras" then
				tab_items=ES.Auras;
			elseif itemtype=="props" then
				tab_items=ES.Props;
			end

			if not tab_items then continue end
			
			table.insert(temp,tab_items[v]);
		end

		LocalPlayer()["_es_inventory_"..itemtype] = temp;
	end
end);
