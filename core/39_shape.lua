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

        s:setLineStyle(opt.sw, opt.sc.hex) -- width, color, alpha
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
        s:setStrokeColor(sc.r, sc.g, sc.b)
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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local tblin = table.insert
local tblrm = table.remove

local function upd(self)
    self.__frm = self.__frm + 1
    tblin(self.__pxy, {self:getxy()})
    if #self.__pxy>10 then tblrm(self.__pxy,1) end
    if self.__pxy[10] ~=nil then
        local pxy = self.__pxy
        local x0, y0 = unpack(self.__pxy[10])
        self:__tail{
            pxy[7][1]-x0, pxy[7][2]-y0,
            pxy[4][1]-x0, pxy[4][2]-y0,
            pxy[1][1]-x0, pxy[1][2]-y0,
        }
    end
end

function Shape:drawtail(width)
    self.__pxy = {} -- past xy's
    self.__frm = 0
    self.__twdt = width
    
    --[[
    function self:update()
        self.__frm = self.__frm + 1
        tblin(self.__pxy, {self:getxy()})
        if #self.__pxy>10 then tblrm(self.__pxy,1) end
        if self.__pxy[10] ~=nil then
            local pxy = self.__pxy
            local x0, y0 = unpack(self.__pxy[10])
            self:__tail{
                pxy[7][1]-x0, pxy[7][2]-y0,
                pxy[4][1]-x0, pxy[4][2]-y0,
                pxy[1][1]-x0, pxy[1][2]-y0,
            }
        end
    end
    --]]
    self.update = upd
end

local sqrt = math.sqrt
function Shape:__tail(pts)
    --self:fill(Color.rand())
    self:clear()

    local npts = #pts
    local h, w = 0, self.__twdt
    local xp, yp = 0,0

    for k=1,npts,2 do
        local x, y = pts[k]-xp, pts[k+1]-yp
        local r = sqrt(x*x+y*y)
        local hr, wr = h/r, w/r

        --local qx, qy = hr*x + xp,  hr*y + yp
        local qx, qy = hr*x,  hr*y 
        local xwr, ywr = x*wr, y*wr

        local q1x = qx - ywr -- qx - y*wr
        local q1y = qy + xwr -- qy + x*wr


        local q4x = qx + ywr -- qx + y*wr 
        local q4y = qy - xwr -- qy - x*wr
        
        if k~=npts-1 then

            local q2x = x - ywr -- qx - y*wr
            local q2y = y + xwr -- qy + x*wr
    
    
            local q3x = x + ywr -- qx - y*wr
            local q3y = y - xwr -- qy + x*wr
    
            local rshp = Rawshape({q1x,q1y, q2x,q2y,  q3x,q3y, q4x,q4y},self.__sopt)
            rshp:addto(self):xy(xp,yp)
        else

            local rshp = Rawshape({q1x,q1y, q4x,q4y, x,y},self.__sopt)
            rshp:addto(self):xy(xp,yp)

        end
        xp, yp = pts[k], pts[k+1]
    end

end

