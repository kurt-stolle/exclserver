-- This file handles outfit customization.

util.AddNetworkString("ES.Player.UpdateOutfit");

net.Receive("ES.Player.UpdateOutfit",function(len,ply)
	ES.DebugPrint("Received outfit update request from "..ply:Nick().." len: "..len);

	local outfit=net.ReadTable();
	local max_slots = 2+ply:ESGetVIPTier();
	if #outfit > max_slots then return end

	if ply._es_outfit then
		for k,v in pairs(ply._es_outfit) do
			if ES.IsIdenticalTable(outfit[k],v) then
				outfit[k]=false;
			end
		end
	else
		ply._es_outfit={};
	end

	for k,slot in pairs(outfit)do
		if slot and slot.pos and slot.ang and slot.color then
			ply._es_outfit[k]=slot;

			local x=slot.pos.x or 0;
			local y=slot.pos.y or 0;
			local z=slot.pos.z or 0;
			local pitch=slot.ang.p or 0;
			local yaw=slot.ang.y or 0;
			local roll=slot.ang.r or 0;
			local red=slot.color.r or 255;
			local green=slot.color.g or 255;
			local blue=slot.color.b or 255;

			ES.DBQuery(string.format("INSERT INTO `es_player_outfit` (id,slot,x,y,z,pitch,yaw,roll,red,green,blue) VALUES ("..ply:ESID()..",%s,%s,%s,%s,%s,%s,%s,%s,%s) ON DUPLICATE KEY UPDATE slot=VALUES(slot), x=VALUES(x), y=VALUES(y), z=VALUES(z), pitch=VALUES(pitch), yaw=VALUES(yaw), roll=VALUES(roll), red=VALUES(red), green=VALUES(green), blue=VALUES(blue);",tostring(k),x,y,z,pitch,yaw,roll,red,green,blue));
		end
	end

	net.Start("ES.Player.UpdateOutfit");
	net.WriteEntity(ply);
	net.WriteTable(outfit);
	net.Broadcast();
end);

hook.Add("PlayerInitialSpawn","ES.Outfit.LoadOOnSpawn",function(ply)
	ES.DBQuery("SELECT * FROM `es_player_outfit` WHERE `id`="..ply:ESID().." LIMIT 6;",function(data)
		if not data[1] then return end
		
		ply._es_outfit={};
		for k,v in ipairs(data)do
			ply._es_outfit[v.slot]={
				pos=Vector(v.x,v.y,v.z),
				ang=Angle(v.pitch,v.yaw,v.roll),
				color=Color(v.red,v.green,v.blue)
			}
		end

		net.Start("ES.Player.UpdateOutfit");
		net.WriteEntity(ply);
		net.WriteTable(outfit);
		net.Broadcast();

		for k,v in pairs(player.GetAll())do
			if v ~= ply and v._es_outfit then
				net.Start("ES.Player.UpdateOutfit");
				net.WriteEntity(v);
				net.WriteTable(v._es_outfit);
				net.Broadcast();
			end
		end
	end);
end);