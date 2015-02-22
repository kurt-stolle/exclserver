AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"

function ENT:Initialize()    
  if SERVER then
    self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )

    local min = self.min or Vector(-100,-50,-100)
    local max = self.max or Vector(100,100,100)

    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)

    self:PhysicsInitBox(min,max)
    self:SetCollisionBounds(min,max)

    local phys = self:GetPhysicsObject()
    if phys and phys:IsValid() then
      phys:EnableMotion(false) -- Freezes the object in place.
    end   
  end
end

if SERVER then return end

local cube = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl",RENDERGROUP_BOTH)
cube:SetNoDraw(true)

function ENT:Draw()
  if LocalPlayer().editingBlockades then
    self:SetRenderBounds(self:OBBMins(),self:OBBMaxs())

    cube:SetRenderOrigin(self:LocalToWorld(self:OBBCenter()))
    cube:SetRenderAngles( self:GetAngles() )
    
    local mtr = Matrix()
    mtr:Scale( (self:OBBMaxs() - self:OBBMins())/11.75 )
    cube:EnableMatrix("RenderMultiply", mtr )

    cube:SetupBones()
    cube:SetColor(Color(255,255,255))
    cube:DrawModel()
    
    cube:SetRenderOrigin()
    cube:SetRenderAngles()
  end
end

local blockadeStart = false
local blockadeEnd = false
local drawingBlockades = false
net.Receive("ESBlockStart",function()
  blockadeStart = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 10
  drawingBlockades = true
  blockadeEnd = false
end)
net.Receive("ESBlockEnd",function()
  blockadeEnd = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 30
end)
net.Receive("ESBlockConfirm",function()
  ES.ChatAddText("server",COLOR_WHITE,"Blockade added, type :blockadeStart to add a new blockade.")
  blockadeStart = false
  blockadeEnd = false
  drawingBlockades = false
end)

hook.Add("PostDrawTranslucentRenderables","ESPaintBlockades",function()
  if LocalPlayer().editingBlockades and drawingBlockades and blockadeStart then
      local ending = Vector(0,0,0)
      if not blockadeEnd then 
        ending = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 30
      else
        ending = blockadeEnd
      end

      cube:SetRenderOrigin(blockadeStart + (ending - blockadeStart)/2)
      cube:SetRenderAngles( Angle(0,0,0) )
      
      local mtr = Matrix()
      mtr:Scale( (ending - blockadeStart)/11.75 )
      cube:EnableMatrix("RenderMultiply", mtr )

      cube:SetupBones()
      cube:SetColor(Color(255,0,0))
      cube:DrawModel()
      
      cube:SetRenderOrigin()
      cube:SetRenderAngles()
    end
end)