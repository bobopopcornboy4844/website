width,height = term.getSize()
local pixels = {}
local emptyPixels = {}
local acceptedColorsK = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
screenLib = {}
for i,v in pairs(acceptedColorsK) do
    acceptedColors[v] = colors.fromBlit(v)
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
    for y=1, height do
        XROWblitT = ""
        XROWblitB = ""
        XROWblit  = ""
        for x=1, width do
            if math.mod(y,2) == 1 then
                yITEMt = pixels[(y*2)][x]
                yITEMb = pixels[(y*2)+1][x]
            else
                yITEMt = pixels[(y*2)-1][x]
                yITEMb = pixels[(y*2)][x]
            end
            if not (yITEMb and acceptedColors[yITEMb]) then
                yITEMb = 'f'
            end
            if not (yITEMt and acceptedColors[yITEMt]) then
                yITEMt = 'f'
            end
            XROWblitB = XROWblitB..yITEMb
            XROWblitT = XROWblitT..yITEMt
            if math.mod(y,2) == 1 then
                XROWblit = XROWblit..a
            else
                XROWblit = XROWblit..b
            end
        end
        term.setCursorPos(1,y)
        term.blit(XROWblit,XROWblitT,XROWblitB)
    end
end
