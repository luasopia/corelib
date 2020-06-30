--------------------------------------------------------------------------------
-- 2019/12/27: 작성 시작 : 60프레임, 화면 1080x1920 기준으로
-- 2020/02/16: init.lua를 luasopia/init.lua로 옮김
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
    -- 2020/05/27 아래는 (screen Rect객체 때문에)궂이 필요없음
    --application:setBackgroundColor(0x000000)
    
    _Gideros = moveg()

    local contentwidth = _Gideros.application:getContentWidth()
    local contentheight = _Gideros.application:getContentHeight()
    local x0, y0, endx, endy = _Gideros.application:getDeviceSafeArea(true)
    local fps = _Gideros.application:getFps()

    _luasopia = {
        width = contentwidth,
        height = contentheight,

        centerx = contentwidth/2,
        centery = contentheight/2,

        devicewidth = _Gideros.application:getDeviceWidth(),
        deviceheight = _Gideros.application:getDeviceHeight(),
        -- 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
        orientation = _Gideros.application:getOrientation(),
        -- 디바이스에서 실제 표시되는 영역의 (x0,y0), (endx,endy) 좌표값들을 구한다.
        x0 = x0,
        y0 = y0,
        endx = endx-1,
        endy = endy-1,

        fps = fps,
    }

    _luasopia.baselayer = {
        __bd = _Gideros.Sprite.new(),
        add = function(self, child) return self.__bd:addChild(child.__bd) end,
    }
    -- _Gideros.stage:addChild(screen.__bd)
    _Gideros.stage:addChild(_luasopia.baselayer.__bd)



elseif coronabaselib then -- in the case of using CoronaSDK

    print('luasopia.init (corona)')
    _Corona = moveg()

    local contentwidth = _Corona.display.contentWidth
    local contentheight = _Corona.display.contentHeight

	-- 디바이스에서 실제 표시되는 영역의 (x0,y0), (endx,endy) 좌표값들을 구한다.
	local x0, y0 = _Corona.display.screenOriginX, _Corona.display.screenOriginY
	local endx = _Corona.display.actualContentWidth + x0 - 1
	local endy = _Corona.display.actualContentHeight + y0 - 1
    local fps = _Corona.display.fps

	_luasopia = {

        width = contentwidth,
        height = contentheight,

        centerx = contentwidth/2,
        centery = contentheight/2,

        devicewidth = _Corona.display.pixelWidth,
        deviceheight = _Corona.display.pixelHeight,
        -- 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'            
        orientation = system.orientation, 

        x0 = x0,
        y0 = y0,
        endx = endx,
        endy = endy,

        fps = fps,
    }

    -- screen = {
    _luasopia.baselayer = {
        __bd = _Corona.display.newGroup(),
        add = function(self, child) return self.__bd:insert(child.__bd) end,
    }


elseif love then-- in the case of using LOVE2d

end

-- 2020/06/23 먼저 아래와 같이 저장한 후 나중에 scene0.__stg__로 교체
-- 이렇게 해야 scene0나 screen 객체를 맨 처음 생성할 때 예외가 발생하지 않음
_luasopia.stage = _luasopia.baselayer

--------------------------------------------------------------------------------
-- global constants -- 이 위치여야 한다.(위로 옮기면 안됨)
math.randomseed(os.time())
rand = math.random
INF = -math.huge -- infinity constant (일부러 -를 앞에 붙임)
_luasopia.debug = false
lib = {} -- 2020/03/07 added
ui = {} -- 2020/03/07 added
-- 2020/04/21 Disp.__getNumObjs 에서 빼야될  수
-- enterframe.lua에서 screen 객체(Rect)가 생성되기 때문에 초기값은 1
_luasopia.dcdobj = 1 

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
require 'luasopia.core.16_disp_coll'
require 'luasopia.core.17_disp_fllw'
require 'luasopia.core.18_disp_path'
require 'luasopia.core.19_disp_wave' -- 2020/07/01

require 'luasopia.core.20_group'
require 'luasopia.core.21_image'
require 'luasopia.core.22_image_region'
require 'luasopia.core.23_getsheet'
require 'luasopia.core.24_sprite'
require 'luasopia.core.30_text'

require 'luasopia.core.31_getshape'
require 'luasopia.core.32_shape'
require 'luasopia.core.33_rect'
require 'luasopia.core.34_polygon'
require 'luasopia.core.35_circle'
require 'luasopia.core.40_line' -- required refactoring
require 'luasopia.core.44_star'-- required refactoring
require 'luasopia.core.45_heart'-- required refactoring

require 'luasopia.core.50_sound'
local enterframedbg = require 'luasopia.core.99_enterframe' -- 맨 마지막에 로딩해야 한다

require 'luasopia.core.60_scene'--이후에는 scene0.__stg__안에 객체가 생성




require 'luasopia.lib.blink'
require 'luasopia.lib.Path' -- 2020/06/13 added
require 'luasopia.lib.Tail' -- 2020/06/18 added
require 'luasopia.lib.maketile' -- 2020/06/24 added



-- 반환되는 함수(init)가 아예 호출이 안될 때 logf를 빈함수로 설정
logf = function(...) print(string.format(...)) end

local init = function(args)
    
    if args then 

        if _Gideros then

            _luasopia.loglayer = {
                __bd = _Gideros.Sprite.new(),
                add = function(self, child) return self.__bd:addChild(child.__bd) end,
                --2020/03/15 isobj(_loglayer, Group)==true 이려면 아래 두 개 필요
                __clsid__ = Group.__id__,
            }
            _Gideros.stage:addChild(_luasopia.loglayer.__bd)
        
        elseif _Corona then
                
            _luasopia.loglayer = {
                __bd = _Corona.display.newGroup(),
                add = function(self, child) return self.__bd:insert(child.__bd) end,
                --2020/03/15 isobj(_loglayer, Group)가 true가 되려면 아래 두 개 필요
                __clsid__ = Group.__id__
            }
        
        end


        if args.debug then

            _luasopia.debug = true
            require 'luasopia.core.98_logf'
            if args.loglines then logf.setNumLines(args.loglines) end
            
            enterframedbg()

            -- 2020/05/30: added
            logf("(content)width:%d, height:%d", _luasopia.width, _luasopia.height)
            logf("(device)width:%d, height:%d", _luasopia.devicewidth, _luasopia.deviceheight)
            logf("orientation:'%s', fps:%d", _luasopia.orientation, _luasopia.fps)
            logf("x0:%d,y0:%d,ex:%d,ey:%d", screen.x0, screen.y0,screen.endx, screen.endy)
        
        end
        
        local linecolor = Color(100,100,100)

        if args.border then
            local border = args.border
            if type(border) ~= 'table' then border = {} end
            local color = border.color or linecolor
            local width = border.width or 3

            local br = Rect(screen.width, screen.height):empty()
            br:strokewidth(width):strokecolor(color)
            _luasopia.dcdobj = _luasopia.dcdobj + 1
        
        end 

        -- 2020/04/21 그리드선 추가
        if args.grid then
            local grid = args.grid
            if type(grid) ~= 'table' then grid = {} end

            local xgap = grid.xgap or 100
            local ygap = grid.ygap or 100
            local color = grid.color or linecolor
            local width = grid.width or 2

            for x = xgap, screen.width, xgap do
                Line(x, 0, x, screen.height, {width=width, color=color}, _luasopia.loglayer)
                _luasopia.dcdobj = _luasopia.dcdobj + 1
            end

            for y = ygap, screen.height, ygap do
                Line(0, y, screen.width, y, {width=width, color=color}, _luasopia.loglayer)
                _luasopia.dcdobj = _luasopia.dcdobj + 1
            end

        end

    end

end

-- 2020/04/12: 사용자가 _G에 변수를 생성하는 것을 막는다
-- 모든 사용자 전역변수는 global테이블에 만들어야 한다.
global = {} 
setmetatable(_G, {
    __newindex = function(_,n)
        error('attempt to create GLOBAL variable/function '..n, 2)
    end,
--[[ -- 읽는 것 까지 예외를 발생시킨다.
    __index = function(_,n)
        error('attempt to read undeclared variable '..n, 2)
    end
--]]
})

return init