print('core.enterFrame')

local Display = Display
local Timer = Timer
local int = math.floor
local mtxts = {}

local getTxtMem
local deviceWidth, deviceHeight, orientation
--local scaleMode
local x0, y0, endx, endy -- added 2020/05/06


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
	-- 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
	orientation = _Gideros.application:getOrientation() 
	-- 디바이스에서 실제 표시되는 영역의 (x0,y0), (endx,endy) 좌표값들을 구한다.
	x0, y0, endx, endy = _Gideros.application:getDeviceSafeArea(true)
	endx, endy = endx-1, endy-1

	getTxtMem = function() return _Gideros.application:getTextureMemoryUsage() end

	_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, update)

elseif _Corona then

	deviceWidth = _Corona.display.pixelWidth
	deviceHeight = _Corona.display.pixelHeight
	orientation = system.orientation -- 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
	-- 디바이스에서 실제 표시되는 영역의 (x0,y0), (endx,endy) 좌표값들을 구한다.
	x0, y0 = _Corona.display.screenOriginX, _Corona.display.screenOriginY
	endx = _Corona.display.actualContentWidth + x0 - 1
	endy = _Corona.display.actualContentHeight + y0 - 1
		
	getTxtMem = function() return system.getInfo("textureMemoryUsed") / 1000 end

	Runtime:addEventListener( "enterFrame", update)

elseif _Love then

end

--------------------------------------------------------------------------------
-- 2020/02/23 : screen 에 touch()를 직접붙이기 위해서 Rect를 screen으로 생성해서
-- _baselayer에 삽입
--------------------------------------------------------------------------------
local bl = _luasopia.baselayer
--screen = Rect(bl.width, bl.height,{fillcolor=Color.BLACK})
--2020/05/06 Rect(screen)가 safe영역 전체를 덮도록 수정
screen = Rect(endx-x0+1, endy-y0+1,{fillcolor=Color.BLACK})
screen.width = bl.width
screen.height = bl.height
screen.centerx = bl.centerx
screen.centery = bl.centery
screen.fps = bl.fps
-- added 2020/05/05
screen.devicewidth = deviceWidth
screen.deviceheight = deviceHeight
-- orientations: 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
screen.orientation = orientation 
-- added 2020/05/06
screen.x0, screen.y0, screen.endx, screen.endy = x0, y0, endx, endy
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
	