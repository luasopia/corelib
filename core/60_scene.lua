-- if not_required then return end -- This prevents auto-loading in Gideros

print('lib.scene')

local scenes = {}
local sceneIn = nil -- current (or scheduled to enter) scene in the screen
local Group = Group
local transitionTime = 300

Scene = class()
--------------------------------------------------------------------------------
-- private static methods
--------------------------------------------------------------------------------
local function hideOut(stage)
    print('hide away')
    stage:disableTouch()
    stage:hide()
end

-- 이전에 hideout되면서 위치가 화면밖이거나 투명일 수 있으므로
-- 다시 (표준위치로 )원위치 시켜야 한다.
local function showIn(stage)
    print('stage showin')
    stage:set{x=0,y=0,scale=1,angle=0,alpha=1}
    stage:enableTouch()
    stage:show()
end

--------------------------------------------------------------------------------
-- scene.stage은 screen에 add되는 group
function Scene:init()
    self.stage = Group():xy(0,0)
    -- self.classname = 'Scene'
end    

-- The following create() method must be overridden.
function Scene:create(stage) end

-- The following methods are overridden optionally.
function Scene:beforeShow(stage) end -- called just before entering into screen
function Scene:afterHide(stage) end -- called just after hided out of the screen
function Scene:destroy(stage) end

--------------------------------------------------------------------------------
-- Scene.goto(url [,effect [,time] ])
-- effect = 'fade', 'slideRight'
--------------------------------------------------------------------------------
function Scene.goto(url, effect, time)
    effect = effect or 'none'
    time = time or transitionTime -- set given/default transition time

    local pastScene = sceneIn
    sceneIn = scenes[url]
    if sceneIn == nil then
        sceneIn = require(url) -- stage를 새로운 scene으로 교체한다
        sceneIn:create(sceneIn.stage)
        scenes[url] = sceneIn
    end
    
    sceneIn:beforeShow(sceneIn.stage)
    showIn(sceneIn.stage)

    if effect == 'none' then
        if pastScene then hideOut(pastScene.stage) end
        showIn(sceneIn.stage)
        
    elseif effect == 'slideRight' then
        
        sceneIn.stage:setx(screen.width)
        
        if pastScene then 
            pastScene.stage:shift{time=time, x=-screen.width, onEnd = function()
                hideOut(pastScene.stage)
                pastScene:afterHide(pastScene.stage)
            end}
        end
        
        sceneIn.stage:shift{time=time, x=0}
        
    elseif effect == 'rotateRight' then
        
        -- sceneIn.stage:setx(screen.width)
        sceneIn.stage:set{x=screen.width, angle = -90}
        
        if pastScene then 
            pastScene.stage:shift{time=time, x=-screen.width, angle=90, onEnd = function()
                hideOut(pastScene.stage)
                pastScene:afterHide(pastScene.stage)
            end}
        end
        
        sceneIn.stage:shift{time=time, x=0, angle=0}
        
-- --[[
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
    end

end