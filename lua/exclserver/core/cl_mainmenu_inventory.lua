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
	local modelIndex = 0;

	local models = LocalPlayer()._es_inventory_models or {};
	local function modelbykey(k)
		if k < 1 then
			return table.Random(ES.DefaultModels);
		else
			return ES.Models[ models[k] ]:GetModel();
		end
	end

	local timeAnimate = CurTime();
	function mdl:Think()
		if timeAnimate + 2 > CurTime() then return end
		timeAnimate = CurTime();

		mdl:SetModel(modelbykey(modelIndex))
	end

	mdl:SetModel(modelbykey(modelIndex))

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
		modelIndex = modelIndex - 1;
		if modelIndex < 0 then modelIndex = 0; return end;

		mdl:SetModel(modelbykey(modelIndex))
		if modelIndex <= 0 then
			net.Start("ESDeactivateItem");
			net.WriteUInt(ES.ITEM_MODEL,4);
			net.SendToServer();
		else
			net.Start("ESActivateItem");
			net.WriteUInt(ES.ITEM_MODEL,4);
			net.WriteUInt(ES.Models[ models[modelIndex] ]:GetKey(),8);
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
		modelIndex = modelIndex + 1;
		if modelIndex > #models then modelIndex = #models; return end;

		mdl:SetModel(modelbykey(modelIndex))

		net.Start("ESActivateItem");
		net.WriteUInt(ES.ITEM_MODEL,4);
		net.WriteUInt(ES.Models[ models[modelIndex] ]:GetKey(),8);
		net.SendToServer();
	end

	if activeModel then
		for k,v in pairs(models)do
			if activeModel:GetName() == v then
				mdl:SetModel(activeModel:GetModel());
				modelIndex=k;
				break;
			end
		end
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
	iconAura:Dock(FILL);

	if activeAura then
		iconAura:SetImage(activeAura:GetModel());
		invAuras.rm:SetVisible(true);
	end
	
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
	iconTrail:Dock(FILL);

	if activeTrail then
		iconTrail:SetImage(activeTrail:GetModel());
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
	iconMelee:Dock(FILL);

	if activeMeleeWeapon then
		iconMelee:SetModel(activeMeleeWeapon:GetModel());
		invMelee.rm:SetVisible(true);
	else
		iconMelee:SetVisible(false)
	end
end

local color_background_faded=Color(0,0,0,150)
function ES._MMGenerateInventoryOutfit(base)
	local p = base:OpenFrame(); 
	p:SetTitle("Outfit");

	local openEditor; -- prototype	

	local inv=LocalPlayer()._es_inventory_props and table.Copy(LocalPlayer()._es_inventory_props) or {};

	local slots={};

	local tab = vgui.Create("Panel",p);	
	tab:SetPos(1,p:GetTall()-64-1);	
	tab:SetSize(p:GetWide(),64)	
	tab.Paint = function(self,w,h)	
		draw.RoundedBox(0,0,0,w,h,color_background_faded);
	
		--draw.SimpleText("Slots","ES.MainMenu.MainElementInfoBnns",64*6.3,h/2,Color(170,170,170),0,1);	
	end

	local slotSelected = 1;					
	for i=1,2+LocalPlayer():ESGetVIPTier() do	
		local tab = vgui.Create("Panel",p);	
		tab:SetPos(-63 + i*64,p:GetTall()-65);	
		tab:SetSize(64,64)	
		tab.OnCursorEntered = function(self) self.Hover = true end; tab.OnCursorExited = function(self) self.Hover = false end;	
		tab.Paint = function(self,w,h)	
			if slotSelected != i then	
				draw.RoundedBox(0,1,1,w-2,h-1,self.Hover and ES.GetColorScheme(3) or Color(255,255,255,1));	
			else	
				draw.RoundedBox(0,0,0,w,h,ES.Color["#1E1E1E"]);	
			end	
			draw.SimpleText(i,"ES.MainMenu.MainElementInfoBnns",w/2,h/2,(slotSelected == i or self.Hover) and COLOR_WHITE or Color(255,255,255,50),1,1);	
		end	
		tab.OnMouseReleased = function()	
			if i > 2+LocalPlayer():ESGetVIPTier() then	
				return;	
			end	
			slotSelected = i;	
			openEditor(i);	
		end	
	end

	local editor;	
	openEditor = function(slot)
		if editor and IsValid(editor) then editor:Remove() end	
		editor = vgui.Create("Panel",p);	
		editor:SetPos(0,0);	
		editor:SetSize(p:GetWide(),p:GetTall()-65);	
	
		local itemSelected;	
		local createIcons; -- prototype	

		local right=editor:Add("Panel");
		right:SetWide(105*3 + 20);
		right:Dock(RIGHT);

			local btnSave = right:Add("esButton");	
			btnSave:SetText("Save changes made to this slot");	
			btnSave:SetTall(32);	
			btnSave.DoClick = function()	
				if slots[slot] and slots[slot].item then	
					RunConsoleCommand("es_outfit_customize",slot,slots[slot].item,tostring(slots[slot].pos),tostring(slots[slot].ang),tostring(slots[slot].scale),slots[slot].bone,slots[slot].color.r.." "..slots[slot].color.g.." "..slots[slot].color.b);	
				else	
					RunConsoleCommand("es_outfit_customize",slot);	
				end	
			end
			btnSave:Dock(BOTTOM);
			btnSave:DockMargin(10,0,10,10);

			local invpnl = right:Add("esPanel");	
			invpnl:DockMargin(10,10,10,10);
			invpnl:Dock(FILL);

				local eqpnl = invpnl:Add("Panel");	
				eqpnl:SetTall(100);	
				eqpnl:Dock(TOP);

					local itemname = Label("No item selected",eqpnl);	
					itemname:SetPos(105,10);	
					itemname:SetFont("ES.MainMenu.HeadingText");	
					itemname:SetColor(COLOR_WHITE);	
					itemname:SizeToContents();	
					local spicon = invpnl:Add("Spawnicon");	
					spicon:SetSize(98,98);	
					spicon:SetPos(1,1);	
					spicon:SetVisible(false);	
					local rm = vgui.Create("esIconButton",eqpnl)	
					rm:SetIcon(Material("icon16/cancel.png"));	
					rm:SetSize(16,16);	
					rm:SetPos(100-16-5,5)	
					rm.DoClick = function()	
						spicon:SetVisible(false);	
						rm:SetVisible(false);	
						itemname:SetText("No item selected");	
						itemname:SizeToContents()	
						inv[itemSelected] = inv[itemSelected] and inv[itemSelected] + 1 or 1;	
						slots[slot] = {};	
						openEditor(slot);	
					end	
					spicon.OnMouseReleased = rm.DoClick	
					rm:SetVisible(false);	
					local boneSelected = slots[slot] and slots[slot].bone or "ValveBiped.Bip01_Head1";	
					local DComboBox = vgui.Create( "DComboBox",eqpnl )	
					DComboBox:SetPos( 105,eqpnl:GetTall()-10-20 )	
					DComboBox:SetSize( eqpnl:GetWide()-105-10, 20 )	
					DComboBox:SetValue( boneSelected )	
					for k,v in pairs(ES.PropBones)do	
						DComboBox:AddChoice( v )	
					end	
					DComboBox.OnSelect = function( panel, index, value, data )	
						boneSelected = value;	
						mdl:SetFocus(boneSelected);
				
						if slots[slot] and slots[slot].item then	
							slots[slot].bone = boneSelected;	
						end	
					end	

				local navpnl=invpnl:Add("Panel");
				navpnl:SetTall(64);
				navpnl:Dock(BOTTOM);

					local lblPage;	
					local page=1;	
					local perPage = math.floor((invpnl:GetTall()-100-64)/105)*3;	
					local maxPages = math.ceil(table.Count(inv)/perPage);	

					local butPrev = vgui.Create("esIconButton",navpnl)	
					butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));	
					butPrev:SetSize(32,32);	
					butPrev:SetPos(16,16);	
					butPrev.DoClick = function(self)	
						page = page - 1;	
						if page < 1 then page = 1 end;
				
						createIcons();

						lblPage:SetText("Page "..page.."/"..maxPages)	
						lblPage:SizeToContents();	
					end	
					butPrev:SetRotation(180);
					butPrev:DockMargin(16,16,16,16);

					local butNext = vgui.Create("esIconButton",navpnl)	
					butNext:SetIcon(Material("exclserver/mmarrowicon.png"));	
					butNext:SetSize(32,32);	
					butNext:SetPos(16+32+16,16);	
					butNext.DoClick = function(self)	
						page = page + 1;	
						if page > maxPages then page = maxPages end;
				
						createIcons();	
						lblPage:SetText("Page "..page.."/"..maxPages)	
						lblPage:SizeToContents();	
					end	

					lblPage = Label("Page 1/"..maxPages,navpnl);	
					lblPage:SetFont("ES.MainMenu.HeadingText");	
					lblPage:SetPos(16+32*2+16*2,16);	
					lblPage:SizeToContents();	
					lblPage:SetColor(COLOR_WHITE);	

				local containerpnl=invpnl:Add("esPanel");
				containerpnl:Dock(FILL);
				containerpnl:SetColor(ES.Color["#00000033"])

				local icons = {};	
				createIcons = function()	
					for k,v in pairs(icons)do	
						if v and IsValid(v) then	
							v:Remove();	
						end	
					end	
					icons = {};
			
					local count_all = 0;	
					local count = 0;	
					local curRow = 0;	
					local curNum = 0;	
					for k,v in pairs(inv or {})do		
						if true then continue end
						-- EDIT ME
						-- EDIT ME 
			
						count_all = count_all + 1;	
						if count >= perPage  or count_all < (page-1) * perPage then	
							continue;	
						end	
						if not first then first = k end	
						local icon = vgui.Create("esMMItemBuyTile",containerpnl);
			
						curNum = curNum + 1;
			
						if curNum > 3 then	
							curRow = curRow + 1;	
							curNum = 1;	
						end
			
						local it = ES.Items[k];	
						if not it then continue end	
						icon:SetSize(105,105);	
						icon:SetPos((curNum-1)*105,100 + curRow*105);	
						icon:PerformLayout();	
						icon.icon:SetModel(it.model);	
						icon.text = it.name;	
						icon.item = it.id;	
						icon.OnMouseReleased = function()	
							itemname:SetText(it.name);	
							itemname:SizeToContents();	
							rm:SetVisible(true);	
							spicon:SetModel(it.model);	
							spicon:SetVisible(true);	
							if itemSelected and ES.Items[itemSelected] then	
								inv[itemSelected] = inv[itemSelected] + 1;	
							end	
							itemSelected = k;	
							inv[k] = inv[k] - 1;	
							createIcons();
			
							if slots[slot] and slots[slot].item then	
								slots[slot].item = k;	
								slots[slot].scale = Vector(0,0,0);	
							else	
								slots[slot] = {};	
								slots[slot].item = k;	
								slots[slot].bone = boneSelected;	
								slots[slot].pos = Vector(0,0,0);	
								slots[slot].ang = Angle(0,0,0);	
								slots[slot].scale = Vector(0,0,0);	
								slots[slot].color = Color(255,255,255);	
							end	
						end	
						count = count + 1;	
						table.insert(icons,icon);	
					end						
				end	
				createIcons();
			
		local left=editor:Add("Panel");
		left:Dock(FILL);

			local pnlpreview=left:Add("Panel");
			pnlpreview:Dock(FILL);
			pnlpreview:DockMargin(10,10,0,0);

				local sizePreview = p:GetWide() - 10 - invpnl:GetWide();	
				if sizePreview > editor:GetTall()-10-32-10-170 then	
					sizePreview = editor:GetTall()-10-32-10-172; 	
				end	

				local mdl = pnlpreview:Add("esMMHatPreview");
				mdl:Dock(FILL);
				mdl:DockMargin(0,0,0,0);
				mdl:SetModel(LocalPlayer():ESGetActiveModel());	
				mdl:SetLookAt(Vector(0,0,0));	
				mdl:SetCamPos(Vector(10,10,10));	
				mdl:SetFocus(boneSelected);	
				mdl.slots = slots;
			
				local zoommin = pnlpreview:Add("esIconButton")	
				zoommin:SetIcon(Material("icon16/zoom_out.png"));	
				zoommin:SetSize(16,16);	
				zoommin:SetPos(pnlpreview:GetWide()-16-10,10);	
				zoommin.DoClick = function(self)	
					mdl.zoom = mdl.zoom + 8;	
					mdl:SetFocus(boneSelected);	
				end	
				local zoommore = pnlpreview:Add("esIconButton")	
				zoommore:SetIcon(Material("icon16/zoom_in.png"));	
				zoommore:SetSize(16,16);	
				zoommore:SetPos(zoommin.x - 8 - 16,zoommin.y);	
				zoommore.DoClick = function(self)	
					mdl.zoom = mdl.zoom - 8;	
					mdl:SetFocus(boneSelected);	
				end
			
				local rotmin = pnlpreview:Add("esIconButton")	
				rotmin:SetIcon(Material("icon16/arrow_rotate_clockwise.png"));	
				rotmin:SetSize(16,16);	
				rotmin:SetPos(zoommin.x,zoommin.y + 16+8);	
				rotmin.DoClick = function(self)	
					mdl.rotate = mdl.rotate + 1;	
					mdl:SetFocus(boneSelected);	
				end	
				local rotmore = pnlpreview:Add("esIconButton")	
				rotmore:SetIcon(Material("icon16/arrow_rotate_anticlockwise.png"));	
				rotmore:SetSize(16,16);	
				rotmore:SetPos(rotmin.x - 8 - 16,rotmin.y);	
				rotmore.DoClick = function(self)	
					mdl.rotate = mdl.rotate - 1;	
					mdl:SetFocus(boneSelected);	
				end
			
			local tabpnl = left:Add("esTabPanel");	
			tabpnl:SetTall(170);	
			tabpnl:Dock(BOTTOM);
			tabpnl:DockMargin(10,0,0,10);	
				local pnl = tabpnl:AddTab("Position","exclserver/tabs/generic.png");	
					local slideX = pnl:Add("esSlider");	
					slideX:SetPos(10,10);	
					slideX:SetSize(pnl:GetWide() - 20,30);	
					slideX.text = "X";	
					slideX.min = -8;	
					slideX.max = 8;	
					slideX:SetValue(slots[slot] and slots[slot].pos and slots[slot].pos.x or 0);	
					slideX.Think = function(self) if slots[slot] and slots[slot].pos then	
						slots[slot].pos.x = self:GetValue();	
					end end	
					local slideY = pnl:Add("esSlider");	
					slideY:SetPos(10,50);	
					slideY:SetSize(pnl:GetWide() - 20,30);	
					slideY.text = "Y";	
					slideY.min = -8;	
					slideY.max = 8;	
					slideY:SetValue(slots[slot] and slots[slot].pos and slots[slot].pos.y or 0);	
					slideY.Think = function(self) if slots[slot] and slots[slot].pos then	
						slots[slot].pos.y = self:GetValue();	
					end end	
					local slideZ = pnl:Add("esSlider");	
					slideZ:SetPos(10,90);	
					slideZ:SetSize(pnl:GetWide() - 20,30);	
					slideZ.text = "Z";	
					slideZ.min = -8;	
					slideZ.max = 8;	
					slideZ:SetValue(slots[slot] and slots[slot].pos and slots[slot].pos.z or 0);	
					slideZ.Think = function(self) if slots[slot] and slots[slot].pos then	
						slots[slot].pos.z = self:GetValue();	
					end end
			
				local pnl = tabpnl:AddTab("Angles","exclserver/tabs/generic.png");	
					local slideP = pnl:Add("esSlider");	
					slideP:SetPos(10,10);	
					slideP:SetSize(pnl:GetWide() - 20,30);	
					slideP.text = "Pitch";	
					slideP.min = -180;	
					slideP.max = 180;	
					slideP:SetValue(slots[slot] and slots[slot].ang and slots[slot].ang.p or 0);	
					slideP.Think = function(self) if slots[slot] and slots[slot].ang then	
						slots[slot].ang.p = self:GetValue();	
					end end	
					local slideYa = pnl:Add("esSlider");	
					slideYa:SetPos(10,50);	
					slideYa:SetSize(pnl:GetWide() - 20,30);	
					slideYa.text = "Yaw";	
					slideYa.min = -180;	
					slideYa.max = 180;	
					slideYa:SetValue(slots[slot] and slots[slot].ang and slots[slot].ang.y or 0);	
					slideYa.Think = function(self) if slots[slot] and slots[slot].ang then	
						slots[slot].ang.y = self:GetValue();	
					end end	
					local slideR = pnl:Add("esSlider");	
					slideR:SetPos(10,90);	
					slideR:SetSize(pnl:GetWide() - 20,30);	
					slideR.text = "Roll";	
					slideR.min = -180;	
					slideR.max = 180;	
					slideR:SetValue(slots[slot] and slots[slot].ang and slots[slot].ang.r or 0);	
					slideR.Think = function(self) if slots[slot] and slots[slot].ang then	
						slots[slot].ang.r = self:GetValue();	
					end end
			
				local pnl = tabpnl:AddTab("Scale","exclserver/tabs/generic.png");	
					local slideSX = pnl:Add("esSlider");	
					slideSX:SetPos(10,10);	
					slideSX:SetSize(pnl:GetWide() - 20,30);	
					slideSX.text = "X";	
					slideSX.min = -.3;	
					slideSX.max = .3;	
					slideSX:SetValue(slots[slot] and slots[slot].scale and slots[slot].scale.x or 0);	
					slideSX.Think = function(self) if slots[slot] and slots[slot].scale then	
						slots[slot].scale.x = self:GetValue();	
					end end	
					local slideSY = pnl:Add("esSlider");	
					slideSY:SetPos(10,50);	
					slideSY:SetSize(pnl:GetWide() - 20,30);	
					slideSY.text = "Y";	
					slideSY.min = -.3;	
					slideSY.max = .3;	
					slideSY:SetValue(slots[slot] and slots[slot].scale and slots[slot].scale.y or 0);	
					slideSY.Think = function(self) if slots[slot] and slots[slot].scale then	
						slots[slot].scale.y = self:GetValue();	
					end end	
					local slideSZ = pnl:Add("esSlider");	
					slideSZ:SetPos(10,90);	
					slideSZ:SetSize(pnl:GetWide() - 20,30);	
					slideSZ.text = "Z";	
					slideSZ.min = -.3;	
					slideSZ.max = .3;	
					slideSZ:SetValue(slots[slot] and slots[slot].scale and slots[slot].scale.z or 0);	
					slideSZ.Think = function(self) if slots[slot] and slots[slot].scale then	
						slots[slot].scale.z = self:GetValue();	
					end end
			
				local pnl = tabpnl:AddTab("Color","exclserver/tabs/generic.png");	
					local cube = pnl:Add("DColorMixer");	
					cube:SetPos(2,2);	
					cube:SetSize(256,200);	
					cube:SetLabel("")	
					cube:SetColor(Color(255,255,255));	
					function cube:ValueChanged()	
						--ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())	
					end
		
		
	
		if slots[slot] and slots[slot].item and ES.Items[slots[slot].item] then	
			local it = ES.Items[slots[slot].item];	
			itemname:SetText(it.name);	
			itemname:SizeToContents();	
			itemSelected = it.id;	
			rm:SetVisible(true);	
			spicon:SetModel(it.model);	
			spicon:SetVisible(true);	
		end	
	end	
	openEditor(1);
end