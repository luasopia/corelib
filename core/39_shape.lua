-- 2020/06/15 
--------------------------------------------------------------------------------
local WHITE = Color.WHITE -- default stroke/fill color
--------------------------------------------------------------------------------
local Shp = class(Display)
--------------------------------------------------------------------------------
if _Gideros then

    local GShape = _Gideros.Shape

    function Shp:init (pts)

        local xs, ys = pts[1], pts[2]
        local s = GShape.new()

        s:setLineStyle(pts.sw, pts.sc.hex) -- width, color, alpha
        s:setFillStyle(GShape.SOLID, pts.fc.hex, pts.fc.a)
        
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
    function Shp:init(pts)

        local x, y = pts[1], pts[2]
        local xmin,ymin,  xmax,ymax = x,y,  x,y
        for k=1,#pts,2 do
            x, y = pts[k], pts[k+1]
            if x<xmin then xmin = x elseif x>xmax then xmax = x end
            if y<ymin then ymin = y elseif y>ymax then ymax = y end
        end
        
        local s = newPoly(0, 0, pts)
        -- solar2d의 폴리곤은 자동으로 중심점에 anchor가 위치한다.
        -- 그래서 아래와 같이 anchor point를 원점(0,0)으로 만든다.
        s.anchorX = -xmin/(xmax-xmin) --(0-xmin)/(xmax-xmin)
        s.anchorY = -ymin/(ymax-ymin) --(0-ymin)/(ymax-ymin)
        
        local sc = pts.sc
        local fc = pts.fc
        s.strokeWidth = pts.sw
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

    opt = opt or {}
    pts.sw = opt.strokewidth or 0
    pts.sc = opt.strokecolor or WHITE
    pts.fc = opt.fillcolor or WHITE

    --self.__sopt = opt -- shape option
    self.__spts = pts

    self:add(Shp(pts))
    --self:add(Circle(10):fill(Color.RED))
end

function Shape:redraw(pts, opt)
    -- opt에서 지정된 것만 바꾸고 기존 것은 유지한다
    opt = opt or {}
    pts.sw = opt.strokewidth or self.__spts.sw
    pts.sc = opt.strokecolor or self.__spts.sc
    pts.fc = opt.fillcolor or self.__spts.fc
    self.__spts = pts

    self:clear()
    self:add( Shp(pts) )
end
