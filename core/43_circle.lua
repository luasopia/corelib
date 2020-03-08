if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
local Disp = Display
local tIn = table.insert
-- (x,y)점을 원점간격으로 r(radian)만큼회전시킨 좌표(xr, yr) 반환
local cos, sin, _2pi, max = math.cos, math.sin, 2*math.pi, math.max
local int = math.floor
-- local int, log, exp = math.floor, math.log, math.exp
local function rot(x,y,r)
    return cos(r)*x-sin(r)*y, sin(r)*x+cos(r)*y
end
local Color, WHITE = Color, Color.WHITE
--------------------------------------------------------------------------------
-- local r = Circle(radius, npoints [, parent])
--------------------------------------------------------------------------------
Circle = class(Disp)
--------------------------------------------------------------------------------
if _Gideros then
    print('core.Circle(gid)')

    local Shape = _Gideros.Shape
    local Sprtnew = _Gideros.Sprite.new

    -- 2020/02/27 : determine number of points using radius
    -- local gain = 0.006 --0.0024142293418408806 --log(23/10)/345
    -- local function detpts(r) return int(exp(0.006*r)+16) end
    -- --[[
    local function detpts(r)
        if r<=30 then return 10
        elseif r<=100 then return 15
        elseif r<=300 then return 23
        else return int(r/13)
        end
    end
    --]]

    function Circle:__draw()
        local xs, ys = 0, -self.__rd
        local s = Shape.new()
        s:beginPath()
        s:setLineStyle(self.__strkw, self.__strkc.hex) -- width, color, alpha
        s:setFillStyle(Shape.SOLID, self.__fillca.hex, self.__fillca.a)
        s:moveTo(xs, ys) -- starting at upmost point
        local npts = detpts(self.__rd) -- max(23, int(self.__rd/15)) --15
        -- log('r:%d, npts:%d',self.__rd, npts)
        local rgap = _2pi/npts
        for k=1, npts-1 do
            local xr, yr = rot(xs, ys, k*rgap)
            s:lineTo(xr, yr)
        end
        s:lineTo(xs, ys) -- ending at the (first) starting point
        s:endPath()

        s:setPosition(self.__apx or 0, self.__apy or 0)
        return s
    end

    function Circle:init(radius, parent)
        self.__rd = radius
        self.__strkw, self.__strkc = 0, WHITE -- stroke width and color
        self.__fillca = Color(WHITE, 1) -- fill color and alpha
        self.__bd = Sprtnew()
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        self.__pr = parent
        return Disp.init(self)
    end

    function Circle:strokeWidth(w)
        self.__strkw = w
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Circle:strokeColor(r,g,b)
        self.__strkc = Color(r,g,b)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

-- r,g,b는 0-255 범위의 정수
    function Circle:fillColor(r,g,b,a)
        -- self.__fillc = r*65536+g*256+b
        -- self.__filla = a or 1
        self.__fillca = Color(r,g,b,a)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    function Circle:anchor(ax, ay)
        local x, y = self.__rd*(1-2*ax), self.__rd*(1-2*ay)
        self.__sbd:setPosition(x,y)
        self.__apx, self.__apy = x,y -- (calculated) Anchor Point X/Y
        self.__ancx, self.__ancy = ax, ay
        return self
    end

    function Circle:getanchor()
        return self.__ancx, self.__ancy
    end


elseif _Corona then --#############################################################

    print('core.Rect(cor)')
    local newCirc = _Corona.display.newCircle
    --------------------------------------------------------------------------------
    function Circle:init(radius, parent)
        self.__bd = newCirc(0,0,radius)
        self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5
        self.__pr = parent
        return Disp.init(self) --return self:superInit()
    end  

    function Circle:strokeWidth(w)
        self.__bd.strokeWidth = w
        return self
    end

    -- r, g, b are integers between 0 and 255
    -- fillcolor 는 외곽선은 불투명, 내부색은 투명일 수 있으므로 a도 받는다.
    -- 단, a는 0에서 1사이값
    function Circle:fillColor(r,g,b,a)
        local ca = Color(r,g,b,a)
        self.__bd:setFillColor(ca.r, ca.g, ca.b, ca.a)
        self.__fillca = ca
        return self
    end
    
    -- r,g,b는 0-255 범위의 정수
    function Circle:strokeColor(r,g,b)
        local c = Color(r,g,b)
        self.__bd:setStrokeColor(c.r, c.g, c.b)
        self.__strkc = c
        return self
    end

end