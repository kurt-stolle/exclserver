local PANEL={}
AccessorFunc(PANEL,"_visible","Visible",FORCE_BOOL);
AccessorFunc(PANEL,"_team","Team",FORCE_BOOL);
function PANEL:Init()
	self.BaseClass.Init(self)

	ES.DebugPrint("Created ExclServer chat panel.");

	self:SetTitle("Casual Bananas Chat")

	local scrollpanel=self:Add("esPanel")
	scrollpanel:SetColor(ES.Color.Invisible)
	scrollpanel:Dock(FILL)
	scrollpanel:DockMargin(4,4,4,4)
	scrollpanel:AddScrollbar()
	scrollpanel:SetAutoScroll(true)

		local container=scrollpanel:Add("Panel")
		function container.PerformLayout(_self)
				local hMax = 0
				for k,v in ipairs(_self:GetChildren())do
					if v.y + v:GetTall() > hMax then
						hMax = v.y + v:GetTall()
					end
				end
				_self:SetTall(hMax)
				_self:SetWide(_self:GetParent():GetWide()-4*2-_self:GetParent().scrollbar:GetWide())
		end

	local bottom=self:Add("esPanel");
	bottom:Dock(BOTTOM);
	bottom:SetTall(32);
	bottom:SetColor(ES.Color["#151515FF"])

		local entry=bottom:Add("esTextEntry");
		entry:Dock(BOTTOM);
		entry:DockMargin((32-24)/2,(32-24)/2,(32-24)/2,(32-24)/2);
		entry:SetHistoryEnabled(true);
		entry:SetFont("ESChatFont");

		local send=bottom:Add("esIconButton");
		send:SetIcon(Material("exclserver/arrow_right.png"));
		send:SetWide(32);
		send:Dock(RIGHT);
		send:DockMargin(0,0,0,0);
		send.DoClick=function()
			local str=string.Trim(entry:GetValue())
			local prefix=string.Left(str,1)
			if prefix == "!" or prefix == ":" or prefix == "/" then

				local ret=ES.ExplodeQuotes(string.Right(str,string.len(str)-1));

				local cmd=ret[1]
				table.remove(ret,1)

				if ES.Commands[cmd] then
					RunConsoleCommand("excl",cmd,unpack(ret))

					ES.DebugPrint("Command ran: "..cmd)

					entry:SetText("");
					entry:SetValue("");
					self:SetVisible(false);

					return
				end
			end

			RunConsoleCommand(self._team and "say_team" or "say",str);

			entry:AddHistory(entry:GetValue())
			entry:SetText("");
			entry:SetValue("");
			self:SetVisible(false);
		end

		entry.OnEnter=send.DoClick;


	self.bottom=bottom;
	--self.top=top;
	self.container=container
	self.scrollpanel=scrollpanel
	--self.title=title
	self.entry=entry

	self.becomeInvisible=0;

	self.btn_close.OnMouseReleased=function()
		self:SetVisible(false)
	end
end
function PANEL:Think()
	self.BaseClass.Think(self)

	if CurTime() > self.becomeInvisible then
		self:HardSetVisible(false);
	end


end
PANEL.HardSetVisible = PANEL.SetVisible;
function PANEL:SetVisible(b)
	self:HardSetVisible(true);

	if b==true then
		self:MakePopup();

		--self.top:SetVisible(true);
		self.bottom:SetVisible(true);
		self.scrollpanel.scrollbar:SetVisible(true);
		self.entry:RequestFocus();
		self.btn_close:SetVisible(true)

		self:SetKeyBoardInputEnabled(true);
		self:SetMouseInputEnabled(true);

		self.becomeInvisible=CurTime()+99999999
	elseif b==false then
		--self.top:SetVisible(false);
		self.bottom:SetVisible(false);
		self.scrollpanel.scrollbar:SetVisible(false);
		self.btn_close:SetVisible(false)

		self:SetKeyBoardInputEnabled(false);
		self:SetMouseInputEnabled(false);
		self.becomeInvisible=CurTime()+3;
	end

	self._visible=b;


end
function PANEL:Paint(w,h)
	if self:GetVisible() then
		self.BaseClass.Paint(self,w,h)
	end
end
function PANEL:PaintOver(w,h)
	if self:GetVisible() then
		self.BaseClass.PaintOver(self,w,h)
	end
end
vgui.Register("esChat",PANEL,"esFrame")
