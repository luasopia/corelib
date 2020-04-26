-- if not_required then return end -- This prevents auto-loading in Gideros

local Display = Display

ImageRegion = class(Display)

if _Gideros then
	print('core.imageRegion(Gid)')

	local Texture_new = _Gideros.Texture.new
	local Bitmap_new = _Gideros.Bitmap.new
	local TextureRegion_new = _Gideros.TextureRegion.new
	--============================================================================== 
	-- sht = {x=n, y=n, width=n, height=n,
	--	__textureRegion -- 첫 번째 호출에서 생성됨
	-- }
	-- __textureRegion은 첫 호출에서 저장한다.
	-- 두 번째 이후에는 Texture.new()를 호출할 필요없이 저장된 것을 사용
	--============================================================================== 

	--------------------------------------------------------------------------------
	function ImageRegion:init(url, sht, parent)
		-- if not sht.__txtureRegion then
		-- 	sht.__textureRegion = TextureRegion_new(Texture_new(url), sht.x, sht.y, sht.width, sht.height)
		-- end
		-- self.__bd = Bitmap_new(sht.__textureRegion)

		local tr = TextureRegion_new(Texture_new(url), sht.x, sht.y, sht.width, sht.height)
		self.__bd = Bitmap_new(tr)
		self.__bd:setAnchorPoint(0.5, 0.5)
		self.__pr = parent
		return Display.init(self)
	end

elseif _Corona then

	print('core.imageRegion(Cor)')
	local newImgSht = _Corona.graphics.newImageSheet
	local newImg =  _Corona.display.newImage
	function ImageRegion:init(url, sht, parent)
		local opt = {frames={[1]=sht}}
		-- {
		-- 	{x=sht.x, y=sht.y, width=sht.width, height=sht.height} -- frame 1
		-- }
		local imgsht = newImgSht(url, opt)
		self.__bd = newImg(imgsht, 1)
		self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5
		self.__pr = parent
		return Display.init(self)
	end

end