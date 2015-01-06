-- sh_emotes
-- for gestures.

ES.EmotesBuy = {}

function  ES:AddEmote(n,d,p,i,g) -- maybe a bit silly to not just edit the table, but we want to make it so people who edit ExclServer do not have to touch files in core/
	ES.EmotesBuy[n] = {name = n, discr = d, cost = p, icon = i, gest = g}; 
end

ES:AddEmote ("Wave",d,p,i,g)
