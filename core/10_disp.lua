print('core.dobj')
--------------------------------------------------------------------------------
local tIn = table.insert
local tRm = table.remove
local tmgapf = 1000/_luasopia.fps
local int = math.floor
local Timer = Timer
--local baselayer = _luasopia.baselayer
local cx, cy = _luasopia.centerx, _luasopia.centery
--------------------------------------------------------------------------------
-- Display 객체 d에 대해서
-- 읽기- d:getx(), d:gety(), d:getangle() d:getscale() img:getalpha()
-- 쓰기- d:set{}, d:setx(v), d:sety(v), d:setxy(x,y) d:setangle(v)
--       d:setscale(v) d:setalpha(v)
-- 메서드 - d:move{}, d:shift{}, d:removeAfter(n), d:remove()
--------------------------------------------------------------------------------
-- 2020/02/06: 모든 set...()함수는 self를 반환하도록 수정됨
-- 향후: 내부코드는 속도를 조금이라도 높이기 위해서 self.__bd객체를 직접 접근한다
----------------------------------------------------------------------------------
Display = class()
--------------------------------------------------------------------------------
-- static members of this class ------------------------------------------------
--------------------------------------------------------------------------------
local dobjs = {} -- Display OBJectS
Display._dtobj = {}
local dtobj = Display._dtobj -- Display Tagged OBJect
local ndobjs = 0
-------------------------------------------------------------------------------
-- static public method
-------------------------------------------------------------------------------
--[[
Display.updateAll = function()
    --(1) __upd() 호출, 그 내부에서 없앨 객체는 remove()를 호출해야한다
    --2020/03/10 이미 __del__()이 호출된 경우는 dobjs 테이블에서 삭제만 한다
    -- child는 Group이 소멸될 때 이미 __del__()이 호출되었으므로
    -- 이경우 dobjs에서만 삭제한다.
    for k = #dobjs, 1, -1 do
        local obj = dobjs[k]
        if obj.__bd ~= nil then
            obj:__upd()
        else -- 이미 __del__()함수가 호출되어 내부가 삭제된 경우
             -- dobjs 테이블에서만 삭제한다.
            tRm(dobjs, k)
        end
    end

    --(2) 제거될 객체로 표시된 것들을 (반드시 *역순*으로) 제거한다.
    for k = #dobjs, 1, -1 do
        local obj = dobjs[k]
        if obj.__rm then
            obj:__del__()
            tRm(dobjs, k)
        end
    end
end
--]]

--2020/06/20 dobj[self]=self로 저장하기 때문에 self:remove()안에서 바로 삭제 가능
-- 따라서 updateAll()함수의 구조가 (위의 함수와 비교해서) 매우 간단해 짐
Display.updateAll = function()
    for _, obj in pairs(dobjs) do --for k = #dobjs,1,-1 do local obj = dobjs[k]
        obj:__upd()
    end
end

Display.__getNumObjs = function() return ndobjs - _luasopia.dcdobj end

-------------------------------------------------------------------------------
-- public methods
-------------------------------------------------------------------------------

function Display:init()

    -- 2020/02/16 screen에 add하는 경우 중앙에 위치시킨다.
    if self.__pr == nil then
        self.__pr = _luasopia.stage --baselayer
        self.__pr:add(self)
        self:xy(cx, cy)
    else -- 2020/03/04 : 그룹에 넣는 경우는 원점으로 위치를 바꾼다
        self.__pr:add(self)
    end
    -- 2020/02/20 그룹에 넣는 경우는 원점(0,0)에 배치한다.

    self.__bd.__obj = self -- body에 원객체를 등록 (_Grp의 __del함수에서 사용)
    self.__al = self.__al or 1 -- only for coronaSDK (for storing alpha)

    --return tIn(dobjs, self) -- 꼬리호출
    dobjs[self] = self
    ndobjs = ndobjs + 1
end

-- This function is called in every frames
function Display:__upd()
    --if self.__rm then return end -- 반드시 필요함

    if self.__tm then self.__tm = self.__tm + tmgapf end
    if self.__d then self:__playd() end  -- move{}
    if self.__tr then self:__playTr() end -- shift{}
    
    -- 2020/02/16 call user update if exists
    -- 2020/06/02 : update()가 true를 반환하면 삭제하도록 수정
    if self.update and not self.__noupd then
        self.__retupd = self:update()
    end 
    
    if self.touch and self.__tch==nil then self:__touchon() end
    if self.tap and self.__tap==nil then self:__tapon() end

    if (self.__rma and self.__rma<=self.__tm)
        or self.__retupd
        or (self.removeif and self:removeif()) then
        return self:remove()
    end
    
    -- 아래가 더 간단해 보이지만 이경우 self.__rm이 이미 true인데 
    -- 다시 false로 바뀌어버리는 경우도 존재
    -- 2020/03/19:따라서 **절대로** 아래와 같이 하면 안됨
    -- self.__rm = (self.__rma and self.__rma<=self.__tm) or
    --         (self.removeif and self:removeif())
end


-- function Display:setTimer(delay, func, loops, onEnd)
function Display:timer(...)
    self.__tmrs = self.__tmrs or {}
    local tmr = Timer(...)
    tmr.__dobj = self -- callback함수의 첫 번째 인자로 넘긴다.
    --tIn(self.__tmrs, t)
    self.__tmrs[tmr] = tmr
    
    --return self
    return tmr -- 2020/03/27 수정
end

function Display:removeafter(ms)
    self.__tm = 0
    self.__rma = ms
    return self
end

function Display:resumeupdate() self.__noupd = false; return self end
function Display:stopupdate() self.__noupd = true; return self end

--2020/03/02: group:add(child) returns child
function Display:addto(g)
    g:add(self)
    return self
end

--function Display:remove() self.__rm = true end
function Display:isremoved() return self.__bd==nil end

--2020/06/12
function Display:getparent()
    return self.__pr
end

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
if _Gideros then -- gideros
    
    --[[
    Display.__get__ = function(o, k)
        if k=='x' then return o.__bd:getX()
        elseif k=='y' then return o.__bd:getY()
        elseif k=='r' or k=='rot' then return o.__bd:getRotation()
        elseif k=='s' or k=='scale' then 
            local sx, sy = o.__bd:getScale()
            return (sx+sy)/2 
        elseif k=='a' or k=='alpha' then return o.__bd:getAlpha()
        elseif k=='xs' or k=='xscale' then return o.__bd:getScaleX()
        elseif k=='ys' or k=='yscale' then return o.__bd:getScaleY()
        else return Display[k] end
    end
    --]]

    function Display:getx() return self.__bd:getX() end
    function Display:gety() return self.__bd:getY() end

    function Display:getrot() return self.__bd:getRotation() end -- 2020/02/26
    Display.getr = Display.getrot

    -- gideros getScale() returns xScale, yScale, and zScale
    function Display:getscale() local sx, sy = self.__bd:getScale(); return (sx+sy)/2 end
    Display.gets = Display.getscale

    function Display:getalpha() return self.__bd:getAlpha() end
    Display.geta = Display.getalpha

    function Display:getxscale() return self.__bd:getScaleX() end
    Display.getxs = Display.getxscale

    function Display:getyscale() return self.__bd:getScaleY() end
    Display.getys = Display.getyscale

    function Display:getxy() return self.__bd:getPosition() end
    
    function Display:getvisible() return self.__bd:isVisible() end

    function Display:getanchor() return self.__bd:getAnchorPoint() end
    -- 2020/02/04 args.init을 제거하고 대신 set()메서드 추가
    function Display:set(arg)
        local t
        if arg.x then self.__bd:setX(arg.x) end
        if arg.y then self.__bd:setY(arg.y) end
        t = arg.r or arg.rot; if t then self.__bd:setRotation(t) end
        t = arg.s or arg.scale; if t then self.__bd:setScale(t) end
        t = arg.a or arg.alpha; if t then self.__bd:setAlpha(t) end
        t = arg.xs or arg.xscale; if t then self.__bd:setScaleX(t) end
        t = arg.ys or arg.yscale; if t then self.__bd:setScaleY(t) end
        return self
    end

    -- 2020/02/18 ---------------------------------------------------------
    function Display:x(v) self.__bd:setX(v); return self end
    function Display:y(v) self.__bd:setY(v); return self end
    
    function Display:rot(v) self.__bd:setRotation(v); return self end -- 2020/02/26
    Display.r = Display.rot

    -- gid는 setScale(v)라고 하면 scaleX, scaleY(, scaleZ)에 모두 v가 적용됨
    function Display:scale(x,y) self.__bd:setScale(x,y); return self end
    Display.s = Display.scale
    
    -- 2020/04/26 : alpha가 1초과면 1로 세팅한다.
    -- gideros는 1이 넘으면 이미지가 열화(?)되고, 코로나는 자동으로 1로 세팅됨
    function Display:alpha(v) self.__bd:setAlpha(v>1 and 1 or v);return self end
    Display.a = Display.alpha

    -- xs()와 ys()는 x and scale, y and scale로 혼동할 여지가 있어서 삭제
    function Display:xscale(v) self.__bd:setScaleX(v); return self end
    Display.xs = Display.xscale

    function Display:yscale(v) self.__bd:setScaleY(v); return self end
    Display.ys = Display.yscale

    function Display:xy(x,y) self.__bd:setPosition(x,y); return self end
    function Display:xyr(x,y,r)
        self.__bd:setPosition(x,y)
        self.__bd:setRotation(r);
        return self
    end
    
    function Display:anchor(x,y) self.__bd:setAnchorPoint(x,y);return self end
    
    -- 2020/02/18 ---------------------------------------------------------
    
    
    function Display:hide() self.__bd:setVisible(false); return self end
    function Display:show() self.__bd:setVisible(true); return self end
    function Display:visible(v) self.__bd:setVisible(v); return self end

    function Display:tint(r,g,b)
        self.__bd:setColorTransform(r, g ,b)
    return self
    end
    --------------------------------------------------------------------------------
    -- 2020/01/17, 2020/01/27
    -- 외부에서 객체를 제거하려면 소멸자 remove()메서드를 호출한다.
    -- remove()함수가 호출된 즉시 내부 타이머가 실행되지 않는다
    --------------------------------------------------------------------------------

    function Display:remove()
        if self.__tmrs then -- 이 시점에서는 이미 죽은 timer도 있을 것
            -- __rm == true/false 상관없이 무조건 true로 만들면 살아있는 것만 죽을 것임
            -- for k=1,#self.__tmrs do self.__tmrs[k]:remove() end
            for _, tmr in pairs(self.__tmrs) do
                tmr:remove()
            end
        end
        if self.__tch then self:stoptouch() end
        if self.__tap then self:stoptap() end

        self.__bd:removeFromParent()
        self.__bd = nil -- __del__()이 호출되었음을 표시한다.

        --2020/06/20 dobj[self]=self로 저장하기 때문에 삭제가 아래에서 바로 가능해짐
        dobjs[self] = nil
        if self._tag ~=nil then dtobj[self._tag][self] = nil end
        ndobjs = ndobjs - 1
    end

    -- 2020/06/08 : 추가 
    function Display:getglobalxy(x,y)
        return self.__bd:localToGlobal(x or 0,y or 0)
    end

elseif _Corona then -- if coronaSDK --------------------------------------

    function Display:getx() return self.__bd.x end
    function Display:gety() return self.__bd.y end

    function Display:getrot() return self.__bd.rotation end -- 2020/02/26
    Display.getr = Display.getrot
    -- function Display:getr() return self.__bd.rotation end -- 2020/02/25

    -- function Display:getangle() return self.__bd.rotation end
    function Display:getscale() return (self.__bd.xScale + self.__bd.yScale)/2 end
    Display.gets = Display.getscale

    function Display:getalpha() return self.__al end
    Display.geta = Display.getalpha

    function Display:getxscale() return self.__bd.xScale end
    Display.getxs = Display.getxscale

    function Display:getyscale() return self.__bd.yScale end
    Display.getys = Display.getyscale
    
    function Display:getxy() return self.__bd.x, self.__bd.y end
    
    function Display:getvisible() return self.__bd.isVisible end

    function Display:getanchor()
        return self.__bd.anchorX, self.__bd.anchorY
    end

    -- 2020/02/04 args.init을 제거하고 대신 set()메서드 추가
    function Display:set(arg)
        local t
        if arg.x then self.__bd.x = arg.x end
        if arg.y then self.__bd.y = arg.y end
        t = arg.r or arg.rot; if t then self.__bd.rotation = t end
        t = arg.s or arg.scale; if t then self.__bd.xScale,self.__bd.yScale=t,t end
        t = arg.a or arg.alpha; if t then self.__al, self.__bd.alpha = t, t end
        t = arg.xs or arg.xscale; if t then self.__bd.xScale = t end
        t = arg.ys or arg.yscale; if t then self.__bd.yScale = t end
        --[[
        -- 2020/03/08: 추가
        if arg.dx then self.__d = self.__d or {};self.__d.dx = arg.dx end
        if arg.dy then self.__d = self.__d or {};self.__d.dy = arg.dy end
        t = arg.dr or arg.drot; if t then self.__d = self.__d or {};self.__d.dr = t end
        t = arg.da or arg.dalpha; if t then self.__d = self.__d or {};self.__d.da = t end
        t = arg.ds or arg.dscale; if t then self.__d = self.__d or {};self.__d.ds = t end
        t = arg.dxs or arg.dxscale; if t then self.__d = self.__d or {};self.__d.dxs = t end
        t = arg.dys or arg.dyscale; if t then self.__d = self.__d or {};self.__d.dys = t end
        --]]
        return self
    end

    -- 2020/02/18 시험메서드--------------------------------------------------
    function Display:x(v) self.__bd.x = v; return self end
    function Display:y(v) self.__bd.y = v; return self end
    
    function Display:rot(v) self.__bd.rotation = v; return self end -- 2020/02/25
    Display.r = Display.rot
    
    -- setscale(v) 는 xScale, yScale 둘 다 v로;setscale(x,y)는 xScale=x, yScale=y로 설정
    function Display:scale(x, y) self.__bd.xScale, self.__bd.yScale = x, y or x;return self end
    Display.s = Display.scale
    
    function Display:alpha(v) self.__al, self.__bd.alpha = v,v; return self end
    Display.a = Display.alpha
    
    function Display:xscale(v) self.__bd.xScale = v; return self end
    Display.xs = Display.xscale

    function Display:yscale(v) self.__bd.yScale = v; return self end
    Display.ys = Display.yscale

    function Display:xy(x,y) self.__bd.x, self.__bd.y = x, y; return self end
    function Display:xyr(x,y,r) 
        self.__bd.x, self.__bd.y = x, y
        self.__bd.rotation = r
        return self
    end

    function Display:anchor(x,y) self.__bd.anchorX, self.__bd.anchorY = x,y;return self end

    -- 2020/02/18 ---------------------------------------------------------

    function Display:hide() self.__bd.isVisible = false; return self end
    function Display:show() self.__bd.isVisible = true; return self end
    
    function Display:visible(v) self.__bd.isVisible = v; return self end

    function Display:remove() --print('disp_del_') 
        if self.__tmrs then -- 이 시점에서는 이미 죽은 timer도 있을 것
            for _, tmr in pairs(self.__tmrs) do
                tmr:remove()
            end
        end

        if self.__tch then self:stoptouch() end
        if self.__tap then self:stoptap() end

        self.__bd:removeSelf()
        self.__bd = nil -- __del__()이 호출되었음을 표시하는 역할도 함

        --2020/06/20 소멸자안에서 dobjs 테이블의 참조를 삭제한다
        dobjs[self] = nil
        ndobjs = ndobjs - 1
        if self._tag ~=nil then dtobj[self._tag][self] = nil end
    end

    function Display:tint(r,g,b)
        self.__bd:setFillColor(r,g,b)
        return self
    end

    -- 2020/06/08 : 추가 
    function Display:getglobalxy(x,y)
        return self.__bd:localToContent(x or 0,y or 0)
    end
end
