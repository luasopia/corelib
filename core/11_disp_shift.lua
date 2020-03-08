if not_required then return end -- This prevents auto-loading in Gideros

print('core.disp_tr')

-- local tmgapf = 1000/screen.fps
local tmgapf = 1000/_baselayer.fps
local int = math.floor
----------------------------------------------------------------------------------
-- shift테이블에 여러 지점을 등록할 수 있다.
-- tr = {time, x,...
--		loops(=1), -- 반복 회수, 0이면 무한반복
--		onEnd = function(self) ... end, --모든 tr이 종료될 때 실행되는 함수
--		{time(필수), x, y, angle, xscale, yscale, scale, alpha},
--		{time(필수), x, y, angle, xscale, yscale, scale, alpha},
--		...
-- }
----------------------------------------------------------------------------------
local function calcTr(self, shr)
    local tr = {}
    local fc = int(shr.time/tmgapf)+1
    tr.fcnt = fc -- final count
    tr.cnt = 0
    if shr.x then tr.dx = (shr.x-self:getx())/fc end
    if shr.y then tr.dy = (shr.y-self:gety())/fc end
    if shr.r then tr.dr = (shr.r-self:getr())/fc end
    if shr.scale then tr.ds = (shr.scale-self:getscale())/fc end
    if shr.xscale then tr.dxs = (shr.xscale-self:getxscale())/fc end
    if shr.yscale then tr.dys = (shr.yscale-self:getyscale())/fc end
    if shr.alpha then tr.da = (shr.alpha-self:getalpha())/fc end
    tr.dest = shr
    tr.__to = shr.__to
    tr.__to1 = shr.__to1
    return tr
end

function Display:__playTr() -- tr == self.__trInfo
    local tr = self.__tr
    tr.cnt = tr.cnt + 1
    if tr.cnt == tr.fcnt then

        if tr.dest.x then self:x(tr.dest.x) end
        if tr.dest.y then self:y(tr.dest.y) end
        if tr.dest.r then self:r(tr.dest.r) end
        if tr.dest.scale then self:scale(tr.dest.scale) end
        if tr.dest.xscale then self:xscale(tr.dest.xscale) end
        if tr.dest.yscale then self:yscale(tr.dest.yscale) end
        if tr.dest.alpha then self:alpha(tr.dest.alpha) end

        if tr.__to1 then

            self.__sh.__cnt = self.__sh.__cnt + 1
            if self.__sh.loops == self.__sh.__cnt then
                if self.__sh.onEnd then self.__sh.onEnd(self) end
                self.__tr = nil
                return
            end
            self.__tr = calcTr(self, tr.__to1)
        
        elseif tr.__to then

            self.__tr = calcTr(self, tr.__to)

        else 
            if self.__sh.onEnd then self.__sh.onEnd(self) end
            self.__tr = nil -- tr=nil로 하면 안된다.
        end
    
    else

        if tr.dx then self:x(self:getx()+tr.dx) end
        if tr.dy then self:y(self:gety()+tr.dy) end
        if tr.dr then self:r(self:getr()+tr.dr) end
        if tr.ds then self:scale(self:getscale()+tr.ds) end
        if tr.dxs then self:xscale(self:getxscale()+tr.dxs) end
        if tr.dys then self:yscale(self:getyscale()+tr.dys) end
        if tr.da then self:alpha(self:getalpha()+tr.da) end
    
    end
end

local function makeTr(self, sh)
    sh.loops = sh.loops or 1
    sh.__cnt = 0

    local tr, lastk = nil, 0

    if sh.time then
        sh.__to = sh[1]
        tr = calcTr(self, sh)
    end

    for k, v in ipairs(sh) do
        v.__to = sh[k+1]
        if k==1 and tr==nil then tr = calcTr(self, v) end
        lastk = k
    end
    --print('lastk:'..tostring(lastk))
    if lastk>1 then sh[lastk].__to1 = sh[1] end

    return tr
end

-- 외부 사용자 함수
function Display:shift(sh)
    self.__sh = sh
    self.__tr = makeTr(self, sh)
    return self
end

function Display:stopshift()
    self.__tr=nil
    return self
end
