-- The shop menus.

local marginFrameHalved = 16 /2-- margin divided by 2

local marginTile = 10
local sizeTile = 108

function ES._MMGenerateShop(base,name,itemtype,tileVGUIName)
	local tab
	local tiletype

	if itemtype == ES.ITEM_PROP then
		tab=ES.Props
		tiletype="ES.ItemTile.Model" 
	elseif itemtype == ES.ITEM_TRAIL then
		tab=ES.Trails
		tiletype="ES.ItemTile.Texture" 
	elseif itemtype == ES.ITEM_AURA then
		tab=ES.Auras
		tiletype="ES.ItemTile.Texture" 
	elseif itemtype == ES.ITEM_MELEE then
		tab=ES.MeleeWeapons
		tiletype="ES.ItemTile.Model" 
	elseif itemtype == ES.ITEM_MODEL then
		tab=ES.Models
		tiletype="ES.ItemTile.Model" 
	end

	if not tab then return end

	local page=1
	local pageMax=1
	local tiles = {}
	local buildTiles -- prototype
	local itemSelected

	local frame = base:OpenFrame()
	frame:SetTitle(name.." shop")
	frame:DockPadding(marginFrameHalved,marginFrameHalved,marginFrameHalved,marginFrameHalved)

	local pnl_preview= frame:Add("esPanel")
	pnl_preview:SetWide(258)
	pnl_preview:DockMargin(marginFrameHalved,marginFrameHalved,marginFrameHalved,marginFrameHalved)
	pnl_preview:Dock(RIGHT)

		local pnl_iconArea= pnl_preview:Add("esPanel")
		pnl_iconArea:SetTall(pnl_preview:GetWide())
		pnl_iconArea:Dock(TOP)
		pnl_iconArea.color = ES.Color["#00000055"]

		local lbl_name= pnl_preview:Add("esLabel")
		lbl_name:SetText("No selection")
		lbl_name:SetFont("ESDefault+")
		lbl_name:SizeToContents()
		lbl_name:DockMargin(10,10,10,10)
		lbl_name:SetColor(ES.Color.White)
		lbl_name:Dock(TOP)

		local lbl_description= pnl_preview:Add("esLabel")
		lbl_description:SetText("Click an item to the right to select it.")
		lbl_description:SetFont("ESDefault")
		lbl_description:SizeToContents()
		lbl_description:DockMargin(11,0,11,11)
		lbl_description:SetColor(ES.Color.White)
		lbl_description:Dock(TOP)

		local btn_purchase= pnl_preview:Add("esButton")
		btn_purchase:SetTall(30)
		btn_purchase:DockMargin(10,0,10,10)
		btn_purchase:Dock(BOTTOM)
		btn_purchase:SetText("Purchase")
		btn_purchase.DoClick = function()
			if type(itemSelected) == "number" then
				net.Start("ESBuyItem")
				net.WriteUInt(itemtype,4)
				net.WriteUInt(itemSelected,8)
				net.SendToServer()
			end
		end
	

	local pnl_nav= frame:Add("Panel")
	pnl_nav:SetTall(32)
	pnl_nav:DockMargin(marginFrameHalved,marginFrameHalved,marginFrameHalved,marginFrameHalved)
	pnl_nav:Dock(BOTTOM)

		local btn_left= pnl_nav:Add("esIconButton")
		btn_left:SetIcon(Material("exclserver/mmarrowicon.png"))
		btn_left:SetSize(32,32)
		btn_left:SetPos(0,0)
		btn_left:SetRotation(180)
		btn_left.DoClick = function(self)
			if page <= 1 then return end

			page=page-1
			buildTiles()
		end

		local btn_right= pnl_nav:Add("esIconButton")
		btn_right:SetIcon(Material("exclserver/mmarrowicon.png"))
		btn_right:SetSize(32,32)
		btn_right:SetPos(btn_left.x + btn_left:GetWide() + 16,btn_left.y)
		btn_right.DoClick = function(self)
			if page >= pageMax then return end

			page=page+1
			buildTiles()
		end

		local lbl_page= pnl_nav:Add("esLabel")
		lbl_page:SetFont("ESDefault+")
		lbl_page:SetColor(ES.Color.White)
		lbl_page.Think = function(self)
			lbl_page:SetText("Page "..(tostring(page)).."/"..(tostring(pageMax)))
			lbl_page:SizeToContents()
			lbl_page:SetPos(btn_right.x + btn_right:GetWide() + 16, pnl_nav:GetTall()/2 - self:GetTall()/2)
		end
	

	local pnl_tiles= frame:Add("Panel")
	pnl_tiles:DockMargin(marginFrameHalved,marginFrameHalved,marginFrameHalved,marginFrameHalved)
	pnl_tiles:Dock(FILL)
	pnl_tiles:NoClipping(false)
		buildTiles=function()
			local tile
			local iX,iY=0,1
			local space=sizeTile + marginTile

			local numTilesX=math.floor((pnl_tiles:GetWide() + marginTile*2)/space)
			local numTilesY=math.floor((pnl_tiles:GetTall() + marginTile*2)/space)
			local numTiles =numTilesX * numTilesY

			pageMax=math.ceil(#tab/numTiles)

			for _,tile in pairs(tiles)do
				if IsValid(tile) then
					tile:Remove()
				end
			end
			tiles = {}
			local icon

			for i=( (page-1) *  numTiles ) + 1 , page * numTiles do
				local item=tab[i]
				if not item then 
					break
				end

				iX=iX+1
				if iX > numTilesX then
					iY = iY+1
					iX = 1
				end

				tile= pnl_tiles:Add(tiletype)
				tile:SetSize(sizeTile,sizeTile)
				tile:SetPos( (iX-1) * space, (iY-1) * space )
				tile:SetText(item:GetName())
				tile:SetVIP(item:GetVIP())
				tile:SetCost(item:GetCost())
				tile:SetType(itemtype)

				tile:Setup(item)

				tile.delay=CurTime() + ( (iY-1) + (iX-1) --[[+ iY]] )*.05

				local this=i
				tile.OnMouseReleased=function()
					if IsValid(icon) then icon:Remove() end

					itemSelected=this

					lbl_name:SetText(item:GetName())
					lbl_description:SetText("")
					lbl_description:SizeToContents()
					lbl_description:SetText(item:GetDescription())
					lbl_description:SizeToContents()

					if itemtype == ES.ITEM_PROP or itemtype == ES.ITEM_MODEL or itemtype == ES.ITEM_MELEE then
						icon=pnl_iconArea:Add("ModelImage")
						icon:SetSize(pnl_iconArea:GetTall()-2,pnl_iconArea:GetWide()-2)
						icon:SetPos(1,1)
						icon:SetModel(item:GetModel())
						icon:RebuildSpawnIcon()
					elseif itemtype == ES.ITEM_AURA or itemtype == ES.ITEM_TRAIL then
						icon=pnl_iconArea:Add("DImage")
						icon:SetSize(pnl_iconArea:GetTall()-2,pnl_iconArea:GetWide()-2)
						icon:SetPos(1,1)
						icon:SetMaterial(item:GetModel())
					end

				end

				table.insert(tiles,tile)
			end
		end

	frame.OnReady = function(self)
		if IsValid(pnl_tiles) then
			buildTiles()
		end
	end

	return frame
end