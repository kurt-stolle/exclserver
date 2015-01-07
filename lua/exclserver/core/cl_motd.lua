-- cl_motd.lua
-- the motd
ES.motdEnabled = true;
ES.serverRules={
	"Do act friendly towards other players.",
	"Do obey to the administration team's directions.",
	"Do not spam in any way.",
	"Do not cheat.",
}

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

local navigationOptions={
	{
			title="Rules",
			fn=function(pnl)

			end
	},
	{
			title="About",
			fn=function(pnl)

			end
	},
	{
			title="Donate",
			fn=function(pnl)

			end
	},

}

local motd

local w=760;
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

		local master=motd:Add("ES.MainMenu.Frame");
		master:SetSize(w,h);
		master:SetPos(ScrW(),(ScrH()/2)-(h/2));
		master.Title="MOTD";
		master.xDesired=(ScrW()/2)-(w/2)
		master:PerformLayout();

		local frame=master.context;
		local context=frame:Add("Panel");
		local navigation=frame:Add("Panel");
		local btn_close=frame:Add("esButton");

		navigation:SetPos(0,0);
		navigation:SetSize(256,frame:GetTall());
		navigation.Paint=navPaint;

			local i=1;
			for k,v in ipairs(navigationOptions)do
				local btn=navigation:Add("ES.MainMenu.NavigationItem");
				btn:SetSize(256,32);
				btn:SetPos(0,i*32);
				btn.Title=v.title;
				btn.DoClick=function()
					fn(context);
				end

				i=i+1;
			end
		
		context:SetSize(frame:GetWide()-navigation:GetWide(),frame:GetTall()-10-30-10);
		context:SetPos(navigation.x+navigation:GetWide(),0);

				

		btn_close:SetSize(context:GetWide()-20,30);
		btn_close:SetPos(context.x+10,frame:GetTall()-10-30);
		btn_close.Text="Close MOTD"
		btn_close.DoClick=ES.CloseMOTD

	motd:MakePopup();
end

-- Open this when the client loads.
hook.Add("InitPostEntity","ES.OpenMOTD",ES.OpenMOTD)