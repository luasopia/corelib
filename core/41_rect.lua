-- if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
local Disp = Display
local Color, WHITE = Color, Color.WHITE -- default color
--------------------------------------------------------------------------------
-- local r = Rect(width, height [, parent])
--------------------------------------------------------------------------------
Rect = class(Disp)
-- _luasopia.Rawrect = class(Disp)
-- local Rawrect = _luasopia.Rawrect
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

    --2020/06/23
    function Rect:width(n)
        self.__width = n
        return self:_rdrw()
    end

    function Rect:height(n)
        self.__height = n
        return self:_rdrw()
    end

    function Rect:_rdrw()
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

elseif _Corona then --##############################################################

    print('core.Rect(cor)')
    local nRect = _Corona.display.newRect
    local nGrp = _Corona.display.newGroup
    --------------------------------------------------------------------------------
    function Rect:_drw()
        local rect = nRect(0, 0, self._wdh, self._hgt)
        rect.anchorX, rect.anchorY = self._apx, self._apy

        local sc = self.__strkc
        local fca = self.__fillca
        rect.strokeWidth = self.__strkw
        rect:setStrokeColor(sc.r, sc.g, sc.b)
        rect:setFillColor(fca.r, fca.g, fca.b, fca.a)
         
        return rect
    end
    --------------------------------------------------------------------------------
    function Rect:init(width, height, opt, parent)
        self._wdh = width
        self._hgt = height
        opt = Disp.__optOrPr(self, opt, parent)
        self._apx, self._apy = 0.5, 0.5
        ----------------------------------------------------------------------
        self.__bd = nGrp()
        self._sbd = self:_drw()
        self.__bd:insert(self._sbd)

        return Disp.init(self) --return self:superInit()
    end  


    function Rect:_rdrw()
        -- print('redraw()')
        self.__bd[1]:removeSelf()
        self.__sbd = self:_drw()
        self.__bd:insert(self.__sbd)
        return self
    end

    function Rect:width(w)
        self._wdh = w
        return self:_rdrw()
    end

    function Rect:height(h)
        self._hgt = h
        return self:_rdrw()
    end


end

-- refer methods in Display class
Disp.__regshape__(Rect)