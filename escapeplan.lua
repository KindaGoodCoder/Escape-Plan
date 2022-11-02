exit1,escape1,exit2,escape2 = 0
escapedplrs = {}

function OnScriptLoaded()
    print("EscapePlan")
    return -1
end

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
	if before == 3 then setplayerposition(plr,"gatea", escape2[1], escape2[2], escape2[3]) else setplayerposition(plr,"exit1", escape1[1], escape1[2], escape1[3]) end
    return -1
end

function escaped(plr,before)
    print(os.time().."plr")
    if escapedplrs[plr] then
        print("mango")
        escapedplrs[plr] = false --Remove them from escapedplrs list
        if before == 7 then setplayerposition(plr,"exit1", exit1[1], exit1[2], exit1[3]) else setplayerposition(plr,"gatea", exit2[1], exit2[2], exit2[3]) end
        --If they're on the list and turns into Chaos, then they escaped tho gate b. Otherwise they must have escaped tho gate a.
    end
    return -1
end

function OnPlayerEscape(plr,before);print(os.time()); createtimer("escaped",5000,0,plr,before); print(plr); return -1 end --execute escaped function after 100 milliseconds to make room for the natural (delayed) spawn position change

function OnPlayerCuffPlayer(_,plr)
    if getplayerhandcuff(plr) == 0 then	return -1 end
    local role = getplayertype(plr)
    room = getroomname(getplayerroomid(plr))
    local plrentity = getplayerentity(plr)
    local plrposition = {entityx(plrentity),entityy(plrentity),entityz(plrentity)}
    if room == "exit1" and role ~= 3 and (plrposition[1] >= escape1[1] - 2) and (plrposition[3] <= escape1[3] + 10) then --if handcuffed SCPF staff then be sure to become CI
        escapedplrs[plr] = true
        setplayerposition(plr,"gatea", escape2[1], escape2[2], escape2[3])
    end
    if room == "gatea" and role == 3 and plrposition[1] >= 118 and plrposition[2] <= 496 and plrposition[3] <= 20 then --if handcuffed CD then MTF
        escapedplrs[plr] = true
        setplayerposition(plr,"exit1", escape1[1], escape1[2], escape1[3])
    end
    createtimer("OnPlayerCuffPlayer",1000,0,_,plr) --script needs to run every 1 second to detect. It takes >1 second from the beginning of new escape coords to reach proper
    return -1
end

function OnPlayerConsole(plr,txt)
    if txt == "handcuff" then
        if getplayerhandcuff(plr) == 1 then
            setplayerhandcuff(plr,0)
        else
            setplayerhandcuff(plr,1)
            OnPlayerCuffPlayer(0,plr) --Call cuff callback. Assume player 0 == server
        end
    elseif txt == "escape" then
        local role = getplayertype(plr)
        if role == 3 then
            setplayerposition(plr,"gatea", escape2[1], escape2[2], escape2[3])
        elseif role == 4 or role == 8 then
            setplayerposition(plr,"exit1", escape1[1], escape1[2], escape1[3])
        else
            sendmessage(plr,"You are not an Escape Class Role")
        end
    elseif txt == "testescape" then
        local role = getplayertype(plr)
        if role == 3 then
            setplayerposition(plr,"exit1", escape1[1], escape1[2], escape1[3])
        elseif role == 4 or role == 8 then
            setplayerposition(plr,"gatea", escape2[1], escape2[2], escape2[3])            
        else
            sendmessage(plr,"You are not an Escape Class Role")
        end
    end
    return -1
end