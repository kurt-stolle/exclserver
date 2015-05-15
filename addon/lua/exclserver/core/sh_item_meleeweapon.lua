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

local PLAYER = FindMetaTable("Player")
function PLAYER:ESGetMeleeWeapon()
	if not self.excl or not self.excl.activemelee then return false end
	return ES.MeleeWeapons[self.excl.activemelee]
end
local emeta = FindMetaTable("Weapon")
function emeta:ESIsMelee()
	return (self:GetClass() == ES.MeleeBaseClass or string.Left(self:GetClass(),8) == "es_melee")
end
function PLAYER:ESGetMeleeWeaponClass()
	if not self:ESGetMeleeWeapon() then return ES.MeleeBaseClass end
	return "es_melee_"..string.gsub(string.lower(self:ESGetMeleeWeapon().name)," ","_")
end

function PLAYER:ESReplaceMelee()
	for k,v in pairs(self:GetWeapons())do
		if !IsValid(v) or !v:ESIsMelee() then continue end

		if self:ESGetMeleeWeapon() and (v:GetClass() ~= ( "es_melee_"..string.gsub(string.lower(self:ESGetMeleeWeapon().name)," ","_")) or v:GetClass() == ES.MeleeBaseClass) then
			v:Remove()

			print("replaced")
			self:Give( "es_melee_"..string.gsub(string.lower(self:ESGetMeleeWeapon().name)," ","_") )
		elseif not self:ESGetMeleeWeapon() and v:GetClass() ~= ES.MeleeBaseClass then
			v:Remove()

			self:Give( ES.MeleeBaseClass )
		end
	end
end

--[[hook.Add("PostGamemodeLoaded","ES.Melee.InitializeOverride",function()
	if gmod.GetGamemode().Name == "Trouble in Terrorist Town" then
		ES.MeleeBaseClass = "weapon_zm_improvised"
	elseif gmod.GetGamemode().Name == "JailBreak" then
		ES.MeleeBaseClass = "jb_knife"
	end

	for k,v in pairs(ES.MeleeWeapons)do
		weapons.Register({
			WorldModel = v.model,
			ViewModel = v.viewmodel,
			HoldType = v.holdtype,
			Base = ES.MeleeBaseClass,
			GetClass = function() return "es_melee_"..string.gsub(string.lower(v.name)," ","_") end,
		},"es_melee_"..string.gsub(string.lower(v.name)," ","_"))
	end
end)]]

ES.AddMelee("Sword","A katana from ancient times",3000,"models/weapons/w_katana.mdl","models/weapons/v_katana.mdl","melee2")