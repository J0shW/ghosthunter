-- this a simple minesweeper game
-- it is called ghost hunter
-- the player is a ghost hunter
-- the ghosts and curses are the mines
-- the player has to find the friendly ghosts
-- the player has to avoid the curses

function _init()
 boardWidth=7
 boardHeight=6

 -- empty=0
 -- emptyFlagged=1
 -- emptyRevealed=2
 -- ghost=3
 -- ghostFlagged=4
 -- ghostRevealed=5
 -- curse=6
 -- curseFlagged=7
 -- curseRevealed=8
 tileStates={empty=0, emptyFlagged=1, emptyRevealed=2, ghost=3, ghostFlagged=4, ghostRevealed=5, curse=6, curseFlagged=7, curseRevealed=8}

 board={
  3,0,0,0,3,3,0,
  0,0,3,0,0,0,0,
  0,0,0,0,0,0,0,
  0,0,0,3,0,0,0,
  0,0,0,0,0,0,0,
  0,0,0,3,0,3,3
 }

 cursor=1
end
   
function _draw()
 cls(13)
 for i=1,#board do
  local tx=flr((i-1)%boardWidth)*8
  -- we use the lua backslash here to divide and floor at the same time
  local ty=flr((i-1)\boardWidth)*12
  spr(1, tx, ty)
  spr(2, tx, ty+8)
  -- spr(2, flr((i-1)%boardWidth)*8, flr((i-1)%boardHeight)*13+8)
  -- print(board[i], tx+2, ty+3, 7)

  if board[i]==tileStates.emptyRevealed then
   countNeighbors(i, tx+2, ty+3)
  end
 end

 local cx=flr((cursor-1)%boardWidth)*8
 local cy=flr((cursor-1)\boardWidth)*12
 spr(0, cx, cy)
end
   
function _update()
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
  if board[cursor]==tileStates.empty then
   board[cursor]=tileStates.emptyRevealed
  elseif board[cursor]==tileStates.ghost then
   board[cursor]=tileStates.ghostRevealed
  elseif board[cursor]==tileStates.curse then
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
  if board[i-boardWidth]==tileStates.ghost then
   count+=1
  end
 end
 if belowExists then
  -- ghost below
  if board[i+boardWidth]==tileStates.ghost then
   count+=1
  end
 end
 if leftExists then
  -- ghost to the left
  if board[i-1]==tileStates.ghost then
   count+=1
  end
 end
 if rightExists then
  -- ghost to the right
  if board[i+1]==tileStates.ghost then
   count+=1
  end
 end
 if aboveExists and leftExists then
  -- ghost to the upper left
  if board[i-boardWidth-1]==tileStates.ghost then
   count+=1
  end
 end
 if aboveExists and rightExists then
  -- ghost to the upper right
  if board[i-boardWidth+1]==tileStates.ghost then
   count+=1
  end
 end
 if belowExists and leftExists then
  -- ghost to the lower left
  if board[i+boardWidth-1]==tileStates.ghost then
   count+=1
  end
 end
 if belowExists and rightExists then
  -- ghost to the lower right
  if board[i+boardWidth+1]==tileStates.ghost then
   count+=1
  end
 end

 if count>0 then
  print(count, x, y, 7)
 end
end