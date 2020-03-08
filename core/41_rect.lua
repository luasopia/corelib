if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
local Disp = Display
local Color, WHITE = Color, Color.WHITE
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
    
    function Rect:init(width, height, parent)
        self.__ancx, self.__ancy = 0.5, 0.5
        self.__width, self.__height = width, height
        self.__strkw, self.__strkc = 0, WHITE -- stroke width and color
        self.__fillca = Color(WHITE, 1) -- fill color and alpha
        self.__ancx, self.__ancy = 0.5, 0.5
        self.__bd = Sprtnew()
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        self.__pr = parent
        return Disp.init(self)
    end


    --[[
    function Rect:strokeWidth(w)
        self.__strkw = w
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Rect:strokeColor(r,g,b)
        self.__strkc = Color(r,g,b)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Rect:fillColor(r,g,b,a)
        self.__fillca = Color(r,g,b,a)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end
    --]]


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

elseif _Corona then

    print('core.Rect(cor)')
    local newRect = _Corona.display.newRect
    --------------------------------------------------------------------------------
    function Rect:init(width, height, parent)
        self.__bd = newRect(0,0,width,height)
        self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5
        self.__pr = parent
        return Disp.init(self) --return self:superInit()
    end  
--[[
    function Rect:strokeWidth(w)
        self.__bd.strokeWidth = w
        self.__strkw = w
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Rect:strokeColor(r,g,b)
        local c = Color(r,g,b)
        self.__bd:setStrokeColor(c.r ,c.g, c.b)
        self.__strkc = c
        return self
    end

    -- r, g, b are integers between 0 and 255
    -- fillcolor 는 외곽선은 불투명, 내부색은 투명일 수 있으므로 a도 받는다.
    -- 단, a는 0에서 1사이값
    function Rect:fillColor(r,g,b,a)
        local ca = Color(r,g,b,a)
        self.__bd:setFillColor(ca.r, ca.g, ca.b, ca.a)
        self.__fillca = ca
        return self
    end
    --]]

end

Rect.strokeWidth = Disp.__strokeWidth__
Rect.strokeColor = Disp.__strokeColor__
Rect.fillColor = Disp.__fillColor__
