-- physgun

PLUGIN:SetInfo("Physgun","Gives the admin a physgun.","Excl")
PLUGIN:AddCommand("physgun",function(p)
	if IsValid(p) then
		p:Give("weapon_physgun");
		p:SelectWeapon("weapon_physgun");
	end
end,40);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)