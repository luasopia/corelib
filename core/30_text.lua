if not_required then return end -- This prevents auto-loading in Gideros

print('core.text')
--------------------------------------------------------------------------------
-- Text(str) 
-- Text(str, font)
-- Text(str, parent)
-- Text(str, font, parent)
--------------------------------------------------------------------------------
-- 2020/02/15:아래테이블은 !luasophia/ttf 폴더의 public domain ttf 리스트
-- 첫 번째 폰트가 defualt 폰트로 지정됨
local ttfs = {'opensans', 'typed', 'cabin', 'cruft',}
local ttfurl = 'luasopia/ttf/%s.ttf'
-- default font and fontSize
local fontname0 = ttfs[1]
local fontsize0 = 50 --50
--------------------------------------------------------------------------------
local Disp = Display
local strf = string.format

local function isvalid(name)
	for _, v in ipairs(ttfs) do
		if v==name then return true end
	end
end

-- 2020/02/15:font name이 잘못 지정되었을 때의 에러메세지를 생성
local function errmsg()
	local msg = 'Invalid font name. It must be one of '
	for k, v in ipairs(ttfs) do 
		if k==#ttfs then msg = msg .. strf("and '%s'.",v)
		else msg = msg .. strf("'%s', ",v) end
	end
	return msg
end
--------------------------------------------------------------------------------
Text = class(Disp)
--------------------------------------------------------------------------------
-- local fontcolor0 = {255,255,255} -- r,g,b
--------------------------------------------------------------------------------
function Text.setDefaultFont(fontname)
	if assert(isvalid(fontname), errmsg()) then
		fontname0 = fontname
	end
end

function Text.setDefaultFontSize(size)
	fontsize0 = size
end
--------------------------------------------------------------------------------
if _Gideros then -- for Gideros ###############################################

	print('cor.Text(gid)')

	local fontcolor0 = 0xffffff
	function Text.setDefaultColor(r,g,b)
		fontcolor0 = r*65526+g*256+b
	end
	
	local ttfnew = _Gideros.TTFont.new
	local tfnew = _Gideros.TextField.new
	-- y축의 중점을 잡기 위한 setAnchorPoint(x,y) 에서 y값(보정값)
	-- (corona에서는 자동으로 중점이 잡힌다.)
	local apys = {[0]=-0.35, 0.15, 0.27, 0.34, 0.36, 0.4, 0.41}
--------------------------------------------------------------------------------
	local function getya(str) -- 보정할 anchorY값을 구한다.
		local nn = select(2, str:gsub('\n', '\n')) -- number of '\n' character
		if nn>6 then return 0.41 end
		return apys[nn] -- 1:-0.35,  2:0.15, 3:0.27, 4:0.34
	end

	function Text:__newtext()
		local fonturl
		if assert(isvalid(self.__fnm), errmsg()) then
			fonturl = strf(ttfurl, self.__fnm)
		end
		-- print(fonturl,size)
		local font = ttfnew(fonturl, self.__fsz)
		local text = tfnew(font, self.__str)
		text:setTextColor(self.__fclr)
		text:setAnchorPoint(0.5, getya(self.__str)) -- 1:-0.35,  2:0.15, 3:0.27, 4:0.34
		return text
	end

	-- 2020/02/15: text의 size를 조절하기 위해 sprite안에 text를 삽입
	function Text:init(str, parent)

		self.__str = str
		self.__fnm = fontname0 -- font name(fnm)
		self.__fsz = fontsize0 -- font size (fsz)
		self.__fclr = fontcolor0
		self.__tbd = self:__newtext()
		
		self.__bd = _Gideros.Sprite.new()
		self.__bd:addChild(self.__tbd)
		self.__pr = parent
		return Disp.init(self)
	end

	function Text:font(fontname, size)
		self.__fnm = fontname -- fontname은 필수요소임
		self.__fsz = size or self.__fsz -- size가 nil이면 기존크기로
		self.__tbd = self:__newtext()
		self.__bd:removeChildAt(1)
		self.__bd:addChild(self.__tbd)
		return self
	end


	-- r, g, b는 0-255 범위의 정수
	function Text:color(r,g,b)
		self.__fclr = r*65536+g*256+b
		self.__tbd:setTextColor(self.__fclr)
		return self
	end

	-- 2020/01/28 text가 변경되면 중심점도 다시 잡아야 한다.
	function Text:setText(str,...)
		self.__str = strf(str,...)
		self.__tbd:setText(self.__str)
		self.__tbd:setAnchorPoint(0.5, getya(self.__str))
		return self
	end

	function Text:fontSize(v)
		self.__fsz = v
		self.__tbd = self:__newtext()
		self.__bd:removeChildAt(1)
		self.__bd:addChild(self.__tbd)
		return self
	end

	--[[ -- 소멸자를 오버로딩하나 안하나 textmem은 차이가 없음
	function Text:remove()
		self.__tbd:removeFromParent()
		Disp.remove(self)
	end
--]]

	function Text:getFontSize() return self.__fsz end
	function Text:anchor(xa, ya)
		self.__tbd:setAnchorPoint(xa,ya)
		return self
	end


elseif _Corona then -- for Corona ########################################

	local fontcolor0 = {1,1,1} -- white
	function Text.setDefaultColor(r,g,b) fontcolor0={r/255,g/255,b/255} end

	local newText = _Corona.display.newText
	local newGroup =  _Corona.display.newGroup

	function Text:__newtext()
		local fonturl
		if assert(isvalid(self.__fnm), errmsg()) then
			fonturl = strf(ttfurl, self.__fnm)
		end

		local text = newText({ -- font options
			text = self.__str,
			font = fonturl,
			fontSize = self.__fsz
		})
		text:setFillColor(unpack(self.__fclr))
		return text
	end

	function Text:init(str, parent)
		self.__str = str
		self.__fnm = fontname0
		self.__fsz = fontsize0
		self.__fclr = fontcolor0

		self.__tbd = self:__newtext()
		self.__bd = newGroup()
		self.__bd:insert(self.__tbd)
		self.__pr = parent
		return Disp.init(self)

	end

	
	function Text:fontSize(v)
		self.__tbd.size = v
		return self
	end
	
	
	function Text:setText(str,...)
		self.__str = strf(str,...)
		self.__tbd.text = self.__str
		return self
	end
	
	-- r, g, b는 0-255 범위의 정수
	function Text:color(r,g,b)
		self.__fclr = {r/255,g/255,b/255}
		self.__tbd:setFillColor(unpack(self.__fclr))
		return self
	end
	
	function Text:font(fontname, size)
		self.__fnm = fontname -- fontname은 필수요소임
		self.__fsz = size or self.__fsz -- size가 nil이면 기존크기로
		self.__tbd:removeSelf()
		self.__tbd = self:__newtext()
		self.__bd:insert(self.__tbd)
		return self
	end

	function Text:getFontSize() return self.__tbd.size end
	function Text:anchor(xa, ya)
		self.__tbd.anchorX, self.__tbd.anchorY = xa, ya
		return self
	end

end