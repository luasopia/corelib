if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
local cos, _2PI = math.cos, 2*math.pi
local tmfrm = 1000/screen.fps
local function wavefn(t, p) return (1-cos(_2PI*t/p))/2 end


lib.wave = function(dobj, period, ratio)
    local drat = ratio-1
    local wavtm = 0
    local initscl = dobj:gets()
    local prevupd = dobj.update
    function dobj:update()
        wavtm = wavtm + tmfrm
        local s = initscl*(1 + drat*wavefn(wavtm, period))
        self:s(s)
        if prevupd then return prevupd(self) end
    end
end

lib.xwave = function(dobj, period, ratio)
    local drat = ratio-1
    local wavtm = 0
    local initscl = dobj:gets()
    local prevupd = dobj.update
    function dobj:update()
        wavtm = wavtm + tmfrm
        local s = initscl*(1 + drat*wavefn(wavtm, period))
        self:xs(s)
        if prevupd then return prevupd(self) end
    end
end

lib.ywave = function(dobj, period, ratio)
    local drat = ratio-1
    local wavtm = 0
    local initscl = dobj:gets()
    local prevupd = dobj.update
    function dobj:update()
        wavtm = wavtm + tmfrm
        local s = initscl*(1 + drat*wavefn(wavtm, period))
        self:ys(s)
        if prevupd then return prevupd(self) end
    end
end