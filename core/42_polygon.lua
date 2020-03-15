if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
local Disp = Display
local tIn = table.insert
-- (x,y)점을 원점간격으로 r(radian)만큼회전시킨 좌표(xr, yr) 반환
local cos, sin, _2pi = math.cos, math.sin, 2*math.pi
local function rot(x,y,r)
    return cos(r)*x-sin(r)*y, sin(r)*x+cos(r)*y
end
local Color, WHITE = Color, Color.WHITE
--------------------------------------------------------------------------------
-- local r = Polygon(radius, points [, parent])
--------------------------------------------------------------------------------
Polygon = class(Disp)
--------------------------------------------------------------------------------
if _Gideros then
    print('core.Polygon(gid)')

    local Shape = _Gideros.Shape
    local Sprtnew = _Gideros.Sprite.new

    function Polygon:__draw()
        local xs, ys = 0, -self.__rd
        local s = Shape.new()
        s:beginPath()
        s:setLineStyle(self.__strkw, self.__strkc.hex) -- width, color, alpha
        s:setFillStyle(Shape.SOLID, self.__fillca.hex, self.__fillca.a)
        s:moveTo(xs, ys) -- starting at upmost point
        local rgap = _2pi/self.__npts
        for k=1, self.__npts-1 do
            local xr, yr = rot(xs, ys, k*rgap)
            s:lineTo(xr, yr)
        end
        s:lineTo(xs, ys) -- ending at the (first) starting point
        s:endPath()

        s:setPosition(self.__apx or 0, self.__apy or 0)
        return s
    end

    function Polygon:init(radius, points, opt, parent)
        assert(points>=3, 'Number of points for Polygon must be greater than 2.')
        self.__rd, self.__npts = radius, points
        opt = Disp.__optOrPr(self, opt, parent)
        -- self.__strkw, self.__strkc = 0, WHITE -- stroke width and color
        -- self.__fillca = Color(WHITE, 1) -- fill color and alpha
        self.__ancx, self.__ancy = 0.5, 0.5
        self.__bd = Sprtnew()
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)

        return Disp.init(self)
    end
--[[
    function Polygon:strokeWidth(w)
        self.__strkw = w
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Polygon:strokeColor(r,g,b)
        self.__strkc = Color(r,g,b)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end


    -- r,g,b는 0-255 범위의 정수
    function Polygon:fillColor(r,g,b,a)
        self.__fillca = Color(r,g,b,a)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end
--]]

    function Polygon:anchor(ax, ay)
        local x, y = self.__rd*(1-2*ax), self.__rd*(1-2*ay)
        self.__sbd:setPosition(x,y)
        self.__apx, self.__apy = x,y -- (calculated) Anchor Point X/Y
        self.__ancx, self.__ancy = ax, ay
        return self
    end

    function Polygon:getanchor()
        return self.__ancx, self.__ancy
    end


--]]
elseif _Corona then --#############################################################

    print('core.Polygon(cor)')
    local newPoly = _Corona.display.newPolygon
    --------------------------------------------------------------------------------
    function Polygon:init(radius, points, opt, parent)
        assert(points>=3, 'Number of points for Polygon must be greater than 2.')
        -- self.__rd, self.__npts = radius, points
        opt = Disp.__optOrPr(self, opt, parent)

        local pts = {0,-radius}
        local rgap = _2pi/points
        for k=1, points-1 do
            local xr, yr = rot(0, -radius, k*rgap)
            tIn(pts, xr); tIn(pts, yr)
        end

        self.__bd = newPoly(0, 0, pts)
        self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5

        local sc = self.__strkc
        local fca = self.__fillca
        self.__bd.strokeWidth = self.__strkw
        self.__bd:setStrokeColor(sc.r, sc.g, sc.b)
        self.__bd:setFillColor(fca.r, fca.g, fca.b, fca.a)

        return Disp.init(self)
    end  

    --[[
    function Polygon:strokeWidth(w)
        self.__bd.strokeWidth = w
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Polygon:strokeColor(r,g,b)
        local c = Color(r,g,b)
        self.__bd:setStrokeColor(c.r, c.g, c.b)
        self.__strkc = c
        return self
    end

    -- r, g, b are integers between 0 and 255
    -- fillcolor 는 외곽선은 불투명, 내부색은 투명일 수 있으므로 a도 받는다.
    -- 단, a는 0에서 1사이값
    function Polygon:fillColor(r,g,b,a)
        local ca = Color(r,g,b,a)
        self.__bd:setFillColor(ca.r, ca.g, ca.b, ca.a)
        self.__fillca = ca
        return self
    end
--]]

end

-- refer methods in Display class
Polygon.strokewidth = Disp.__strokeWidth__
Polygon.strokecolor = Disp.__strokeColor__
Polygon.fillcolor = Disp.__fillColor__