function ES._MMGenerateInventoryEffects(base)
	local ply 				= LocalPlayer();
	local p 				= base:OpenFrame()

	local activeTrail 		= ES.Trails[ply:ESGetNetworkedVariable("active_trail")];
	local activeModel 		= ES.Models[ply:ESGetNetworkedVariable("active_model")];
	local activeAura 		= ES.Auras[ply:ESGetNetworkedVariable("active_aura")];
	local activeMeleeWeapon = ES.MeleeWeapons[ply:ESGetNetworkedVariable("active_meleeweapon")];

	local invTall = (p:GetTall()-10*4)/3

	p:SetTitle("Effects");

--## Models
	local mdl = p:Add("esMMHatPreview");
	--mdl.useCurrentHat = true;
	mdl:SetSize(500,500);
	mdl:SetModel(LocalPlayer():ESGetActiveModel());
	mdl:SetPos(p:GetWide()-380,p:GetTall()-501);
	mdl:SetLookAt(Vector(0,0,62));
	mdl:SetCamPos(Vector(38,18,64));

	local nextPress = CurTime()+.5;
	local modeIndex = 0;

	local models = LocalPlayer()._es_inventory_models or {};
	local function modelbykey(k)
		if k < 1 then
			return table.Random(ES.DefaultModels);
		else
			return ES.Models[ k ]:GetModel();
		end
	end

	local timeAnimate = CurTime();
	function mdl:Think()
		if timeAnimate + 2 > CurTime() then return end
		timeAnimate = CurTime();

		mdl:SetModel(modelbykey(modeIndex))
	end

	mdl:SetModel(modelbykey(modeIndex))

	local pnlmdl = p:Add("Panel");
	function pnlmdl:Paint(w,h)
		surface.SetDrawColor(ES.GetColorScheme(2))
		surface.DrawRect(0,0,w,h)
		draw.SimpleText("Model","esMMInventoryTitle",10,10,COLOR_WHITE);
		if activeModel then
			draw.SimpleText(activeModel:GetName(),"ESDefaultBold",15,h-30,COLOR_WHITE);
			return;
		end
		
		draw.SimpleText("Random citizen","ESDefaultBold",15,h-30,COLOR_WHITE);

	end
	pnlmdl:SetSize(p:GetWide() - 30 - 10 - (p:GetWide()-30-230),64 + 5*4)
	pnlmdl:SetPos(p:GetWide()-10-pnlmdl:GetWide(),p:GetTall()-pnlmdl:GetTall()-10);
	mdl.y = pnlmdl.y-500;

	local butPrev = vgui.Create("esIconButton",pnlmdl)
	butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
	butPrev:SetSize(32,32);
	butPrev:SetPos(pnlmdl:GetWide()-32-10-32-9,15);
	butPrev:SetRotation(180);
	butPrev.DoClick = function(self)
		if CurTime() < nextPress then return end
		nextPress = CurTime()+.7;
		modeIndex = modeIndex - 1;
		if modeIndex < 0 then modeIndex = 0 end;

		mdl:SetModel(modelbykey(modeIndex))
		if modeIndex <= 0 then
			RunConsoleCommand("excl","deactivate","model");
		else
			RunConsoleCommand("excl","activate",models[modeIndex],"model");
		end
	end

	local butNext = vgui.Create("esIconButton",pnlmdl)
	butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
	butNext:SetSize(32,32);
	butNext:SetPos(pnlmdl:GetWide()-32-10,15);
	butNext.DoClick = function(self)
		if CurTime() < nextPress then return end
		nextPress = CurTime()+.7;
		page = page + 1;
		if modeIndex > #models then modeIndex = #models end;

		mdl:SetModel(modelbykey(modeIndex))
		RunConsoleCommand("excl","activate",models[modeIndex],"model");
	end
	
--## Auras
	local invAuras = vgui.Create("ES.InventoryPanel",p);
	invAuras:SetSize(p:GetWide()-30-230,invTall);
	invAuras.title = "Auras";
	invAuras:SetPos(10,10);
	invAuras.rm.typ = "aura";

	local iconAura = invAuras.PanelCurrent:Add("DImage");

	local y = 0;
	local x = 0;
	for k,v in pairs(LocalPlayer()._es_inventory_auras or {}) do
		if not ES.ValidItem(v,ES.ITEM_AURA) then continue end
			
		local ic = invAuras.PanelInventory:Add("esMMAuraInventoryTile");
		ic:SetPos(x*100,y*100);
		ic:SetSize(100,100);
		ic.item = v;
		ic.icon:SetMaterial(ES.Auras[v].text);
		ic.text = ES.Auras[v].name
		ic.OnMouseReleased = function()
			iconAura:SetMaterial(ES.Auras[v].text);
			iconAura:SetVisible(true);
			invAuras.rm:SetVisible(true);
				
			LocalPlayer().excl.activeaura = v;
			RunConsoleCommand("excl","activate",v,"aura");
		end

		table.insert(invAuras.PanelInventory.items,ic);

		y = y + 1;
		if y >= 2 then
			y = 0;
			x = x + 1;
		end
	end
	iconAura:SetSize(90,90);
	iconAura:SetPos(5,5);
	
--## Trails
	local invTrails = vgui.Create("ES.InventoryPanel",p);
	invTrails:SetSize(p:GetWide()-30-230,invTall);
	invTrails.title = "Trails";
	invTrails:SetPos(10,invAuras.y + invTall + 10);
	invTrails.rm.typ = "trail";

	local iconTrail = invTrails.PanelCurrent:Add("DImage");

		local y = 0;
		local x = 0;
		for k,v in pairs(LocalPlayer()._es_inventory_trails or {})do
			if not ES.ValidItem(v,ES.ITEM_TRAIL) then continue end
			
			local ic = invTrails.PanelInventory:Add("esMMTrailInventoryTile");
			ic:SetPos(x*100,y*100);
			ic:SetSize(100,100);
			ic.item = v;
			ic.icon:SetImage(ES.Trails[v].text);
			ic.text = ES.Trails[v].name
			ic.OnMouseReleased = function()
				iconTrail:SetImage(ES.Trails[v].text);
				iconTrail:SetVisible(true);
				invTrails.rm:SetVisible(true);

				RunConsoleCommand("excl","activate",v,"trail");
			end

			table.insert(invTrails.PanelInventory.items,ic);

			y = y + 1;
			if y >= 2 then
				y = 0;
				x = x + 1;
			end
		end
	iconTrail:SetSize(90,90);
	iconTrail:SetPos(5,5);

	if activeTrail then
		iconTrail:SetImage(activeTrail.text);
		invTrails.rm:SetVisible(true);
	end

--## Melee weapons
	local invMelee = vgui.Create("ES.InventoryPanel",p);
	invMelee:SetSize(p:GetWide()-30-230,invTall);
	invMelee.title = "Melee";
	invMelee:SetPos(10,invTrails.y + invTall + 10);
	invMelee.rm.typ = "melee";

	local iconMelee = invMelee.PanelCurrent:Add("Spawnicon");

		local y = 0;
		local x = 0;
		for k,v in pairs(LocalPlayer()._es_inventory_meleeweapons or {})do
			if not ES.ValidItem(v,ES.ITEM_MELEE) then continue end
			
			local ic = invMelee.PanelInventory:Add("esMMMeleeInventoryTile");
			ic:SetPos(x*100,y*100);
			ic:SetSize(100,100);
			ic.item = v;
			ic.icon:SetModel(ES.MeleeWeapons[v].model);
			ic.text = ES.MeleeWeapons[v].name
			ic.OnMouseReleased = function()
				iconMelee:SetModel(ES.MeleeWeapons[v].model);
				iconMelee:SetVisible(true);
				invMelee.rm:SetVisible(true);
				
				RunConsoleCommand("excl","activate",v,"melee");
			end

			table.insert(invMelee.PanelInventory.items,ic);

			y = y + 1;
			if y >= 2 then
				y = 0;
				x = x + 1;
			end
		end
	iconMelee:SetSize(90,90);
	iconMelee:SetPos(5,5);

	if activeMelee then
		iconMelee:SetModel(activeMelee.model);
		invMelee.rm:SetVisible(true);
	else
		iconMelee:SetVisible(false);
	end
end