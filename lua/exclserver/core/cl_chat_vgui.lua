surface.CreateFont("ES.Chat.Title",{
	font="Calibri",
	size=20,
	weight=700
})

local PANEL={}
AccessorFunc(PANEL,"_visible","Visible",FORCE_BOOL);
AccessorFunc(PANEL,"_team","Team",FORCE_BOOL);
function PANEL:Init()
	ES.DebugPrint("Created ExclServer chat panel.");

	local top=self:Add("esPanel");
	top:SetTall(32);
	top:SizeToContents();
	top:Dock(TOP);

		local title=top:Add("esLabel");
		title:SetFont("ES.Chat.Title");
		title:SetText(string.upper(string.Trim(GetHostName( ))));
		title:Dock(LEFT);
		title:SizeToContents();
		title:DockMargin((32-title:GetTall())/2,(32-title:GetTall())/2,(32-title:GetTall())/2,(32-title:GetTall())/2)
		title:SetColor(ES.Color.White)

	local container=self:Add("Panel");
	container:Dock(FILL);
	container:DockMargin(6,6,6,6);

	local bottom=self:Add("esPanel");
	bottom:Dock(BOTTOM);
	bottom:SetTall(32);
	bottom:SetColor(ES.Color["#151515FF"])

		local entry=bottom:Add("esTextEntry");
		entry:Dock(BOTTOM);
		entry:DockMargin((32-24)/2,(32-24)/2,(32-24)/2,(32-24)/2);
		entry:SetHistoryEnabled(true);

		local send=bottom:Add("esIconButton");
		send:SetIcon(Material("exclserver/arrow_right.png"));
		send:SetWide(32);
		send:Dock(RIGHT);
		send:DockMargin(0,0,0,0);
		send.DoClick=function()
			RunConsoleCommand("say",string.Trim(entry:GetValue()));
			entry:AddHistory(entry:GetValue())
			entry:SetText("");
			entry:SetValue("");
			self:SetVisible(false);
		end

		entry.OnEnter=send.DoClick;
	

	self.bottom=bottom;
	self.top=top;
	self.container=container
	self.title=title
	self.entry=entry
end
function PANEL:Think()

end
function PANEL:SetVisible(b)
	if b==true then
		self:MakePopup();

		self.top:SetVisible(true);
		self.bottom:SetVisible(true);
		self.entry:RequestFocus();

		self:SetKeyBoardInputEnabled(true);
		self:SetMouseInputEnabled(true);
	elseif b==false then
		self.top:SetVisible(false);
		self.bottom:SetVisible(false);

		self:SetKeyBoardInputEnabled(false);
		self:SetMouseInputEnabled(false);
	end

	self._visible=b;


end
function PANEL:Paint(w,h)
	if self:GetVisible() then
		surface.SetDrawColor(ES.Color.Black);
			surface.DrawRect(0,0,w,h);
		surface.SetDrawColor(ES.Color["#1E1E1EFF"]);
			surface.DrawRect(1,1,w-2,h-2);
	end
end
function PANEL:PaintOver(w,h)
	if self:GetVisible() then
		surface.SetDrawColor(ES.Color["#000000FF"]);
			surface.DrawLine(0,0,w,0);
			surface.DrawLine(0,0,0,h-1);
			surface.DrawLine(0,h-1,w-1,h-1);
			surface.DrawLine(w-1,0,w-1,h-1);
		surface.SetDrawColor(ES.Color["#FFFFFF01"]);
			surface.DrawLine(1,1,w-2,2);
			surface.DrawLine(1,2,1,h-2);
			surface.DrawLine(w-2,1,w-2,h-3);
			surface.DrawLine(1,h-2,w-2,h-2);
	end
end
vgui.Register("esChat",PANEL,"EditablePanel")