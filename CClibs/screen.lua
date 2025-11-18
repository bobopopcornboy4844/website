width,height = term.getSize()
local pixels = {}
local emptyPixels = {}
local acceptedColorsK = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
local acceptedColors = {}
screenLib = {}
for i,v in pairs(acceptedColorsK) do
    acceptedColors[v] = colors.fromBlit(v)
end
for x=1,width do
    pixels[x] = {}
    emptyPixels[x] = {}
    for y=1,height do
        pixels[x][y] = "f"
        emptyPixels[x][y] = "f"
    end
end

screenLib.getPixel = function(x,y)
    if x < 1 or x > width then
        return nil,1
    end
    if y < 1 or y > height then
        return nil,2
    end
    if pixels[x][y] then
        return pixels[x][y]
    end
    return nil,3
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
    if y < 1 or y > height then
        return nil,2
    end
    if pixels[x][y] then
        pixels[x][y] = c
        return true
    end
    return nil,3
end

screenLib.draw = function()
    for x=1, width do
        xROW = pixels[x]
        for y=1, height do
            yITEM = xROW[y+1]
            yITEMt = xROW[y]
            if not yITEM then
                yITEM = 'f'
            end
            if not yITEMt then
                yITEMt = 'f'
            end

            term.setBackgroundColor(acceptedColors[yITEM])
            term.setTextColor(acceptedColors[yITEMt])
            term.setCursorPos(x,y)
            if math.mod(y,2) == 0 or true then
                term.write("\143")
            else
                term.write("\131")
            end
        end
    end
end
