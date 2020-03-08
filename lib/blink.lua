if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
-- time  : one peroid time
-- loops : number of repeatition
--------------------------------------------------------------------------------
local function tmrfn(self, e)
    if e.isfinal then
        self:visible(self.__wasv)
        self.__wasv = nil
        return
    end
    return self:visible(not self:getvisible())
end

lib.blink = function(obj, time, loops, onEnd)
    obj.__wasv = obj:getvisible() -- wasSeen
    obj:visible(not obj.__wasv)
    return obj:timer(time/2, tmrfn, loops*2-1, onEnd)
end
