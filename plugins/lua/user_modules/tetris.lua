
local L=true
local n=false

local LEFT=true
local RIGHT=false

local prints={
	[L]="#"
	[n]="_"
}

local function write_piece_to_board(piece,board,what)
	local overwrote=false
	for y=1,piece.size[1] do
		for x=1,piece.size[2] do
			if(piece.shape[x][y] == L)then
				if(board[y+piece.pos[2]-1][x+piece.pos[1]-1])then
					overwrote=true
				end
				board[y+piece.pos[2]-1][x+piece.pos[1]-1]=what
			end
		end
	end
	return overwrote
end

local function generate_piece()
	return {
		pos={1,1}
		shape={
			{L,n,n,n},
			{n,n,n,n},
			{n,n,n,n},
			{n,n,n,n},
		}
		size={1,1}
		offset=0
	}
end

function make_board(width,height)
	local r={}
	for y=1,height do 
		r[y]={}
		for x=1,width do
			r[y][x]=n
		end
	end
	r.size={width,height}
	r.active=generate_piece()
	return r
end

local function board_print(board)
	io.write".\r\n"
	for y=1,board.size[2] do
		for x=1,board.size[1] do
			io.write(prints[board[y][x]])
		end
		io.write"\r\n"
	end
end

function board_tick(board,fall,x)
	local active=board.active
	write_piece_to_board(active,board,n)
	
	local before_x,before_y=active.pos[1],active.pos[2]
	
	if(fall)then
		active.pos[2]=active.pos[2] + 1
	elseif(x ~= nil)then
		if(x == LEFT)then
			active.pos[1]=active.pos[1] - 1
		elseif(x == RIGHT)then
			active.pos[1]=active.pos[1] + 1
		end
		
		if(active.pos[1] < 1 or active.pos[1] > board.size[1])then
			active.pos[1]=before_x
		end
	end
	
	local biggest_y=0
	local hit=false
	for y=1,active.size[1] do
		for x=1,active.size[2] do
			if(active.shape[x][y] == L)then
				biggest_y=y
				if(active.pos[2] + biggest_y - 2 == board.size[2] or board[y+active.pos[2]-1][x+active.pos[1]-1] == L)then
					hit=true
				end
			end
		end
	end
	
	if(hit)then
		active.pos[1]=before_x
		active.pos[2]=before_y
	end
	
	write_piece_to_board(active,board,L)
	
	local ded=false
	if(hit and fall)then 
		board.active=generate_piece()
		ded=write_piece_to_board(board.active,board,L)
	end
	
	for y=board.size[2],-1 do
		local full=true
		for x=1,board.size[1] do
			if(board[y][x] == n)then
				full=false
				break
			end
		end
		if(full)then
			for y2=y - 1,1 do
				board[y2 + 1]=board[y2]
			end
			board[1]={n,n,n,n}
		end
	end
	
	board_print(board)
	if(ded)then print("YOU DIED"); return true; end
	return false
end
local board=nil

function start_tetris()
	board=make_board()
	timer.Create("TETRIS",1,0,function()
		if(not board)then timer.Remove("TETRIS"); return; end
		if(board_tick(board,true))then
			board=nil
		end
	end)
end

hook.Add("Message","TETRIS",function(_,_,_)
	if(board and _:find"right")then
		board_tick(board,false,RIGHT)
	elseif(board and _:find"left")then
		board_tick(board,false,LEFT)
	end
end)