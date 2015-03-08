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
		if self._skipLayout then self._skipLayout=false return end

		if self._inlineElements then
			local w,h=self:GetWide(),self:GetTall()

			local x,y=0,0;
			local doInline;
			doInline = function(element)
				element.x=x;
				element.y=y+(self._lineHeight/2 - element:GetTall()/2);

				if x+element:GetWide() > w then
					if element.ESIsLabel then
						local txt=element:GetText()
						local len=string.len(txt)
						local txt_right=""
						while (x+element:GetWide()>w) do
							element:SetText(string.Left(txt,len-(string.len(txt_right)+1)))
							element:SizeToContents()
							txt_right=string.Right(txt,string.len(txt_right)+1)
						end

						local new_label=vgui.Create("esLabel")
						new_label:CopyAttibutes(element)
						new_label:SetParent(self)
						new_label:SetText(txt_right)
						new_label:SizeToContents()

						x=0
						y=y+self._lineHeight

						self._skipLayout=true;
						self:SetTall(self:GetTall()+self._lineHeight)

						doInline(new_label)
					else
						x=0;
						y=y+self._lineHeight;

						element.x=x;
						element.y=y+(self._lineHeight/2 - self._lineHeight/2);

						self._skipLayout=true;
						self:SetTall(self:GetTall()+self._lineHeight)
					end
				else
					x=x+element:GetWide();
				end
			end


			for k,v in ipairs(self._inlineElements)do
				doInline(v)
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
		self._lineHeight = 20;
	end,
	Think = function(self)

	end,
	Inline=function(self,panel,lineHeight)
		if not IsValid(panel) then return end

		if not self._inlineElements then
			self._inlineElements={};
		end

		self._lineHeight=lineHeight;

		table.insert(self._inlineElements,panel);

	end,
	UpdateTall=function(self)

	end
}
AccessorFunc(PNL,"_alwaysScrollToBottom","AlwaysScrollToBottom",FORCE_BOOL);
AccessorFunc(PNL,"_scrolling","Scrolling",FORCE_BOOL);
vgui.Register( "esPanel",PNL, "Panel" )
