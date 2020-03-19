if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------

if _Gideros then

    local Event = _Gideros.Event

    local function tapfn(self, event) printf('%s touch begin', self.name)
        local t = event.touch
        if self.__bd:hitTestPoint(t.x, t.y) then
            self:tap{numTaps=1, x=t.x, y=t.y}
            event:stopPropagation()
        end
    end

    function Display:tapon() print('try tap')
        if self.tap then
            self.__bd:addEventListener(Event.TOUCHES_BEGIN, tapfn, self)
            self.__tap = true
        end
        return self
    end
    
--[[
    function Display:disableTap()
        if self.tap then
            self.__bd:removeEventListener(Event.TOUCHES_BEGIN, tapfn, self)
            self.__tap = false
        end
    end
--]]

elseif _Corona then ---------------------------------------

    local function tapfn(e)
        local self = e.target.__obj
        printf('%s tap event:%s',self.name, e.phase)
        local dx, dy = 0, 0
  
        -- 2020/02/17 : 'ended'이벤트를 self.tap()호출하기 전 강제로 발생시켜
        -- 터치이벤트를 시작하자마자 종료시킨다.
        if e.phase=='began' then print('tap begin')
            self.__bd:dispatchEvent{name='touch',id=e.id, phase='ended', target=self.__bd}
            self:tap{id = e.id, phase="begin", x=e.x, y=e.y, dx=dx, dy=dy}
            return true
          
        elseif e.phase == 'ended' then print('tap end')
            return true
  
        else -- if  event.phase =='cancelled' then
          return true
        end
  
    end
    -- 2020/02/17 누르는 순간에 tap이벤트를 발생시키기 위해서
    -- 코로나의 'tap'이벤트가 아니라 'touch'이벤트를 이용한다.
    
    function Display:tapon()
        if self.tap then --print('enable tap')
            self.__bd:addEventListener('touch', tapfn)
            self.__tap = true
        end
        return self
    end
--[[

    function Display:__offtap()
        if self.tap then 
            self.__bd:removeEventListener('touch', tapfn)
            self.__tap = false
        end
    end
--]]
end