ES.Color = {}
setmetatable(ES.Color,{
	__index = function(tbl,key)
		if type(key) == "string" then
			if #key == 4 then
				return tbl["#"..key[2]..key[2]..key[3]..key[3]..key[4]..key[4].."FF"];
			elseif #key == 7 then
				return tbl[key.."FF"];
			elseif #key == 9 then
				rawset( tbl, key, Color(tonumber("0x"..key:sub(2,3)), tonumber("0x"..key:sub(4,5)), tonumber("0x"..key:sub(6,7)), tonumber("0x"..key:sub(8,9)) ) ); -- Cache the result - we may need it later!
				return rawget(tbl,key);
			end
		end

		ES.DebugPrint("Invalid HEX-value passed to ES color parser.");
		
		return Color(math.random(0,255),math.random(0,255),math.random(0,255));
	end
});

ES.Color.Black 		= ES.Color["#000"];
ES.Color.White 		= ES.Color["#FFF"];
ES.Color.Red 		= ES.Color["#e51c23"];
ES.Color.Pink 		= ES.Color["#e91e63"];
ES.Color.Purple 	= ES.Color["#9c27b0"];
ES.Color.DeepPurple = ES.Color["#673ab7"];
ES.Color.Indigo 	= ES.Color["#e351b5"];
ES.Color.Blue 		= ES.Color["#5677fc"];
ES.Color.LightBlue 	= ES.Color["#03a9f4"];
ES.Color.Cyan 		= ES.Color["#00bcd4"];
ES.Color.Teal 		= ES.Color["#009688"];
ES.Color.Green 		= ES.Color["#259b24"];
ES.Color.LightGreen	= ES.Color["#8bc34a"];
ES.Color.Lime 		= ES.Color["#cddc39"];
ES.Color.Yellow 	= ES.Color["#ffeb3b"];
ES.Color.Amber 		= ES.Color["#ffc107"];
ES.Color.Orange 	= ES.Color["#ff9800"];
ES.Color.DeepOrange	= ES.Color["#ff5722"];
ES.Color.Brown 	 	= ES.Color["#795548"];
ES.Color.Grey 	 	= ES.Color["#9e9e9e"];
ES.Color.BlueGrey 	= ES.Color["#607d8b"];

-- Allow users to customize
local firstColor = Color(20,160,160);
local secondColor = Color(60,140,140);
local thirdColor = Color(60,80,80);
hook.Add("InitPostEntity","esLoadPlayerCustomizations",function()
	if file.Read("es_color_customization.txt","DATA") then
		for k,v in pairs(util.JSONToTable(file.Read("es_color_customization.txt","DATA")))do
			ES.PushColorScheme(v.first,v.second,v.third);
		end 
	end
end)
function ES.SaveColorScheme()

end
function ES.GetColorScheme(n)
	if n and n == 1 then
		return firstColor;
	elseif n and n == 2 then
		return secondColor;
	elseif n and n == 3 then
		return thirdColor;
	end

	return firstColor, secondColor, thirdColor;
end
function ES.PushColorScheme(f,s,t)
	if not f or not s or not t then -- reset
		firstColor = Color(20,160,160);
		secondColor = Color(60,140,140);
		thirdColor = Color(60,80,80);
		return;
	end

	firstColor.r = f.r;
	firstColor.g = f.g;
	firstColor.b = f.b;
	secondColor.r = s.r;
	secondColor.g = s.g;
	secondColor.b = s.b;
	thirdColor.r = t.r;
	thirdColor.g = t.g;
	thirdColor.b = t.b;
end