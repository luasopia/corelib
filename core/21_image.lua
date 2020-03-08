if not_required then return end -- This prevents auto-loading in Gideros

local Disp = Display
--------------------------------------------------------------------------------
-- 2020/02/04: Image클래스의 인수를 두 개로 간단히 (parent는 생략 가능)
-- local p = Image(url [, parent])
-- p:set{x=0, y=0, xscale=1, yscale=1, scale=1, alpha=1}
-- p:getX(), p:getY(), p:getXscale(), p:getYscale(), p:getScale(), p:getAlpha() 
-- p:setX(v), p:setY(v), p:setXscale(v), p:setYscale(v), p:setScale(v), p:setAlpha(v) 
-- p:removeIf = function(self) ... end
-- p:removeAfter(ms)
-- p:remove() -- 즉시 삭제
-- p:setSpeed{x=n, y=n, xscale=n, yscale=n, scale=n, alpha=n}
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
Image = class(Disp)
--------------------------------------------------------------------------------
if _Gideros then
  print('core.Image(gid)')

  
    local Tnew = _Gideros.Texture.new
    local Bnew = _Gideros.Bitmap.new
    --------------------------------------------------------------------------------
    -- texture를 외부에서 따로 만들어서 여러 객체에서 공유하는 거나
    -- 아래와 같이 개별 객체에서 별도로 만드는 경우나 textureMemory의 차이가 없다.
    --------------------------------------------------------------------------------
    function Image:init(url, parent)
      --setmetatable(self, {__index=Disp.__get__})

      local texture = Tnew(url)
      self.__bd = Bnew(texture)
      self.__bd:setAnchorPoint(0.5, 0.5)
      self.__pr = parent or scrn
      return Disp.init(self) --return self:superInit()
    end
  
elseif _Corona then

  print('core.Image(cor)')
  local newImg = _Corona.display.newImage
  --------------------------------------------------------------------------------
  function Image:init(url, parent)
    self.__bd = newImg(url)
    self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5
    self.__pr = parent
    return Disp.init(self) --return self:superInit()
  end  
  
end