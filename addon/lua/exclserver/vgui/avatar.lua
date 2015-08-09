-- variables
local mat=Material("models/debug/debugwhite")

-- Table
local PNL={}

-- Metamethods
function PNL:Paint(w,h)
  if not self.circle or self.circe_rad ~= w then
    self.circle=ES.GenerateCirclePoly(w/2,h/2,w/2,16)
  end

  render.ClearStencil()
	render.SetStencilEnable( true )

  render.SetStencilFailOperation( STENCILOPERATION_INCR )
  render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
  render.SetStencilPassOperation( STENCILOPERATION_KEEP )
  render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

  surface.SetDrawColor( ES.Color.White )
  surface.SetMaterial(mat)
  surface.DrawPoly(self.circle)

  render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
end
function PNL:PaintOver(w,h)
  render.SetStencilEnable( false )
end

-- Registeer
vgui.Register("esAvatar",PNL,"AvatarImage")
