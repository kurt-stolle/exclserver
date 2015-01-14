-- cl_motd.lua
-- the motd
ES.motdEnabled = true;
ES.ServerRules = {
	"Do act friendly towards other players.",
	"Do obey to the administration team's directions.",
	"Do not spam in any way.",
	"Do not cheat."
};

local color_background_faded=Color(0,0,0,150)

local timeOpen=0;
local motdPaint=function(self,w,h)
	surface.SetDrawColor(color_background_faded);
	surface.DrawRect(0,0,w,h);
	Derma_DrawBackgroundBlur(self,timeOpen)
end
local navPaint=function(self,w,h)
	surface.SetDrawColor(color_background_faded)
	surface.DrawRect(0,0,w,h);
end
local navPaintButton=function(self,w,h)
	if self:GetSelected() then
		surface.SetDrawColor(ES.Color["#1E1E1E"])
		surface.DrawRect(0,0,w,h);
	end

	if self:GetHover() then
		surface.SetDrawColor(ES.GetColorScheme(3));
		surface.DrawRect(1,1,w-2,h-2);
	end

	surface.SetDrawColor(ES.Color.White);
	surface.SetMaterial(self.Icon);
	surface.DrawTexturedRect(w/2-(64/2),0,64,64);

	draw.DrawText(self.Title,"ESDefault",w/2,h-22,ES.Color.White,1,1);
end
local navigationOptions={
	{
			title="Rules",
			icon=Material("exclserver/motd/rules.png"),
			fn=function(pnl)
				local y=20;

				local text;
				text=Label(exclFormatLine("Below is a list of all rules that apply to this server. Not following any of the rules stated below may result in receiving a punishment or penalty.\n","ESDefault",pnl:GetWide()-40),pnl);
				text:SetPos(20,y);
				text:SizeToContents();

				y=y+text:GetTall();

				for k,v in ipairs(ES.ServerRules)do


					text=Label(exclFormatLine(k..". "..v,"ESDefault",pnl:GetWide()-40),pnl);
					text:SetPos(20,y);
					text:SizeToContents();

					y=y+text:GetTall();
				end
			end
	},
	{
			title="About",
			icon=Material("exclserver/motd/info.png"),
			fn=function(pnl)
				local text=Label(exclFormatLine("This server is running ExclServer. ExclServer is a all-in-one server system that includes a shop, donation system, motd, administration, group management and an elaborate plugin system.\n\nPlayers can use ExclServer by pressing F6. From this menu the player can choose a number of different actions.\n\nItems can be bought with the Bananas currency. Bananas are earned through playing and achieving in-game goals. Completing achievements, listed in the F6 menu, also award Bananas.\n\nExclServer is made by Casual Bananas Software Development.\nPlease report any bugs to info@casualbananas.com.\n\n\n\nCOPYRIGHT (c) 2011-2015 CASUALBANANAS.COM","ESDefault",pnl:GetWide()-40),pnl);
				text:SetPos(20,20);
				text:SizeToContents();
			end
	},
	{
			title="Donate",
			icon=Material("exclserver/motd/donate.png"),
			fn=function(pnl)
				local text=Label(exclFormatLine("This page is currently being worked on. Check back later!","ESDefault",pnl:GetWide()-40),pnl);
				text:SetPos(20,20);
				text:SizeToContents();
			end
	},

}

local motd

local w=560;
local h=600;
function ES.CloseMOTD()
	if IsValid(motd) then 
		motd:Remove() 
	end
end
function ES.OpenMOTD()
	ES.CloseMOTD();

	timeOpen=SysTime();
	
	motd=vgui.Create("EditablePanel");
	motd:SetSize(ScrW(),ScrH());
	motd:SetPos(0,0);
	motd.Paint=motdPaint;

		local master=motd:Add("esFrame");
		master:SetSize(w,h);
		--[[master:SetPos(ScrW(),(ScrH()/2)-(h/2));
		master.Title="Welcome";
		master.xDesired=(ScrW()/2)-(w/2)
		master:PerformLayout();]]
		master.Title="Welcome";
		master:Center();

		local oldRemove=master.Remove;
		function master:Remove()
			oldRemove(self);
			motd:Remove();
		end

		local frame=master:Add("Panel");
		frame:SetSize(w-2,h-31);
		frame:SetPos(1,30);


		local context=frame:Add("Panel");
		local navigation=frame:Add("Panel");
		local btn_close=frame:Add("esButton");

		navigation:SetPos(0,0);
		navigation:SetSize(74,frame:GetTall());
		navigation.Paint=navPaint;

			local i=0;
			for k,v in ipairs(navigationOptions)do
				local btn=navigation:Add("Panel");
				btn:SetSize(74,74);
				btn:SetPos(0,i*74);
				btn.Title=v.title;
				btn.Icon=v.icon;
				btn.Paint = navPaintButton
				btn.OnMouseReleased=function(self)
					for k,v in pairs(context:GetChildren())do
						if IsValid(v) then
							v:Remove();
						end
					end

					v.fn(context);

					for k,v in ipairs(navigationOptions)do
						if IsValid(v._Panel) then
							v._Panel:SetSelected(false);
						end
					end

					self:SetSelected(true);
				end

				ES.UIAddHoverListener(btn);
				AccessorFunc(btn,"selected","Selected",FORCE_BOOL);

				if k == 1 then
					btn:SetSelected(true);
				end

				v._Panel=btn;

				i=i+1;
			end

		
		context:SetSize(frame:GetWide()-navigation:GetWide(),frame:GetTall()-10-30-10);
		context:SetPos(navigation.x+navigation:GetWide(),0);

				

		btn_close:SetSize(context:GetWide()-20,30);
		btn_close:SetPos(context.x+10,frame:GetTall()-10-30);
		btn_close.Text="Close MOTD"
		btn_close.DoClick=ES.CloseMOTD

		navigationOptions[1]._Panel:OnMouseReleased();

	motd:MakePopup();
end

-- Open this when the client loads.
hook.Add("InitPostEntity","ES.OpenMOTD",ES.OpenMOTD)