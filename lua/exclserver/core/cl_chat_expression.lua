ES.Expressions = {}
setmetatable(ES.Expressions,{
	__index = function(self,key)
		for k,v in ipairs(self) do
			if v:GetExpression() == key or v:GetID() == key then
				return v
			end
		end
		return nil
	end
})

local meta = {}
AccessorFunc(meta,"expression","Expression",FORCE_STRING)
AccessorFunc(meta,"id","ID",FORCE_STRING)
AccessorFunc(meta,"prettyExpression","PrettyExpression",FORCE_STRING)
function ES.Expression(expr, id)
	if not expr or type(expr) ~= "string" or not id or type(id) ~= "string" then
		ES.DebugPrint("Failed to contruct new expression.")
		return
	end

	local obj = {}

	setmetatable(obj, meta)
	meta.__index = meta

	obj:SetExpression(expr)
	obj:SetPrettyExpression(expr) -- Should be overriden if the expression is ugly because of patterns, etc.
	obj:SetID(id)

	table.insert(ES.Expressions,obj)

	return obj
end
function meta:GetPlayer()
	return self.player
end

-- EMOTES
local emotes = {}
emotes[":)"] = "icon16/emoticon_smile.png"
emotes[":D"] = "icon16/emoticon_happy.png"
emotes[":O"] = "icon16/emoticon_surprised.png"
emotes[":p"] = "icon16/emoticon_tongue.png"
emotes[":P"] = "icon16/emoticon_tongue.png"
emotes[":("] = "icon16/emoticon_unhappy.png"
-- NOTE: Add new emotes under this line.

-- NOTE: Add new emotes above this line.

local escape = '(['..("%^$().[]*+-?"):gsub("(.)", "%%%1")..'])'
for k,v in pairs(emotes) do
	local expression = ES.Expression("("..string.gsub(k,escape, "%%%1")..")",k)
	expression.image = true

	function expression:Execute(base)
		local img = base:Add("DImage")
		img:SetImage(v)
		img:SetSize(16, 16)
		img:SetMouseInputEnabled(true)

		return img
	end
end

-- NO PARSING
local expression = ES.Expression("<noparse>(.-)</noparse>","noparse")
expression:SetPrettyExpression("<noparse> </noparse>")
function expression:Execute(base,text)
	local label = vgui.Create("esLabel")
	label:SetParent(base)
	label:SetText(text)
	label:SetShadow(2)
	label:SetColor(ES.Color.White)
	label:SizeToContents(base)

	return label
end

-- CLICKABLE URL :)
local expression = ES.Expression("<url>(.-)</url>", "url")
expression:SetPrettyExpression("<url> </url>")

local color_url=ES.Color["#03F"]
function expression:Execute(base,text)
	local label = vgui.Create("esLabel")
	label:SetFont("ESChatFont");
	label:SetParent(base)
	label:SetText(text)
	label:SetShadow(2)
	label:SetColor(color_url)
	label:SizeToContents(base)

	function label:PaintOver(w, h)
		surface.SetDrawColor(color_url)
		surface.DrawLine(0, h -1, w, h -1)
	end

	function label:OnCursorEntered()
		self:SetCursor("hand")
	end

	function label:OnCursorExited()
		self:SetCursor("arrow")
	end

	function label:OnMouseReleased()
		gui.OpenURL(self:GetText())
	end

	return label
end

-- COLOURED TEXT
local expression = ES.Expression("<c=#(%x%x%x%x%x%x)>(.-)</c>", "color")
expression:SetPrettyExpression("<c=#HEX> </c>")

function expression:Execute(base, color, text)
	local color = ES.Color["#"..color]

	local label = vgui.Create("esLabel")
	label:SetFont("ESChatFont");
	label:SetParent(base)
	label:SetText(text)
	label:SetShadow(2)
	label:SetColor(color)
	label:SizeToContents(base)

	return label
end

-- AVATARS
local av_size=32 -- easy changing later.

local expression = ES.Expression("<av=(STEAM_[0-5]:[01]:%d+)>","image-avatar")
expression:SetPrettyExpression("<av=STEAMID>")
function expression:Execute(base, sid)
	if not sid then return end

	sid = util.SteamIDTo64(sid)

	local avatar = vgui.Create("AvatarImage")
	avatar:SetParent(base)
	avatar:SetSize(24,24)
	avatar:SetSteamID(sid, av_size)
	local paint=avatar.Paint;
	avatar.Paint=function()
		render.PushFilterMag(TEXFILTER.ANISOTROPIC);
		render.PushFilterMin(TEXFILTER.ANISOTROPIC);
	end
	avatar.PaintOver=function()
		render.PopFilterMag();
		render.PopFilterMin();
	end



	return avatar
end

-- HIGHLIGHT
local expression = ES.Expression("<hl>(.-)</hl>", "highlight")
expression:SetPrettyExpression("<hl> </hl>")

function expression:Execute(base, text)
	local label = vgui.Create("esLabel")
	label:SetFont("ESChatFont");
	label:SetParent(base)
	label:SetShadow(2)
	label:SetText(text)
	label:SetColor(ES.Color.LightGreen);
	label:SizeToContents(base)

	return label
end

-- SPOILER
local expression = ES.Expression("<sp>(.-)</sp>", "spoiler")
expression:SetPrettyExpression("<sp> </sp>")
function expression:Execute(base, text)
	local label = vgui.Create("esLabel")
	label:SetFont("ESChatFont");
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(ES.Color.White)
	label:SetShadow(2)
	label:SizeToContents(base)
	label:SetMouseInputEnabled(true)
	ES.UIAddHoverListener(label);

	function label:PaintOver(w, h)
		if (!self.clicked) then
			surface.SetDrawColor(ES.Color["#222"])
			surface.DrawRect(0,0,w,h)
		end
	end

	function label:OnMousePressed()
		self.clicked = true
	end

	return label
end

-- REVERSE
local expression = ES.Expression("<rev>(.-)</rev>", "reverse")
expression:SetPrettyExpression("<rev> </rev>")

function expression:Execute(base, text)
	local text = string.reverse(text)

	local label = vgui.Create("esLabel")
	label:SetFont("ESChatFont");
	label:SetParent(base)
	label:SetText(text)
	label:SizeToContents(base)
	label:SetShadow(2)
	label:SetColor(base.activeColor);

	return label
end

-- ITALIC
local expression = ES.Expression("<i>(.-)</i>", "italic")
expression:SetPrettyExpression("<i> </i>")

function expression:Execute(base, text)
	local label = vgui.Create("esLabel")
	label:SetFont("ESChatFont.Italic");
	label:SetParent(base)
	label:SetText(text)
	label:SizeToContents(base)
	label:SetShadow(2)
	label:SetColor(base.activeColor);

	return label
end

-- BOLD
local expression = ES.Expression("<b>(.-)</b>", "bold")
expression:SetPrettyExpression("<b> </b>")

function expression:Execute(base, text)

	local label = vgui.Create("esLabel")
	label:SetFont("ESChatFont.Bold");
	label:SetParent(base)
	label:SetText(text)
	label:SizeToContents(base)
	label:SetShadow(2)
	label:SetColor(base.activeColor);

	return label
end
