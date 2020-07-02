-- 2020/06/15 
--------------------------------------------------------------------------------
local Rawshape = _luasopia.Rawshape
local WHITE = Color.WHITE -- default stroke/fill color
local getshp = _luasopia.getshape
local Disp = Display
--------------------------------------------------------------------------------
Shape = class(Disp)
local newGrp
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if _Gideros then

    newGrp = _Gideros.Sprite.new

    function Shape:_add(shp)
        self.__bd:addChild(shp)
        return self
    end

    function Shape:_clr()
        for k = self.__bd:getNumChildren(),1,-1 do
            self.__bd:getChildAt(k):removeFromParent() -- 모든 차일드 삭제
        end
    end

    -- shape이 딱 하나만 있는 경우
    function Shape:_clr1()
        self.__bd:getChildAt(1):removeFromParent()
    end
--------------------------------------------------------------------------------
elseif _Corona then

    newGrp = _Corona.display.newGroup

    function Shape:_add(shp)
        self.__bd:insert(shp)
        return self
    end

    function Shape:_clr()
        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k]:removeSelf() -- 차일드 각각의 소멸자 호출(즉시 삭제)
          end    
    end

    function Shape:_clr1()
        self.__bd[1]:removeSelf()
    end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Shape:init(pts, opt)
    self._pts = pts
    if opt == nil then
        self._sopt = {sw=0, sc=WHITE, fc=WHITE}
    else
        self._sopt = {
            sw = opt.strokewidth or 0,
            sc = opt.strokecolor or WHITE,
            fc = opt.fill or opt.fillcolor or WHITE,
        }
    end

    self.__bd = newGrp()
    self:_add( getshp(pts, self._sopt) )

    return Disp.init(self)
end

function Shape:_rdrw(pts, opt)
    self._pts = pts
    
    if opt~=nil then 
        local so = self._sopt
        so.sw = opt.strokewidth or so.sw
        so.sc = opt.strokecolor or so.sc
        so.fc = opt.fill or opt.fillcolor or so.fc
    end
    
    self:_clr()
    return self:_add( getshp(pts, self._sopt) )
end

-- pts만 새로 주어지는 경우 (shape객체가 하나만 있는 경우)
function Shape:_re_pts1(pts)
    self._pts = pts
    self:_clr1()
    return self:_add( getshp(pts, self._sopt) )
end

-- 옵션만 변경되는 경우 (shape객체가 하나만 있는 경우)
function Shape:_re_opt1(pts, opt)
    local so = self._sopt
    so.sw = opt.strokewidth or so.sw
    so.sc = opt.strokecolor or so.sc
    so.fc = opt.fill or opt.fillcolor or so.fc
    
    self:_clr1()
    return self:_add( getshp(self._pts, so) )
end

-- pts와 opt 둘 다 변경되는 경우 (shape객체가 하나만 있는 경우)
-- pts 와 opt 둘 다 table이어야 한다.
function Shape:_rdrw1(pts, opt)
    self._pts = pts
    
    --if opt~=nil then 
    local so = self._sopt
    so.sw = opt.strokewidth or so.sw
    so.sc = opt.strokecolor or so.sc
    so.fc = opt.fill or opt.fillcolor or so.fc
    --end
    
    self:_clr1()
    return self:_add( getshp(pts, self._sopt) )
end

function Shape:fill(color)
    self._sopt.fc = color
    self:_clr1()
    return self:_add( getshp(self._pts, self._sopt) )
end
Shape.fillcolor = Shape.fill

function Shape:strokewidth(sw)
    self._sopt.sw = sw
    self:_clr1()
    return self:_add( getshp(self._pts, self._sopt) )
end

function Shape:strokecolor(color)
    self._sopt.sc = color
    self:_clr1()
    return self:_add( getshp(self._pts, self._sopt) )
end