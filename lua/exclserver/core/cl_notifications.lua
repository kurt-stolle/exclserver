-- cl_notifications.lua
-- ####################################################################################
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     CASUAL BANANAS CONFIDENTIAL                                                ##
-- ##                                                                                ##
-- ##     __________________________                                                 ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Copyright 2014 (c) Casual Bananas                                          ##
-- ##     All Rights Reserved.                                                       ##
-- ##                                                                                ##
-- ##     NOTICE:  All information contained herein is, and remains                  ##
-- ##     the property of Casual Bananas. The intellectual and technical             ##
-- ##     concepts contained herein are proprietary to Casual Bananas and may be     ##
-- ##     covered by U.S. and Foreign Patents, patents in process, and are           ##
-- ##     protected by trade secret or copyright law.                                ##
-- ##     Dissemination of this information or reproduction of this material         ##
-- ##     is strictly forbidden unless prior written permission is obtained          ##
-- ##     from Casual Bananas                                                        ##
-- ##                                                                                ##
-- ##     _________________________                                                  ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Casual Bananas is registered with the "Kamer van Koophandel" (Dutch        ##
-- ##     chamber of commerce) in The Netherlands.                                   ##
-- ##                                                                                ##
-- ##     Company (KVK) number     : 59449837                                        ##
-- ##     Email                    : info@casualbananas.com                          ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ####################################################################################

-- Fonts
surface.CreateFont("ES.Notification",{
	font = "roboto",
	weight = 400,
	size = 26
});

surface.CreateFont("ES.Notification.Shadow",{
	font = "roboto",
	weight = 400,
	size = 26,
	blursize = 2,
});

/* 

BANANAS NOTIFICATIONS

*/
color_black = ES.Color.Black;
color_white = ES.Color.White;
local icon_bananas = Material("exclserver/bananas.png");
local icon_notification = Material("exclserver/notifications/generic.png");
local bananaDisplay = 0;
local bananaOld = 0;
local didLoad = false;
local fadeToDark = 0;
local x,y = 16,16;
local p;
local colorBlur;
local popModelMatrix = cam.PopModelMatrix
local pushModelMatrix = cam.PushModelMatrix
local pushFilterMag = render.PushFilterMag;
local pushFilterMin = render.PushFilterMin;
local popFilterMag = render.PopFilterMag;
local popFilterMin = render.PopFilterMin;
local setMaterial = surface.SetMaterial;
local setDrawColor = surface.SetDrawColor;
local drawTexturedRect = surface.DrawTexturedRect;
local simpleText = draw.SimpleText;
local sin=math.sin;
local cos=math.cos;
local deg2rad=math.rad;
local floor=math.floor;
local matrixAngle = Angle(0, 0, 0)
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)
local halvedPi = math.pi/2;
local color=Color(255,255,255,255);
local color_dark=Color(0,0,0,255);
local clamp = math.Clamp;
local scale=0;
local ang = 0;
local color_circle = Color(255,255,255,0);
local color_text = Color(255,255,255,0);
local color_text_dark = Color(0,0,0,255);
local matrix,width,height,rad
local text = "";
local function drawText(text)
	simpleText(text,"ES.Notification.Shadow"	,x,y+(32/2),color_black,0,1);
	simpleText(text,"ES.Notification"		,x,y+(32/2),color_white,0,1);
end

hook.Add("HUDPaint","ESDrawBananasToHUD",function()
	x,y = 16,16;
	p = LocalPlayer();

	setDrawColor(color_white);
	setMaterial(icon_bananas);
	drawTexturedRect(x-16,y-16,64,64);

	if not (IsValid(p) and p.excl ) then
		x=x+32+16
		drawText("Loading...");
	else
		if not didLoad then
			bananaDisplay = p:ESGetBananas();
			didLoad = true;
		end
		local add = 0;
		local bananaDisplayRound = math.Round(bananaDisplay);
		if bananaDisplayRound != p:ESGetBananas() then
			if bananaDisplay - p:ESGetBananas() > 0 then
				bananaDisplay = Lerp(0.01,bananaDisplay-1,p:ESGetBananas());
			else
				bananaDisplay = Lerp(0.01,bananaDisplay+1,p:ESGetBananas());
			end
			add = (p:ESGetBananas()-bananaDisplayRound)
		else
			bananaDisplay = bananaDisplayRound;
		end

		x=x+32+16
		drawText(tostring(bananaDisplayRound));
	end
end)

/*

TEXT NOTIFICATIONS

*/

local queue={};

function ES.Notify(kind,msg)
	if type(kind) != "string" or type(msg) != "string" or (kind != "generic" and kind != "error") then
		return
	end

	table.insert(queue,{kind=kind,msg=msg,lifetime=0});
end

net.Receive("ES.SendNotification",function(len)
	ES.Notify(net.ReadString(),net.ReadString());
end)



hook.Add("HUDPaint","ES.Notifications",function()
	if queue[1] then
		scale = Lerp(FrameTime()*8,scale,1);
		text = queue[1].msg;

		if scale > .9 then
			queue[1].lifetime = queue[1].lifetime + FrameTime();
			if queue[1].lifetime > 2 then
				color_text.a = Lerp(FrameTime()*10,color_text.a,0);
				if color_text.a < 1 then
					table.remove(queue,1);
				end
			else
				color_text.a = Lerp(FrameTime()*10,color_text.a,255);
			end
		end

	else
		color_text.a = Lerp(FrameTime()*10,color_text.a,0);

		if color_text.a < 1 then
			scale = Lerp(FrameTime()*8,scale,0);
		end
	end

	if scale > 0.001 then
		-- setup matrix
		rad = -deg2rad( ang )
		x = 32 - ( sin( rad + halvedPi ) * 64*scale / 2 + sin( rad ) * 64*scale / 2 )
		y = 64+32 - ( cos( rad + halvedPi ) * 64*scale / 2 + cos( rad ) * 64*scale / 2 )
		
		color_circle.a = scale*255;

		matrix=Matrix();
		matrixAngle.y = ang;
		matrix:SetAngles( matrixAngle )
		matrixTranslation.x = x;
		matrixTranslation.y = y;
		matrix:SetTranslation( matrixTranslation )
		matrixScale.x = scale;
		matrixScale.y = scale;
		matrix:Scale( matrixScale )

		-- push matrix
		pushModelMatrix( matrix )

		-- draw
		setMaterial(icon_notification);
		setDrawColor(color_circle);
		drawTexturedRect(0,0,64,64,0);

		-- pop matrix
		popModelMatrix()
	end

	if color_text.a >= 1 then
		-- draw text
		color_text_dark.a = color_text.a * (220/255);
		x,y = 64,64+16;
		drawText(text);
	end
end);