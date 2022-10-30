exit1,escape1,exit2,escape2,escapedplrs,escape1cuff

function OnServerStart()
    for i = 1, 10 do createfakeplayer(i) end
    escapecoords()
    return -1
end

function escapecoords()
    local entitypointers = {}    
    for i = 1, 70 do
        local findcoords = function(index) entity = getroomobjectentity(i,index); return entity,{EntityX(entity),EntityY(entity),EntityZ(entity)} end
        local select = {
            exit1 = function() entitypointers[1], exit1, entitypointers[2], escape1 = findcoords(26),findcoords(27),
            gatea = function() entitypointers[3], exit2, entitypointers[4], escape2 = findcoords(27),findcoords(11) end
        }
        type(select[i]) == "function" and select[i]()
    end
end