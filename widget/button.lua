--------------------------------------------------------------------------------
-- 2020/08/27: created
--------------------------------------------------------------------------------
-- default values
local marginratio = 0.5 -- side margin == fontsize*marginratio0
local strokewidthratio0 = 0.15 -- strokewidth == fontsize*strokewidthratio0
local fillcolor0 = Color.GREEN
local strokecolor0 = Color.LIGHT_GREEN
local fontsize0 = 50 -- the same as Text class default value
local fontcolor0 = Color.WHITE
--------------------------------------------------------------------------------
Button = class(Group)
--[[
    local btn = Button('string', func [, opt])
    opt = {
        fontsize = n, -- default:50
        margin = n, -- in pixel, default:fontzise*0.5
        fill = color, -- default: Color.GREEN
        fontcolor = color, -- default: Color.WHITE
        strokecolor = color, -- default: Color.LIGHT_GREEN
        strokewidth = n,  -- in pixel, default:fontzise*0.15
        effect = bool, -- default:true  'shrink', 'expand', 'invertcolor'
    }
--]]
--------------------------------------------------------------------------------
function Button:init(str, func, opt)
    Group.init(self)
    
    opt = opt or {}
    local fillcolor = opt.fill or fillcolor0
    local fontcolor = opt.fontcolor or fontcolor0
    local fontsize = opt.fontsize or fontsize0
    local margin = opt.margin or fontsize*marginratio
    local strokecolor = opt.strokecolor or strokecolor0
    local strokewidth = opt.strokewidth or fontsize*strokewidthratio0
    local effect = true
    if opt.effect==false then effect = false end
    
    -- (1) background rect must be firsly generated
    self.rect = Rect(3,3):fill(fillcolor):addto(self) -- background rect
    self.rect:strokecolor(strokecolor)
    self.rect:strokewidth(strokewidth)
    self.rect.__btn = self

    -- (2) then, text object
    self.text = Text(str,{fontsize=fontsize, color=fontcolor}):addto(self)
    
    self.__wdth = self.text:getwidth()  + 2*margin
    self.__hght = self.text:getheight() + 2*margin

    self.rect:width(self.__wdth):height(self.__hght)
    
    --self.rect.tap = func
    function self.rect:tap(e)
        if effect then
            self.__btn:s(0.97) -- 0.97
            self.__btn:timer(100, function(self) self:s(1) end)
        end

        --[[
        local ic1 = Color.invert(fillcolor)
        local ic2 = Color.invert(strokecolor)
        local ic3 = Color.invert(fontcolor)

        -- self:fill(ic1)
        -- self:strokecolor(ic2)
        -- self.__btn.text:color(ic3)
        
        self:timer(100, function(self)
            self:fill(fillcolor)
            self:strokecolor(strokecolor)
            self.__btn.text:color(fontcolor)
        end)
        --]]
        func(self.__btn, e)
    end

    print(self.text:getwidth())
    print(self.text:getheight())

end

function Button:getwidth() return self.__wdth end
function Button:getheight() return self.__hght end

function Button:fill(c) self.rect:fill(c); return self end
function Button:strokecolor(c) self.rect:strokecolor(c); return self end
function Button:strokewidth(w) self.rect:strokewidth(w); return self end
function Button:fontcolor(c) self.text:color(c); return self end