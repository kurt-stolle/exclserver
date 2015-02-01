
--#### Inventory
surface.CreateFont("esMMInventoryTitle",{
	font = "Calibri",
	size = 36,
	weight=400
})
surface.CreateFont("esMMInventoryAppearthere",{
	font = "Calibri",
	size = 26,
	weight=400,
	italic=true
})
local PNL = {};
function PNL:Init()
	self.title = "Undefined"
	self.PanelCurrent = vgui.Create("Panel",self);

	self.PanelInventory = vgui.Create("Panel",self);
	self.Icons={};
	function self.PanelInventory:Paint(w,h) 
		surface.SetDrawColor(Color(0,0,0,100)); 
		surface.DrawRect(0,0,w,h) 

		if self:GetParent().Icons and #self:GetParent().Icons > 0 then return end

		draw.SimpleText("Your purchases will appear here","esMMInventoryAppearthere",w/2,h/2,ES.Color.White,1,1);
	end

	self.PanelInventory.items = {};
	self.scrollTo = 0;
	self.curX = 0;
	self.tilesX = 0;

	self.butPrev = vgui.Create("esIconButton",self)
	self.butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
	self.butPrev:SetSize(32,32);
	self.butPrev:SetRotation(-90);
	self.butPrev.DoClick = function(self)
		self:GetParent().scrollTo = (self:GetParent().scrollTo - self:GetParent().tilesX);
		if self:GetParent().scrollTo < 0 then
			self:GetParent().scrollTo = 0;
		end
	end

	self.butNext = vgui.Create("esIconButton",self)
	self.butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
	self.butNext:SetSize(32,32);
	self.butNext:SetRotation(90);
	self.butNext.DoClick = function(self)
		self:GetParent().scrollTo = (self:GetParent().scrollTo + self:GetParent().tilesX);

		if not self:GetParent().PanelInventory.items[ self:GetParent().scrollTo*2 - 1 ] then
			self:GetParent().scrollTo = (self:GetParent().scrollTo - self:GetParent().tilesX); --undo the damage done
		end
	end

	self.rm = vgui.Create("esIconButton",self)
	self.rm:SetIcon(Material("icon16/cancel.png"));
	self.rm:SetSize(16,16);
	self.rm.DoClick = function(self)

			self:SetVisible(false);
			for k,v in pairs(self:GetParent().PanelCurrent:GetChildren())do
				if IsValid(v) then v:Remove() end
			end
	end
	self.rm:SetVisible(false);
end
function PNL:Think()
	if self.curX != self.scrollTo*100 then
		self.curX = math.Approach(self.curX,self.scrollTo*100,32);

		local x = 0;
		local y = 0;

		for k,v in pairs(self.PanelInventory.items)do
			if v and IsValid(v) then
				v:SetPos(-self.curX + x*100,y*100);
			end

			y = y + 1;
			if y >= 2 then
				y = 0;
				x = x + 1;
			end
		end
	end
end
function PNL:PerformLayout()
	local w,h = self:GetWide(),self:GetTall();

	self.PanelCurrent:SetSize(110,110);
	self.PanelCurrent:SetPos(0,h-110);
	self.PanelInventory:SetSize(w-110-(32+16),h);
	self.PanelInventory:SetPos(5+100+5,0);

	self.butNext:SetPos(w-32-8,h/2-4-32);
	self.butPrev:SetPos(w-32-8,h/2+4);

	self.tilesX = math.floor(self.PanelInventory:GetWide()/100);

	self.rm:SetPos(self.PanelCurrent.x + self.PanelCurrent:GetWide()-17,self.PanelCurrent.y + 1);
end
function PNL:IncludeIcon(ic)
	table.insert(self.Icons,ic);
end
function PNL:Paint(w,h)
	surface.SetDrawColor(ES.GetColorScheme(2));
	surface.DrawRect(0,0,w,h);
	draw.SimpleText(self.title,"esMMInventoryTitle",10,5,ES.Color.White);
	draw.DrawText("Select an item to\nactivate it.","ESDefault",10,50,ES.Color.White);
end
vgui.Register("ES.InventoryPanel",PNL,"Panel");
