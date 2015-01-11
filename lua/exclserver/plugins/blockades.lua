local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Blockades","Block off parts of a map to prevent exploits.","Excl")
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED);


PLUGIN:AddCommand("showblockades",function(p,a)
	if not p or not p:IsValid() then return end

	p:SendLua("LocalPlayer().editingBlockades = !LocalPlayer().editingBlockades");
end,0);

if SERVER then

util.AddNetworkString("ESBlockStart");
util.AddNetworkString("ESBlockEnd");
util.AddNetworkString("ESBlockConfirm");

hook.Add("ESDBDefineTables","ESBlockadesDatatableSetup",function()
	ES.DBDefineTable("blockades",false,"mapname varchar(255), startX int(16), startY int(16), startZ int(16), endX int(16), endY int(16), endZ int(16)")
end)
hook.Add("Initialize","WDAGHGINITBLOCKADESEXCLWASHEREESS",function()
	ES.DBQuery("SELECT * FROM es_blockades WHERE mapname = '"..game.GetMap().."';",function(r) 
		ES.DebugPrint("Attempting to spawn blockades");

		if not r or not r[1] then return end

		for k,v in pairs(r) do
			local e = ents.Create("es_blockade");

			local d = Vector(v.endX,v.endY,v.endZ) - Vector(v.startX,v.startY,v.startZ);

			e:SetPos(Vector(v.startX,v.startY,v.startZ));
			e:SetAngles(Angle(0,0,0));
			e.min = Vector(0,0,0);
			e.max = d;
			e:Spawn();
		end

		ES.DebugPrint(#r.." blockades spawned");
	end);
end)

end

PLUGIN:AddCommand("startblockade",function(p,a)
	if not p or not p:IsValid() then return end

	net.Start("ESBlockStart");
	net.Send(p);

	p.startedBlockade = true;
	p.blockadeStart = p:EyePos() + p:EyeAngles():Forward() * 10;
	
end,60);

PLUGIN:AddCommand("endblockade",function(p,a)
	if not p or not p:IsValid() or !p.startedBlockade then return end

	net.Start("ESBlockEnd");
	net.Send(p);

	p.blockadeEnd = p:EyePos() + p:EyeAngles():Forward() * 30;
end,60);

PLUGIN:AddCommand("confirmblockade",function(p,a)
	if not p or not p:IsValid() or !p.startedBlockade or !p.blockadeEnd then return end

	p.startedBlockade = false;

	net.Start("ESBlockConfirm");
	net.Send(p);

	ES.DBQuery("INSERT INTO es_blockades SET mapname = '"..game.GetMap().."', startX = "..p.blockadeStart.x..", startY = "..p.blockadeStart.y..", startZ = "..p.blockadeStart.z..", endX = "..p.blockadeEnd.x..", endY = "..p.blockadeEnd.y..", endZ = "..p.blockadeEnd.z..";")

	local e = ents.Create("es_blockade");

	local d = Vector(p.blockadeEnd.x,p.blockadeEnd.y,p.blockadeEnd.z) - Vector(p.blockadeStart.x,p.blockadeStart.y,p.blockadeStart.z);

	e:SetPos(Vector(p.blockadeStart.x,p.blockadeStart.y,p.blockadeStart.z));
	e:SetAngles(Angle(0,0,0));
	e.min = Vector(0,0,0);
	e.max = d;
	e:Spawn();

end,60);
PLUGIN();