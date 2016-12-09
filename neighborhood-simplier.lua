-- Lua version of Adam P. Goucher's neighborhood simplifier.

local g = golly()
local bor = bit32.bor
local band = bit32.band
local rshift = bit32.rshift

local magic_code = {0, 1, 2, 3, 4, 5, 6, 4, 6, 4, 3, 0, 1, 6, 5, 2}

local function sq4(x)
    return magic_code[bor(band(x, 3) , band(rshift(x, 1), 12)) + 1]
end
local function sq9(y)
    return sq4(y), sq4(rshift(y, 1)), sq4(rshift(y, 3)), sq4(rshift(y, 4))
end

if g.numstates() ~= 2 then
    g.exit('Pattern must be 2-state')
end

-- get current rule, remove any suffix and any slashes
local origrule = g.getrule()
origrule = origrule:match("^(.+):") or origrule
origrule = origrule:gsub("/","")

local clist = g.getcells(g.getrect())
g.addlayer()

-- Construct transition table:
for i = 0, 511 do
    local x = 5 * band(i, 31)
    local y = 5 * rshift(i, 5)
    for u = 0, 2 do
        for v = 0, 2 do
            g.setcell(x + u, y + v, band(rshift(i, 3 * v + u), 1))
        end
    end
end
g.run(1)
local tt = {}
for i = 0, 511 do
    tt[#tt+1] = g.getcell(5 * band(i, 31) + 1, 5 * rshift(i, 5) + 1)
end

local rulename = 'Moore2vn-'..origrule

local f = io.open(g.getdir('rules')..rulename..'.rule', 'w')
if f then
    f:write('@RULE '..rulename..'\n')
    f:write('@TABLE\nn_states:8\nneighborhood:vonNeumann\nsymmetries:none\n\n')
    for i = 0, 15 do
        local a = band(i, 1)
        local b = band(rshift(i, 1), 1)
        local c = band(rshift(i, 2), 1)
        local d = band(rshift(i, 3), 1)
        f:write(string.format('0%d%d%d%d%d\n', 7*a, 7*b, 7*d, 7*c, magic_code[i+1]))
    end
    for i = 0, 511 do
        local a, b, c, d = sq9(i)
        f:write(string.format('0%d%d%d%d%d\n', a, b, d, c, 7 * tt[i+1]))
    end
    for i = 0, 7 do
        f:write(i..'00000\n')
    end
    f:close()
else
    g.exit('Failed to create .rule file!')
end

g.new('Converted pattern')
g.setrule(rulename)

if #clist > 0 then
    local newcells = {}
    for i = 1, #clist, 2 do
        local x = clist[i]
        local y = clist[i+1]
        newcells[#newcells+1] = x-y
        newcells[#newcells+1] = x+y
        newcells[#newcells+1] = 7
    end
    if #newcells % 2 == 0 then
        newcells[#newcells+1] = 0
    end
    g.putcells(newcells)
end
g.fit()