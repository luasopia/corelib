print('Scene class')

local scenes = {}
local sceneIn = nil -- current (or scheduled to enter) scene in the screen
local Group = Group
local transitionTime = 300
local x0, y0, endx, endy = screen.x0, screen.y0, screen.endx, screen.endy

Scene = class()
--------------------------------------------------------------------------------
-- private static methods
--------------------------------------------------------------------------------
local function create(scn)
    _luasopia.stage = scn.__stage__
    scn:create(scn.__stage__)
end

local function beforeshow(scn)
    _luasopia.stage = scn.__stage__
    scn:beforeshow(scn.__stage__)
end

local function aftershow(scn)
    _luasopia.stage = scn.__stage__
    scn:aftershow(scn.__stage__)
end

local function hide(scn)
    print('scene hideout')
    scn.__stage__:stoptouch()
    scn.__stage__:hide()

    _luasopia.stage = scn.__stage__
    scn:afterhide(scn.__stage__)
end

-- 이전에 hideout되면서 위치가 화면밖이거나 투명일 수 있으므로
-- 다시 (표준위치로 )원위치 시켜야 한다.
local function ready(scn)
    print('scene ready')
    scn.__stage__:set{x=0,y=0,s=1,r=0,a=1}
    scn.__stage__:resumetouch()
    scn.__stage__:show()

    _luasopia.stage = scn.__stage__
    scn:beforeshow(scn.__stage__)
end

--------------------------------------------------------------------------------
-- scene.stage은 screen에 add되는 group
function Scene:init()
    self.__stage__ = Group():xy(0,0)
    -- self.classname = 'Scene'
end    

-- The following create() method must be overridden.
-- create()메서드는 반드시 오버라이딩되어야 하고 최초에 딱 한 번만 호출됨
function Scene:create() end

-- The following methods are optionally overridden.
function Scene:beforeshow() end -- called just before showing
function Scene:aftershow() end -- called just after showing
function Scene:beforehide() end -- called just before hiding
function Scene:afterhide() end -- called just after hiding
function Scene:destroy() end

--------------------------------------------------------------------------------
-- Scene.goto(url [,effect [,time] ])
-- effect = 'fade', 'slideRight'
--------------------------------------------------------------------------------
function Scene.goto(url, effect, time)
    effect = effect or 'none'
    time = time or transitionTime -- set given/default transition time

    local pastScene = sceneIn
    -- 과거 scenes테이블을 뒤져서 한 번이라도 create()되었다면 그걸 사용
    -- scenes테이블에 없다면 create를 이용하여 새로 생성하고 scenes에 저장
    sceneIn = scenes[url]
    if sceneIn == nil then
        sceneIn = require(url) -- stage를 새로운 Scene 객체로 교체한다
        scenes[url] = sceneIn
        create(sceneIn)
    end
    
    beforeshow(sceneIn)
    ready(sceneIn)

    if effect == 'slideRight' then
        
        sceneIn.__stage__:x(screen.endx+1)
        
        if pastScene then 
            pastScene.__stage__:shift{time=time, x=-screen.endx, onend = function()
                hide(pastScene)
                pastScene:afterhide(pastScene.__stage__)
            end}
        end
        
        sceneIn.__stage__:shift{time=time, x=0, onend = function()
            aftershow(sceneIn)
        end}

-- --[[
    elseif effect == 'rotateRight' then
        
        -- sceneIn.stage:x(screen.width)
        sceneIn.__stage__:set{r=-90}
        
        if pastScene then 
            pastScene.__stage__:shift{time=time, r=90, onend = function()
                hide(pastScene)
                pastScene:afterhide(pastScene.__stage__)
            end}
        end
        
        sceneIn.__stage__:shift{time=time, x=0, r=0, onend = function()
            aftershow(sceneIn)
        end}
        
--[[
    elseif effect == 'fade' then
        
        sceneIn.stage:setalpha(0)

        if pastScene then 
            pastScene.stage:shift{time=time, alpha = 0, onEnd = function()
                hideOut(pastScene.stage)
                pastScene:afterHide(pastScene.stage)
            end}
        end

        sceneIn.stage:shift{time=time, alpha=1}

 --]]
    else
        if pastScene then hide(pastScene) end
        aftershow(sceneIn)
    end

end