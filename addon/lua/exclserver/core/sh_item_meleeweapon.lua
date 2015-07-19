-- sh_melee
-- melee weapons

ES.MeleeWeapons = {}
ES.ImplementIndexMatcher(ES.MeleeWeapons,"_name")

function ES.AddMelee(n,d,p,t,viewmodel,holdtype)
	local tab=ES.Item( ES.ITEM_MELEE )
	tab:SetName(n)
	tab:SetDescription(d)
	tab:SetCost(p)
	if file.Exists(t,"GAME") then
		tab:SetModel(t)
	else
		ES.DebugPrint("Prevented unknown model: "..t)
	end
	tab.viewmodel = viewmodel
	tab.holdtype = holdtype

	table.insert(ES.MeleeWeapons,tab)
end

ES.MeleeBaseClass = "excl_crowbar"

local WEAPON = FindMetaTable("Weapon")
function WEAPON:ESIsMelee()
	return (self:GetClass() == ES.MeleeBaseClass or string.Left(self:GetClass(),8) == "es_melee")
end

local PLAYER = FindMetaTable("Player")
function PLAYER:ESGetMeleeWeaponClass()
	if not ES.MeleeWeapons[self:ESGetNetworkedVariable("active_meleeweapon",nil)] then 
		return ES.MeleeBaseClass
	end

	return "es_melee_"..string.gsub(string.lower(ES.MeleeWeapons[self:ESGetNetworkedVariable("active_meleeweapon",nil)]:GetName())," ","_")
end

local oldGive = PLAYER.Give;
function PLAYER:Give(class,...)
	if class==ES.MeleeBaseClass and ES.MeleeWeapons[self:ESGetNetworkedVariable("active_meleeweapon",nil)] then
		return oldGive(self,self:ESGetMeleeWeaponClass(),...)
	end

	return oldGive(self,class,...)
end

function PLAYER:ESReplaceMelee()
	for k,v in pairs(self:GetWeapons())do
		if not IsValid(v) or not v:ESIsMelee() then continue end

		if ES.MeleeWeapons[self:ESGetNetworkedVariable("active_meleeweapon",nil)] and (v:GetClass() ~= ( "es_melee_"..string.gsub(string.lower(ES.MeleeWeapons[self:ESGetNetworkedVariable("active_meleeweapon",nil)]:GetName())," ","_")) or v:GetClass() == ES.MeleeBaseClass) then
			v:Remove()
			self:Give( "es_melee_"..string.gsub(string.lower(ES.MeleeWeapons[self:ESGetNetworkedVariable("active_meleeweapon",nil)]:GetName())," ","_") )
		elseif not ES.MeleeWeapons[self:ESGetNetworkedVariable("active_meleeweapon",nil)] and v:GetClass() ~= ES.MeleeBaseClass then
			v:Remove()

			self:Give( ES.MeleeBaseClass )
		end
	end
end

hook.Add("PostGamemodeLoaded","exclserver.melee.override",function()
	if gmod.GetGamemode().Name == "Trouble in Terrorist Town" then
		ES.MeleeBaseClass = "weapon_zm_improvised"
	elseif gmod.GetGamemode().Name == "Jail Break" then
		ES.MeleeBaseClass = "weapon_jb_knife"
	end

	for k,v in pairs(ES.MeleeWeapons)do
		weapons.Register({
			WorldModel = v:GetModel(),
			ViewModel = v.viewmodel,
			HoldType = v.holdtype,
			Base = ES.MeleeBaseClass,
			GetClass = function() return "es_melee_"..string.gsub(string.lower(v:GetName())," ","_") end,
		},"es_melee_"..string.gsub(string.lower(v:GetName())," ","_"))
	end
end)

ES.AddMelee("Sword","A katana from ancient times",3000,"models/weapons/w_katana.mdl","models/weapons/v_katana.mdl","melee2")