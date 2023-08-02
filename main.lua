-- this a simple minesweeper game
-- it is called ghost hunter
-- the player is a ghost hunter
-- the ghosts and curses are the mines
-- the player has to find the friendly ghosts
-- the player has to avoid the curses

function _init()
 boardWidth=7
 boardHeight=6

 tileStates={empty=0, emptyFlagged=1, emptyRevealed=2, ghost=3, ghostFlagged=4, ghostRevealed=5, curse=6, curseFlagged=7, curseRevealed=8}
 ghostAndCurse={tileStates.ghost, tileStates.ghostFlagged, tileStates.curse, tileStates.curseFlagged}
 tileWidth=12
 tileHeight=16
 board={
  3,6,0,0,3,3,0,
  0,0,3,0,0,0,0,
  0,0,0,0,0,0,0,
  0,0,0,3,0,0,0,
  0,0,0,0,0,0,0,
  0,0,0,3,0,3,3
 }
 boardOffsetX=20
 boardOffsetY=20

 cursor=1

 gameStates={playing=0, won=1, lost=2}
end
   
function _draw()
 cls(13)

 -- draw ground
 -- fillp(0B100000110000100)
 -- rectfill(15, 15, 104, 117, 61)
 -- fillp(0)
 -- rectfill(18, 18, 101, 114, 3)

 -- draw moon
 -- local moonx=144
 -- local moony=-20
 -- fillp(0B100000110000100)
 -- circfill(moonx, moony, 50, 167)
 -- fillp(0B1000000000000000)
 -- circfill(moonx, moony, 45, 167)
 -- fillp(0)

 -- switch display based on gamestate
 if gamestate==gameStates.playing then
  -- drawBoard()
 elseif gamestate==gameStates.won then
  print("you won!", 45, 10, 7)
 elseif gamestate==gameStates.lost then
  print("you lost!", 45, 10, 7)
 end

 for i=1,#board do
  local tx=flr((i-1)%boardWidth)*tileWidth+boardOffsetX
  -- we use the lua backslash here to divide and floor at the same time
  local ty=flr((i-1)\boardWidth)*tileHeight+boardOffsetY

		-- if hidden tile
  if board[i]!=tileStates.emptyRevealed and board[i]!=tileStates.ghostRevealed and board[i]!=tileStates.curseRevealed then
   spr(1, tx, ty)
   spr(2, tx, ty+8)

		-- if revealed tile
  elseif board[i]==tileStates.emptyRevealed or board[i]==tileStates.ghostRevealed or board[i]==tileStates.curseRevealed then
   spr(3, tx, ty)
   spr(4, tx, ty+8)
   if board[i]==tileStates.ghostRevealed then
    spr(17, tx, ty+1)
   elseif board[i]==tileStates.curseRevealed then
    spr(18, tx, ty)
   end
  end
  
  -- spr(2, flr((i-1)%boardWidth)*8, flr((i-1)%boardHeight)*13+8)
  -- print(board[i], tx+2, ty+3, 7)

  if board[i]==tileStates.emptyRevealed then
   countNeighbors(i, tx+3, ty+3)
  end
  if board[i]==tileStates.emptyFlagged or board[i]==tileStates.ghostFlagged or board[i]==tileStates.curseFlagged then
   spr(19, tx+1, ty-6)
  end
 end

 local cx=flr((cursor-1)%boardWidth)*tileWidth+boardOffsetX
 local cy=flr((cursor-1)\boardWidth)*tileHeight+boardOffsetY
--  spr(17, cx-4, cy+2)
 spr(5, cx-3, cy+2, 2, 2)
end
   
function _update()
 -- win check
 local win=true
 for i=1,#board do
  -- if there are any empty tiles or ghost tiles left, the player hasn't won yet
  if board[i]==tileStates.empty or board[i]==tileStates.ghost then
   win=false
  end
 end
 if win then
  gamestate=gameStates.won
 end

 -- lose check
 local lose=false
 for i=1,#board do
  -- if there are any curses revealed, the player has lost
  if board[i]==tileStates.curseRevealed then
   lose=true
  end
 end
 if lose then
  gamestate=gameStates.lost
 end

 local aboveExists=cursor>boardWidth
 local belowExists=cursor<=(boardWidth*boardHeight)-boardWidth
 local leftExists=cursor%boardWidth!=1
 local rightExists=cursor%boardWidth!=0
 if btnp(⬆️) then
  cursor=aboveExists and cursor-boardWidth or (boardWidth*boardHeight)-(boardWidth-cursor)
 end
 if btnp(⬇️) then
  cursor=belowExists and cursor+boardWidth or ((cursor-1)%boardWidth)+1
 end
 if btnp(⬅️) then
  cursor=leftExists and cursor-1 or cursor+(boardWidth-1)
 end
 if btnp(➡️) then
  cursor=rightExists and cursor+1 or cursor-(boardWidth-1)
 end
 if btnp(❎) then
  if board[cursor]==tileStates.empty then
   board[cursor]=tileStates.emptyFlagged
  elseif board[cursor]==tileStates.emptyFlagged then
   board[cursor]=tileStates.empty
  elseif board[cursor]==tileStates.ghost then
   board[cursor]=tileStates.ghostFlagged
  elseif board[cursor]==tileStates.ghostFlagged then
   board[cursor]=tileStates.ghost
  elseif board[cursor]==tileStates.curse then
   board[cursor]=tileStates.curseFlagged
  elseif board[cursor]==tileStates.curseFlagged then
   board[cursor]=tileStates.curse
  end
 end
 if btnp(🅾️) then
  if board[cursor]==tileStates.empty or board[cursor]==tileStates.emptyFlagged then
   board[cursor]=tileStates.emptyRevealed
  elseif board[cursor]==tileStates.ghost or board[cursor]==tileStates.ghostFlagged then
   board[cursor]=tileStates.ghostRevealed
  elseif board[cursor]==tileStates.curse or board[cursor]==tileStates.curseFlagged then
   board[cursor]=tileStates.curseRevealed
  end
 end
end

function has_value (tab, val)
 for index, value in ipairs(tab) do
  if value == val then
   return true
  end
 end
 return false
end

function countNeighbors(i, x, y)
 local count=0
 local aboveExists=i>boardWidth
 local belowExists=i<=(boardWidth*boardHeight)-boardWidth
 local leftExists=i%boardWidth!=1
 local rightExists=i%boardWidth!=0

 if aboveExists then
  -- ghost above
  if has_value(ghostAndCurse, board[i-boardWidth]) then
   count+=1
  end
 end
 if belowExists then
  -- ghost below
  if has_value(ghostAndCurse, board[i+boardWidth]) then
   count+=1
  end
 end
 if leftExists then
  -- ghost to the left
  if has_value(ghostAndCurse, board[i-1]) then
   count+=1
  end
 end
 if rightExists then
  -- ghost to the right
  if has_value(ghostAndCurse, board[i+1]) then
   count+=1
  end
 end
 if aboveExists and leftExists then
  -- ghost to the upper left
  if has_value(ghostAndCurse, board[i-boardWidth-1]) then
   count+=1
  end
 end
 if aboveExists and rightExists then
  -- ghost to the upper right
  if has_value(ghostAndCurse, board[i-boardWidth+1]) then
   count+=1
  end
 end
 if belowExists and leftExists then
  -- ghost to the lower left
  if has_value(ghostAndCurse, board[i+boardWidth-1]) then
   count+=1
  end
 end
 if belowExists and rightExists then
  -- ghost to the lower right
  if has_value(ghostAndCurse, board[i+boardWidth+1]) then
   count+=1
  end
 end

 if count>0 then
  print(count, x, y, 7)
 end
end