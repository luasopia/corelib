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

    function Circle:init(radius, opt, parent)
        self.__rd = radius
        opt = Disp.__optOrPr(self, opt, parent)
        -- self.__strkw, self.__strkc = 0, WHITE -- stroke width and color
        -- self.__fillca = Color(WHITE, 1) -- fill color and alpha
        self.__bd = Sprtnew()
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        -- self.__pr = parent
        return Disp.init(self)
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
    function Circle:init(radius, opt, parent)
        opt = Disp.__optOrPr(self, opt, parent)

        self.__bd = newCirc(0,0,radius)
        self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5
        -- self.__pr = parent

        local sc = self.__strkc
        local fca = self.__fillca
        self.__bd.strokeWidth = self.__strkw
        self.__bd:setStrokeColor(sc.r, sc.g, sc.b)
        self.__bd:setFillColor(fca.r, fca.g, fca.b, fca.a)

        return Disp.init(self) --return self:superInit()
    end  

end

-- refer methods in Display class
Circle.strokewidth = Disp.__strokeWidth__
Circle.strokecolor = Disp.__strokeColor__
Circle.fillcolor = Disp.__fillColor__

