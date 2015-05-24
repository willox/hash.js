local WHITE, BLACK = 0, 1 -- 1 > 0 :^)

local turn = WHITE

local teamstring = {
	[WHITE] = "White",
	[BLACK] = "Black",
}

local teams = {}

local WPAWN, WROOK, WKNIGHT, WBISHOP, WQUEEN, WKING, BPAWN, BROOK, BKNIGHT, BBISHOP, BQUEEN, BKING = 1, 2, 3, 4, 5, 6, -1, -2, -3, -4, -5, -6
local chars = {
	[WPAWN] = "♙",
	[WROOK] = "♖",
	[WKNIGHT] = "♘",
	[WBISHOP] = "♗",
	[WQUEEN] = "♕",
	[WKING] = "♔",
	[BPAWN] = "♟",
	[BROOK] = "♜",
	[BKNIGHT] = "♞",
	[BBISHOP] = "♝",
	[BQUEEN] = "♛",
	[BKING] = "♚",
}

local board

local function reset()
	board = {
		{BROOK,BKNIGHT,BBISHOP,BQUEEN,BKING,BBISHOP,BKNIGHT,BROOK},
		{BPAWN,BPAWN,BPAWN,BPAWN,BPAWN,BPAWN,BPAWN,BPAWN},
		0,0,0,0,
		{WPAWN,WPAWN,WPAWN,WPAWN,WPAWN,WPAWN,WPAWN,WPAWN},
		{WROOK,WKNIGHT,WBISHOP,WQUEEN,WKING,WBISHOP,WKNIGHT,WROOK},
	}
	for i = 3, 6 do
		board[i] = {0,0,0,0,0,0,0,0}
	end
end
reset()

local function err(msg)
	print("[Chess Error]: "..msg)
end

local function chessprint(msg)
	print("[Chess]: "..msg)
end

local function printboard()
	print("\n")
	for coli, column in ipairs(board) do
		local ret = coli
		for rowi, piece in ipairs(column) do
			if piece == 0 then
				ret = ret .. ((rowi % 2) == (coli % 2) and " " or  "█")
			else
				ret = ret .. chars[piece]
			end
		end
		print(ret)
	end
	print("  A  B  C  D  E  F  G  H")
end

local function xytoxy(xy)
	local x, y = string.lower(string.sub(xy, 1, 1)), tonumber(string.sub(xy, 2, 2))
	x = type(x) == "string" and string.byte(x) - 96 or tonumber(x)
	return x, y
end

local function movepiece(sid64, oldxy, xy)
	if not (teams[BLACK] and teams[WHITE]) then err("Game not started.") return end
	if not (teams[BLACK] == sid64 or teams[WHITE] == sid64) then err("You are not in this game.") return end

	if teams[turn] ~= sid64 then err("It's not your turn!") return end

	-- get on my level
	local oldx, oldy = xytoxy(oldxy)
	if not oldx or oldx > 8 or oldx < 1 then err("Invalid old horizontal position (must be 1-8 or a-h)") return end
	if not oldy or oldy > 8 or oldy < 1 then err("Invalid old vertical position (must be 1-8)") return end

	if not board[oldy][oldx] then err("There is no piece at the old position!") return end

	local x, y = xytoxy(xy)
	if not x or x > 8 or x < 1 then err("Invalid new horizontal position (must be 1-8 or a-h)") return end
	if not y or y > 8 or y < 1 then err("Invalid new vertical position (must be 1-8)") return end

	local newspot = board[y][x]
	if newspot ~= 0 then
		chessprint(newspot[spot] .. " was captured and removed from play.")
	end

	board[y][x] = board[oldy][oldx]

	board[oldy][oldx] = nil

	printboard()

	turn = (turn == WHITE) and BLACK or WHITE
end

local cmd = "!chess "
hook.Add("Message", "CHESSAGE", function(ply, sid64, msg)
	if string.sub(msg, 1, #cmd) ~= cmd then return end
	local subcmd = string.sub(msg, #cmd + 1)
	if subcmd == "join" then
		if teams[WHITE] and teams[BLACK] then err("Game is full.") return end
		if not teams[WHITE] then
			teams[WHITE] = sid64
			chessprint(ply.." joined white side!")
		else
			teams[BLACK] = sid64
			chessprint(ply.." joined black side!")
		end
		if teams[BLACK] and teams[WHITE] then chessprint("Game starting.") end
	elseif subcmd == "leave" then
		if not (teams[BLACK] == sid64 or teams[WHITE] == sid64) then err("You are not playing.") return end
		if teams[WHITE] == sid64 then
			teams[WHITE] = nil
			chessprint(ply.." left white side! Game resetting.")
		else
			teams[BLACK] = nil
			chessprint(ply.." left black side! Game resetting.")
		end
		reset()
	elseif subcmd == "print" then
		printboard()
	elseif subcmd == "status" then
		chessprint("White player: "..tostring(teams[WHITE]), "Black player: "..tostring(teams[BLACK]) .. "; Turn: "..teamstring[turn])
	elseif subcmd == "help" then
		chessprint("Commands: join, leave, print, status, help")
		chessprint("To move: !chess <piece> <XY>")
	elseif subcmd == "reset" then
		if not (teams[BLACK] == sid64 or teams[WHITE] == sid64) then err("You are not playing.") return end
		reset()
	else
		if not (teams[BLACK] == sid64 or teams[WHITE] == sid64) then err("You are not playing.") return end
		local space = string.find(subcmd, " ")
		if not space then return end
		local piece, xy = string.sub(subcmd, 1, space), string.sub(subcmd, space + 1)
		if not (piece and xy) then return end
		movepiece(sid64, piece, xy)
	end
end)

printboard()
