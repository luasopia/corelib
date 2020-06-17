-- 2020/06/15 
--------------------------------------------------------------------------------
local WHITE = Color.WHITE -- default stroke/fill color
--------------------------------------------------------------------------------
_luasopia.Rawshape = class(Display)
local Rawshape = _luasopia.Rawshape
--------------------------------------------------------------------------------
if _Gideros then

    local GShape = _Gideros.Shape

    function Rawshape:init(pts, opt)

        local xs, ys = pts[1], pts[2]
        local s = GShape.new()

        s:setLineStyle(opt.sw, opt.sc.hex, opt.sc.a) -- width, color, alpha
        s:setFillStyle(GShape.SOLID, opt.fc.hex, opt.fc.a)
        
        s:beginPath()
        s:moveTo(xs, ys) -- starting at upmost point
        for k=1,#pts,2 do s:lineTo(pts[k], pts[k+1]) end
        s:lineTo(xs, ys) -- ending at the (first) starting point
        s:endPath()
        -- gideros의 shape는 자동으로 원점(0,0)이 anchor point가 된다
        --s:setPosition(self.__apx or 0, self.__apy or 0)
        ------------------------------------------------------------------------
        self.__bd = s
        return Display.init(self)
    end


elseif _Corona then

    local newPoly = _Corona.display.newPolygon
    
    -- function Shp:init(pts, opt)
    function Rawshape:init(pts, opt)

        local x, y = pts[1], pts[2]
        local xmin,ymin,  xmax,ymax = x,y,  x,y
        for k=3,#pts,2 do
            x, y = pts[k], pts[k+1]
            if x<xmin then xmin = x elseif x>xmax then xmax = x end
            if y<ymin then ymin = y elseif y>ymax then ymax = y end
        end
        
        local s = newPoly(0, 0, pts)
        -- solar2d의 폴리곤은 자동으로 중심점에 anchor가 위치한다.
        -- 그래서 아래와 같이 anchor point를 원점(0,0)으로 만든다.
        s.anchorX = -xmin/(xmax-xmin) --(0-xmin)/(xmax-xmin)
        s.anchorY = -ymin/(ymax-ymin) --(0-ymin)/(ymax-ymin)
        
        local sc = opt.sc
        local fc = opt.fc
        s.strokeWidth = opt.sw
        s:setStrokeColor(sc.r, sc.g, sc.b, sc.a)
        s:setFillColor(fc.r, fc.g, fc.b, fc.a)
        ------------------------------------------------------------------------
        self.__bd = s
        return Display.init(self)
    end

end -- elseif _Corona then
--------------------------------------------------------------------------------

Shape = class(Group)

function Shape:init(pts, opt)
    Group.init(self)
    -- --[[
    if pts==nil then
        self.__sopt = {sw=0, sc=WHITE, fc=WHITE}
    else
        opt = opt or {}
        opt.sw = opt.strokewidth or 0
        opt.sc = opt.strokecolor or WHITE
        opt.fc = opt.fillcolor or WHITE

        self.__sopt = opt -- shape option
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
    self.__sopt = opt

    self:clear()
    self:add( Rawshape(pts, opt) )
end

function Shape:fill(color)
    self.__sopt.fc = color
    return self
end

function Shape:strokecolor(color)
    self.__sopt.sc = color
    return self
end

function Shape:strokewidth(w)
    self.__sopt.sw = w
    return self
end

--------------------------------------------------------------------------------
-- 2020/06/16 tail effect 구현
-- 주의: tail에서는 strokecolor는 지정하지 않는 것이 좋다(경계선이 생기므로)
--------------------------------------------------------------------------------
local tblin = table.insert
local tblrm = table.remove
local unpack = unpack

local function upd(self)

    tblin(self.__pxy, {self:getxy()})
    if #self.__pxy>self._tlen then tblrm(self.__pxy,1) end
    if self.__pxy[self._tlen] ~=nil then
        local pxy = self.__pxy
        local x0, y0 = unpack(pxy[self._tlen])

        local pts = {}
        for k = self._tlen-self._fgap, 1, -self._fgap do
            tblin(pts, pxy[k][1]-x0); tblin(pts, pxy[k][2]-y0)
        end
        self:__tail(pts)
--[[
        self:__tail{
            pxy[7][1]-x0, pxy[7][2]-y0,
            pxy[4][1]-x0, pxy[4][2]-y0,
            pxy[1][1]-x0, pxy[1][2]-y0,
        }
    --]]
    end
end

local function upd2(self)
    self._frmc = self._frmc + 1
    if self._fgap ~= self._frmc then return end
    self._frmc = 0 -- %연산자를 사용하는 것보다 약간 빠르지 않을까
    local len = self._tlen

    tblin(self.__pxy, {self:getxy()})
    if #self.__pxy>len then tblrm(self.__pxy,1) end
    if self.__pxy[len] ~=nil then
        local pxy = self.__pxy
        local x0, y0 = unpack(pxy[len])

        local pts = {pxy[len][1]-x0, pxy[len][2]-y0}
        for k = self._tlen-1, 1, -1 do
            tblin(pts, pxy[k][1]-x0); tblin(pts, pxy[k][2]-y0)
        end
        self:__tail(pts)
--[[
        self:__tail{
            pxy[7][1]-x0, pxy[7][2]-y0,
            pxy[4][1]-x0, pxy[4][2]-y0,
            pxy[1][1]-x0, pxy[1][2]-y0,
        }
    --]]
    end
end

-- opt = {
--  length (default=10) : tail length
--  framegap (default=3) : length of tail segment
--}

function Shape:drawtail(width, opt)
    opt = opt or {}
    self.__pxy = {} -- past xy's
    self._frmc = 0
    self.__twdt = width/2
    self._tlen = opt.length or 10
    self._fgap= opt.framegap or 2
    self.update = upd
    return self
end



local function tmrf(self)
    tblin(self.__pxy, {self:getxy()})
    if #self.__pxy>self.__tlen1 then tblrm(self.__pxy,1) end
    if self.__pxy[self.__tlen1] ~=nil then
        local pxy = self.__pxy
        local x0, y0 = unpack(pxy[self.__tlen1])
        local pts = {pxy[self.__tlen][1]-x0, pxy[self.__tlen][2]-y0}
        for k=self.__tlen-1,1,-1 do
            tblin(pts, pxy[k][1]-x0)
            tblin(pts, pxy[k][2]-y0)
        end
        self:__tail(pts)
        --[[
        self:__tail{
            pxy[4][1]-x0, pxy[4][2]-y0,
            pxy[3][1]-x0, pxy[3][2]-y0,
            pxy[2][1]-x0, pxy[2][2]-y0,
            pxy[1][1]-x0, pxy[1][2]-y0,
        }
        --]]
    end
end

function Shape:drawtail2(width)
    self.__pxy = {} -- past xy's
    self.__twdt = width/2 -- 2로나눠야 실제 폭이 width가 된다
    self.__tlen = 4
    self.__tlen1 = self.__tlen+1
    self:timer(40, tmrf, INF) -- 40
    return self
end

----[[
--------------------------------------------------------------------------------
local sqrt = math.sqrt
local wwgt = 0.8 -- 0.75 weight 꼬리 폭의 길이가 점점 줄어드는 비율
local awgt = 0.85 -- 0.85 weight 꼬리 폭의 길이가 점점 줄어드는 비율
local hgt = 0 -- 꼬리가 시작되는 지점



function Shape:__tail(pts)
    --self:fill(Color.rand())
    self:clear()

    local npts = #pts
    local h, w0 = hgt, self.__twdt
    local xk_1, yk_1 = 0,0

    local fc = self.__sopt.fc
    local fca = fc.a -- backup original fillcolor alpha
    --local sc = self.__sopt.sc
    --local sca = sc.a -- backup original fillcolor alpha
    
    local ww = w0 -- width weighted

    local xk_2, yk_2, q1xp, q1yp, q2xp, q2yp

    for k=1,npts,2 do
        w0 = ww
        ww = wwgt*w0
        if k>1 then h=0 end
        -- self.__sopt.fc=Color.rand()

        local x, y = pts[k]-xk_1, pts[k+1]-yk_1
        local r = sqrt(x*x+y*y)

        local hr, w0r, wwr = h/r, w0/r, ww/r

        --local qx, qy = hr*x + xp,  hr*y + yp
        local qx, qy = hr*x,  hr*y 
        local xw0r, yw0r = x*w0r, y*w0r
        local xwwr, ywwr = x*wwr, y*wwr

        local q1x = -yw0r -- qx - y*wr
        local q1y = xw0r -- qy + x*wr

        local q2x = yw0r -- qx + y*wr 
        local q2y = -xw0r -- qy - x*wr
        
        local rshp = Rawshape({q1x,q1y, q2x,q2y, x, y},self.__sopt)
        rshp:addto(self):xy(xk_1,yk_1)

        if k>1 then
            local rshp = Rawshape({
                --q2x+xk_1-q1xp, q2y+yk_1-q1yp,
                pts[k-2]-q1xp, pts[k-1]-q1yp,
                q1x+xk_1-q1xp, q1y+yk_1-q1yp,
                0,0
            },self.__sopt) --{sw=0, sc=Color.WHITE, fc=Color.RED})
            rshp:addto(self):xy(q1xp, q1yp)
            Rawshape({
                --q1x+xk_1-q2xp, q1y+yk_1-q2yp,
                pts[k-2]-q2xp, pts[k-1]-q2yp,
                q2x+xk_1-q2xp, q2y+yk_1-q2yp,
                0, 0
            },self.__sopt):addto(self):xy(q2xp, q2yp)
        end
        
        q1xp, q1yp = q1x+xk_1, q1y+yk_1
        q2xp, q2yp = q2x+xk_1, q2y+yk_1

        -- xk_2, yk_2 = xk_1, xk_1
        xk_1, yk_1 = pts[k], pts[k+1]
        --xp, yp = x, y

        --fc.a = fc.a-0.2 -- 꼬리로 갈수록 점점 희미해진다.
        fc.a = awgt*fc.a -- 꼬리로 갈수록 점점 희미해진다.
        -- sc.a = sc.a-0.3 -- 꼬리로 갈수록 점점 희미해진다.
    end

    fc.a = fca -- 원래 알파값 복원
    -- sc.a = sca -- 원래 알파값 복원
    --self:add( Circle(self.__twdt*0.9):fill(self.__sopt.fc) )
    --self:add( Circle(15):fill(Color.RED) )
    --local c1 = Circle(15):fill(Color.SKY_BLUE)
    --self:add(c1); c1:xy(pts[1],pts[2])
end
--]]
--------------------------------------------------------------------------------
--[[
local sqrt = math.sqrt
local wwgt = 0.8 -- 0.75 weight 꼬리 폭의 길이가 점점 줄어드는 비율
local awgt = 1 --0.85 -- 0.85 weight 꼬리 폭의 길이가 점점 줄어드는 비율
local hgt = 0 -- 꼬리가 시작되는 지점



function Shape:__tail(pts)
    --self:fill(Color.rand())
    self:clear()

    local npts = #pts
    local h, w0 = hgt, self.__twdt
    local xp, yp = 0,0

    local fc = self.__sopt.fc
    local fca = fc.a -- backup original fillcolor alpha
    
    -- local sc = self.__sopt.sc
    -- local sca = sc.a -- backup original fillcolor alpha
    local ww = w0 -- width weighted

    for k=1,npts,2 do
        w0 = ww
        ww = wwgt*w0
        if k>1 then h=0 end

        local x, y = pts[k]-xp, pts[k+1]-yp
        local r = sqrt(x*x+y*y)

        if k==1 then h=0 else h = -r/4 end

        local hr, w0r, wwr = h/r, w0/r, ww/r

        --local qx, qy = hr*x + xp,  hr*y + yp
        local qx, qy = hr*x,  hr*y 
        local xw0r, yw0r = x*w0r, y*w0r
        local xwwr, ywwr = x*wwr, y*wwr

        local q1x = qx - yw0r -- qx - y*wr
        local q1y = qy + xw0r -- qy + x*wr


        local q4x = qx + yw0r -- qx + y*wr 
        local q4y = qy - xw0r -- qy - x*wr
        
        if k~=npts-1 then

            local q2x = x - ywwr -- qx - y*wr
            local q2y = y + xwwr -- qy + x*wr
    
    
            local q3x = x + ywwr -- qx - y*wr
            local q3y = y - xwwr -- qy + x*wr
    
            local rshp = Rawshape({q1x,q1y, q2x,q2y,  q3x,q3y, q4x,q4y},self.__sopt)
            rshp:addto(self):xy(xp,yp)
        else

            local rshp = Rawshape({q1x,q1y, q4x,q4y, x,y},self.__sopt)
            rshp:addto(self):xy(xp,yp)

        end
        xp, yp = pts[k], pts[k+1]

        --fc.a = fc.a-0.2 -- 꼬리로 갈수록 점점 희미해진다.
        fc.a = awgt*fc.a -- 꼬리로 갈수록 점점 희미해진다.
        -- sc.a = sc.a-0.3 -- 꼬리로 갈수록 점점 희미해진다.
    end

    fc.a = fca -- 원래 알파값 복원
    -- sc.a = sca -- 원래 알파값 복원
    self:add( Circle(self.__twdt*0.9):fill(self.__sopt.fc) )
end
--]]
