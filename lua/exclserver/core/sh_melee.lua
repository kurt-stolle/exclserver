-- sh_melee
-- melee weapons

ES.MeleeBuy = {}

function ES:AddMelee(n,d,p,model,viewmodel,holdtype)
	ES.MeleeBuy[string.lower(n)] = {name = n, descr = d, cost = p, model = model, viewmodel = viewmodel,holdtype = holdtype}; 
end

ES.MeleeBaseClass = "excl_crowbar";

local pmeta = FindMetaTable("Player");
function pmeta:ESGetMeleeWeapon()
	if not self.excl or not self.excl.activemelee then return false end
	return ES.MeleeBuy[self.excl.activemelee];
end
local emeta = FindMetaTable("Weapon");
function emeta:ESIsMelee()
	return (self:GetClass() == ES.MeleeBaseClass or string.Left(self:GetClass(),8) == "es_melee")
end
function pmeta:ESGetMeleeWeaponClass()
	if not self:ESGetMeleeWeapon() then return ES.MeleeBaseClass end
	return "es_melee_"..string.gsub(string.lower(self:ESGetMeleeWeapon().name)," ","_");
end

function pmeta:ESReplaceMelee()
	for k,v in pairs(self:GetWeapons())do
		if !IsValid(v) or !v:ESIsMelee() then continue end

		if self:ESGetMeleeWeapon() and (v:GetClass() != ( "es_melee_"..string.gsub(string.lower(self:ESGetMeleeWeapon().name)," ","_")) or v:GetClass() == ES.MeleeBaseClass) then
			v:Remove();

			print("replaced")
			self:Give( "es_melee_"..string.gsub(string.lower(self:ESGetMeleeWeapon().name)," ","_") );
		elseif not self:ESGetMeleeWeapon() and v:GetClass() != ES.MeleeBaseClass then
			v:Remove();

			self:Give( ES.MeleeBaseClass )
		end
	end
end

hook.Add("Initialize","exclInitCustomMelee",function()
	 -- works on most of my gamemodes...
	if gmod.GetGamemode().Name == "Trouble in Terrorist Town" then
		ES.MeleeBaseClass = "weapon_zm_improvised"
	elseif gmod.GetGamemode().Name == "JailBreak" then
		ES.MeleeBaseClass = "jb_knife"
	end

	for k,v in pairs(ES.MeleeBuy)do
		weapons.Register({
			WorldModel = v.model,
			ViewModel = v.viewmodel,
			HoldType = v.holdtype,
			Base = ES.MeleeBaseClass,
			GetClass = function() return "es_melee_"..string.gsub(string.lower(v.name)," ","_") end,
		},"es_melee_"..string.gsub(string.lower(v.name)," ","_"))
	end
end)
