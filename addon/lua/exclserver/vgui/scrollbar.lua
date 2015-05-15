--button
local PANEL = {}

AccessorFunc(PANEL,"_dragging","Dragging",FORCE_BOOL);
AccessorFunc(PANEL,"_autoScroll","AutoScroll",FORCE_BOOL);
function PANEL:Init()
	self:SetWide(8);
	self:DockMargin(0,0,0,0);
	self:Dock(RIGHT);

	self.Elements = {}
	self.scrollMax = 0

	self:SetDragging(false);

	self.button = vgui.Create("esScrollbar.Button",self)
	self.button:SetPos(1,1)
	self.button:SetWide(self:GetWide()-2);

	self.curScroll = 0;

	self.maxScroll = 0;
end
function PANEL:Setup()
	self.Elements = self:GetParent():GetChildren()

	for k,v in ipairs(self.Elements)do
		if v.ClassName == "esScrollbar" then
			table.remove(self.Elements,k)
		end
	end

	local hMax = 0
	for k,v in ipairs(self.Elements) do
		v._esScrollbar_originalY = v.y + self.curScroll;
		if v._esScrollbar_originalY + v:GetTall() > hMax then
			hMax = v._esScrollbar_originalY + v:GetTall();
		end
	end

	self.button:SetTall(math.Clamp( (self:GetParent():GetTall()/hMax) * (self:GetTall()-2),self:GetWide()-2,self:GetTall()-2))

	self.oldMax=self.maxScroll;
	self.maxScroll=hMax;

	if self:GetAutoScroll() and self.oldMax ~= self.maxScroll then
		self:Scroll(99999,true)
	end
end
function PANEL:Scroll(y,setButton)
	y = math.Clamp(y,0,self.maxScroll-self:GetParent():GetTall());

	if setButton then
		self.button.y = (y/(self.maxScroll-self:GetParent():GetTall()) * (self:GetTall()-2-self.button:GetTall()))+1
	end

	for k,v in ipairs(self.Elements)do
		v.y = (v._esScrollbar_originalY or 0) - y
	end

	self.curScroll = y;
end
function PANEL:Think()
	if not self:GetDragging() then
		return;
	elseif not (input.IsMouseDown(MOUSE_LEFT)) then
		self:SetDragging(false);
		return;
	end

	local _,y = gui.MousePos()

	self.button.y = math.Clamp(self.button.y + (y-self.startDrag),1,self:GetTall()-2-self.button:GetTall());
	self.startDrag = y;

	self:Scroll( math.ceil(((self.button.y-1) / (self:GetTall()-2-self.button:GetTall())) * (self.maxScroll-self:GetParent():GetTall())) )
end
function PANEL:Paint(w,h)
	local a,b,c = ES.GetColorScheme()

	draw.RoundedBox(4,0,0,w,h,ES.Color["#000000AF"]);

	if self.PaintHook then
		self.PaintHook()
	end
end
vgui.Register( "esScrollbar", PANEL, "Panel" )

local PANEL = {}
ES.UIAddHoverListener(PANEL);
function PANEL:OnMousePressed()
	self:GetParent():SetDragging(true);

	local _,y=gui.MousePos()
	self:GetParent().startDrag = y
end
function PANEL:Paint(w,h)
	draw.RoundedBox(4,0,0,w,h,ES.GetColorScheme(1));
end
vgui.Register( "esScrollbar.Button", PANEL, "Panel")
