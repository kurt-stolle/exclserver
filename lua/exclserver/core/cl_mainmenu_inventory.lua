function ES._MMGenerateInventoryEffects(base)
	local ply 				= LocalPlayer()
	local p 				= base:OpenFrame()

	local activeTrail 		= ES.Trails[ply:ESGetNetworkedVariable("active_trail")]
	local activeModel 		= ES.Models[ply:ESGetNetworkedVariable("active_model")]
	local activeAura 		= ES.Auras[ply:ESGetNetworkedVariable("active_aura")]
	local activeMeleeWeapon = ES.MeleeWeapons[ply:ESGetNetworkedVariable("active_meleeweapon")]

	local invTall = (p:GetTall()-10*4)/3
	local invWide = (p:GetWide()-30-230)

	local iconMargin = 4
	local iconSize = 110--with and height.

	local iconsPerRow = math.floor( invWide / (iconSize + iconMargin*2) ) -- the amount of icons per row, width divided by size+margins*2.

	p:SetTitle("Effects")

--## Models
	local mdl = p:Add("ES.PlayerModel")
	--mdl.useCurrentHat = true
	mdl:SetSize(500,500)
	mdl:SetModel(LocalPlayer():ESGetActiveModel())
	mdl:SetPos(p:GetWide()-380,p:GetTall()-501)
	mdl:SetLookAt(Vector(0,0,62))
	mdl:SetCamPos(Vector(38,18,64))
	mdl:SetUseOutfit(true)
	mdl.Slots=LocalPlayer()._es_outfit or {}

	local nextPress = CurTime()+.5
	local modelIndex = 0

	local models = LocalPlayer()._es_inventory_models or {}
	local function modelbykey(k)
		if k < 1 then
			return table.Random(ES.DefaultModels)
		else
			return ES.Models[ models[k] ]:GetModel()
		end
	end

	local timeAnimate = CurTime()
	function mdl:Think()
		if timeAnimate + 2 > CurTime() then return end
		timeAnimate = CurTime()

		mdl:SetModel(modelbykey(modelIndex))
	end

	mdl:SetModel(modelbykey(modelIndex))

	local pnlmdl = p:Add("Panel")
	function pnlmdl:Paint(w,h)
		surface.SetDrawColor(ES.GetColorScheme(2))
		surface.DrawRect(0,0,w,h)
		draw.SimpleText("Model","esMMInventoryTitle",10,10,COLOR_WHITE)
		if activeModel then
			draw.SimpleText(activeModel:GetName(),"ESDefaultBold",15,h-30,COLOR_WHITE)
			return
		end

		draw.SimpleText("Random citizen","ESDefaultBold",15,h-30,COLOR_WHITE)

	end
	pnlmdl:SetSize(p:GetWide() - 30 - 10 - (p:GetWide()-30-230),64 + 5*4)
	pnlmdl:SetPos(p:GetWide()-10-pnlmdl:GetWide(),p:GetTall()-pnlmdl:GetTall()-10)
	mdl.y = pnlmdl.y-500

	local butPrev = vgui.Create("esIconButton",pnlmdl)
	butPrev:SetIcon(Material("exclserver/mmarrowicon.png"))
	butPrev:SetSize(32,32)
	butPrev:SetPos(pnlmdl:GetWide()-32-10-32-9,15)
	butPrev:SetRotation(180)
	butPrev.DoClick = function(self)
		if CurTime() < nextPress then return end
		nextPress = CurTime()+.2
		modelIndex = modelIndex - 1
		if modelIndex < 0 then modelIndex = 0 return end

		mdl:SetModel(modelbykey(modelIndex))
		if modelIndex <= 0 then
			net.Start("ESDeactivateItem")
			net.WriteUInt(ES.ITEM_MODEL,4)
			net.SendToServer()
		else
			net.Start("ESActivateItem")
			net.WriteUInt(ES.ITEM_MODEL,4)
			net.WriteUInt(ES.Models[ models[modelIndex] ]:GetKey(),8)
			net.SendToServer()
		end
	end

	local butNext = vgui.Create("esIconButton",pnlmdl)
	butNext:SetIcon(Material("exclserver/mmarrowicon.png"))
	butNext:SetSize(32,32)
	butNext:SetPos(pnlmdl:GetWide()-32-10,15)
	butNext.DoClick = function(self)
		if CurTime() < nextPress then return end
		nextPress = CurTime()+.7
		modelIndex = modelIndex + 1
		if modelIndex > #models then modelIndex = #models return end

		mdl:SetModel(modelbykey(modelIndex))

		net.Start("ESActivateItem")
		net.WriteUInt(ES.ITEM_MODEL,4)
		net.WriteUInt(ES.Models[ models[modelIndex] ]:GetKey(),8)
		net.SendToServer()
	end

	if activeModel then
		for k,v in pairs(models)do
			if activeModel:GetName() == v then
				mdl:SetModel(activeModel:GetModel())
				modelIndex=k
				break
			end
		end
	end

--## Auras
	local invAuras = vgui.Create("ES.InventoryPanel",p)
	invAuras:SetSize(invWide,invTall)
	invAuras.title = "Auras"
	invAuras:SetPos(10,10)
	invAuras.rm.typ = "aura"

	local iconAura = invAuras.PanelCurrent:Add("DImage")

	local y = 0
	local x = 0
	for k,v in pairs(LocalPlayer()._es_inventory_auras or {}) do
		if not ES.ValidItem(v,ES.ITEM_AURA) then
			continue
		end

		local item=ES.Auras[v]

		local ic = invAuras.PanelInventory:Add("ES.ItemTile.Texture")
		ic:SetSize(iconSize,iconSize)
		ic:SetPos(iconMargin+x*(iconSize+iconMargin),iconMargin+y*(iconSize+iconMargin))
		ic:Setup(item)
		ic:SetType(ES.ITEM_AURA)
		ic:SetText(item:GetName())
		ic.OnMouseReleased = function()
			if not item then return end

			iconAura:SetMaterial(item:GetModel())
			iconAura:SetVisible(true)
			invAuras.rm:SetVisible(true)

			net.Start("ESActivateItem")
			net.WriteUInt(ES.ITEM_AURA,4)
			net.WriteUInt(item:GetKey(),8)
			net.SendToServer()
		end

		invAuras:IncludeIcon(ic)

		x = x + 1
		if x > iconsPerRow-1 then
			x=0
			y=y+1
		end
	end
	iconAura:Dock(FILL)

	if activeAura then
		iconAura:SetImage(activeAura:GetModel())
		invAuras.rm:SetVisible(true)
	end

--## Trails
	local invTrails = vgui.Create("ES.InventoryPanel",p)
	invTrails:SetSize(invWide,invTall)
	invTrails.title = "Trails"
	invTrails:SetPos(10,invAuras.y + invTall + 10)
	invTrails.rm.typ = "trail"

	local iconTrail = invTrails.PanelCurrent:Add("DImage")

		local y = 0
		local x = 0
		for k,v in pairs(LocalPlayer()._es_inventory_trails or {})do
			if not ES.ValidItem(v,ES.ITEM_TRAIL) then continue end

			local item=ES.Trails[v]

			local ic = invTrails.PanelInventory:Add("ES.ItemTile.Texture")
			ic:SetSize(iconSize,iconSize)
			ic:SetPos(iconMargin+x*(iconSize+iconMargin),iconMargin+y*(iconSize+iconMargin))
			ic:Setup(item)
			ic:SetType(ES.ITEM_TRAIL)
			ic:SetText(item:GetName())
			ic.OnMouseReleased = function()
				if not item then return end

				iconTrail:SetImage(item:GetModel())
				iconTrail:SetVisible(true)
				invTrails.rm:SetVisible(true)


				print("Item selected: "..tostring(item:GetKey()))

				net.Start("ESActivateItem")
				net.WriteUInt(ES.ITEM_TRAIL,4)
				net.WriteUInt(item:GetKey(),8)
				net.SendToServer()
			end

			invTrails:IncludeIcon(ic)

			x = x + 1
			if x > iconsPerRow-1 then
				x=0
				y=y+1
			end
		end
	iconTrail:Dock(FILL)

	if activeTrail then
		iconTrail:SetImage(activeTrail:GetModel())
		invTrails.rm:SetVisible(true)
	end

--## Melee weapons
	local invMelee = vgui.Create("ES.InventoryPanel",p)
	invMelee:SetSize(invWide,invTall)
	invMelee.title = "Melee"
	invMelee:SetPos(10,invTrails.y + invTall + 10)
	invMelee.rm.typ = "melee"

	local iconMelee = invMelee.PanelCurrent:Add("Spawnicon")

		local y = 0
		local x = 0
		for k,v in pairs(LocalPlayer()._es_inventory_meleeweapons or {})do
			if not ES.ValidItem(v,ES.ITEM_MELEE) then continue end

			local item=ES.MeleeWeapons[v]

			local ic = invMelee.PanelInventory:Add("ES.ItemTile.Model")
			ic:SetSize(iconSize,iconSize)
			ic:SetPos(iconMargin+x*(iconSize+iconMargin),iconMargin+y*(iconSize+iconMargin))
			ic:Setup(item)
			ic:SetType(ES.ITEM_MELEE)
			ic:SetText(item:GetName())
			ic.OnMouseReleased = function()
				if not item then return end

				iconMelee:SetModel(item:GetModel())
				iconMelee:SetVisible(true)
				invMelee.rm:SetVisible(true)

				net.Start("ESActivateItem")
				net.WriteUInt(ES.ITEM_MELEE,4)
				net.WriteUInt(item:GetKey(),8)
				net.SendToServer()
			end

			invMelee:IncludeIcon(ic)

			x = x + 1
			if x > iconsPerRow-1 then
				x=0
				y=y+1
			end
		end
	iconMelee:Dock(FILL)

	if activeMeleeWeapon then
		iconMelee:SetModel(activeMeleeWeapon:GetModel())
		invMelee.rm:SetVisible(true)
	else
		iconMelee:SetVisible(false)
	end
end

local boneTranslations={}


local color_background_faded=Color(0,0,0,150)
function ES._MMGenerateInventoryOutfit(base)
	for k,v in pairs(ES.PropBones)do
		boneTranslations[string.gsub(string.gsub(string.gsub(v,"ValveBiped.Bip01_",""),"R_","Right "),"L_","Left ")]=v
	end

	local p = base:OpenFrame()
	p:SetTitle("Outfit")

	local openEditor -- prototype

	local inv=LocalPlayer()._es_inventory_props and table.Copy(LocalPlayer()._es_inventory_props) or {}

	local slots=LocalPlayer()._es_outfit and table.Copy(LocalPlayer()._es_outfit) or {}

	local tab = vgui.Create("Panel",p)
	tab:SetPos(1,p:GetTall()-64-1)
	tab:SetSize(p:GetWide(),64)
	tab.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,color_background_faded)

		--draw.SimpleText("Slots","ES.MainMenu.MainElementInfoBnns",64*6.3,h/2,Color(170,170,170),0,1)
	end

	local slotSelected = 1
	for i=1,2+LocalPlayer():ESGetVIPTier() do
		local tab = vgui.Create("Panel",p)
		tab:SetPos(-63 + i*64,p:GetTall()-65)
		tab:SetSize(64,64)
		tab.OnCursorEntered = function(self) self.Hover = true end tab.OnCursorExited = function(self) self.Hover = false end
		tab.Paint = function(self,w,h)
			if slotSelected ~= i then
				draw.RoundedBox(0,1,1,w-2,h-1,self.Hover and ES.GetColorScheme(3) or Color(150,150,150,1))	
			else
				draw.RoundedBox(0,0,0,w,h,ES.Color["#1E1E1E"])
			end
			draw.SimpleText(i,"ES.MainMenu.MainElementInfoBnns",w/2,h/2,(slotSelected == i or self.Hover) and COLOR_WHITE or Color(255,255,255,50),1,1)
		end
		tab.OnMouseReleased = function()
			if i > 2+LocalPlayer():ESGetVIPTier() then
				return
			end
			slotSelected = i
			openEditor(i)
		end
	end

	local editor
	openEditor = function(slot)
		if editor and IsValid(editor) then editor:Remove() end
		editor = vgui.Create("Panel",p)
		editor:SetPos(0,0)
		editor:SetSize(p:GetWide(),p:GetTall()-65)

		local itemSelected
		local createIcons -- prototype

		local right=editor:Add("Panel")
		right:SetWide(105*3 + 20)
		right:Dock(RIGHT)

			local btnSave = right:Add("esButton")
			btnSave:SetText("Save changes made to this slot")
			btnSave:SetTall(32)
			btnSave.DoClick = function()
				if slots[slot] and slots[slot].item then
					net.Start("ES.Player.UpdateOutfit")
						net.WriteUInt(slot,4)
						net.WriteUInt(ES.Props[slots[slot].item]:GetKey(),8)
						net.WriteVector(slots[slot].pos)
						net.WriteAngle(slots[slot].ang)
						net.WriteVector(slots[slot].scale)
						net.WriteString(slots[slot].color)
						net.WriteString(slots[slot].bone)
					net.SendToServer()
				else
					-- Delete the item
				end
			end
			btnSave:Dock(BOTTOM)
			btnSave:DockMargin(10,0,10,10)

			local mdl

			local invpnl = right:Add("esPanel")
			invpnl:DockMargin(10,10,10,10)
			invpnl:Dock(FILL)

				local eqpnl = invpnl:Add("Panel")
				eqpnl:SetTall(100)
				eqpnl:Dock(TOP)

					local itemname = Label("No item selected",eqpnl)
					itemname:SetPos(105,10)
					itemname:SetFont("ES.MainMenu.HeadingText")
					itemname:SetColor(COLOR_WHITE)
					itemname:SizeToContents()
					local spicon = invpnl:Add("Spawnicon")
					spicon:SetSize(98,98)
					spicon:SetPos(1,1)
					spicon:SetVisible(false)
					local rm = vgui.Create("esIconButton",eqpnl)
					rm:SetIcon(Material("icon16/cancel.png"))
					rm:SetSize(16,16)
					rm:SetPos(100-16-5,5)
					rm.DoClick = function()
						openEditor(slot)
					end
					spicon.OnMouseReleased = rm.DoClick
					rm:SetVisible(false)

					local boneSelected = slots[slot] and slots[slot].bone or boneTranslations["Head1"]
					local DComboBox = vgui.Create( "DComboBox",eqpnl )
					DComboBox:DockMargin(105,5,10,10)
					DComboBox:Dock(BOTTOM)
					DComboBox:SetWide( eqpnl:GetWide()-105-10 )

					for k,v in pairs(boneTranslations)do
						if v==boneSelected then
							DComboBox:SetValue( k )
						end

						DComboBox:AddChoice( k )
					end

					DComboBox.OnSelect = function( panel, index, value, data )
						boneSelected = boneTranslations[value]

						if not boneSelected then return end

						mdl:SetFocus(boneSelected)

						if slots[slot] and slots[slot].item then
							slots[slot].bone = boneSelected
						end
					end

					local lbl=eqpnl:Add("esLabel")
					lbl:SetColor(ES.Color.White)
					lbl:SetFont("ESDefault")
					lbl:SetText("Attach to bone:")
					lbl:SizeToContents()
					lbl:DockMargin(105,10,10,0)
					lbl:Dock(BOTTOM)

				local navpnl=invpnl:Add("Panel")
				navpnl:SetTall(64)
				navpnl:Dock(BOTTOM)

				local page=0
				local perPage = 0
				local maxPages = 0

				local done=false
				function invpnl.PerformLayout(self)
					if done then return end

					done=true

					local lblPage
					page=1
					perPage = math.floor((invpnl:GetTall()-100-64)/105)*3
					maxPages = math.ceil(table.Count(inv)/perPage)

					local butPrev = vgui.Create("esIconButton",navpnl)
					butPrev:SetIcon(Material("exclserver/mmarrowicon.png"))
					butPrev:SetSize(32,32)
					butPrev:SetPos(16,16)
					butPrev.DoClick = function(self)
						page = page - 1
						if page < 1 then page = 1 end

						createIcons()

						lblPage:SetText("Page "..page.."/"..maxPages)
						lblPage:SizeToContents()
					end
					butPrev:SetRotation(180)
					butPrev:DockMargin(16,16,16,16)

					local butNext = vgui.Create("esIconButton",navpnl)
					butNext:SetIcon(Material("exclserver/mmarrowicon.png"))
					butNext:SetSize(32,32)
					butNext:SetPos(16+32+16,16)
					butNext.DoClick = function(self)
						page = page + 1
						if page > maxPages then page = maxPages end

						createIcons()
						lblPage:SetText("Page "..page.."/"..maxPages)
						lblPage:SizeToContents()
					end

					lblPage = Label("Page 1/"..maxPages,navpnl)
					lblPage:SetFont("ES.MainMenu.HeadingText")
					lblPage:SetPos(16+32*2+16*2,16)
					lblPage:SizeToContents()
					lblPage:SetColor(COLOR_WHITE)

					createIcons()
				end

				local containerpnl=invpnl:Add("esPanel")
				containerpnl:Dock(FILL)
				containerpnl:SetColor(ES.Color["#00000033"])

				local icons = {}
				createIcons = function()
					for k,v in pairs(icons)do
						if v and IsValid(v) then
							v:Remove()
						end
					end
					icons = {}

					local icon
					for i=(page-1) * perPage + 1, page*perPage do
						local item=ES.Props[inv[i]]
						if not item then return end

						local x,y = 0,0
						if IsValid(icon) then
							x=icon.x + 105
							y=icon.y

							if x >= 105*3 then
								x=0
								y=y+105
							end


						end

						icon=vgui.Create("ES.ItemTile.Model",containerpnl)
						icon:SetSize(105,105)
						icon:SetPos(x,y)
						icon:Setup(item)
						icon:SetText(item:GetName())
						icon.delay=CurTime() + ( y/105 + x/105 )*.05

						icon.OnMouseReleased=function()
							itemname:SetText(item:GetName())
							itemname:SizeToContents()

							rm:SetVisible(true)

							spicon:SetModel(item:GetModel())
							spicon:SetVisible(true)

							if not mdl.Slots then return end

							mdl.Slots[slot] = {
								item=item:GetName(),
								pos=Vector(0,0,0),
								ang=Angle(0,0,0),
								color="#FFFFFFFF",
								bone=boneTranslations[DComboBox:GetValue()],
								scale=Vector(0,0,0)
							}
						end

						table.insert(icons,icon)
					end
				end


		local left=editor:Add("Panel")
		left:Dock(FILL)

			local pnlpreview=left:Add("Panel")
			pnlpreview:Dock(FILL)
			pnlpreview:DockMargin(10,10,0,0)

				local sizePreview = p:GetWide() - 10 - invpnl:GetWide()
				if sizePreview > editor:GetTall()-10-32-10-170 then
					sizePreview = editor:GetTall()-10-32-10-172
				end

				mdl = pnlpreview:Add("ES.PlayerModel") -- prototype above
				mdl:Dock(FILL)
				mdl:DockMargin(0,0,0,0)
				mdl:SetModel(LocalPlayer():ESGetActiveModel())
				mdl:SetLookAt(Vector(0,0,0))
				mdl:SetCamPos(Vector(10,10,10))
				mdl:SetFocus(boneSelected)
				mdl.Slots = slots

				local zoommin = pnlpreview:Add("esIconButton")
				zoommin:SetIcon(Material("icon16/zoom_out.png"))
				zoommin:SetSize(16,16)
				zoommin:SetPos(pnlpreview:GetWide()-16-10,10)
				zoommin.DoClick = function(self)
					mdl.zoom = mdl.zoom + 8
					mdl:SetFocus(boneSelected)
				end
				local zoommore = pnlpreview:Add("esIconButton")
				zoommore:SetIcon(Material("icon16/zoom_in.png"))
				zoommore:SetSize(16,16)
				zoommore:SetPos(zoommin.x - 8 - 16,zoommin.y)
				zoommore.DoClick = function(self)
					mdl.zoom = mdl.zoom - 8
					mdl:SetFocus(boneSelected)
				end

				local rotmin = pnlpreview:Add("esIconButton")
				rotmin:SetIcon(Material("icon16/arrow_rotate_clockwise.png"))
				rotmin:SetSize(16,16)
				rotmin:SetPos(zoommin.x,zoommin.y + 16+8)
				rotmin.DoClick = function(self)
					mdl.rotate = mdl.rotate + 45
					mdl:SetFocus(boneSelected)
				end
				local rotmore = pnlpreview:Add("esIconButton")
				rotmore:SetIcon(Material("icon16/arrow_rotate_anticlockwise.png"))
				rotmore:SetSize(16,16)
				rotmore:SetPos(rotmin.x - 8 - 16,rotmin.y)
				rotmore.DoClick = function(self)
					mdl.rotate = mdl.rotate - 45
					mdl:SetFocus(boneSelected)
				end

			local tabpnl = left:Add("esTabPanel")
			tabpnl:SetTall(170)
			tabpnl:Dock(BOTTOM)
			tabpnl:DockMargin(10,0,0,10)
				local pnl = tabpnl:AddTab("Position","exclserver/tabs/generic.png")
				pnl:DockPadding(10,10,10,10)
					local slideX = pnl:Add("esSlider")
					slideX:Dock(TOP)
					slideX:SetTall(30)
					slideX.text = "X"
					slideX.min = -8
					slideX.max = 8
					slideX:SetValue(slots[slot] and slots[slot].pos and slots[slot].pos.x or 0)
					slideX.Think = function(self) if slots[slot] and slots[slot].pos then
						slots[slot].pos.x = self:GetValue()
					end end
					local slideY = pnl:Add("esSlider")
					slideY:Dock(TOP)
					slideY:SetTall(30)
					slideY.text = "Y"
					slideY.min = -8
					slideY.max = 8
					slideY:SetValue(slots[slot] and slots[slot].pos and slots[slot].pos.y or 0)
					slideY.Think = function(self) if slots[slot] and slots[slot].pos then
						slots[slot].pos.y = self:GetValue()
					end end
					local slideZ = pnl:Add("esSlider")
					slideZ:Dock(TOP)
					slideZ:SetTall(30)
					slideZ.text = "Z"
					slideZ.min = -8
					slideZ.max = 8
					slideZ:SetValue(slots[slot] and slots[slot].pos and slots[slot].pos.z or 0)
					slideZ.Think = function(self) if slots[slot] and slots[slot].pos then
						slots[slot].pos.z = self:GetValue()
					end end

				local pnl = tabpnl:AddTab("Angles","exclserver/tabs/generic.png")
				pnl:DockPadding(10,10,10,10)
					local slideP = pnl:Add("esSlider")
					slideP:SetPrecision(0)
					slideP:Dock(TOP)
					slideP:SetTall(30)
					slideP.text = "Pitch"
					slideP.min = -180
					slideP.max = 180
					slideP:SetValue(slots[slot] and slots[slot].ang and slots[slot].ang.p or 0)
					slideP.Think = function(self) if slots[slot] and slots[slot].ang then
						slots[slot].ang.p = self:GetValue()
					end end
					local slideYa = pnl:Add("esSlider")
					slideYa:SetPrecision(0)
					slideYa:Dock(TOP)
					slideYa:SetTall(30)
					slideYa.text = "Yaw"
					slideYa.min = -180
					slideYa.max = 180
					slideYa:SetValue(slots[slot] and slots[slot].ang and slots[slot].ang.y or 0)
					slideYa.Think = function(self) if slots[slot] and slots[slot].ang then
						slots[slot].ang.y = self:GetValue()
					end end
					local slideR = pnl:Add("esSlider")
					slideR:SetPrecision(0)
					slideR:Dock(TOP)
					slideR:SetTall(30)
					slideR.text = "Roll"
					slideR.min = -180
					slideR.max = 180
					slideR:SetValue(slots[slot] and slots[slot].ang and slots[slot].ang.r or 0)
					slideR.Think = function(self) if slots[slot] and slots[slot].ang then
						slots[slot].ang.r = self:GetValue()
					end end

				local pnl = tabpnl:AddTab("Scale","exclserver/tabs/generic.png")
				pnl:DockPadding(10,10,10,10)
					local slideSX = pnl:Add("esSlider")
					slideSX:SetPrecision(3)
					slideSX:SetTall(30)
					slideSX:Dock(TOP)
					slideSX.text = "X"
					slideSX.min = -.3
					slideSX.max = .3
					slideSX:SetValue(slots[slot] and slots[slot].scale and slots[slot].scale.x or 0)
					slideSX.Think = function(self) if slots[slot] and slots[slot].scale then
						slots[slot].scale.x = self:GetValue()
					end end
					local slideSY = pnl:Add("esSlider")
					slideSY:SetPrecision(3)
					slideSY:Dock(TOP)
					slideSY:SetTall(30)
					slideSY.text = "Y"
					slideSY.min = -.3
					slideSY.max = .3
					slideSY:SetValue(slots[slot] and slots[slot].scale and slots[slot].scale.y or 0)
					slideSY.Think = function(self) if slots[slot] and slots[slot].scale then
						slots[slot].scale.y = self:GetValue()
					end end
					local slideSZ = pnl:Add("esSlider")
					slideSZ:SetPrecision(3)
					slideSZ:Dock(TOP)
					slideSZ:SetTall(30)
					slideSZ.text = "Z"
					slideSZ.min = -.3
					slideSZ.max = .3
					slideSZ:SetValue(slots[slot] and slots[slot].scale and slots[slot].scale.z or 0)
					slideSZ.Think = function(self) if slots[slot] and slots[slot].scale then
						slots[slot].scale.z = self:GetValue()
					end end

				local pnl = tabpnl:AddTab("Color","exclserver/tabs/generic.png")
				pnl:DockPadding(10,10,10,10)
					local cube = pnl:Add("DColorMixer")
					cube:SetPos(2,2)
					cube:SetSize(256,200)
					cube:SetLabel("")
					cube:SetColor(Color(255,255,255))
					function cube:ValueChanged()
						slots[slot].color = ES.RGBToHex(cube:GetColor())
					end


		if slots[slot] and slots[slot].item then
			local it = ES.Props[slots[slot].item]
			if it then

				itemname:SetText(it:GetName())
				itemname:SizeToContents()
				itemSelected = it:GetName()
				rm:SetVisible(true)
				spicon:SetModel(it:GetModel())
				spicon:SetVisible(true)
			end
		end
	end
	openEditor(1)
end
