local Disp = Display
local sqrt, atan2 = math.sqrt, math.atan2
local _R2D = 180/math.pi -- radian to degree constant

local function upd(self)
    local ga = self._rspd

    -- 타겟을 향하는 단위벡터 계산
    local x, y = self:getxy()
    local dx, dy = self._trgt:getxy()
    dx, dy = dx-x, dy-y
    local dist = sqrt(dx*dx + dy*dy)
    dx, dy = dx/dist, dy/dist

    -- 1st order filtering (for smooth following)
    local dxk = ga*self._pdx + (1-ga)*dx
    local dyk = ga*self._pdy + (1-ga)*dy
    local rot = atan2(dyk,dxk)*_R2D + 90 

    self:xyr(x+dxk*self._lspd, y+dyk*self._lspd, rot)
    self._pdx, self._pdy = dxk, dyk
    --[[
    
    
    -- store current values for the next frame
    bb.prevDx, bb.prevDy = dxk, dyk
    --]]
end


function Disp:follow(target,opt) -- oncotact
    self._trgt = target
    opt = opt or {}
    self._pdx = opt.initdx or 0
    self._pdy = opt.initdy or 0
    self._rspd = opt.rotspeed or 0.9 -- <1,(각속도) 작을수록 회전이 빠르다.
    self._lspd = (opt.linspeed or 1)*20 -- 선속도

    self.removeif = upd
end