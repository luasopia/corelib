if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
local cos, _2PI = math.cos, 2*math.pi
local tmgap = 50
local function wavefn(t, p) return (1-cos(_2PI*t/p))/2 end


lib.wave = function(dobj, period, ratio)
    local dratio = ratio-1
    local wavtm = 0
    dobj.__orgnscl = dobj:gets()
    -- local prevupd = dobj.update
    -- function dobj:update()
    
    if dobj.__tmrwav then dobj.__tmrwav:remove() end

    dobj.__tmrwav = dobj:timer(tmgap, function(self)
        wavtm = wavtm + tmgap
        local s = dobj.__orgnscl*(1 + dratio*wavefn(wavtm, period))
        self:s(s)
    end, INF)

end

lib.stopwave = function(dobj)
    if dobj.__tmrwav then
        dobj.__tmrwav:remove()
        dobj:s(dobj.__orgnscl)
    end
end
