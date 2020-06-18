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

--[[
--------------------------------------------------------------------------------
-- 2020/06/16 tail effect 구현
-- 주의: tail에서는 strokecolor는 지정하지 않는 것이 좋다(경계선이 생기므로)
--------------------------------------------------------------------------------
local tblin = table.insert
local tblrm = table.remove
local unpack = unpack

-- opt = {
--  joints (default=4) : number of joints of tail
--  framegap (default=3) : length of tail segment
--}

local function tmrf(self)
    local pxys, njnt, njnt1 = self._pxys, self._njnt, self._njnt1

    tblin(pxys, {self:getxy()})
    if #pxys>njnt1 then tblrm(pxys,1) end
    if pxys[njnt1] ~=nil then
        local x0, y0 = unpack(pxys[njnt1])
        local pts = {pxys[njnt][1]-x0, pxys[njnt][2]-y0}
        for k=njnt-1,1,-1 do
            tblin(pts, pxys[k][1]-x0)
            tblin(pts, pxys[k][2]-y0)
        end
        self:__tail(pts)
    end
end

function Shape:drawtail(width, opt)
    opt = opt or {}

    self._pxys = {} -- past xy's
    self._twdt = width/2 -- 2로나눠야 실제 폭이 width가 된다
    self._njnt = opt.joints or 2
    self._njnt1 = self._njnt+1
    self:timer(40, tmrf, INF) -- 40
    return self
end
--]]