if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
local cx, cy = screen.centerx, screen.centery
local tIn, tRm = table.insert, table.remove
local int = math.floor
--------------------------------------------------------------------------------
local txtobjs = {}
local linespace = 1.3 -- 줄간격을 0.3으로 설정(너무 붙으면 가독성이 떨어짐)
local yoff = 0; if _Gideros then yoff = 50 end
local numlines = 7
local leftmargin = 10

--local function initlog()

    local txtobj = Text("logf ready.", _loglayer):anchor(0,0) --:xy(0,cursorY+yoff)
    local fontSize =  txtobj:getFontSize()*linespace
    local maxlines = int(screen.height / fontSize)
    txtobj:xy(leftmargin, fontSize*(maxlines-1)+yoff) -- 맨 마지막줄부터 출력 시작
    local cursorY = fontSize*maxlines
    tIn(txtobjs, txtobj)
    print('maxlines:'..maxlines)

--end

--initlog()

logf = setmetatable({},{__call=function(_, str,...)

    local strf = string.format(str,...)
    local txtobj = Text(strf,_loglayer):anchor(0,0):xy(leftmargin,cursorY+yoff)
    tIn(txtobjs, txtobj)
    cursorY = cursorY + fontSize

    if cursorY > maxlines*fontSize then
        for k=#txtobjs,1,-1 do local v = txtobjs[k]
            v:y(v:gety()-fontSize)
            if v:gety() < fontSize*(maxlines-numlines) then
                tRm(txtobjs,k)
                v:remove()
            end
        end
        cursorY = cursorY - fontSize
    end

    return txtobj
end})


logf.clear = function()
    for k=#txtobjs,1,-1 do local v = txtobjs[k]
        tRm(txtobjs,k)
        v:remove()
    end
    cursorY = 0
end

logf.setNumLines = function(n)
    if n == INF then numlines = maxlines
    else numlines = n end
end

logf.__getNumObjs = function() return #txtobjs end