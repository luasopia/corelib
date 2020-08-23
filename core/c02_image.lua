-- if not_required then return end -- This prevents auto-loading in Gideros

local Disp = Display
--------------------------------------------------------------------------------
-- 2020/08/23: Image클래스의 인수를 url 한 개만으로
-- local p = Image(url)
-- p:set{x=0, y=0, xscale=1, yscale=1, scale=1, alpha=1}
-- p:getx()), p:gety(), p:getxscale(), p:getyscale(), p:getscale(), p:getalpha() 
-- p:x(v), p:y(v), p:xscale(v), p:yscale(v), p:scale(v), p:alpha(v) 
-- function p:update() ... end
-- p:remove() -- 즉시 삭제
-- p:removeafter(ms) -- ms 이후에 삭제
-- p:move{dx=n, dy=n, dxscale=n, dyscale=n, dscale=n, dalpha=n}
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
    function Image:init(url)
      local texture = Tnew(url)
      self.__bd = Bnew(texture)
      self.__bd:setAnchorPoint(0.5, 0.5)
      return Disp.init(self) --return self:superInit()
    end

    -- 2020/06/20 arguemt ture means 'do not consider transformation'
    function Image:getwidth() return self.__bd:getWidth(true) end
    function Image:getheight() return self.__bd:getHeight(true) end
  
elseif _Corona then

  print('core.Image(cor)')
  local newImg = _Corona.display.newImage
  --------------------------------------------------------------------------------
  function Image:init(url, parent)
    self.__bd = newImg(url)
    self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5
    return Disp.init(self) --return self:superInit()
  end  
  
  -- 2020/06/20
  function Image:getwidth() return self.__bd.width end
  function Image:getheight() return self.__bd.height end

end