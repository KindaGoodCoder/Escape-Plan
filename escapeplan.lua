escapedplrs = {} --List that temporarily contains any players escaping at a rival gate

function OnScriptLoaded() --Check if script loaded
    print("EscapePlan")
    return -1
end

function OnServerStart()
    for i = 1, 10 do createfakeplayer(i) end
    OnServerRestart()
    return -1
end

function OnServerRestart()    
    exit1, exit2 = nil
    local debounce = false
    for i = 1, 70 do

        local findcoords = function(index,index2) --Function that finds and returnsobject entity of 2 index
            local entity,entity2 = getroomobjectentity(i,index), getroomobjectentity(i,index2)
            return {entityx(entity),entityy(entity),entityz(entity)},{entityx(entity2),entityy(entity2),entityz(entity2)}
            --returns true for entitypointer to confirm room, spawn location and escape location
        end

        local select = {
            ["exit1"] = function() exit1, escape1 = findcoords(26,27) end,
            ["gatea"] = function() exit2, escape2 = findcoords(27,11) end,
            ["gateaentrance"] = function() debounce = true end
        }
        if type(select[getroomname(i)]) == "function" then select[getroomname(i)]() end

        if exit1 and exit2 and debounce then --if all coords found, end function
            escape1f = function(plr) setplayerposition(plr,"exit1", escape1[1], escape1[2], escape1[3]) end --escape1f(plr) will now teleport plr to gate b escape
            escape2f = function(plr) setplayerposition(plr,"gatea", escape2[1], escape2[2], escape2[3]) end --escape2f(plr) will now teleport plr to gate a escape            
            return -1
        end

    end
    restartserver()
    return -1
end

function OnPlayerEscapeButDead(plr,_,role) --make them actually escape
	setplayertype(plr,role)
	escapedplrs[plr] = true
	if role == 3 then escape2f(plr) else escape1f(plr) end
    return -1
end

function OnPlayerEscape(plr,role)

    escaped = function()
        if escapedplrs[plr] then
            print("pain")
            escapedplrs[plr] = false --Remove them from escapedplrs list
            if role == 7 then setplayerposition(plr,"exit1", exit1[1], exit1[2]+1, exit1[3])
            else setplayerposition(plr,"gatea", exit2[1], exit2[2], exit2[3]) end
            --If they're on the list and turns into Chaos, then they escaped tho gate b. Otherwise they must have escaped tho gate a.
        end
        return -1
    end

    createtimer("escaped",50,0)
    return -1
end --execute escaped function after 100 milliseconds to make room for the natural (delayed) spawn position change

function OnPlayerCuffPlayer(_,plr) --For cuffed players to join enemy team even if escape tho own gate
    plr = tonumber(plr)
    if getplayerhandcuff(plr) == 0 then return -1
    local plrposition = getplayerentity(plr)
    plrposition = {entityx(plrposition),entityy(plrposition),entityz(plrposition)}

    if getroomname(getplayerroomid(plr)) == "exit1" and getplayertype(plr) ~= 3 and (plrposition[1] >= escape1[1] - 2) and (plrposition[3] <= escape1[3] + 10) then --if handcuffed SCPF staff then be sure to become CI
        escapedplrs[plr] = true
        escape2f(plr)
    end

    if getroomname(getplayerroomid(plr)) == "gatea" and getplayertype(plr) == 3 and plrposition[1] >= 118 and plrposition[2] <= 496 and plrposition[3] <= 20 then --if handcuffed CD then MTF
        escapedplrs[plr] = true
        escape1f(plr)
    end

    recursive = function() OnPlayerCuffPlayer(_,plr); return -1 end
    createtimer("recursive",1000,0) --script runs every 1 second to avoid possible lag.  It takes >1 second from the beginning of new escape coords to reach proper escape
    return -1
end

function OnPlayerConsole(plr,txt) --Console makes testing a lot easier

    local teleport = function(f1,f2) --You can pass functions as arguments and have them run when needed
        local role = getplayertype(plr)
        if role == 3 then f1()
        elseif role == 4 or role == 8 or role == 9 then f2()
        else sendmessage(plr,"You are not an Escape Class Role") end
    end

    local select = {
        ["handcuff"] = function()
            if getplayerhandcuff(plr) == 1 then setplayerhandcuff(plr,0)
            else
                setplayerhandcuff(plr,1)
                OnPlayerCuffPlayer(0,plr) --Call cuff callback. Assume player 0 == server
            end
        end,
        ["escape"] = function() teleport(function() escape2f(plr) end, function() escape1f(plr) end) end, --Functions as arguements. Runs when called inside the teleport()
        ["testescape"] = function() teleport(function() escape1f(plr) end, function() escape2f(plr) end) end --Teleports player to opposite gate to test script
    }
    txt = string.lower(txt:gsub("%s+","")) -- Strip and lower command
    if type(select[txt]) == "function" then select[txt]() end
    
    return -1
end