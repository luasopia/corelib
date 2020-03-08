if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------

local Disp = Display
local tIn = table.insert
-- (x,y)점을 원점간격으로 r(radian)만큼회전시킨 좌표(xr, yr) 반환
local cos, sin, _2PI, PI = math.cos, math.sin, 2*math.pi, math.pi
local int = math.floor
-- local int, log, exp = math.floor, math.log, math.exp
local function rot(x,y,r)
    return cos(r)*x-sin(r)*y, sin(r)*x+cos(r)*y
end
local Color, WHITE = Color, Color.WHITE

-- 2020/02/27 : determine number of points using radius
-- local gain = 0.006 --0.0024142293418408806 --log(23/10)/345
-- local function detpts(r) return int(exp(0.006*r)+16) end
-- --[[
local function detpts(r)
    if r<=30 then return 12 -- 10
    elseif r<=100 then return 22 --15
    elseif r<=300 then return 37 --23
    else return int(r/8.1) -- r/13
    end
end
--]]

local function eq(t, gain)
    gain = gain or 1

    local x = 16*sin(t)^3
    local y = -12*cos(t)+5*cos(2*t)+2*cos(3*t)+cos(4*t)

    return x*gain, y*gain
end
    
--------------------------------------------------------------------------------
-- local r = Heart(radius, npoints [, parent])
--------------------------------------------------------------------------------

Heart = class(Disp)
--------------------------------------------------------------------------------
if _Gideros then
    print('core.Heart(gid)')

    local Shape = _Gideros.Shape
    local Sprtnew = _Gideros.Sprite.new

    function Heart:__draw()
        local gain = self.__rd*0.059 --0.06 --외접원의 반지름으로 eq함수의 gain 계산
        local xs, ys = eq(-PI, gain)
        local s = Shape.new()
        s:beginPath()
        s:setLineStyle(self.__strkw, self.__strkc.hex) -- width, color, alpha
        s:setFillStyle(Shape.SOLID, self.__fillca.hex, self.__fillca.a)
        s:moveTo(xs, ys) -- starting at upmost point
        local npts = detpts(self.__rd) -- max(23, int(self.__rd/15)) --15
        -- log('r:%d, npts:%d',self.__rd, npts)
        local rgap = _2PI/npts --npts
        for t=-PI+rgap, PI-rgap, rgap do
            local x, y = eq(t, gain)
            s:lineTo(x, y)
        end
        s:lineTo(xs, ys) -- ending at the (first) starting point
        s:endPath()

        s:setPosition(self.__apx or 0, self.__apy or 0)
        return s
    end

    function Heart:init(radius, opt, parent)
        self.__rd = radius

        -------------------------------------------------------------------------
        --2020/03/04 두 번째 파라메터는 opt 혹은 parent(Group object)일 수 있다.
        if isobj(opt, Group) then
            self.__pr = opt
            opt = {}
        else -- opt가 nil일 수도 table일 수도 있음
            self.__pr = parent
            opt = opt or {}
        end
        -------------------------------------------------------------------------

        self.__strkw = opt.strokeWidth or 0
        self.__strkc = opt.strokeColor or WHITE
        self.__fillca = opt.fillColor or Color(WHITE,1)
        
        self.__bd = Sprtnew()
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return Disp.init(self)
    end

    function Heart:strokeWidth(w)
        self.__strkw = w
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Heart:strokeColor(r,g,b)
        self.__strkc = Color(r,g,b)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

-- r,g,b는 0-255 범위의 정수
    function Heart:fillColor(r,g,b,a)
        self.__fillca = Color(r,g,b,a)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    function Heart:anchor(ax, ay)
        local x, y = self.__rd*(1-2*ax), self.__rd*(1-2*ay)
        self.__sbd:setPosition(x,y)
        self.__apx, self.__apy = x,y -- (calculated) Anchor Point X/Y
        self.__ancx, self.__ancy = ax, ay
        return self
    end

    function Heart:getanchor()
        return self.__ancx, self.__ancy
    end


elseif _Corona then --#############################################################

    print('core.Polygon(cor)')
    local newPoly = _Corona.display.newPolygon
    --------------------------------------------------------------------------------
    function Heart:init(radius, opt, parent)
        self.__rd = radius

        -------------------------------------------------------------------------
        --2020/03/04 두 번째 파라메터는 opt 혹은 parent(Group object)일 수 있다.
        if isobj(opt, Group) then
            self.__pr = opt
            opt = {}
        else -- opt가 nil일수도 table일 수도 있음
            self.__pr = parent
            opt = opt or {}
        end
        -------------------------------------------------------------------------
        self.__strkw = opt.strokeWidth or 0
        self.__strkc = opt.strokeColor or WHITE
        self.__fillca = opt.fillColor or Color(WHITE,1)
        -------------------------------------------------------------------------

        local gain = radius*0.06
        local npts = detpts(radius)
        local pts = {}
        local rgap = _2PI/npts
        for t=-PI,PI-rgap, rgap do
            local x, y = eq(t, gain)
            tIn(pts, x); tIn(pts, y)
        end

        self.__bd = newPoly(0, 0, pts)
        self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.4 -- not 0.5

        self.__bd.strokeWidth = self.__strkw
        self:strokeColor(self.__strkc)
        self:fillColor(self.__fillca)

        return Disp.init(self) --return self:superInit()
    end  
-- --[[
    function Heart:strokeWidth(w)
        self.__bd.strokeWidth = w
        self.__strkw = w
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Heart:strokeColor(r,g,b)
        local c = Color(r,g,b)
        self.__bd:setStrokeColor(c.r, c.g, c.b)
        self.__strkc = c
        return self
    end
--]]

    -- r, g, b are integers between 0 and 255
    -- fillcolor 는 외곽선은 불투명, 내부색은 투명일 수 있으므로 a도 받는다.
    -- 단, a는 0에서 1사이값
    function Heart:fillColor(r,g,b,a)
        local ca = Color(r,g,b,a)
        self.__bd:setFillColor(ca.r, ca.g, ca.b, ca.a)
        self.__fillca = ca
        return self
    end

end