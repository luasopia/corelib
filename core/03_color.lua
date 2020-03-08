if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
Color = class() --:is'Color'
--------------------------------------------------------------------------------
-- r,g,b are integers between 0~255, alpha is real number between 0~1
-- 2020/03/02 : considering the fisrt argument of constructor is a Color obj
--------------------------------------------------------------------------------
if _Gideros then

    function Color:init(r, g, b, a)
        if isobj(r,Color) then
            self.hex = r.hex
            self.a = g or 1 -- in this case, 2nd argument is an alpha
        else
            self.hex = r*65536 + g*256 + b
            self.a = a or 1
        end
    end

elseif _Corona then
    
    function Color:init(r, g, b, a)
        if isobj(r,Color) then
            self.r, self.g, self.b = r.r, r.g, r.b
            self.a = g or 1 -- in this case, 2nd argument is an alpha
        else
            self.r, self.g, self.b = r/255, g/255, b/255
            -- self.rgb = {self.r, self.g, self.b}
            self.a = a or 1
        end
    end

end

local rnd = math.random
Color.random = function() return Color(rnd(255),rnd(255),rnd(255)) end

-- web color (refer to : https://en.wikipedia.org/wiki/Web_colors )

-- Pink colors
Color.PINK              = Color(255, 192, 203)
Color.LIGHT_PINK        = Color(255, 182, 193) 
Color.HOT_PINK          = Color(255, 105, 180)
Color.DEEP_PINK         = Color(255, 20, 147)
Color.PALE_VIOLET_RED   = Color(219, 112, 147)
Color.MEDIUM_VIOLET_RED = Color(199, 21, 133)

-- Red colors
Color.LIGHT_SALMON      = Color(255, 160, 122)
Color.SALMON            = Color(250, 128, 114)
Color.DARK_SALMON       = Color(233, 150, 122)
Color.LIGHT_CORAL       = Color(240, 128, 128)
Color.INDIAN_RED        = Color(205, 92, 92)
Color.CRIMSON           = Color(220, 20, 60)
Color.FIRE_BRICK        = Color(178, 34, 34)	
Color.DARK_RED          = Color(139, 0, 0)
Color.RED               = Color(255, 0, 0)

-- Orange colors
Color.ORANGE_RED         = Color(255, 69, 0)
Color.TOMATO            = Color(255, 99, 71)
Color.CORAL             = Color(255, 127, 80)
Color.DARK_ORANGE       = Color(255, 140, 0)
Color.ORANGE            = Color(255, 165, 0)

-- Yellow colors
Color.YELLOW            = Color(255,255,0)

-- Brown colors

-- White colors
Color.WHITE = Color(255,255,255)

-- Gray and black colors
Color.black = Color(0,0,0)

-- Green colors
Color.green = Color(0, 255, 0)

-- Blue colors
Color.blue = Color(0, 0, 255)

--[[
-- 2020/03/02 : {r,g,b}로 부터 Color를 반환하는 함수
Color.getcolor = function(rc,g,b)
    if isobjof(rc,Color) then
        return rc
    else
        return Color(rc,g,b)
    end
end
-- 2020/03/02 : {r,g,b,a}로 부터 {Color,a}를 반환하는 함수
Color.getcolora = function(rc,ga,b,a)
    if isobjof(rc, Color) then
        return rc, ga
    else
        return Color(rc,ga,b), a
    end
end
--]]