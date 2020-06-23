print('core.enterFrame')

local Display = Display
local Timer = Timer
local int = math.floor
local mtxts = {}

local getTxtMem

-- local deviceWidth, deviceHeight, orientation
-- local x0, y0, endx, endy -- added 2020/05/06

--  local noupd = false; Timer(500, function() noupd=true end)

local function update()
	-- if noupd then return end


	Timer.updateAll()
	Display.updateAll()
	if _luasopia.debug then
		local txtmem = getTxtMem()
		local mem = int(collectgarbage('count'))
		mtxts[1]:string('mem: %d kb, texture mem: %d kb', mem, txtmem)
		local ndisp = Display.__getNumObjs() -- - logf.__getNumObjs() - 2
		mtxts[2]:string('Display:%d, Timer:%d', ndisp, Timer.__getNumObjs())
	end
end

if _Gideros then

	getTxtMem = function() return _Gideros.application:getTextureMemoryUsage() end
	_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, update)

elseif _Corona then

	getTxtMem = function() return system.getInfo("textureMemoryUsed") / 1000 end
	Runtime:addEventListener( "enterFrame", update)

elseif _Love then

end

--[[
--------------------------------------------------------------------------------
-- 2020/02/23 : screen 에 touch()를 직접붙이기 위해서 Rect를 screen으로 생성해서
-- _baselayer에 삽입
--------------------------------------------------------------------------------
local ls = _luasopia
local x0, y0, endx, endy = ls.x0, ls.y0, ls.endx, ls.endy
--2020/05/06 Rect(screen)가 safe영역 전체를 덮도록 수정
--2020/05/29 baselayer에 생성되어야 한다. xy는 센터로

--screen = Rect(endx-x0+1, endy-y0+1,{fillcolor=Color.BLACK}, _luasopia.baselayer)
screen = Rect(endx-x0+1, endy-y0+1):fill(Color.BLACK)

--screen = Rect(endx-x0+1, endy-y0+1,{fillcolor=Color.BLACK}):addto(_luasopia.baselayer)

screen:xy(ls.centerx, ls.centery)
screen.width = ls.width
screen.height = ls.height
screen.centerx = ls.centerx
screen.centery = ls.centery
screen.fps = ls.fps
-- added 2020/05/05
screen.devicewidth = ls.devicewidth
screen.deviceheight = ls.deviceheight
-- orientations: 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
screen.orientation = ls.orientation 
-- added 2020/05/06
screen.x0, screen.y0, screen.endx, screen.endy = x0, y0, endx, endy
--------------------------------------------------------------------------------
--]]

-- 아래 함수를 리턴한다. debug모드일 때 실행해야 한다.
local TCOLOR = Color.LIGHT_PINK
return function() -- initEnterFrame()
	if _luasopia.debug then
		mtxts[1] = Text("",_luasopia.loglayer):xy(screen.centerx, 30):color(TCOLOR)
		mtxts[2] = Text("",_luasopia.loglayer):xy(screen.centerx, 90):color(TCOLOR)
		-- mtxts[1] = Text("", _luasopia.loglayer):xy(screen.centerx, 30)--:color(255,182,193)
		-- mtxts[2] = Text("", _luasopia.loglayer):xy(screen.centerx, 90)--:color(255,182,193)
		_luasopia.dcdobj = _luasopia.dcdobj + 2
	end
end
	