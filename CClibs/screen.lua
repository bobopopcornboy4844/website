width,height = term.getSize()
local pixels = {}
local acceptedColorsK = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
local acceptedColors = {}
for i,v in pairs(acceptedColorsK) do
    acceptedColors[v] = colors.fromBlit(v)
end
for x=1,width do
    pixels[x] = {}
    for y=1,height do
        pixels[x][y] = "f"
    end
end

function getPixel(x,y)
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

function setPixel(x,y,Rc)
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

function draw()
    for x=1, width do
        xROW = pixels[x]
        for y=1, height do
            if math.mod(y,2) == 1 then
                yITEM = xROW[y]
                yITEMt = xROW[y+1]
            else
                yITEM = xROW[y-1]
                yITEMt = xROW[y]
            end
            if not yITEM then
                yITEM = 'f'
            end
            if not yITEMt then
                yITEMt = 'f'
            end

            term.setBackgroundColor(acceptedColors[yITEM])
            term.setTextColor(acceptedColors[yITEMt])
            term.setCursorPos(x,y)
            term.write("\131")
        end
    end
end
