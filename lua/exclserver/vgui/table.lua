--pannel
local PANEL = {};
function PANEL:Init()
	self.rows = {};
end

COLOR_BLACK = COLOR_BLACK or Color(0,0,0);
COLOR_WHITE = COLOR_WHITE or Color(255,255,255);
local color_black_transparent = Color(0,0,0,100);
local color_shadow = Color(255,255,255,25);
local colorItemBG = Color(50,50,50);
local headColor = Color(213,213,213);
local mat = Material("exclserver/bananas_16.png");
local margin = 10;
COLOR_BLACK = COLOR_BLACK or Color(0,0,0);

surface.CreateFont("ES.VIPTableFont",{
	font = "Roboto",
	size = 16,
	weight = 700
})

function PANEL:SetRows(x,y)
	for r,t in pairs(self.rows)do
		for k,v in pairs(t)do
			if v and IsValid(v) then
				v:Remove();
			end
			table.remove(k);
		end
		table.remove(r);
	end

	for x=1,x do
		for y=1,y do
			if not self.rows[x] then
				self.rows[x] = {};
			end
			self.rows[x][y] = "Undefined"
		end
	end

	self.headColors = {};
	self.itemPrice = {};
	self.buttons = {};

	w = self:GetWide();
	local wRow = #self.rows;
	wRow = (w-((#self.rows-1) * margin))/wRow;
	for i=2,x do
		local xpos = (wRow * (i-1)) + (margin * (i-1)) -1;
		self.buttons[i] = vgui.Create("esButton",self);
		self.buttons[i]:SetPos(xpos+3,self:GetTall()-33);
		self.buttons[i]:SetSize(wRow-6,30);
		self.buttons[i].Text = "Buy";
	end
end

local matYes = Material("icon16/tick.png");
local matNo = Material("icon16/cross.png");

function PANEL:Paint(w,h)
	if #self.rows > 0 then

		local wRow = #self.rows;
		wRow = (w-((#self.rows-1) * margin))/wRow;

		for i=2,(#self.rows) do
			local x = (wRow * (i-1)) + (margin * (i-1)) -1;
			draw.RoundedBox(0,x-1,0,wRow+2,h,color_black_transparent);
			draw.RoundedBox(0,x,1,wRow,h-2,colorItemBG);

			draw.RoundedBoxEx(0,x,1,wRow,48,(self.headColors[i] or headColor),false,false,true,true)
			
			draw.SimpleText(self.rows[i][1],"ES.VIPTableFont",x+(wRow/2)+1,5+1,color_shadow,1,0)
			draw.SimpleText(self.rows[i][1],"ES.VIPTableFont",x+(wRow/2),5,COLOR_BLACK,1,0)
			

			if self.itemPrice[i] > 0 then
				draw.SimpleText((self.itemPrice[i] or 0).." Bananas","ES.VIPTableFont",x+(wRow/2)+1,24+1,color_shadow,1,0)
				draw.SimpleText((self.itemPrice[i] or 0).." Bananas","ES.VIPTableFont",x+(wRow/2),24,COLOR_BLACK,1,0)
			else
				draw.SimpleText("Already bought","ES.VIPTableFont",x+(wRow/2)+1,24+1,color_shadow,1,0)
				draw.SimpleText("Already bought","ES.VIPTableFont",x+(wRow/2),24,COLOR_BLACK,1,0)
			end
		end

		for i=1,(#self.rows) do
			local x = (wRow * (i-1)) + (margin * (i-1)) -1;
			for j=2,#self.rows[i] do
				if (i == 1 and j == 1) or j == 1 then continue end
				local y = 50+5 + ((j-2) * 24 );
				if i == 1 and (j == 3 or j == 5 or j == 7 or j == 9 or j == 11) then
					draw.RoundedBoxEx(0,0,y-2,w,24,color_black_transparent);
				end

				if i == 1 then
					draw.SimpleText(self.rows[i][j],"ESDefaultBold",10,y + 20/2,COLOR_WHITE,0,1);
				else
					surface.SetDrawColor(COLOR_WHITE);
					if !self.rows[i][j] or self.rows[i][j] != true then
						surface.SetMaterial(matNo);
					else
						surface.SetMaterial(matYes);
					end
					surface.DrawTexturedRect(x+ (wRow/2) - (16/2),y + 20/2 - 16/2,16,16);
				end
			end
		end
	end
end
vgui.Register( "esTable", PANEL, "Panel" );