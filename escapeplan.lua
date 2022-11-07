escapedplrs = {}

function OnScriptLoaded()
    print("EscapePlan")
    return -1
end

function OnServerStart()
    for i = 1, 10 do createfakeplayer(i) end
    OnServerRestart()
    return -1
end

function OnServerRestart()    
    local entitypointers = {}    
    for i = 1, 70 do
        local findcoords = function(index,index2)
            local entity,entity2 = getroomobjectentity(i,index), getroomobjectentity(i,index2)
            return true,{entityx(entity),entityy(entity),entityz(entity)},{entityx(entity2),entityy(entity2),entityz(entity2)}
        end
        local select = {
            ["exit1"] = function() entitypointers[1], exit1, escape1 = findcoords(26,27) end,
            ["gatea"] = function() entitypointers[2], exit2, escape2 = findcoords(27,11) end,
            ["gateaentrance"] = function() entitypointers[3] = true end}    
        if type(select[getroomname(i)]) == "function" then select[getroomname(i)]() end
        if entitypointers[1] and entitypointers[2] and entitypointers[3] then --if all coords found, end function
            escape2f = function(plr) setplayerposition(plr,"gatea", escape2[1], escape2[2], escape2[3]) end --escape2f(plr) will now teleport plr to gate a escape
            escape1f = function(plr) setplayerposition(plr,"exit1", escape1[1], escape1[2], escape1[3]) end --escape2f(plr) will now teleport plr to gate b escape
            return -1
        end
    end
    restartserver()
    return -1
end

function OnPlayerEscapeButDead(plr,_,role) --make them actually escape
	setplayertype(plr,role)
    print("lego")
	escapedplrs[plr] = true
	if role == 3 then escape2f(plr) else escape1f(plr) end
    return -1
end

function escaped(plr,role)
    plr,role = tonumber(plr), tonumber(role)
    if escapedplrs[plr] then
        print("pain")
        escapedplrs[plr] = false --Remove them from escapedplrs list
        if role == 7 then setplayerposition(plr,"exit1", exit1[1], exit1[2]+1, exit1[3]) else setplayerposition(plr,"gatea", exit2[1], exit2[2], exit2[3]) end
        --If they're on the list and turns into Chaos, then they escaped tho gate b. Otherwise they must have escaped tho gate a.
    end
    return -1
end

function OnPlayerEscape(plr,role) createtimer("escaped",50,0,plr,role) return -1 end --execute escaped function after 100 milliseconds to make room for the natural (delayed) spawn position change

function OnPlayerCuffPlayer(_,plr) --For cuffed players to join enemy team even if escape tho own gate
    plr = tonumber(plr)
    if getplayerhandcuff(plr) == 1 then
        local role = getplayertype(plr)
        room = getroomname(getplayerroomid(plr))
        local plrposition = getplayerentity(plr)
        plrposition = {entityx(plrposition),entityy(plrposition),entityz(plrposition)}
        if room == "exit1" and role ~= 3 and (plrposition[1] >= escape1[1] - 2) and (plrposition[3] <= escape1[3] + 10) then --if handcuffed SCPF staff then be sure to become CI
            escapedplrs[plr] = true
            escape2f(plr)
        end
        if room == "gatea" and role == 3 and plrposition[1] >= 118 and plrposition[2] <= 496 and plrposition[3] <= 20 then --if handcuffed CD then MTF
            escapedplrs[plr] = true
            escape1f(plr)
        end
        recursive = function(_,plr) OnPlayerCuffPlayer(_,plr); return -1 end
        createtimer("recursive",1000,0,_,plr) --script needs to run every 1 second to detect. It takes >1 second from the beginning of new escape coords to reach proper
    end
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
        ["escape"] = function() teleport(function() escape2f(plr) end, function() escape1f(plr) end) end, --Functions as arguements. Runs when called inside the teleport()
        ["testescape"] = function() teleport(function() escape1f(plr) end, function() escape2f(plr) end) end}
    if type(select[txt]) == "function" then select[txt]() end
    return -1
end