if not_required then return end -- This prevents auto-loading in Gideros
print('core.class')
--------------------------------------------------------------------------------
-- magic methods : init(), update(), remove()
--------------------------------------------------------------------------------
local nilFn = function() end

--2020/02/15 class 테이블에 __clsid__ 필드를 추가하고
-- 어떤 테이블이 class 자체인지 rawget()함수를 이용하여 검사한다
local function _isobj(t) return type(t)=='table' and t.__isobj__ end
local function _iscls(t) return type(t)=='table' and rawget(t,'__clsid__') end
-- 어떤 객체가 클래스의 객체인지를 판단하는 (전역)함수
function isobj(obj, cls)
	return _isobj(obj) and _iscls(cls) and obj.__clsid__ == cls.__clsid__
end

-- function isnum(v) return type(v)=='number' end

local Object = {
	init = nilFn, -- default constructor
	remove = nilFn, -- default destructor
	classname = 'Object',
	__clsid__ = 0,
	name = 'obj',
	-- 2020/02/21 added
	is = function(self, name) self.classname = name; return self end
}

local clsid = 0

local function constructor(cls, ...)
	local obj = setmetatable({ __isobj__ = true }, { __index = cls })
	cls.init(obj, ...)
	return obj
end

class = function(baseClass)
	local super = baseClass or Object
	clsid = clsid + 1 -- 생성되는 클래스마다 고유의 id를 갖게 한다.
	return setmetatable(
		------------------------------------------------------------------------
		-- init=nilFn 으로 지정해서 만약 사용자 생성자가 없어도
		-- super.init이 자동 실행되는 것을 막는다.
		-- 따라서 자식클래스는 **반드시 생성자를 만들어야 한다**
		-- 부모생성자를 호출하려면 자식생성자 안에서 parentCls.init(self,...) 라고 호출
		-- 단, remove 은 빈함수로 지정하지 않았으므로
		-- 자식의 소멸자가 없으면 **부모의 소멸자가 자동호출된다.**
		------------------------------------------------------------------------
		--{init=nilFn, __super=super, superInit=__superInit, superDel=__superDel}, -- cls
		{	
			init = nilFn,
			__clsid__ = clsid, -- 클래스 고유번호, isobjof()메서드에서 사용된다
		}, -- cls (constructor의 cls로 넘겨짐)
		------------------------------------------------------------------------
		-- 아래는 cls의 메타테이블
		------------------------------------------------------------------------
		{__index = super, --[[상속구현]] __call = constructor}
	)
end