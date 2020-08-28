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
ProgressBar = class(Group)
--[[
    local btn = ProgressBar('string', func [, opt])
    opt = {
        height = n, -- in pixel, default:width*0.12
        framecolor = color, -- default: Color.LIGHT_GREEN
        frameswidth = n,  -- in pixel, width/50
        
        text = {fontsize, color}, -- default: Color.GREEN
        barcolor = color, -- default:true  'shrink', 'expand', 'invertcolor'

        min = n, -- default:0
        max = n, -- defulat:100
    }
--]]
--------------------------------------------------------------------------------
function ProgressBar:init(width, opt)
    Group.init(self)
    
    opt = opt or {}
    local height = opt.height or width*0.12
    local framecolor = opt.framecolor or Color.WHITE
    local barcolor = opt.barcolor or Color.RED
    local framewidth = opt.framewidth or math.floor(width/50)
    
    self.fillrect = Rect(width,height):fillcolor(barcolor):addto(self)
    self.fillrect:anchor(0,0.5):x(-width/2)
    
    self.frame = Rect(width,height):empty():addto(self) -- framerect
    self.frame:strokecolor(framecolor):strokewidth(framewidth)

    -- self.fillrect = Rect(width-framewidth,height-framewidth):fillcolor(barcolor):addto(self)
    -- self.fillrect:anchor(0,0.5):x(-width/2 + framewidth/2)
end

function ProgressBar:value(n)
    self.fillrect:xs(n/100)
end