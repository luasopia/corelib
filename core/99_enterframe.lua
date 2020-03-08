if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
print('core.enterFrame')

local Display = Display
local Timer = Timer
local int = math.floor
-- local str = tostring
local mtxts = {}

local getTxtMem
if _Gideros then
		-- return _Gideros.application:getTextureMemoryUsage()
	getTxtMem = function() return _Gideros._gorgnapp:getTextureMemoryUsage() end

elseif _Corona then
		
	getTxtMem=function() return system.getInfo("textureMemoryUsed") / 1000 end

end

local frameCount = 0
local function update()
	frameCount = frameCount + 1
	Timer.updateAll()
	Display.updateAll()

	if _isdebugmode then
		local txtmem = getTxtMem()
		local mem = int(collectgarbage('count'))
		mtxts[1]:setText('mem: %d kb, texture mem: %d kb', mem, txtmem)
		local ndisp = Display.__getNumObjs() - logf.__getNumObjs() - 2
		mtxts[2]:setText('disp:%d, timer:%d', ndisp, Timer.__getNumObjs())
	end
	--]]
end

if _Gideros then

	_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, update)
	--screen.__bd:addEventListener(Event.ENTER_FRAME, enterFrame)else

elseif _Corona then

	Runtime:addEventListener( "enterFrame", update)

elseif _Love then

end

--------------------------------------------------------------------------------
-- 2020/02/23 : screen 에 touch()를 직접붙이기 위해서 Rect를 screen으로 생성해서
-- _baselayer에 삽입
--------------------------------------------------------------------------------
screen = Rect(_baselayer.width, _baselayer.height):fillColor(0,0,0)
screen.width = _baselayer.width
screen.height = _baselayer.height
screen.centerx = _baselayer.centerx
screen.centery = _baselayer.centery
screen.fps =_baselayer.fps
_baselayer:add(screen)
--------------------------------------------------------------------------------

-- 아래 함수를 리턴한다. debug모드일 때 실행해야 한다.
return function() -- initEnterFrame()
	if _isdebugmode then
		mtxts[1] = Text("",_loglayer):xy(screen.centerx, 30):color(255,182,193)
		mtxts[2] = Text("",_loglayer):xy(screen.centerx, 90):color(255,182,193)
	end
end
	