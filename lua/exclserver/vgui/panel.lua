--pannel
vgui.Register( "esPanel", {
	Paint = function(self,w,h)
		draw.RoundedBox(2,0,0,w,h,self.color) 

		surface.SetDrawColor(ES.Color["#00000022"]);
		surface.DrawRect(0,0,w,1);
		surface.DrawRect(0,h-1,w,1);
		surface.DrawRect(0,1,1,h-2);
		surface.DrawRect(w-1,1,1,h-2)

		if self.PaintHook then
			self.PaintHook(w,h)
		end
	end,
	SetColor = function(self,color)
		self.color = color;
	end,
	Init = function(self)
		self.color = ES.GetColorScheme(2);
		self.PaintHook = function(w,h) end
	end
}, "Panel" );