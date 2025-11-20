width,height = term.getSize()
local pixels = {}
local acceptedColorsK = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
local fromBlit = {}
local acceptedColors = {}
screenLib = {}
for i,v in pairs(acceptedColorsK) do
    acceptedColors[v] = 2^tonumber(v,16)
end
for y=1,(height*2)+1 do
    pixels[y] = {}
    for x=1,width do
        pixels[y][x] = "f"
    end
end

screenLib.getPixel = function(x,y)
    if x < 1 or x > width then
        return nil,1
    end
    if y < 1 or y > height*2 then
        return nil,2
    end
    if pixels[y][x] then
        return pixels[y][x]
    end
    return nil,3
end

screenLib.clear = function()
    for y=1,(height*2)+1 do
        pixels[y] = {}
        for x=1,width do
            pixels[y][x] = "f"
        end
    end
end

screenLib.setPixel = function(x,y,Rc)
    local c = tostring(Rc)
    c = c:lower()
    if not acceptedColors[c] then
        return 4
    end
    if x < 1 or x > width then
        return nil,1
    end
    if y < 1 or y > height*2 then
        return nil,2
    end
    if pixels[y][x] then
        pixels[y][x] = c
        return true
    end
    return nil,3
end

local a = "\143"
local b = "\131"

screenLib.draw = function()
    for y=1, height/2 do
        local yITEMt, yITEMb
        local t_fg = {}
        local t_bg = {}
        local t_ch = {}
        local t_fg_2 = {}
        local t_bg_2 = {}
        local t_ch_2 = {}
        for x=1, width do
            yITEMt = pixels[(y*3)-2][x]
            yITEMb = pixels[(y*3)-1][x]
            if not (yITEMb and acceptedColors[yITEMb]) then
                yITEMb = 'f'
            end
            if not (yITEMt and acceptedColors[yITEMt]) then
                yITEMt = 'f'
            end
            table.insert(t_bg,yITEMb)
            table.insert(t_fg,yITEMt)
            table.insert(t_ch,a)


            yITEMt = pixels[(y*3)-1][x]
            yITEMb = pixels[(y*3)][x]
            if not (yITEMb and acceptedColors[yITEMb]) then
                yITEMb = 'f'
            end
            if not (yITEMt and acceptedColors[yITEMt]) then
                yITEMt = 'f'
            end
            table.insert(t_bg_2,yITEMb)
            table.insert(t_fg_2,yITEMt)
            table.insert(t_ch_2,b)
        end
        local XROWblitT, XROWblitB, XROWblit = table.concat(t_fg),table.concat(t_bg),table.concat(t_ch)
        term.setCursorPos(1,(y*2)-1)
        term.blit(XROWblit,XROWblitT,XROWblitB)

        local XROWblitT, XROWblitB, XROWblit = table.concat(t_fg_2),table.concat(t_bg_2),table.concat(t_ch_2)
        term.setCursorPos(1,(y*2))
        term.blit(XROWblit,XROWblitT,XROWblitB)
    end
end
