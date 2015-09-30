net.Receive("ESSynchInvAdd",function()
	local name = net.ReadString()
	local itemtype = net.ReadUInt(4)
	local tab_inventory
	local ply=LocalPlayer()

	if itemtype == ES.ITEM_TRAIL then
		if type(ply._es_inventory_trails) ~= "table" then
			ply._es_inventory_trails = {}
		end

		tab_inventory=ply._es_inventory_trails
	elseif itemtype == ES.ITEM_MODEL then
		if type(ply._es_inventory_models) ~= "table" then
			ply._es_inventory_models = {}
		end

		tab_inventory=ply._es_inventory_models
	elseif itemtype == ES.ITEM_MELEE then
		if type(ply._es_inventory_meleeweapons) ~= "table" then
			ply._es_inventory_meleeweapons = {}
		end

		tab_inventory=ply._es_inventory_meleeweapons
	elseif itemtype == ES.ITEM_AURA then
		if type(ply._es_inventory_auras) ~= "table" then
			ply._es_inventory_auras = {}
		end

		tab_inventory=ply._es_inventory_auras
	elseif itemtype == ES.ITEM_PROP then
		if type(ply._es_inventory_props) ~= "table" then
			ply._es_inventory_props = {}
		end

		tab_inventory=ply._es_inventory_props
	end

	if type(tab_inventory) ~= "table" then
		ES.DebugPrint("Failed to synchronize item with itemtype ["..tostring(itemtype).."] tables not found.")
		return
	end


	table.insert(tab_inventory,name)

	ES.DebugPrint("Synchronized item add: '"..name.."'@["..itemtype.."].")

end)
net.Receive("ESSynchInvRemove",function()
	local name = net.ReadString()
	local itemtype = net.ReadInt(8)
	local tab
	local ply=LocalPlayer()

	if itemtype == ES.ITEM_TRAIL then
		tab=ply._es_inventory_trails
	elseif itemtype == ES.ITEM_MODEL then
		tab=ply._es_inventory_models
	elseif itemtype == ES.ITEM_MELEE then
		tab=ply._es_inventory_meleeweapons
	elseif itemtype == ES.ITEM_AURA then
		tab=ply._es_inventory_auras
	elseif itemtype == ES.ITEM_PROP then
		tab=ply._es_inventory_props
	end

	if type(tab) ~= "table" then return end

	for k,v in ipairs(tab)do
		if v == name then
			table.remove(tab,k)
			break
		end
	end
end)
net.Receive("ESSynchInventory",function()
	local ply=LocalPlayer()
	local t = net.ReadTable()

	if not t.models or not t.trails or not t.meleeweapons or not t.auras or not t.props then
		ES.DebugPrint("Received invalid inventory synchronization. Data may be lost.")
	end

	for itemtype,items in pairs(t) do
		local temp={}
		for k,v in ipairs(items)do
			table.insert(temp,v)
		end

		ply["_es_inventory_"..itemtype] = temp
	end
end)
