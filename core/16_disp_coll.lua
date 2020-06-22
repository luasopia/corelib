local Disp = Display
local dtobj = Disp._dtobj -- Display Tagged OBJect
local emptyt = {} -- empty table

--2020/03/03 추가
function Disp:tag(name)
    self._tag = name
    -- 2020/06/21 tagged객체는 아래와 같이 dtobj에 별도로 (중복) 저장
    if dtobj[name] == nil then dtobj[name] = {[self]=self}
    else dtobj[name][self] = self  end
    return self
end

--2020/06/21 dtobj에 tagged객체를 따로 저장하기 때문에
-- collect()함수에서 매번 for반복문으로 tagged객체를 모을 필요가 없어졌음
function Disp.collect(name)
    return dtobj[name] or emptyt
end
--------------------------------------------------------------------------------
--[[
opt = {[x=n,][y=n,]} -- point
opt = {[x=n,][y=n,] radius=n} -- circular area
opt = {[x=n,][y=n,] width=n, height=n} -- rectangular area
--]]

--[[
function Disp:hitzone(opt)

    if opt._hta then
        self._hta = opt._hta
        return
    end

    local opt0 = opt or {}
    local x, y = opt0.x or 0, opt0.y or 0
    if opt0.radius then
        opt0.r = opt0.radius
        opt0.type='c' -- circular type
    else then
        opt0.w = opt0.width or self:getwidth()
        opt0.h = opt0.height or self:getheight()
        opt0.type='r' -- rectangular type
    end

    opt._hta = opt0
    self._hta = opt0
end

function Disp:gethit(name)
end

local function ishit(obj1, obj2)
    if obj1._hta == nil then
        obj1._hta = {x=0, y=0, w=obj1:getwidth(), h=obj1:getheight()}
    end
    if obj2._hta == nil then
        obj2._hta = {x=0, y=0, w=obj2:getwidth(), h=obj2:getheight()}
    end
    local ah1, ah2 = obj1._hta, obj2._hta

    if ah1.r and ah2.r then

    elseif ah1.r and ah2.r==nil then

    elseif ah1.r==nil and ah2.r then

    else -- 둘다 사각형영역인 경우

    end

end


function Disp.checkhit(name1, name2)
    local ret = {}
    local tos1, tos2 = dtobj[name1], dtobj[name2]
    for _, obj1 in next, tos1 do
        for _, obj2 in next, tos2 do

        end
    end
    
    if next(ret) == nil then -- ret가 empty table이라면 nil 반환
        return nil
    else
        return ret
    end
end

function Disp:gethit(name)
    if self._hta==nil then self._hta={x=0,y=0,w=self:getwidth(), h=self:getheight()} end
    local tdo = dtobj[name] or {}
    for _, obj in next, tdo do

    end
end
--]]