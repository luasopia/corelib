if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
-- 2019/12/27: 작성 시작 : 60프레임, 화면 1080x1920 기준으로
-- 2020/02/16: init.lua를 luasopia/init.lua로 옮김
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Lua 고유의 전역변수들만 남기고 특정SDK의 전역변수들을 tbl로 이동
--------------------------------------------------------------------------------
local function moveg()
    local tbl = {}

    local luag = { -- 39 -- lua global variables
    '_G', '_VERSION', 'assert', 'collectgarbage', 'coroutine', 'debug', 'dofile',
    'error', 'gcinfo', 'getfenv', 'getmetatable', 'io', 'ipairs', 'load', 'loadfile',
    'loadstring', 'math', 'module', 'newproxy', 'next', 'os', 'package', 'pairs',
    'pcall', 'print', 'rawequal', 'rawget', 'rawset', 'require', 'select', 'setfenv',
    'setmetatable', 'string', 'table', 'tostring', 'tonumber', 'type', 'unpack', 'xpcall',
    -- CoronaSDK의 경우 아래 세 개는 전역변수로 남아있어야 정상동작한다.
    'system', 'Runtime', 'cloneArray',
    }
    
    local function notin(str)
        for _, v in ipairs(luag) do
            if v==str then return false end
        end
        return true
    end

    for k, v in pairs(_G) do
        if notin(k) then
            tbl[k] = v
            _G[k] = nil
        end
    end

    return tbl
end


if gideros then -- in the case of using Gideros

    print('luasopia.init (gideros)')
    _Gideros = moveg()

    _luasopia = {}

    -- screen = {
    _luasopia.baselayer = {
        __bd = _Gideros.Sprite.new(),
        add = function(self, child) return self.__bd:addChild(child.__bd) end,
        
        width = _Gideros.application.content.width, -- 1080,
        height = _Gideros.application.content.height, -- 1920,
        centerx = _Gideros.application.content.width/2,
        centery = _Gideros.application.content.height/2,
        fps = _Gideros.application.content.fps,
    }
    -- _Gideros.stage:addChild(screen.__bd)
    _Gideros.stage:addChild(_luasopia.baselayer.__bd)


elseif coronabaselib then -- in the case of using CoronaSDK

    print('luasopia.init (corona)')
    _Corona = moveg()

	_luasopia = {}

    -- screen = {
    _luasopia.baselayer = {
        __bd = _Corona.display.newGroup(),
        add = function(self, child) return self.__bd:insert(child.__bd) end,

        width = _Corona.display.contentWidth,
        height = _Corona.display.contentHeight,
        centerx = _Corona.display.contentCenterX,
        centery = _Corona.display.contentCenterY,
        fps = _Corona.display.fps
    }


elseif love then-- in the case of using LOVE2d

end

-- global constants -- 이 위치여야 한다.(위로 옮기면 안됨)
math.randomseed(os.time())
rand = math.random
INF = -math.huge -- infinity constant (일부러 -를 앞에 붙임)
_luasopia.debug = false
lib = {} -- 2020/03/07 added
ui = {} -- 2020/03/07 added

-- load luasopia core/library files
require 'luasopia.core.01_class'
require 'luasopia.core.02_timer'
require 'luasopia.core.03_color'
require 'luasopia.core.04_util'
require 'luasopia.core.10_disp'
require 'luasopia.core.11_disp_shift'
require 'luasopia.core.12_disp_move'
require 'luasopia.core.13_disp_touch'
require 'luasopia.core.14_disp_tap'
require 'luasopia.core.15_disp_shape'
require 'luasopia.core.20_group'
require 'luasopia.core.21_image'
require 'luasopia.core.22_image_region'
require 'luasopia.core.23_getsheet'
require 'luasopia.core.24_sprite'
require 'luasopia.core.30_text'
require 'luasopia.core.40_line'
require 'luasopia.core.41_rect'
require 'luasopia.core.42_polygon'
require 'luasopia.core.43_circle'
require 'luasopia.core.44_star'
require 'luasopia.core.45_heart'
require 'luasopia.core.50_sound'
require 'luasopia.core.60_scene'

local enterFrameInit = require 'luasopia.core.99_enterframe' -- 맨 마지막에 로딩해야 한다

require 'luasopia.lib.blink'
require 'luasopia.lib.wave'

-- 반환되는 함수가 아예 호출이 안될 때 logf를 빈함수로 설정
logf = function() end

local init = function(args)
    if args then 

        if args.debug then

            if _Gideros then

                _luasopia.loglayer = {
                    __bd = _Gideros.Sprite.new(),
                    add = function(self, child) return self.__bd:addChild(child.__bd) end,
                    --2020/03/15 isobj(_loglayer, Group)==true 이러면 아래 두 개 필요
                    __isobj__ = true,
                    __clsid__ = Group.__clsid__
                }
                _Gideros.stage:addChild(_luasopia.loglayer.__bd)
            
            elseif _Corona then
                    
                _luasopia.loglayer = {
                    __bd = _Corona.display.newGroup(),
                    add = function(self, child) return self.__bd:insert(child.__bd) end,
                    --2020/03/15 isobj(_loglayer, Group)가 true가 되려면 아래 두 개 필요
                    __isobj__ = true,
                    __clsid__ = Group.__clsid__
                }
            
            end

            _luasopia.debug = true
            require 'luasopia.core.98_logf'
            if args.loglines then logf.setNumLines(args.loglines) end
            enterFrameInit()

        end
        
        if args.border then

            Rect(screen.width, screen.height):fillColor(0,0,0,0):strokeWidth(args.border)
        
        end

    end

end

-- 2020/04/12 사용자가 _G에 변수를 생성하는 것을 막는다
global = {} -- 모든 사용자 전역변수는 _g테이블에 만들어야 한다.
setmetatable(_G, {
    __newindex = function(_,n)
        error('attempt to write to undeclared variable '..n, 2)
    end,
--[[
    __index = function(_,n)
        error('attempt to read undeclared variable '..n, 2)
    end
--]]
})

return init