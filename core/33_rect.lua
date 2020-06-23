-- 2020/06/23 refactoring Rect class 
--------------------------------------------------------------------------------
-- local r = Rect(width, height [, opt])
--------------------------------------------------------------------------------
Rect = class(Shape)
--------------------------------------------------------------------------------
-- 2020/02/23 : anchor위치에 따라 네 꼭지점의 좌표를 결정
local function mkpts(w, h, apx, apy)
    local x1, y1 = w*-apx, h*-apy -- (x,y) of left-top
    local x2, y2 = w*(1-apx), h*(1-apy) -- (x,y) of right-bottom
    return {
        x1, y1,
        x2, y1,
        x2, y2,
        x1, y2,
    }
end

function Rect:init(width, height, opt)
    self._wdth, self._hght = width, height
    self._apx, self._apy = 0.5, 0.5 -- AnchorPointX, AnchorPointY
    return Shape.init(self, mkpts(width, height, 0.5, 0.5), opt)
end

-- 2020/02/23 : Gideros의 경우 anchor()함수는 오버라이딩해야 한다.
function Rect:anchor(ax, ay)
    self._apx, self._apy = ax, ay
    self:_re_pts1(mkpts(self._wdth, self._hght, ax, ay))
    return self
end

function Rect:getanchor()
    return self._apx, self._apy
end

--2020/06/23
function Rect:width(w)
    self._wdth = w
    self:_re_pts1( mkpts(w,self._hght,self._apx, self._apy) )
    return self
end

function Rect:height(h)
    self._hght = g
    self:_re_pts1( mkpts(self._wdth, h, self._apx, self._apy) )
    return self
end

--##############################################################################
--------------------------------------------------------------------------------
-- 2020/02/23 : screen 에 touch()를 직접붙이기 위해서 Rect를 screen으로 생성해서
-- _baselayer에 등록
-- 2020/06/23 : Rect클래스를 리팩토링한 후 여기로 옮김
--------------------------------------------------------------------------------
local ls = _luasopia
local x0, y0, endx, endy = ls.x0, ls.y0, ls.endx, ls.endy
--2020/05/06 Rect(screen)가 safe영역 전체를 덮도록 수정
--2020/05/29 baselayer에 생성되어야 한다. xy는 센터로
--screen = Rect(endx-x0+1, endy-y0+1,{fillcolor=Color.BLACK}, _luasopia.baselayer)
screen = Rect(endx-x0+1, endy-y0+1, {fillcolor=Color.BLACK})

screen:xy(ls.centerx, ls.centery)
screen.width = ls.width
screen.height = ls.height
screen.centerx = ls.centerx
screen.centery = ls.centery
screen.fps = ls.fps
-- added 2020/05/05
screen.devicewidth = ls.devicewidth
screen.deviceheight = ls.deviceheight
-- orientations: 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
screen.orientation = ls.orientation 
-- added 2020/05/06
screen.x0, screen.y0, screen.endx, screen.endy = x0, y0, endx, endy
--##############################################################################