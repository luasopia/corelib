if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
print('core.timer')

local tIn = table.insert
local tRm = table.remove
local tmgapf = 1000/_baselayer.fps
--------------------------------------------------------------------------------
-- 2020/01/15 times that is NOT use intrinsic (Gideros/Corona) Timer class
--
-- tmr = Timer(delay, func [,loops] [,onEnd])
--
-- 	After delay [ms], func (function) is called.
-- 	loops (default=1) designates the total number of calling func
-- 	if loops is INF, then func is called infinitely with time gap of delay
--
-- 	arguments given to func call : event = {
--	   	count = n, -- 호출된 횟수
--     	isfinal (bool) -- it is true if it is a final call
--     	obj -- timer object
-- 	}
-- 	멤버변수 ------------------------------------------------------------------
--     	tmr.delay
-- 		tmr.count
-- 		tmr.loops
--------------------------------------------------------------------------------
Timer = class()
-- private static member variable
local timers = {} 
--------------------------------------------------------------------------------
-- 타이머객체의 삭제는 이 함수안에서만 이루어지도록 해야 한다.(그래야 덜 꼬임)
-- 외부에서는 remove() 만 호출하면 된다 
-- public static method
--------------------------------------------------------------------------------
function Timer.updateAll()
	for k = #timers,1,-1 do
		local tmr = timers[k] 
		if tmr.__rm then
			tRm(timers, k)
		else
			tmr.__tm = tmr.__tm + tmgapf
			local count = tmr.__tm/tmr.delay - 1
			while  count > tmr.count do
				tmr.count = tmr.count + 1
				local isfinal = tmr.count == tmr.loops
				local event = {
					count = tmr.count,
					isfinal = isfinal,
				} --callback 함수에 넘겨질 파라메터
				if tmr.__dobj then -- display object에 붙어있는 타이머의 경우
					 tmr.__func(tmr.__dobj, event) --dobj를 먼저 넘김
				else -- 일반적인 타이머인 경우
					tmr.__func(event)
				end
				-- 정해진 횟수가 다 찬 경우
				if isfinal then
					if tmr.__onEnd then
						if tmr.__dobj then -- display object에 붙어있는 타이머의 경우
							tmr.__onEnd(tmr.__dobj, event) --dobj를 먼저 넘김
					   else -- 일반적인 타이머인 경우
						   tmr.__onEnd(event)
					   end
					end
					tmr.__rm = true -- Display:update() 내부에서 필요함
					tRm(timers, k)
					break
				end
			end
		end
	end
end

------------------------------------------------------------------------------------------
-- 바로 삭제가 아니라 __rm 플래그를 true로 만들면 
-- updateAll()함수에서 삭제하는 방식으로 해야 한다.
------------------------------------------------------------------------------------------
function Timer.removeAll()
	for k = 1,#timers do timers[k].__rm = true end
end

function Timer.__getNumObjs() return #timers end
------------------------------------------------------------------------------------------
-- 생성자
------------------------------------------------------------------------------------------
function Timer:init(delay, func, loops, onEnd)
	-- local args = args or {}
	self.delay = delay
	self.loops = loops or 1
	self.__func = func
	self.__tm = 0
	self.__onEnd = onEnd
	self.count = 0
	tIn(timers, self)
end

function Timer:pause() end
function Timer:resume() end
function Timer:remove()
    self.__rm = true
end