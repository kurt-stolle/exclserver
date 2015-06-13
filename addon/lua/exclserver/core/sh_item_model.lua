-- sh_models.lua
-- gets a player's desired model.
ES.Models = {}
ES.ImplementIndexMatcher(ES.Models,"_name")

function ES.AddModel(n,d,p,t,bVip)
	local tab=ES.Item( ES.ITEM_MODEL )
	tab:SetName(n)
	tab:SetDescription(d)
	tab:SetCost(p)
	if file.Exists(t,"GAME") then
		tab:SetModel(t)
	else
		ES.DebugPrint("Prevented unknown model: "..t)
		return
	end
	tab:SetVIP(bVip)

	table.insert(ES.Models,tab)
end

ES.DefaultModels = {
	Model("models/player/Group01/Male_01.mdl"),
	Model("models/player/Group01/Male_02.mdl"),
	Model("models/player/Group01/Male_03.mdl"),
	Model("models/player/Group01/Male_04.mdl"),
	Model("models/player/Group01/Male_05.mdl"),
	Model("models/player/Group01/Male_06.mdl"),
	Model("models/player/Group01/Male_07.mdl"),
	Model("models/player/Group01/Male_08.mdl"),
	Model("models/player/Group01/Male_09.mdl"),
	Model("models/player/group01/female_06.mdl"),
	Model("models/player/group01/female_04.mdl"),
	Model("models/player/group01/female_02.mdl"),
	Model("models/player/group01/female_01.mdl"),
}

local PLAYER = FindMetaTable("Player")
function PLAYER:ESGetActiveModel()
	local active=self:ESGetNetworkedVariable("active_model",nil)

	return ES.Models[active] and ES.Models[active]:GetModel() or table.Random(ES.DefaultModels)
end

-- The models below require no custom content
ES.AddModel("Dr. Breen","The city administrator",4000,"models/player/breen.mdl")
ES.AddModel("Father","...",4000,"models/player/monk.mdl")
ES.AddModel("GMan","A mysterious figure",4000,"models/player/gman_high.mdl")
ES.AddModel("Dr. Kleiner","A passionate scientist",4000,"models/player/Kleiner.mdl")
ES.AddModel("Phoenix member","A phoenix terrorist.",4500,"models/player/Phoenix.mdl")
ES.AddModel("Leet member","A leet terrorist.",4500,"models/player/leet.mdl")
ES.AddModel("Arctic member","A arctic terrorist.",4500,"models/player/arctic.mdl")
ES.AddModel("Odessa","Your favoirite security guard.",4500,"models/player/odessa.mdl")
ES.AddModel("American WWII soldier","An American WWII soldier.",5000,"models/player/dod_american.mdl")
ES.AddModel("German WWII soldier","A German WWII soldier.",5000,"models/player/dod_german.mdl")
ES.AddModel("Dr. Magnusson","The character you've never heard about before.",4000,"models/player/magnusson.mdl")
ES.AddModel("Mossman Arctic","...",5500,"models/player/mossman_arctic.mdl")
ES.AddModel("Burned corpse","2spooky",4300,"models/player/charple.mdl")
ES.AddModel("Rotting corpse","...",4000,"models/player/corpse1.mdl")
ES.AddModel("Zombie","A headcrabless zombie",20000,"models/player/zombie_classic.mdl")
ES.AddModel("Alyx","Gordon's company",4000,"models/player/alyx.mdl")
ES.AddModel("Eli","A nigger with a metal leg.",4000,"models/player/eli.mdl")
ES.AddModel("Skeleton","A scary skeleton",25000,"models/player/skeleton.mdl")

-- The models below DO require custom content!


-- Resource the custom models
if SERVER then

end
