-- sv_misc.lua

local oldCleanUp = game.CleanUpMap
function game.CleanUpMap(send,filters)
	if not filters then filters = {} end

	table.insert(filters,"es_blockade")
	table.insert(filters,"es_advert")

	oldCleanUp(send or false, filters)
end
