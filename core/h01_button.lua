local marginratio = 0.5
local fill0 = Color.GREEN
local fontsize0 = 50

Button = class(Group)

--[[
opt = {
    margin = n, -- in pixel
    fill = color,
    fontsize=n,
}
--]]


function Button:init(str, func, opt)
    Group.init(self)
    
    opt = opt or {}
    local fill = opt.fill or fill0
    local fontsize = opt.fontsize or fontsize0
    local margin = opt.margin or fontsize*marginratio

    self.rect = Rect(3,3):fill(fill):addto(self) -- background rect
    self.text = Text(str,{fontsize=fontsize}):addto(self)
    
    local width = self.text:getwidth()  + 2*margin
    local height = self.text:getheight() + 2*margin

    self.rect:width(width):height(height)
    
    self.rect.tap = func

    print(self.text:getwidth())
    print(self.text:getheight())

end