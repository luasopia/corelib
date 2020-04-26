-- if not_required then return end -- This prevents auto-loading in Gideros
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

        opt = Disp.__optOrPr(self, opt, parent)

        self.__bd = Sprtnew()
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return Disp.init(self)
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

        opt = Disp.__optOrPr(self, opt, parent)
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

        local sc = self.__strkc
        local fca = self.__fillca
        self.__bd.strokeWidth = self.__strkw
        self.__bd:setStrokeColor(sc.r, sc.g, sc.b)
        self.__bd:setFillColor(fca.r, fca.g, fca.b, fca.a)

        return Disp.init(self) --return self:superInit()
    end  

end

-- refer methods in Display class
Heart.strokewidth = Disp.__strokeWidth__
Heart.strokecolor = Disp.__strokeColor__
Heart.fillcolor = Disp.__fillColor__