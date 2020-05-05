print('core.enterFrame')

local Display = Display
local Timer = Timer
local int = math.floor
local mtxts = {}

local getTxtMem
local deviceWidth, deviceHeight, orientation, scaleMode

--[[
if _Gideros then

	deviceWidth = _Gideros.application:getDeviceWidth() -- 1920,
    deviceHeight = _Gideros.application:getDeviceHeight() -- 1920,

	getTxtMem = function() return _Gideros.application:getTextureMemoryUsage() end

elseif _Corona then

	deviceWidth = _Corona.display.pixelWidth
	deviceHeight = _Corona.display.pixelHeight
		
	getTxtMem=function() return system.getInfo("textureMemoryUsed") / 1000 end

end
--]]

local frameCount = 0
local function update()
	frameCount = frameCount + 1
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

	deviceWidth = _Gideros.application:getDeviceWidth()
    deviceHeight = _Gideros.application:getDeviceHeight()
	orientation = _Gideros.application:getOrientation()
	scaleMode = _Gideros.application:getScaleMode()

	getTxtMem = function() return _Gideros.application:getTextureMemoryUsage() end

	_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, update)

elseif _Corona then

	deviceWidth = _Corona.display.pixelWidth
	deviceHeight = _Corona.display.pixelHeight
	orientation = system.orientation
	scaleMode = 'unknown'
		
	getTxtMem = function() return system.getInfo("textureMemoryUsed") / 1000 end

	Runtime:addEventListener( "enterFrame", update)

elseif _Love then

end

--------------------------------------------------------------------------------
-- 2020/02/23 : screen 에 touch()를 직접붙이기 위해서 Rect를 screen으로 생성해서
-- _baselayer에 삽입
--------------------------------------------------------------------------------
local bl = _luasopia.baselayer
screen = Rect(bl.width, bl.height,{fillcolor=Color.BLACK})
screen.width = bl.width
screen.height = bl.height
screen.centerx = bl.centerx
screen.centery = bl.centery
screen.fps = bl.fps
-- added 2020/05/05
screen.devicewidth = deviceWidth
screen.deviceheight = deviceHeight
screen.orientation = orientation
screen.scalemode = scaleMode
bl:add(screen)
--------------------------------------------------------------------------------

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
	