function ES._MMGenerateInventoryEffects(base)
	local ply 				= LocalPlayer();
	local p 				= base:OpenFrame()

	local activeTrail 		= ES.Trails[ply:ESGetNetworkedVariable("active_trail")];
	local activeModel 		= ES.Models[ply:ESGetNetworkedVariable("active_model")];
	local activeAura 		= ES.Auras[ply:ESGetNetworkedVariable("active_aura")];
	local activeMeleeWeapon = ES.MeleeWeapons[ply:ESGetNetworkedVariable("active_meleeweapon")];

	local invTall = (p:GetTall()-10*4)/3
	local invWide = (p:GetWide()-30-230);

	local iconMargin = 4;
	local iconSize = 110;--with and height.

	local iconsPerRow = math.floor( invWide / (iconSize + iconMargin*2) ); -- the amount of icons per row, width divided by size+margins*2.

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
		nextPress = CurTime()+.2;
		modeIndex = modeIndex - 1;
		if modeIndex < 0 then modeIndex = 0 end;

		mdl:SetModel(modelbykey(modeIndex))
		if modeIndex <= 0 then
			net.Start("ESDeactivateItem");
			net.WriteUInt(ES.ITEM_MODEL,4);
			net.SendToServer();
		else
			net.Start("ESActivateItem");
			net.WriteUInt(ES.ITEM_MODEL,4);
			net.WriteUInt(modelIndex,8);
			net.SendToServer();
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
	invAuras:SetSize(invWide,invTall);
	invAuras.title = "Auras";
	invAuras:SetPos(10,10);
	invAuras.rm.typ = "aura";

	local iconAura = invAuras.PanelCurrent:Add("DImage");

	local y = 0;
	local x = 0;
	for k,v in pairs(LocalPlayer()._es_inventory_auras or {}) do
		if not ES.ValidItem(v,ES.ITEM_AURA) then
			continue
		end

		local item=ES.Auras[v];
			
		local ic = invAuras.PanelInventory:Add("ES.ItemTile.Texture");
		ic:SetSize(iconSize,iconSize);
		ic:SetPos(iconMargin+x*(iconSize+iconMargin),iconMargin+y*(iconSize+iconMargin));
		ic:Setup(item);
		ic:SetType(ES.ITEM_AURA);
		ic:SetText(item:GetName());
		ic.OnMouseReleased = function()
			if not item then return end

			iconAura:SetMaterial(item:GetModel());
			iconAura:SetVisible(true);
			invAuras.rm:SetVisible(true);
				
			net.Start("ESActivateItem");
			net.WriteUInt(ES.ITEM_AURA,4);
			net.WriteUInt(item:GetKey(),8);
			net.SendToServer();
		end

		invAuras:IncludeIcon(ic);

		x = x + 1;
		if x > iconsPerRow-1 then
			x=0;
			y=y+1;
		end
	end
	iconAura:SetSize(90,90);
	iconAura:SetPos(5,5);
	
--## Trails
	local invTrails = vgui.Create("ES.InventoryPanel",p);
	invTrails:SetSize(invWide,invTall);
	invTrails.title = "Trails";
	invTrails:SetPos(10,invAuras.y + invTall + 10);
	invTrails.rm.typ = "trail";

	local iconTrail = invTrails.PanelCurrent:Add("DImage");

		local y = 0;
		local x = 0;
		for k,v in pairs(LocalPlayer()._es_inventory_trails or {})do
			if not ES.ValidItem(v,ES.ITEM_TRAIL) then continue end
			
			local item=ES.Trails[v];

			local ic = invTrails.PanelInventory:Add("ES.ItemTile.Texture");
			ic:SetSize(iconSize,iconSize);
			ic:SetPos(iconMargin+x*(iconSize+iconMargin),iconMargin+y*(iconSize+iconMargin));
			ic:Setup(item);
			ic:SetType(ES.ITEM_TRAIL);
			ic:SetText(item:GetName());
			ic.OnMouseReleased = function()
				if not item then return end

				iconTrail:SetImage(item:GetModel());
				iconTrail:SetVisible(true);
				invTrails.rm:SetVisible(true);


				print("Item selected: "..tostring(item:GetKey()));

				net.Start("ESActivateItem");
				net.WriteUInt(ES.ITEM_TRAIL,4);
				net.WriteUInt(item:GetKey(),8);
				net.SendToServer();
			end

			invTrails:IncludeIcon(ic);

			x = x + 1;
			if x > iconsPerRow-1 then
				x=0;
				y=y+1;
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
	invMelee:SetSize(invWide,invTall);
	invMelee.title = "Melee";
	invMelee:SetPos(10,invTrails.y + invTall + 10);
	invMelee.rm.typ = "melee";

	local iconMelee = invMelee.PanelCurrent:Add("Spawnicon");

		local y = 0;
		local x = 0;
		for k,v in pairs(LocalPlayer()._es_inventory_meleeweapons or {})do
			if not ES.ValidItem(v,ES.ITEM_MELEE) then continue end
			
			local item=ES.MeleeWeapons[v];

			local ic = invMelee.PanelInventory:Add("ES.ItemTile.Model");
			ic:SetSize(iconSize,iconSize);
			ic:SetPos(iconMargin+x*(iconSize+iconMargin),iconMargin+y*(iconSize+iconMargin));
			ic:Setup(item);
			ic:SetType(ES.ITEM_MELEE);
			ic:SetText(item:GetName());
			ic.OnMouseReleased = function()
				if not item then return end

				iconMelee:SetModel(item:GetModel());
				iconMelee:SetVisible(true);
				invMelee.rm:SetVisible(true);
				
				net.Start("ESActivateItem");
				net.WriteUInt(ES.ITEM_MELEE,4);
				net.WriteUInt(item:GetKey(),8);
				net.SendToServer();
			end

			invMelee:IncludeIcon(ic);

			x = x + 1;
			if x > iconsPerRow-1 then
				x=0;
				y=y+1;
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