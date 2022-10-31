gateb = 0

function OnScriptLoaded() print("EscapePlan"); return -1 end

function OnServerStart()
    for i = 1, 10 do createfakeplayer(i) end
    escapecoords()
    print(gateb[1])
    return -1
end

function escapecoords()
    local entitypointers = {}    
    local findcoords = function(room,index) entity = getroomobjectentity(room,index); return entity,{entityx(entity),entityy(entity),entityz(entity)} end
    local select = {
        ["exit1"] = function(i) entitypointers[1], gateb = findcoords(i,26) end,
        gatea = function() entitypointers[3], exit2, entitypointers[4], escape2 = findcoords(27),findcoords(11) end
    }
    for i = 1, 70 do
        print(getroomname(i))
        if type(select[getroomname(i)]) == "function" then select[getroomname(i)](i) end
    end
end