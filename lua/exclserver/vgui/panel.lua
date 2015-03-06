--pannel
local PNL= {
	Paint = function(self,w,h)
		draw.RoundedBox(2,0,0,w,h,self.color)

		surface.SetDrawColor(Color(0,0,0,self.color.a/255 * 100))
		surface.DrawRect(0,0,w,1)
		surface.DrawRect(0,h-1,w,1)
		surface.DrawRect(0,1,1,h-2)
		surface.DrawRect(w-1,1,1,h-2)

		surface.SetDrawColor(Color(255,255,255,self.color.a/255 * 5));
		surface.DrawRect(1,1,w-2,1)
		surface.DrawRect(1,h-2,w-2,1)
		surface.DrawRect(1,2,1,h-4)
		surface.DrawRect(w-2,2,1,h-4)

	end,
	SetAutoScroll=function(self,b)
		if IsValid(self.scrollbar) then
				self.scrollbar:SetAutoScroll(b);
		end
	end,
	AddScrollbar=function(self)
		self.scrollbar=vgui.Create( "esScrollbar", self );
	end,
	PerformLayout = function(self)
		if self._inlineElements then
			local w,h=self:GetWide(),self:GetTall();

			local x,y=0,0;
			for k,v in ipairs(self._inlineElements)do
				v.x=x;
				v.y=y+(self:GetTall()/2 - v:GetTall()/2);

				x=x+v:GetWide();

				if x > w then
					if v.IsESLabel then

					else
						x=0;
						y=y+self:GetTall();

						v.x=x;
						v.y=y+(self:GetTall()/2 - v:GetTall()/2);
					end
				end


			end
		end

		if IsValid(self.scrollbar) then
			self.scrollbar:Setup();
		end
	end,
	SetColor = function(self,color)
		self.color = color
	end,
	Init = function(self)
		self.color = ES.GetColorScheme(2)
	end,
	Think = function(self)

	end,
	Inline=function(self,panel)
		if not IsValid(panel) then return end

		if not self._inlineElements then
			self._inlineElements={};
		end

		table.insert(self._inlineElements,panel);

	end,
	UpdateTall=function(self)

	end
}
AccessorFunc(PNL,"_alwaysScrollToBottom","AlwaysScrollToBottom",FORCE_BOOL);
AccessorFunc(PNL,"_scrolling","Scrolling",FORCE_BOOL);
vgui.Register( "esPanel",PNL, "Panel" )
