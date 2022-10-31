exit1 = 0

function OnScriptLoaded() print("EscapePlan"); return -1 end

function OnServerStart()
    for i = 1, 10 do createfakeplayer(i) end
    escapecoords()
    print(exit1[1])
    return -1
end

function escapecoords()
    local entitypointers = {}    
    local findcoords = function(index) entity = getroomobjectentity(i,index); return entity,{entityx(entity),entityy(entity),entityz(entity)} end
        local select = {
            exit1 = function() entitypointers[1], exit1, entitypointers[2], escape1 = findcoords(26),findcoords(27) end,
            gatea = function() entitypointers[3], exit2, entitypointers[4], escape2 = findcoords(27),findcoords(11) end
        
    for i = 1, 70 do
        if type(select[getroomname(i)]) == "function" then select[getroomname(i)]() end
    end
end