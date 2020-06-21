local Disp = Display
local dtobj = Disp._dtobj -- Display Tagged OBJect


--[[
opt = {[x=n,][y=n,]radius=n} -- circular area
opt = {[x=n,][y=n,]width=n, height=n} -- rectangular area
--]]
function Disp:collision(opt)

    if opt._coll then
        self._coll = opt._coll
        return
    end

    local opt0 = opt or {}
    local x, y = opt0.x or 0, opt0.y or 0
    if opt0.radius then
        opt0.r = opt0.radius
    elseif opt0.width or opt0.height then
        opt0.w = opt0.width or self:getwidth()
        opt0.h = opt0.height or self:getheight()
    end

    opt._coll = opt0
    self._coll = opt0
end

function Disp:getcollision(name)
end

function Disp.checkcollision(name1, name2)
end
