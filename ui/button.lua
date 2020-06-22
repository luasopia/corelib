ui.Button = class(Group)
local Button = ui.Button

--[[
opt = {with, height, fontsize, fontcolor, fillcolor, }
--]]

function Button:init(str, func, opt)
    self._txt = Text(str):addto(self)
    --self._rct = _luasopia.Rawrect():addto(self)
    --self._rct.tap = func
end