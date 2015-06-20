-- Utilities
function ES.RGBToHex(color)
	local tab={color.r,color.g,color.b,color.a}

	local hexadecimal="#"
	for key, value in ipairs(tab) do
		local hex = ''

		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex
		end

		if(string.len(hex) == 0)then
			hex = '00'

		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end
function ES.HexToRGB(key)
	if string.len(key) < 9 or string.Left(key,1) ~= "#" then return nil end

	return Color(tonumber("0x"..key:sub(2,3)), tonumber("0x"..key:sub(4,5)), tonumber("0x"..key:sub(6,7)), tonumber("0x"..key:sub(8,9)) )
end

-- Color caching function
ES.Color = {}
setmetatable(ES.Color,{
	__index = function(tbl,key)
		if type(key) == "string" then
			if #key == 4 then
				return tbl["#"..key[2].."F"..key[3].."F"..key[4].."F".."FF"]
			elseif #key == 7 then
				return tbl[key.."FF"]
			elseif #key == 9 then
				rawset( tbl, key, ES.HexToRGB(key) ) -- Cache the result - we may need it later!
				return rawget(tbl,key)
			end
		end

		return Color(math.random(0,255),math.random(0,255),math.random(0,255))
	end
})

ES.Color.Invisible  = ES.Color["#00000000"];
ES.Color.Black 		= ES.Color["#000"]
ES.Color.White 		= ES.Color["#FFF"]
ES.Color.Red 		= ES.Color["#e51c23"]
ES.Color.Pink 		= ES.Color["#e91e63"]
ES.Color.Purple 	= ES.Color["#9c27b0"]
ES.Color.DeepPurple = ES.Color["#673ab7"]
ES.Color.Indigo 	= ES.Color["#e351b5"]
ES.Color.Blue 		= ES.Color["#5677fc"]
ES.Color.LightBlue 	= ES.Color["#03a9f4"]
ES.Color.Cyan 		= ES.Color["#00bcd4"]
ES.Color.Teal 		= ES.Color["#009688"]
ES.Color.Green 		= ES.Color["#259b24"]
ES.Color.LightGreen	= ES.Color["#8bc34a"]
ES.Color.Lime 		= ES.Color["#cddc39"]
ES.Color.Yellow 	= ES.Color["#ffeb3b"]
ES.Color.Amber 		= ES.Color["#ffc107"]
ES.Color.Orange 	= ES.Color["#ff9800"]
ES.Color.DeepOrange	= ES.Color["#ff5722"]
ES.Color.Brown 	 	= ES.Color["#795548"]
ES.Color.Grey 	 	= ES.Color["#9e9e9e"]
ES.Color.BlueGrey 	= ES.Color["#607d8b"]
ES.Color.Highlight = ES.Color.LightGreen

-- Allow users to customize
local firstColor = Color(20,165,180)
local secondColor = Color(24,135,150)
local thirdColor = Color(28,105,120)

function ES.SaveColorScheme()
	if not file.IsDir("exclserver","DATA") then
		file.CreateDir("exclserver")
	end

	file.Write("exclserver/colors.txt",util.TableToJSON{first=firstColor,second=secondColor,third=thirdColor});
end
function ES.GetColorScheme(n)
	if type(n) == "number" then
		if n == 1 then
			return firstColor
		elseif n == 2 then
			return secondColor
		elseif n == 3 then
			return thirdColor
		end
	end

	return firstColor, secondColor, thirdColor
end
function ES.PushColorScheme(f,s,t)
	if not f or not s or not t then
		ES.DebugPrint("Color scheme has been reset.");

		firstColor = Color(20,165,180)
		secondColor = Color(24,135,150)
		thirdColor = Color(28,105,120)

		return
	end

	firstColor.r = f.r
	firstColor.g = f.g
	firstColor.b = f.b
	secondColor.r = s.r
	secondColor.g = s.g
	secondColor.b = s.b
	thirdColor.r = t.r
	thirdColor.g = t.g
	thirdColor.b = t.b
end


if file.Exists("exclserver/colors.txt","DATA") then
	local v=util.JSONToTable(file.Read("exclserver/colors.txt","DATA"));
	ES.PushColorScheme(v.first,v.second,v.third)
end
