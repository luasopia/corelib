--------------------------------------------------------------------------------
-- (mouse) click : add new marker
-- 'space' : play
-- 'd' : delete selected marker
-- 'i' : insert next to the selected marker
-- 'p' : print out result
--------------------------------------------------------------------------------
-- 2020/06/10 : 작성 시작
-- 2020/06/13 : luasopia.util 로 이동
--------------------------------------------------------------------------------
local u = global.u
local urlship = u'ship.png'
print(urlship)
local Path = lib.Path
local function puts(...) return print(string.format(...)) end
--------------------------------------------------------------------------------

local x0, y0, endx, endy = screen.x0, screen.y0, screen.endx, screen.endy
local width, height = endx-x0+1, endy-y0+1
local boundrate = 0.8

local selectedmarker
local bound = Rect(width*boundrate, height*boundrate):strokewidth(3):empty()
local markers = {}

-- play()시 비행기가 지나갈 레이어를 밑에 두어야
-- play()종료후 마지막 marker가 터치된다.
local shiplayer = Group():xy(0,0)
-- (spline) 경로점과 마커를 모두 포함하는 그룹
local pathmarkgrp = Group():xy(0,0)
--------------------------------------------------------------------------------
-- screen(x,y)로 부터 normalized(x,y)를 구한다.
local r2 =(1-boundrate)/2
local rw, rh = boundrate*width, boundrate*height
local function norm(x,y)
    local nx = (x-r2*width)/rw
    local ny = (y-r2*height)/rh
    return nx, ny
end

local function denorm(nx,ny)
    local sx = nx*rw + r2*width
    local sy = ny*rh + r2*height
    return sx, sy
end
--------------------------------------------------------------------------------
local pathgroup = Group(pathmarkgrp):xy(0,0)
local pathcircr = 5
local path
local function redraw()
    --puts('redraw(%d)',#pts)
    --if #pts<3 then return end
    if #markers < 3 then return end
    local pts = {}
    for k=1,#markers do
        pts[k]=markers[k].pt
    end


    path = Path(pts)

    pathgroup:remove()
    pathgroup = Group(pathmarkgrp):xy(0,0)
    for k, pt in ipairs(path) do
        -- puts('%d',k)
        local sx, sy = denorm(pt.x, pt.y)
        -- print(string.format("%d:%.2f,%.2f",k,x,y))
        local c1 = Circle(pathcircr):a(0.5):addto(pathgroup)
        c1:xy(sx,sy)
        --local c2 = Circle(3):addto(pathgroup)
        -- c2:xy(sx,sy)
        if pt.given then c1:fill(Color.RED):a(1) end
    end

end
--------------------------------------------------------------------------------
local ship = Rect(0,0):hide()
local function play()
    if path == nil then return end
    pathmarkgrp:a(0.5) --:hide()
    ship:remove()
    ship = Image(urlship,shiplayer):hide()
    -- puts('play(%d)',k)
    ship:show()
    local k = 0
    function ship:update()
        k = k + 1
        if k>#path then
            ship:stopupdate()
            pathmarkgrp:a(1) --:show()
        else
            local sx, sy = denorm(path[k].x, path[k].y)
            ship:set{x=sx, y=sy, r=path[k].rot, s=path[k].z}
        end
    end
end
--------------------------------------------------------------------------------
local marker_r = 50
local markernum = 0 -- marker의 총 갯수


local Marker = class()
function Marker:init(x,y)
    local grp = Group(pathmarkgrp):xy(x,y)
    local handle = Circle(marker_r):a(0.5):addto(grp)
    self.grp = grp
    self.handle = handle
    self.center = Circle(5):addto(grp)
    markernum = markernum + 1
    self.id = markernum
    self.idtext = Text(''):color(Color.PINK):addto(grp)
    self.idtext:string("%d",markernum):y(-50)
    local nx, ny = norm(x,y)
    local pt = {x=nx, y=ny, z=1}
    self.pt = pt
    --pts[markernum] = self.pt
    table.insert(markers, self)
    print(string.format("(%f, %f)", nx, ny))

    local this = self
    function handle:touch(e)
        if e.phase == 'begin' then
            if selectedmarker ~=nil then selectedmarker:unselect() end
            this:select()
            redraw()
        elseif e.phase == 'move' then
            local sx, sy = grp:getx()+e.dx, grp:gety()+e.dy
            grp:xy(sx, sy)
            pt.x, pt.y = norm(sx, sy)
            redraw()
        -- elseif e.phase == 'end' or e.phase =='cancel' then
            -- self:fill(Color.WHITE)
            -- selectedmarker = nil
            --redraw()
        end
    end
end

function Marker:select()
    self.handle:fill(Color.SKY_BLUE)
    self.selected = true

    if selectedmarker ~= nil then selectedmarker:unselect() end
    selectedmarker = self
end

function Marker:unselect()
    self.handle:fill(Color.WHITE)
    self.selected = false
end

function Marker:setnum(n)
    self.id = n
    self.idtext:string("%d",n)
end

function Marker:remove()
    local krm
    for k=1,#markers do
        if krm==nil and markers[k] == self then
            krm = k
        end
        if krm ~= nil then -- 다음에 오는 마커들의 id(숫자)를 하나씩 줄인다.
            markers[k]:setnum(k-1)
        end
    end

    table.remove(markers, krm)
    self.grp:remove()
    markernum = markernum -1
end

function Marker:puts()
    puts("    {x=%.8f, y=%.8f, z=%.8f},", self.pt.x, self.pt.y, self.pt.z)
end
--------------------------------------------------------------------------------
function screen:tap(e)
    local marker = Marker(e.x, e.y)
    if selectedmarker ~=nil then selectedmarker:unselect() end
    marker:select()
    redraw()
end

--------------------------------------------------------------------------------
local function onKeyEvent(e)
    if e.phase == 'down' then -- 'down' or 'up'
        if e.keyName == 'space' then
            puts("[%s]",e.keyName)  
            play()
        elseif e.keyName == 'd' then -- delete marker
            selectedmarker:remove()
            selectedmarker = nil
            redraw()
        elseif e.keyName == 'i' then -- insert marker
            --선택된 노드가 끝점이면 그냥 리턴
            if selectedmarker.id == #markers then return end

            local prev = markers
            markers = {}
            local wasmatched = false
            for k=1, #prev do
                if prev[k] == selectedmarker then
                    markers[k] = prev[k]
                    wasmatched = true
                    local x1, y1 = selectedmarker.grp:getxy()
                    local x2, y2 = prev[k+1].grp:getxy()
                    local newmarker = Marker((x1+x2)/2,(y1+y2)/2)
                    newmarker:setnum(k+1)
                    newmarker:select()
                    markers[k+1] = newmarker
                elseif not wasmatched then -- match 되기 이전에는 단순 복사
                    markers[k] = prev[k]
                else -- 매치된 이후에는 하나씩 밀어서 복사
                    prev[k]:setnum(k+1)
                    markers[k+1] = prev[k]
                end
            end

            redraw()
        elseif e.keyName == 'p' then -- print out
            print('local path = lib.Path{')
            for k=1,#markers do
                markers[k]:puts()
            end
            print('}')
        end
    end


    --[[
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    print( message )

    -- If the "back" key was pressed on Android, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
        if ( system.getInfo("platform") == "android" ) then
            return true
        end
    end
    --]]
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end

Runtime:addEventListener( "key", onKeyEvent )