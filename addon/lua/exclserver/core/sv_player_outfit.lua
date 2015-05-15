-- This file handles outfit customization.

util.AddNetworkString("ES.Player.UpdateOutfit")

net.Receive("ES.Player.UpdateOutfit",function(len,ply)
	ES.DebugPrint("Received outfit update request from "..ply:Nick().." len: "..len)

	local slot=net.ReadUInt(4)
	local item=net.ReadUInt(8)
	local pos=net.ReadVector()
	local ang=net.ReadAngle()
	local scale=net.ReadVector()
	local color=ES.DBEscape(net.ReadString())
	local bone=ES.DBEscape(net.ReadString())

	if not slot or not item or not pos or not ang or not color or not scale or slot > 2+ply:ESGetVIPTier() or not ES.Props[item] or not bone or not table.HasValue(ES.PropBones,bone) or not ES.HexToRGB(color) then return end

	item=ES.Props[item]:GetName()

	if not ply:ESHasItem(item,ES.ITEM_PROP) then return end

	if not ply._es_outfit then
		ply._es_outfit={}
	end

	ply._es_outfit[slot] = {pos=pos,ang=ang,item=item,bone=bone,scale=scale,color=color}

	ES.DBQuery(string.format("INSERT INTO `es_player_outfit` (steamid,slot,item,bone,pos,ang,scale,color) VALUES ('"..ply:SteamID().."',%s,'%s','%s','%s','%s', '%s', '%s') ON DUPLICATE KEY UPDATE slot=VALUES(slot), item=VALUES(item), bone=VALUES(bone), pos=VALUES(pos), ang=VALUES(ang), scale=VALUES(scale), color=VALUES(color)",tostring(slot),tostring(item),bone,tostring(pos),tostring(ang),tostring(scale),color))

	net.Start("ES.Player.UpdateOutfit")
	net.WriteEntity(ply)
	net.WriteTable(ply._es_outfit)
	net.Broadcast()

	ES.DebugPrint("Saved outfit of "..ply:Nick())
end)

hook.Add("ESPlayerReady","ES.Outfit.LoadOOnSpawn",function(ply)
	ES.DBQuery("SELECT * FROM `es_player_outfit` WHERE `steamid`='"..ply:SteamID().."' LIMIT 6",function(data)
		if not data[1] then return end
		
		ply._es_outfit={}
		for k,v in ipairs(data)do
			if not v.item or not v.pos or not v.slot or not v.ang or not v.color or not v.scale or not v.bone or not ES.Props[v.item] then continue end

			ply._es_outfit[v.slot]={
				item=v.item,
				pos=Vector(v.pos),
				ang=Angle(v.ang),
				scale=Vector(v.scale),
				color=v.color,
				bone=v.bone
			}
		end

		net.Start("ES.Player.UpdateOutfit")
		net.WriteEntity(ply)
		net.WriteTable(ply._es_outfit)
		net.Broadcast()

		for k,v in pairs(player.GetAll())do
			if v ~= ply and v._es_outfit then
				net.Start("ES.Player.UpdateOutfit")
				net.WriteEntity(v)
				net.WriteTable(v._es_outfit)
				net.Send(ply)
			end
		end
	end)
end)