if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
local Disp = Display
local Color, WHITE = Color, Color.WHITE -- default color
--------------------------------------------------------------------------------
-- local r = Rect(width, height [, parent])
--------------------------------------------------------------------------------
Rect = class(Disp)
--------------------------------------------------------------------------------
if _Gideros then
    print('core.Rect(gid)')

    local Shape = _Gideros.Shape
    local Sprtnew = _Gideros.Sprite.new

    -- 2020/02/23 : anchor위치에 따라 네 꼭지점의 좌표를 결정
    function Rect:__draw()
        local ltx, lty = self.__width*-self.__ancx, self.__height*-self.__ancy -- (x,y) of left-top
        local rbx, rby = self.__width*(1-self.__ancx), self.__height*(1-self.__ancy) -- (x,y) of right-bottom
        local s = Shape.new()
        s:beginPath()
        s:setLineStyle(self.__strkw, self.__strkc.hex) -- (width, color, alpha)
        s:setFillStyle(Shape.SOLID, self.__fillca.hex, self.__fillca.a)
        s:moveTo(ltx, lty)
        s:lineTo(ltx, rby)
        s:lineTo(rbx, rby)
        s:lineTo(rbx, lty)
        s:lineTo(ltx, lty)
        s:endPath()

        s:setPosition(self.__apx or 0, self.__apy or 0)
        return s
    end
    
    function Rect:init(width, height, opt, parent)
        self.__width, self.__height = width, height
        opt = Disp.__optOrPr(self, opt, parent)
        ----------------------------------------------------------------------
        self.__ancx, self.__ancy = 0.5, 0.5
        self.__bd = Sprtnew()
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)

        return Disp.init(self)
    end

    -- 2020/02/23 : Gideros의 경우 anchor()함수는 오버라이딩해야 한다.
    function Rect:anchor(ax, ay)
        local x, y = self.__width*(0.5-ax), self.__height*(0.5-ay)
        self.__sbd:setPosition(x,y)
        self.__apx, self.__apy = x,y -- Anchor Point X/Y
        self.__ancx, self.__ancy = ax, ay
        return self
    end

    function Rect:getanchor()
        return self.__ancx, self.__ancy
    end

elseif _Corona then --##############################################################

    print('core.Rect(cor)')
    local newRect = _Corona.display.newRect
    --------------------------------------------------------------------------------
    function Rect:init(width, height, opt, parent)
        opt = Disp.__optOrPr(self, opt, parent)
        ----------------------------------------------------------------------
        self.__bd = newRect(0, 0, width, height)
        self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5

        local sc = self.__strkc
        local fca = self.__fillca
        self.__bd.strokeWidth = self.__strkw
        self.__bd:setStrokeColor(sc.r, sc.g, sc.b)
        self.__bd:setFillColor(fca.r, fca.g, fca.b, fca.a)

        return Disp.init(self) --return self:superInit()
    end  

end

-- refer methods in Display class
Rect.strokewidth = Disp.__strokeWidth__
Rect.strokecolor = Disp.__strokeColor__
Rect.fillcolor = Disp.__fillColor__