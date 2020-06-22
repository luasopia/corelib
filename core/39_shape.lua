-- 2020/06/15 
--------------------------------------------------------------------------------
local Rawshape = _luasopia.Rawshape
local WHITE = Color.WHITE -- default stroke/fill color
--------------------------------------------------------------------------------
Shape = class(Group)

function Shape:init(pts, opt)
    Group.init(self)
    -- --[[
    if pts==nil then
        self._sopt = {sw=0, sc=WHITE, fc=WHITE}
    else
        opt = opt or {}
        opt.sw = opt.strokewidth or 0
        opt.sc = opt.strokecolor or WHITE
        opt.fc = opt.fillcolor or WHITE

        self._sopt = opt -- shape option
        --self.__spts = pts
        self:add( Rawshape(pts, opt) )
    end
    --self:add(Circle(10):fill(Color.RED))
    --]]
end

function Shape:redraw(pts, opt)
    -- opt에서 지정된 것만 바꾸고 기존 것은 유지한다
    opt = opt or {}
    opt.sw = opt.strokewidth or self.__spts.sw
    opt.sc = opt.strokecolor or self.__spts.sc
    opt.fc = opt.fillcolor or self.__spts.fc
    self._sopt = opt

    self:clear()
    self:add( Rawshape(pts, opt) )
end

function Shape:fill(color)
    self._sopt.fc = color
    return self
end

function Shape:strokecolor(color)
    self._sopt.sc = color
    return self
end

function Shape:strokewidth(w)
    self._sopt.sw = w
    return self
end