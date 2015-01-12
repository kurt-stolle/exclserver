net.Receive("ESSynchInvAdd",function()
	name = net.ReadString();
	itemtype = net.ReadInt(8);
	if itemtype == ITEM_TRAIL and LocalPlayer().excl then
		if not LocalPlayer()._es_inventory_trails then
			LocalPlayer()._es_inventory_trails = {name}
			return;
		end
		LocalPlayer()._es_inventory_trails[#LocalPlayer()._es_inventory_trails + 1] = name;
	elseif itemtype == ITEM_MODEL and LocalPlayer().excl then
		if not LocalPlayer()._es_inventory_models then
			LocalPlayer()._es_inventory_models = {name}
			return;
		end
		LocalPlayer()._es_inventory_models[#LocalPlayer()._es_inventory_models + 1] = name;
	elseif itemtype == ITEM_MELEE and LocalPlayer().excl then
		if not LocalPlayer()._es_inventory_meleeweapons then
			LocalPlayer()._es_inventory_meleeweapons = {name}
			return;
		end
		LocalPlayer()._es_inventory_meleeweapons[#LocalPlayer()._es_inventory_meleeweapons + 1] = name;
	end 
end)
net.Receive("ESSynchInvRemove",function()
	name = net.ReadString();
	itemtype = net.ReadInt(8);
	if itemtype == ITEM_TRAIL and LocalPlayer()._es_inventory_trails then
		for k,v in pairs(LocalPlayer()._es_inventory_trails)do
			if v == name then
				table.remove(LocalPlayer()._es_inventory_trails,k);
				return;
			end
		end
	elseif itemtype == ITEM_MODEL and LocalPlayer()._es_inventory_models then
		for k,v in pairs(LocalPlayer()._es_inventory_models)do
			if v == name then
				table.remove(LocalPlayer()._es_inventory_models,k);
				return;
			end
		end
	elseif itemtype == ITEM_MELEE and LocalPlayer()._es_inventory_meleeweapons then
		for k,v in pairs(LocalPlayer()._es_inventory_meleeweapons)do
			if v == name then
				table.remove(LocalPlayer()._es_inventory_meleeweapons,k);
				return;
			end
		end
	end  
end)
net.Receive("ESSynchInventory",function()
	local t = net.ReadTable();

	if not t.models or not t.trails or not t.meleeweapons or not t.auras then 
		ES.DebugPrint("Received invalid inventory synchronization. Data was lost.");
		return 
	end

	LocalPlayer()._es_inventory_models = t.models;
	LocalPlayer()._es_inventory_trails = t.trails;
	LocalPlayer()._es_inventory_meleeweapons = t.meleeweapons;
	LocalPlayer()._es_inventory_auras = t.auras
end);
