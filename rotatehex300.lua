local g = golly()
local cells = g.getcells( g.getrect() ) 
local selectarea = g.getselrect()

cells = g.transform( cells, 0, 0 ) 
g.select( g.getrect() )
g.clear( 0 )
g.select( selectarea )
g.putcells( cells, 0, 0, 0, 1, -1, 1 ) 