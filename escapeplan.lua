exit1,escape1,exit2,escape2 = 0
escapedplrs = {}

function OnScriptLoaded()
    print("EscapePlan")
    return -1
end

function OnServerStart()
    for i = 1, 10 do createfakeplayer(i) end
    if escapecoords() then restartserver() end
    return -1
end

function OnServerRestart() if escapecoords() then restartserver() end; return -1 end

function escapecoords()
    local entitypointers = {}    
    for i = 1, 70 do
        local findcoords = function(index,index2)
            entity,entity2 = getroomobjectentity(i,index), getroomobjectentity(i,index2)
            return true,{entityx(entity),entityy(entity),entityz(entity)},{entityx(entity2),entityy(entity2),entityz(entity2)}
        end
        local select = {
            ["exit1"] = function() entitypointers[1], exit1, escape1 = findcoords(26,27) end,
            ["gatea"] = function() entitypointers[2], exit2, escape2 = findcoords(27,11) end,
            ["gateaentrance"] = function() entitypointers[3] = true end
        }    
        if type(select[getroomname(i)]) == "function" then select[getroomname(i)]() end
        if entitypointers[1] and entitypointers[2] and entitypointers[3] then --if all coords found, end function
            escape2f = function() setplayerposition(plr,"gatea", escape2[1], escape2[2], escape2[3]) end --escape2f() will now teleport plr to gate a escape
            escape1f = function() setplayerposition(plr,"exit1", escape1[1], escape1[2], escape1[3]) end --escape2f() will now teleport plr to gate b escape
            return false --return false so script doesnt restart server
        end
    end
    return true
end

function OnPlayerEscapeButDead(plr,_,before) --make them actually escape
	setplayertype(plr,before)
	escapedplrs[plr] = true
	if before == 3 then escape2f() else escape2f() end
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

function OnPlayerCuffPlayer(_,plr) --For cuffed players to join enemy team even if escape tho own gate
    if getplayerhandcuff(plr) == 0 then	return -1 end
    local role = getplayertype(plr)
    room = getroomname(getplayerroomid(plr))
    local plrentity = getplayerentity(plr)
    local plrposition = {entityx(plrentity),entityy(plrentity),entityz(plrentity)}
    if room == "exit1" and role ~= 3 and (plrposition[1] >= escape1[1] - 2) and (plrposition[3] <= escape1[3] + 10) then --if handcuffed SCPF staff then be sure to become CI
        escapedplrs[plr] = true
        escape2f()
    end
    if room == "gatea" and role == 3 and plrposition[1] >= 118 and plrposition[2] <= 496 and plrposition[3] <= 20 then --if handcuffed CD then MTF
        escapedplrs[plr] = true
        escape2f()
    end
    createtimer("OnPlayerCuffPlayer",1000,0,_,plr) --script needs to run every 1 second to detect. It takes >1 second from the beginning of new escape coords to reach proper
    return -1
end

function OnPlayerConsole(plr,txt) --Console makes testing a lot easier
    local teleport = function(f1,f2) --You can pass functions as arguements and have them run when needed
        local role = getplayertype(plr)
        if role == 3 then f1()
        elseif role == 4 or role == 8 or role == 9 then f2()
        else sendmessage(plr,"You are not an Escape Class Role") end
    end
    local select = {
        ["handcuff"] = function()
            if getplayerhandcuff(plr) == 1 then
                setplayerhandcuff(plr,0)
            else
                setplayerhandcuff(plr,1)
                OnPlayerCuffPlayer(0,plr) --Call cuff callback. Assume player 0 == server
            end
        end,
        ["escape"] = function() teleport(function() escape2f() end, function() escape1f() end) end, --Functions as arguements. Runs when called inside the teleport()
        ["testescape"] = function() teleport(function() escape1f() end, function() escape2f() end) end
    }
    if type(select[txt]) == "function" then select[txt]() end
    return -1
end