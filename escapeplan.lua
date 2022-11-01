exit1,escape1,exit2,escape2 = 0
escapedplrs = {}

function OnScriptLoaded() print("EscapePlan"); return -1 end

function OnServerStart()
    for i = 1, 10 do createfakeplayer(i) end
    escapecoords()
    return -1
end

function OnServerRestart() escapecoords(); return -1 end

function escapecoords()
    local entitypointers = {}
    local debounce
    local findcoords = function(room,index,index2)
        entity,entity2 = getroomobjectentity(room,index), getroomobjectentity(room,index2)
        return true,{entityx(entity),entityy(entity),entityz(entity)},{entityx(entity2),entityy(entity2),entityz(entity2)}
    end
    local select = {
        ["exit1"] = function(i) entitypointers[1], exit1, escape1 = findcoords(i,26,27) end,
        ["gatea"] = function(i) entitypointers[2], exit2, escape2 = findcoords(i,27,11) end,
        ["gateaentrance"] = function(i) entitypointers[3] = true end
    }    
    for i = 1, 70 do
        if type(select[getroomname(i)]) == "function" then select[getroomname(i)](i) end
        if entitypointers[1] and entitypointers[2] and entitypointers[3] then
            debounce = true; break
        end
    end
    if not debounce then restartserver() end
end

function OnPlayerEscapeButDead(plr,_,before) --make them actually escape
	setplayertype(plr,before)
	escapedplrs[plr] = true
	if before == 3 then SetPlayerPosition(plr,"gatea", escape2[0], escape2[1], escape2[2]) else SetPlayerPosition(plr,"exit1", escape1[0], escape1[1], escape1[2]) end
end

function escaped(plr,before)
    if not escapedplrs[plr] then return end
    escapedplrs = false --Remove them from escapedplrs list
    if before == 7 then SetPlayerPosition(plr,"exit1", exit1[0], exit1[1], exit1[2]) else SetPlayerPosition(plr,"gatea", exit2[0], exit2[1], exit2[2]) end
    --If they're on the list and turns into Chaos, then they escaped tho gate b. Otherwise they must have escaped tho gate a.
end

function OnPlayerEscape(plr,before) CreateTimer("escaped",100,0,plr,before) end --execute escaped function after 100 milliseconds to make room for the natural (delayed) spawn position change	