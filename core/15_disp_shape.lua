if not_required then return end -- This prevents auto-loading in Gideros
print('core.disp_shape')

-- 2020/03/03: Shape의 공통 메서드를 저장함
-- Disp에 __nn__ 메서드를 저장해 놓고 각 shape 클래스의 메서드에 복사

local Disp = Display

if _Gideros then

    function Disp:__strokeWidth__(w)
        self.__strkw = w
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Disp:__strokeColor__(r,g,b)
        self.__strkc = Color(r,g,b)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Disp:__fillColor__(r,g,b,a)
        self.__fillca = Color(r,g,b,a)
        self.__bd:removeChildAt(1)
        self.__sbd = self:__draw()
        self.__bd:addChild(self.__sbd)
        return self
    end


elseif _Corona then

    function Disp:__strokeWidth__(w)
        self.__bd.strokeWidth = w
        self.__strkw = w
        return self
    end

    -- r,g,b는 0-255 범위의 정수
    function Disp:__strokeColor__(r,g,b)
        local c = Color(r,g,b)
        self.__bd:setStrokeColor(c.r ,c.g, c.b)
        self.__strkc = c
        return self
    end

    -- r, g, b are integers between 0 and 255
    -- fillcolor 는 외곽선은 불투명, 내부색은 투명일 수 있으므로 a도 받는다.
    -- 단, a는 0에서 1사이값
    function Disp:__fillColor__(r,g,b,a)
        local ca = Color(r,g,b,a)
        self.__bd:setFillColor(ca.r, ca.g, ca.b, ca.a)
        self.__fillca = ca
        return self
    end

end