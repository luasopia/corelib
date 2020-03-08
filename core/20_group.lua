if not_required then return end -- This prevents auto-loading in Gideros

local Disp = Display

Group = class(Disp)
--------------------------------------------------------------------------------
if _Gideros then
    print('core.group(gid)')  
  local Snew = _Gideros.Sprite.new
  --------------------------------------------------------------------------------
  function Group:init(parent)
    self.__bd = Snew()
    self.__pr = parent
    -- self.class = 'Group'
    return Disp.init(self)
  end

  function Group:add(child)
    child.__pr = self
    self.__bd:addChild(child.__bd)
    child.__bd:setPosition(0,0) -- 2020/03/04
    return child
  end

  -- Disp 베이스클래스의 remove()를 오버로딩
  function Group:__del__()
    -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
    -- 여기서 소멸자를 호출하여 그룹이 삭제되는 즉시 child들도 삭제토록 한다.
    for k = self.__bd:getNumChildren(),1,-1 do
      local obj = self.__bd:getChildAt(k).__obj
      obj:remove() -- 차일드 각각의 소멸자 호출
    end
    -- (2) 자신도 (부모그룹에서) 제거
    return Disp.remove(self) -- 부모의 소멸자 호출
  end

  -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
  function Group:touchOff()
      -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
      for k = self.__bd:getNumChildren(),1,-1 do
        local obj = self.__bd:getChildAt(k).__obj
        obj:touchOff() -- 차일드 각각의 소멸자 호출
      end
      -- (2) 자신도 (부모그룹에서) 터치를 멈춤
      return Disp.touchOff(self)
  end

    -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
  function Group:touchOn() print('---group enabletch')
      -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
      for k = self.__bd:getNumChildren(),1,-1 do
        local obj = self.__bd:getChildAt(k).__obj
        obj:touchOn() -- 차일드 각각의 소멸자 호출
      end
      -- (2) 자신도 (부모그룹에서) 터치를 멈춤
      return Disp.touchOn(self)
  end

    -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
    function Group:updateOff()
      -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
      for k = self.__bd:getNumChildren(),1,-1 do
        local obj = self.__bd:getChildAt(k).__obj
        obj:updateOff() -- 차일드 각각의 소멸자 호출
      end
      -- (2) 자신도 (부모그룹에서) 터치를 멈춤
      return Disp.updateOff(self)
  end

      -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
      function Group:updateOn()
        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        for k = self.__bd:getNumChildren(),1,-1 do
          local obj = self.__bd:getChildAt(k).__obj
          obj:updateOn() -- 차일드 각각의 소멸자 호출
        end
        -- (2) 자신도 (부모그룹에서) 터치를 멈춤
        return Disp.updateOn(self)
    end
  
  
elseif _Corona then

    print('core.group(cor)')  
  
  local Gnew = _Corona.display.newGroup
  --------------------------------------------------------------------------------
  function Group:init(parent)
    self.__bd = Gnew()
    self.__pr = parent or scrn
    -- self.class = 'Group'
    return Disp.init(self) --return self:superInit()
  end

  function Group:add(child)
    child.__pr = self
    child.__bd.x, child.__bd.y = 0,0
    return self.__bd:insert(child.__bd)
  end

  -- Disp 베이스클래스의 remove()를 오버로딩
  function Group:remove()
    -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
    -- 여기서 소멸자를 호출하여 그룹이 삭제되는 즉시 child들도 삭제토록 한다.
    for k = self.__bd.numChildren, 1, -1 do
      local obj = self.__bd[k].__obj
      obj:remove()
    end
    -- (2) 자신도 (부모그룹에서) 제거
    return Disp.remove(self) -- 부모의 소멸자 호출
  end

end