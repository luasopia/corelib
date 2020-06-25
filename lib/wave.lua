-- 2020/06/14 refactored

local cos, _2PI = math.cos, 2*math.pi
local tmgap = 50
--local function wavefn(t, p) return (1-cos(_2PI*t/p))/2 end

local function wvtmr(self, e)
    local wv = 0.5*(1-cos(_2PI*e.time/self._prd))
    self:s( self._orgns*(1 + self._drt*wv) )
end

local function xwvtmr(self, e)
    local wv = 0.5*(1-cos(_2PI*e.time/self._prd))
    self:xs( self._orgns*(1 + self._drt*wv) )
end

local function ywvtmr(self, e)
    local wv = 0.5*(1-cos(_2PI*e.time/self._prd))
    self:ys( self._orgns*(1 + self._drt*wv) )
end

lib.wave = function(dobj, period, ratio)
    
    if dobj._tmrwv then dobj._tmrwv:remove() end
    
    dobj._drt = ratio-1
    dobj._orgns = dobj:gets() -- original scale
    dobj._prd = period
    dobj._tmrwv = dobj:timer(tmgap, wvtmr, INF)

end

lib.xwave = function(dobj, period, ratio)
    
    if dobj._tmrwv then dobj._tmrwv:remove() end
    
    dobj._drt = ratio-1
    dobj._orgns = dobj:gets() -- original scale
    dobj._prd = period
    dobj._tmrwv = dobj:timer(tmgap, xwvtmr, INF)

end

lib.ywave = function(dobj, period, ratio)
    
    if dobj._tmrwv then dobj._tmrwv:remove() end
    
    dobj._drt = ratio-1
    dobj._orgns = dobj:gets() -- original scale
    dobj._prd = period
    dobj._tmrwv = dobj:timer(tmgap, ywvtmr, INF)

end

lib.stopwave = function(dobj)
    if dobj._tmrwv then
        dobj._tmrwv:remove() -- dobj:removetimer(dobj._tmrwv)
        dobj:s(dobj._orgns)
    end
end
