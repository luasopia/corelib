if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
local Disp = Display
local tIn = table.insert
-- (x,y)점을 원점간격으로 r(radian)만큼회전시킨 좌표(xr, yr) 반환
local cos, sin, PI, _2PI = math.cos, math.sin, math.pi, 2*math.pi
local function rot(x,y,r)
    return cos(r)*x-sin(r)*y, sin(r)*x+cos(r)*y
end
local Color, WHITE = Color, Color.WHITE
local inratio0 = 0.5 -- 0.4= (inner circle radius)/(outer circle radius)
--------------------------------------------------------------------------------
-- local r = Polygon(radius, npoints [, parent])
--------------------------------------------------------------------------------
Star = class(Disp)
--------------------------------------------------------------------------------
if _Gideros then
    print('core.Star(gid)')

    local Shape = _Gideros.Shape
    local Sprtnew = _Gideros.Sprite.new

    function Star:__draw()
        local xs, ys = 0, -self.__rd
        local s = Shape.new()
        s:beginPath()
        s:setLineStyle(self.__strkw, self.__strkc.hex) -- width, color, alpha
        s:setFillStyle(Shape.SOLID, self.__fillca.hex, self.__fillca.a)
        s:moveTo(xs, ys) -- starting at upmost point
        local rgap = PI/self.__npts
        for k=1, self.__npts*2 do
            if k%2==1 then
                local xr, yr = rot(xs, ys*self.__ingain, k*rgap)
                s:lineTo(xr, yr)
            else 
                local xr, yr = rot(xs, ys, k*rgap)
                s:lineTo(xr, yr)
            end
        end
        s:lineTo(xs, ys) -- ending at the (first) starting point
        s:endPath()

        s:setPosition(self.__apx or 0, self.__apy or 0)
        return s
    end

    function Star:init(radius, opt, parent)
        self.__rd = radius

        --[[
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
        --]]
        opt = Disp.__optOrGrp(self, opt, parent)

        self.__ingain = opt.ratio or inratio0
        self.__npts = opt.points or 5

        self.__strkw = opt.strokeWidth or 0
        self.__strkc = opt.strokeColor or WHITE
        self.__fillca = opt.fillColor or Color(WHITE,1)
        -------------------------------------------------------------------------

        -- assert(npoints>=3, 'Number of points for Polygon must be greater than 2.')
        self.__ancx, self.__ancy = 0.5, 0.5
        self.__bd = Sprtnew()
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)

        return Disp.init(self)
    end
-- --[[
    function Star:strokeWidth(w)
        self.__strkw = w
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Star:strokeColor(r,g,b)
        -- self.__strkc = r*65536+g*256+b
        self.__strkc = Color(r,g,b)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end
--]]

    -- r,g,b는 0-255 범위의 정수
    function Star:fillColor(r,g,b,a)
        self.__fillca = Color(r,g,b,a)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    function Star:anchor(ax, ay)
        local x, y = self.__rd*(1-2*ax), self.__rd*(1-2*ay)
        self.__sbd:setPosition(x,y)
        self.__apx, self.__apy = x,y -- (calculated) Anchor Point X/Y
        self.__ancx, self.__ancy = ax, ay
        return self
    end

    function Star:getanchor()
        return self.__ancx, self.__ancy
    end


--]]
elseif _Corona then --#############################################################

    print('core.Polygon(cor)')
    local newPoly = _Corona.display.newPolygon
    --------------------------------------------------------------------------------
    function Star:init(radius, opt, parent)
        self.__rd = radius
--[[
        if isobj(opt, Group) then
            self.__pr = opt
            opt = {}
        else -- opt가 nil일수도 table일 수도 있음
            self.__pr = parent
            opt = opt or {}
        end
        --]]
        opt = Disp.__optOrPr(self, opt, parent)

        local inratio = opt.ratio or inratio0
        local npts = opt.points or 5
        
        self.__strkw = opt.strokeWidth or 0
        self.__strkc = opt.strokeColor or WHITE
        self.__fillca = opt.fillColor or WHITE


        local pts = {0,-radius}
        local rgap = PI/npts
        for k=1, 2*npts-1 do
            if k%2==1 then
                local xr, yr = rot(0, -radius*inratio, k*rgap)
                tIn(pts, xr); tIn(pts, yr)
            else
                local xr, yr = rot(0, -radius, k*rgap)
                tIn(pts, xr); tIn(pts, yr)
            end
        end

        self.__bd = newPoly(0, 0, pts)
        self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5
        
        self.__bd.strokeWidth = self.__strkw
        self:strokeColor(self.__strkc)
        self:fillColor(self.__fillca)

        return Disp.init(self) --return self:superInit()
    end  
-- --[[
    function Star:strokeWidth(w)
        self.__bd.strokeWidth = w
        self.__strkw = w
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Star:strokeColor(r,g,b)
        local c = Color(r,g,b)
        self.__bd:setStrokeColor(c.r, c.g, c.b)
        self.__strkc = c
        return self
    end
--]]

    -- r, g, b are integers between 0 and 255
    -- fillcolor 는 외곽선은 불투명, 내부색은 투명일 수 있으므로 a도 받는다.
    -- 단, a는 0에서 1사이값
    function Star:fillColor(r,g,b,a)
        local ca = Color(r,g,b,a)
        self.__bd:setFillColor(ca.r, ca.g, ca.b, ca.a)
        self.__fillca = ca
        return self
    end

end