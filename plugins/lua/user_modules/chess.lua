local charwidth = 2
local spacewidth = 4

local WHITE, BLACK = 0, 1 -- 1 > 0 :^)

local teams = {}

local WPAWN, WROOK, WKNIGHT, WBISHOP, WQUEEN, WKING, BPAWN, BROOK, BKNIGHT, BBISHOP, BQUEEN, BKING = 1, 2, 3, 4, 5, 6, -1, -2, -3, -4, -5, -6
local pieces = {pawn = WPAWN, rook = WROOK, knight = WKNIGHT, bishop = WBISHOP, queen = WQUEEN, king = WKING}
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

local function findpiecepos(piece) -- fight me
	for coli, column in ipairs(board) do
		for rowi, bpiece in ipairs(column) do
			if bpiece == piece then
				return coli, rowi
			end
		end
	end
	return false
end

local function printboard()
	for coli, column in ipairs(board) do
		local ret = ""
		for rowi, piece in ipairs(column) do
			if piece == 0 then
				ret = ret .. ((rowi % 2) == (coli % 2) and " " or  "█")
			else
				ret = ret .. chars[piece]
			end
		end
		print(ret)
	end
end

local function movepiece(sid64, piece, xy)
	if not (teams[BLACK] and teams[WHITE]) then return end
	if not (teams[BLACK] == sid64 or teams[WHITE] == sid64) then return end
	piece = pieces[string.lower(piece)]
	if not piece then err("Invalid piece. (must be pawn, rook, knight, bishop, queen, or king)") return end
	if teams[BLACK] == sid64 then piece = -piece end

	local x, y = xy[1], xy[2]
	local y = type(y) == "string" and string.byte(string.lower(y)) - 96 or y
	if not tonumber(x) or x > 8 or x < 1 then err("Invalid horizontal position (must be 1-8 or a-h)") return end
	if not tonumber(y) or y > 8 or y < 1 then err("Invalid vertical position (must be 1-8)") return end

	local oldpiecey, oldpiecex = findpiecepos(piece)
	if not oldpiecey then err("Invalid piece. (Is it in play?)") return end

	board[oldpiecey][oldpiecex] = nil

	local spot = board[y][x]
	if spot ~= 0 then
		print(chars[spot] .. " was captured and removed from play.")
	end

	board[y][x] = piece

	printboard()
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
		chessprint("White player: "..teams[WHITE], "Black player: "..teams[BLACK])
	elseif subcmd == "help" then
		chessprint("Commands: join, leave, print, status, help")
		chessprint("To move: !chess <piece> <XY>")
	else
		local space = string.find(subcmd, " ")
		if not space then return end
		local piece, xy = string.sub(subcmd, 1, space), string.sub(subcmd, space + 1)
		if not (piece and xy) then return end
		movepiece(sid64, piece, xy)
	end
end)

printboard()
