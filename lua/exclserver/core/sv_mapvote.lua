-- sv_mapvote.lua
resource.AddFile("materials/excl/vgui/bananaLogo.png");
util.AddNetworkString("exclStartMapvote");

ES.MapvoteEnabled = false;

local mapVoteMaps = {};
local mapsPicked = {};
hook.Add("ESDBDefineTables","ESCreateDTableMapvotes",function()
	ES.DBDefineTable( "mapvote", false, "map varchar(120), serverid int(10), enabled tinyint(1)" );
end)
hook.Add("ESPostGetServerID","ESLoadThisServerMapVoteMaps",function()

	ES.DBQuery("SELECT map FROM es_mapvote WHERE serverid = "..ES.ServerID.." AND enabled = 1 AND map != '"..game.GetMap().."' ORDER BY RAND() LIMIT 4;",function(r)
		if r and r[1] and r[4] then
			ES.MapvoteEnabled = true;
			for k,v in pairs(r)do
				table.insert(mapVoteMaps,v.map);
			end
			if not mapVoteMaps or not type(mapVoteMaps) == "table" or not mapVoteMaps[1] then ES.DebugPrint("This server does not use the mapvote system") return end

			mapsPicked = mapVoteMaps
			mapsPicked[6] = game.GetMap();
			ES.DebugPrint("Mapvote maps were loaded");
		else
			ES.DebugPrint("This server does not use the mapvote system");
		end
	end);

end)

local votesCast = {};
local votesMap = {};

function ES:StartMapVote()
	if not ES.MapvoteEnabled then return end

	hook.Call("ESOnMapVoteStarted")

	ES.VoteStarted = true;

	net.Start("exclStartMapvote");
	net.WriteTable(mapsPicked);
	net.Broadcast();
	
	timer.Simple(20,function()
		ES:EndMapVote();
	end);
end
function ES:EndMapVote() 
	if not ES.MapvoteEnabled then return end

	ES.VoteStarted = false;
	
	local maxMap = table.Random(mapsPicked);
	local maxCast = 0;
	for k,v in pairs(votesMap)do
		if v > maxCast then
			maxCast = v;
			maxMap = k;
		elseif v == maxCast and math.random(1,2) == 1 then
			maxCast = v;
			maxMap = k;
		end
	end
	
	if maxMap != game.GetMap() then
		RunConsoleCommand("changelevel",maxMap);
	else
		votesCast = {};
		votesMap = {};
		
		ES:ResetRTV()
		hook.Call("ESOnMapExtend");

		ES.DBQuery("SELECT map FROM es_mapvote WHERE serverid = "..ES.ServerID.." AND enabled = 1 AND map != '"..game.GetMap().."' ORDER BY RAND() LIMIT 5;",function(r)
			if r and r[1] and r[5] then
				mapVoteMaps = {};
				for k,v in pairs(r)do
					table.insert(mapVoteMaps,v.map);
				end
				if not mapVoteMaps or not type(mapVoteMaps) == "table" or not mapVoteMaps[1] then return end

				mapsPicked = mapVoteMaps

				ES.DebugPrint("A new set of mapvote maps has been loaded");
			end
		end);
	end
end

util.AddNetworkString("exclReceiveMapVote");
concommand.Add("excl_castmapvote",function(p,c,a)
	local map = a[1];
	if not ES.VoteStarted or not map or not table.HasValue(mapsPicked,map) then return end

	if votesCast[p] then
		votesMap[votesCast[p]] = (votesMap[votesCast[p]] or 1) - 1;
	end
	votesCast[p] = map;
	votesMap[map] = (votesMap[map] or 0) + 1;
	
	net.Start("exclReceiveMapVote");
	net.WriteEntity(p);
	net.WriteString(map);
	net.Broadcast();
end)