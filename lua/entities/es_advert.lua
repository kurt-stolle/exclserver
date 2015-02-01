-- es_advert.lua

AddCSLuaFile();

ENT.Type             = "anim"
ENT.Base             = "base_anim"
function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "Text" );
	self:NetworkVar( "Float", 1, "TextScale" );
	self:NetworkVar( "Int", 2, "XAlignment" );
	self:NetworkVar( "Int", 3, "ID");

end
function ENT:Initialize()    
  if SERVER then
    self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" );

    local min = self.min or Vector(-100,-50,-100);
    local max = self.max or Vector(100,100,100);

    self:SetMoveType(MOVETYPE_NONE);
    self:SetSolid(SOLID_NONE);

    --self:SetRenderBounds();

    local phys = self:GetPhysicsObject();
    if phys and phys:IsValid() then
      phys:EnableMotion(false); -- Freezes the object in place.
    end   
  end
end

if SERVER then return end

surface.CreateFont("ESAdvertFont",{
	font = "Calibri",
	size = 98,
	weight = 300,
})
surface.CreateFont("ESAdvertFontBlur",{
	font = "Calibri",
	size = 98,
	weight = 300,
	blursize = 2,
})

function ENT:Draw()
	if not self:GetText() or not self:GetTextScale() or not self:GetXAlignment() then self:DrawModel() return end

	local dist = self:GetPos():Distance(LocalPlayer():EyePos());
	if dist > 1200 then return end

	local alpha = 255;
	if dist > 400 then
		alpha = 255 - (dist-400)/800 * 255;
	end

	local ang = self:GetAngles();
	ang:RotateAroundAxis(ang:Up(),90);
	ang:RotateAroundAxis(ang:Forward(),90);

	cam.Start3D2D( self:GetPos(), ang, self:GetTextScale() )
		draw.SimpleText(self:GetText(),"ESAdvertFontBlur",1,1,Color(0,0,0,alpha),self:GetXAlignment(),1);
		draw.SimpleText(self:GetText(),"ESAdvertFont",0,0,Color(255,255,255,alpha),self:GetXAlignment(),1);
	cam.End3D2D();
end

ES.AddCommand("advert",function()end,60)
ES.AddCommand("editadvert",function()end,60)

hook.Add("HUDPaint","debugddDrawAdIDs",function()
	if ES.Debug then

		for k,v in pairs(ents.FindByClass("es_advert"))do
			local pos = v:GetPos():ToScreen();
			draw.SimpleTextOutlined("Ad "..(v:GetID() or '0'), "ESDefault",pos.x,pos.y,COLOR_WHITE,1,1,1,COLOR_BLACK);
		end

	end
end);