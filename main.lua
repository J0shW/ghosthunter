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

 -- when an upgrade is unavailable, it is set to nil
 -- when an upgrade is available, it is set to true
 -- when the upgrade is used, it is set to false
 upgrades={}
 for i=1,boardHeight do
  add(upgrades, nil)
 end

 cursor=1

 gameStates={startMenu=0, playing=1, won=2, lost=3}
 gamestate=gameStates.startMenu
 numMines=10
 t=0
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
 if gamestate==gameStates.startMenu then
  local title="ghost hunter"
  local btntxt="start"
  print(title,hcenter(title),vcenter(title)-10,7)
  print(btntxt, hcenter(btntxt), vcenter(btntxt)+10, 2)
  spr(32, hcenter(btntxt)-10, vcenter(btntxt)+10)
  -- circfill(hcenter(btntxt)-5,vcenter(btntxt)+12, 1, t%30==1 and 7 or 2)
 end
 if gamestate!=gameStates.startMenu then
  -- center board on screen
  local boardWidthPixels=boardWidth*tileWidth
  local boardHeightPixels=boardHeight*tileHeight
  local boardOffsetX=(128-boardWidthPixels)/2
  local boardOffsetY=(128-boardHeightPixels)/2

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
   
   if board[i]==tileStates.emptyRevealed then
    countNeighbors(i, tx+3, ty+3)
   end
   if board[i]==tileStates.emptyFlagged or board[i]==tileStates.ghostFlagged or board[i]==tileStates.curseFlagged then
    spr(19, tx+1, ty-6)
   end
  end

  for i=1,boardHeight do
   -- if row is revealed, draw an upgrade button
   if upgrades[i]==true then
    spr(10, boardWidthPixels+boardOffsetX, flr((i-1)%boardWidth)*tileHeight+boardOffsetY+1, 2, 2)
   elseif upgrades[i]==nil then
    spr(8, boardWidthPixels+boardOffsetX, flr((i-1)%boardWidth)*tileHeight+boardOffsetY+1, 2, 2)
   end
  end

  -- draw stats row at bottom with 8 height. Number of ghosts, number of curses
  local numGhosts=0
  local numCurses=0
  for i=1,#board do
   if board[i]==tileStates.ghost or board[i]==tileStates.ghostFlagged then
    numGhosts+=1
   elseif board[i]==tileStates.curse or board[i]==tileStates.curseFlagged then
    numCurses+=1
   end
  end
  rectfill(0, 120, 128, 128, 1)
  rectfill(0, 121, 14, 128, 12)
  spr(6, 1, 122)
  print(numGhosts < 10 and "0"..numGhosts or numGhosts, 7, 122, 7)
  rectfill(16, 121, 30, 128, 14)
  spr(7, 17, 122)
  print(numCurses < 10 and "0"..numCurses or numCurses, 23, 122, 7)
  rectfill(32, 121, 128, 128, 15)

  if activeUpgradeRow!=nil then
   local tx=boardWidthPixels+boardOffsetX
   local ty=flr((activeUpgradeRow-1)%boardWidth)*tileHeight+boardOffsetY+1
   spr(5, tx, ty)
  else
   local cx=flr((cursor-1)%boardWidth)*tileWidth+boardOffsetX
   local cy=flr((cursor-1)\boardWidth)*tileHeight+boardOffsetY
   spr(5, cx-3, cy+2)
  end
 end
 if gamestate==gameStates.playing then
  -- show controls
  spr(38, 33, 122)
  print("move", 41, 122, 5)
  spr(32, 65, 122)
  print("reveal", 73, 122, 5)
  spr(33, 104, 122)
  print("flag", 112, 122, 5)
 end
 if gamestate==gameStates.won then
  local title="you won!"
  print(title, hcenter(title), 8, 7)
  spr(32, 55, 122)
  print("play again?", 63, 122, 5)
 end
 if gamestate==gameStates.lost then
  local title="you lost!"
  print(title, hcenter(title), 8, 7)
  spr(32, 55, 122)
  print("play again?", 63, 122, 5)
 end
end
   
function _update()
 t+=1

 if gamestate==gameStates.startMenu then
  if btnp(🅾️) then
   initBoard(4, 4)
   gamestate=gameStates.playing
  end
 elseif gamestate==gameStates.won or gamestate==gameStates.lost then
  if btnp(🅾️) then
   initBoard(4, 4)
   gamestate=gameStates.playing
  end
 elseif gamestate==gameStates.playing then
  -- win check
  local win=true
  for i=1,#board do
   -- if there are any empty tiles or ghost tiles left, the player hasn't won yet
   if board[i]==tileStates.empty or board[i]==tileStates.emptyFlagged or board[i]==tileStates.ghost or board[i]==tileStates.ghostFlagged then
    win=false
   end
  end
  if win then
   gamestate=gameStates.won
   sfx(3)
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
   if activeUpgradeRow!=nil then
    activeUpgradeRow=nil
   else
    cursor=leftExists and cursor-1 or cursor+(boardWidth-1)
   end
  end
  if btnp(➡️) then
   -- get row of cursor
   local cursorRow=flr((cursor-1)/boardWidth)+1
   if rightExists==false and upgrades[cursorRow]==true then
    activeUpgradeRow=cursorRow
   else
    cursor=rightExists and cursor+1 or cursor-(boardWidth-1)
   end
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
   if activeUpgradeRow!=nil then
    if upgrades[activeUpgradeRow]==true then
     -- find a ghost and reveal it
     for i=1,#board do
      if board[i]==tileStates.ghost or board[i]==tileStates.ghostFlagged then
       board[i]=tileStates.ghostRevealed
       -- clear the upgrade
       upgrades[activeUpgradeRow]=false
       sfx(2)
       break
      end
     end
    end
    activeUpgradeRow=nil
   else
    if board[cursor]==tileStates.empty or board[cursor]==tileStates.emptyFlagged then
     board[cursor]=tileStates.emptyRevealed
     sfx(0)
    elseif board[cursor]==tileStates.ghost or board[cursor]==tileStates.ghostFlagged then
     board[cursor]=tileStates.ghostRevealed
     sfx(2)
    elseif board[cursor]==tileStates.curse or board[cursor]==tileStates.curseFlagged then
     board[cursor]=tileStates.curseRevealed
     sfx(1)
    end
   end
  end

  -- check if all tiles in a row are revealed
  for i=1,boardHeight do
   if upgrades[i]==nil then
    local rowStart=(i-1)*boardWidth+1
    local rowEnd=rowStart+boardWidth-1
    local rowRevealed=true
    for j=rowStart,rowEnd do
     if board[j]!=tileStates.emptyRevealed and board[j]!=tileStates.ghostRevealed and board[j]!=tileStates.curseRevealed then
      rowRevealed=false
     end
    end
    if rowRevealed then
     upgrades[i]=true
    end
   end
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

function initBoard(ghostCount, curseCount)
 -- clear upgrades
 for i=1,boardHeight do
  upgrades[i]=nil
 end
 board={}
 for i=1,boardWidth*boardHeight do
  board[i]=tileStates.empty
 end
 for i=1,ghostCount do
  local ghostPos=flr(rnd(boardWidth*boardHeight))+1
  while board[ghostPos]!=tileStates.empty do
   ghostPos=flr(rnd(boardWidth*boardHeight))+1
  end
  board[ghostPos]=tileStates.ghost
 end
 for i=1,curseCount do
  local cursePos=flr(rnd(boardWidth*boardHeight))+1
  while board[cursePos]!=tileStates.empty do
   cursePos=flr(rnd(boardWidth*boardHeight))+1
  end
  board[cursePos]=tileStates.curse
 end
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

function hcenter(s)
 -- screen center minus the
 -- string length times the 
 -- pixels in a char's width,
 -- cut in half
 return 64-#s*2
end

function vcenter(s)
 -- screen center minus the
 -- string height in pixels,
 -- cut in half
 return 61
end