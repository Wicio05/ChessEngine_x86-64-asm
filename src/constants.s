# read-only data section
.section .rodata

test_pos:	.asciz 	"r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - "
tricky_pos:	.asciz 	"r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1 "
start_pos:	.asciz 	"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 "
end_pos:	.asciz	"8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - "
game_pos:	.asciz  "r1bqkbnr/ppp1pppp/2n5/3pP3/8/5N2/PPPP1PPP/RNBQKB1R b KQkq - 2 3"
mate_pos:	.asciz	"4k3/P2pppp1/8/8/8/8/1PPPPPPP/4K3 w - - 0 1"
mate_k_pos:	.asciz	"nb6/kpP3p1/pp6/8/8/8/1PPPPPPP/4K3 w - - 0 1"

gotest:			.asciz	"depth 9"
gotest2:			.asciz	""
position_test:	.asciz	"sth"
move_test:  .asciz	"d7d5"


char: .asciz "%c\n"     # 1-byte
short: .asciz "%hd"     # 2-bytes
integer: .asciz "%d\n" # 4-bytes
long: .asciz "%llu\n"   # 8-bytes
string: .asciz "%s\n"   # -

not_a_file:     .quad	0XFEFEFEFEFEFEFEFE
	
not_h_file:     .quad	0X7F7F7F7F7F7F7F7F
	
not_hg_file:    .quad	0X3F3F3F3F3F3F3F3F
	
not_ab_file:    .quad	0XFCFCFCFCFCFCFCFC

rank7:			.quad 	0XFF00

rank2:			.quad	0XFF000000000000

full_depth_moves:	.long	4

reduction_limit:	.long	3

_evaluatePieceJumpTable:
	.quad	_evaluateWhitePawn
	.quad	_evaluateWhiteKnight
	.quad	_evaluateWhiteBishop
	.quad	_evaluateWhiteRook
	.quad	_evaluateSwitchEnd
	.quad	_evaluateWhiteKing
	.quad	_evaluateBlackPawn
	.quad	_evaluateBlackKnight
	.quad	_evaluateBlackBishop
	.quad	_evaluateBlackRook
	.quad	_evaluateSwitchEnd
	.quad	_evaluateBlackKing


# bishop relevant occupancy bit count for every square on board
bishop_relevant_bits:
	.long	6
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	6
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	7
	.long	7
	.long	7
	.long	7
	.long	5
	.long	5
	.long	5
	.long	5
	.long	7
	.long	9
	.long	9
	.long	7
	.long	5
	.long	5
	.long	5
	.long	5
	.long	7
	.long	9
	.long	9
	.long	7
	.long	5
	.long	5
	.long	5
	.long	5
	.long	7
	.long	7
	.long	7
	.long	7
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	6
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	5
	.long	6

# rook relevant occupancy bit count for every square on board
rook_relevant_bits:
	.long	12
	.long	11
	.long	11
	.long	11
	.long	11
	.long	11
	.long	11
	.long	12
	.long	11
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	11
	.long	11
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	11
	.long	11
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	11
	.long	11
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	11
	.long	11
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	11
	.long	11
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	10
	.long	11
	.long	12
	.long	11
	.long	11
	.long	11
	.long	11
	.long	11
	.long	11
	.long	12

# bishop magic numbers
bishop_magic_numbers:
    .quad   0x40040844404084
    .quad   0x2004208a004208
    .quad   0x10190041080202
    .quad   0x108060845042010
    .quad   0x581104180800210
    .quad   0x2112080446200010
    .quad   0x1080820820060210
    .quad   0x3c0808410220200
    .quad   0x4050404440404
    .quad   0x21001420088
    .quad   0x24d0080801082102
    .quad   0x1020a0a020400
    .quad   0x40308200402
    .quad   0x4011002100800
    .quad   0x401484104104005
    .quad   0x801010402020200
    .quad   0x400210c3880100
    .quad   0x404022024108200
    .quad   0x810018200204102
    .quad   0x4002801a02003
    .quad   0x85040820080400
    .quad   0x810102c808880400
    .quad   0xe900410884800
    .quad   0x8002020480840102
    .quad   0x220200865090201
    .quad   0x2010100a02021202
    .quad   0x152048408022401
    .quad   0x20080002081110
    .quad   0x4001001021004000
    .quad   0x800040400a011002
    .quad   0xe4004081011002
    .quad   0x1c004001012080
    .quad   0x8004200962a00220
    .quad   0x8422100208500202
    .quad   0x2000402200300c08
    .quad   0x8646020080080080
    .quad   0x80020a0200100808
    .quad   0x2010004880111000
    .quad   0x623000a080011400
    .quad   0x42008c0340209202
    .quad   0x209188240001000
    .quad   0x400408a884001800
    .quad   0x110400a6080400
    .quad   0x1840060a44020800
    .quad   0x90080104000041
    .quad   0x201011000808101
    .quad   0x1a2208080504f080
    .quad   0x8012020600211212
    .quad   0x500861011240000
    .quad   0x180806108200800
    .quad   0x4000020e01040044
    .quad   0x300000261044000a
    .quad   0x802241102020002
    .quad   0x20906061210001
    .quad   0x5a84841004010310
    .quad   0x4010801011c04
    .quad   0xa010109502200
    .quad   0x4a02012000
    .quad   0x500201010098b028
    .quad   0x8040002811040900
    .quad   0x28000010020204
    .quad   0x6000020202d0240
    .quad   0x8918844842082200
    .quad   0x4010011029020020

# rook magic numbers
rook_magic_numbers:
    .quad   0x8a80104000800020
    .quad   0x140002000100040
    .quad   0x2801880a0017001
    .quad   0x100081001000420
    .quad   0x200020010080420
    .quad   0x3001c0002010008
    .quad   0x8480008002000100
    .quad   0x2080088004402900
    .quad   0x800098204000
    .quad   0x2024401000200040
    .quad   0x100802000801000
    .quad   0x120800800801000
    .quad   0x208808088000400
    .quad   0x2802200800400
    .quad   0x2200800100020080
    .quad   0x801000060821100
    .quad   0x80044006422000
    .quad   0x100808020004000
    .quad   0x12108a0010204200
    .quad   0x140848010000802
    .quad   0x481828014002800
    .quad   0x8094004002004100
    .quad   0x4010040010010802
    .quad   0x20008806104
    .quad   0x100400080208000
    .quad   0x2040002120081000
    .quad   0x21200680100081
    .quad   0x20100080080080
    .quad   0x2000a00200410
    .quad   0x20080800400
    .quad   0x80088400100102
    .quad   0x80004600042881
    .quad   0x4040008040800020
    .quad   0x440003000200801
    .quad   0x4200011004500
    .quad   0x188020010100100
    .quad   0x14800401802800
    .quad   0x2080040080800200
    .quad   0x124080204001001
    .quad   0x200046502000484
    .quad   0x480400080088020
    .quad   0x1000422010034000
    .quad   0x30200100110040
    .quad   0x100021010009
    .quad   0x2002080100110004
    .quad   0x202008004008002
    .quad   0x20020004010100
    .quad   0x2048440040820001
    .quad   0x101002200408200
    .quad   0x40802000401080
    .quad   0x4008142004410100
    .quad   0x2060820c0120200
    .quad   0x1001004080100
    .quad   0x20c020080040080
    .quad   0x2935610830022400
    .quad   0x44440041009200
    .quad   0x280001040802101
    .quad   0x2100190040002085
    .quad   0x80c0084100102001
    .quad   0x4024081001000421
    .quad   0x20030a0244872
    .quad   0x12001008414402
    .quad   0x2006104900a0804
    .quad   0x1004081002402

# castling rights update constants
castling_rights:
	.long	7
	.long	15
	.long	15
	.long	15
	.long	3
	.long	15
	.long	15
	.long	11
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	15
	.long	13
	.long	15
	.long	15
	.long	15
	.long	12
	.long	15
	.long	15
	.long	14

# score of every piece
#	 ♙ =   100   = ♙
#    ♘ =   300   = ♙ * 3
#    ♗ =   350   = ♙ * 3 + ♙ * 0.5
#    ♖ =   500   = ♙ * 5
#    ♕ =   1000  = ♙ * 10
#    ♔ =   10000 = ♙ * 100
material_score:
	.long	100
	.long	300
	.long	350
	.long	500
	.long	1000
	.long	10000
	.long	-100
	.long	-300
	.long	-350
	.long	-500
	.long	-1000
	.long	-10000
	
# score for every square for pawns (better positioning)
pawn_score:
	.long	90
	.long	90
	.long	90
	.long	90
	.long	90
	.long	90
	.long	90
	.long	90
	.long	30
	.long	30
	.long	30
	.long	40
	.long	40
	.long	30
	.long	30
	.long	30
	.long	20
	.long	20
	.long	20
	.long	30
	.long	30
	.long	30
	.long	20
	.long	20
	.long	10
	.long	10
	.long	10
	.long	20
	.long	20
	.long	10
	.long	10
	.long	10
	.long	5
	.long	5
	.long	10
	.long	20
	.long	20
	.long	5
	.long	5
	.long	5
	.long	0
	.long	0
	.long	0
	.long	5
	.long	5
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	-10
	.long	-10
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0

# score for every square for knighs (better positioning)
knight_score:
	.long	-5
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	-5
	.long	-5
	.long	0
	.long	0
	.long	10
	.long	10
	.long	0
	.long	0
	.long	-5
	.long	-5
	.long	5
	.long	20
	.long	20
	.long	20
	.long	20
	.long	5
	.long	-5
	.long	-5
	.long	10
	.long	20
	.long	30
	.long	30
	.long	20
	.long	10
	.long	-5
	.long	-5
	.long	10
	.long	20
	.long	30
	.long	30
	.long	20
	.long	10
	.long	-5
	.long	-5
	.long	5
	.long	20
	.long	10
	.long	10
	.long	20
	.long	5
	.long	-5
	.long	-5
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	-5
	.long	-5
	.long	-10
	.long	0
	.long	0
	.long	0
	.long	0
	.long	-10
	.long	-5

# score for every square for bishops (better positioning)
bishop_score:
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	10
	.long	10
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	10
	.long	20
	.long	20
	.long	10
	.long	0
	.long	0
	.long	0
	.long	0
	.long	10
	.long	20
	.long	20
	.long	10
	.long	0
	.long	0
	.long	0
	.long	10
	.long	0
	.long	0
	.long	0
	.long	0
	.long	10
	.long	0
	.long	0
	.long	30
	.long	0
	.long	0
	.long	0
	.long	0
	.long	30
	.long	0
	.long	0
	.long	0
	.long	-10
	.long	0
	.long	0
	.long	-10
	.long	0
	.long	0

# score for every square for rooks (better positioning)
rook_score:
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	50
	.long	0
	.long	0
	.long	10
	.long	20
	.long	20
	.long	10
	.long	0
	.long	0
	.long	0
	.long	0
	.long	10
	.long	20
	.long	20
	.long	10
	.long	0
	.long	0
	.long	0
	.long	0
	.long	10
	.long	20
	.long	20
	.long	10
	.long	0
	.long	0
	.long	0
	.long	0
	.long	10
	.long	20
	.long	20
	.long	10
	.long	0
	.long	0
	.long	0
	.long	0
	.long	10
	.long	20
	.long	20
	.long	10
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	20
	.long	20
	.long	0
	.long	0
	.long	0

# score for every square for king (better positioning)
king_score:
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	5
	.long	5
	.long	5
	.long	5
	.long	0
	.long	0
	.long	0
	.long	5
	.long	5
	.long	10
	.long	10
	.long	5
	.long	5
	.long	0
	.long	0
	.long	5
	.long	10
	.long	20
	.long	20
	.long	10
	.long	5
	.long	0
	.long	0
	.long	5
	.long	10
	.long	20
	.long	20
	.long	10
	.long	5
	.long	0
	.long	0
	.long	0
	.long	5
	.long	10
	.long	10
	.long	5
	.long	0
	.long	0
	.long	0
	.long	5
	.long	5
	.long	-5
	.long	-5
	.long	0
	.long	5
	.long	0
	.long	0
	.long	0
	.long	5
	.long	0
	.long	-15
	.long	0
	.long	10
	.long	0


# fwef
mirror_score:
	.long	56
	.long	57
	.long	58
	.long	59
	.long	60
	.long	61
	.long	62
	.long	63
	.long	48
	.long	49
	.long	50
	.long	51
	.long	52
	.long	53
	.long	54
	.long	55
	.long	40
	.long	41
	.long	42
	.long	43
	.long	44
	.long	45
	.long	46
	.long	47
	.long	32
	.long	33
	.long	34
	.long	35
	.long	36
	.long	37
	.long	38
	.long	39
	.long	24
	.long	25
	.long	26
	.long	27
	.long	28
	.long	29
	.long	30
	.long	31
	.long	16
	.long	17
	.long	18
	.long	19
	.long	20
	.long	21
	.long	22
	.long	23
	.long	8
	.long	9
	.long	10
	.long	11
	.long	12
	.long	13
	.long	14
	.long	15
	.long	0
	.long	1
	.long	2
	.long	3
	.long	4
	.long	5
	.long	6
	.long	7

# MVV LVA [attacker][victim] (pieces)
mvv_lva:
	.long	105
	.long	205
	.long	305
	.long	405
	.long	505
	.long	605
	.long	105
	.long	205
	.long	305
	.long	405
	.long	505
	.long	605
	.long	104
	.long	204
	.long	304
	.long	404
	.long	504
	.long	604
	.long	104
	.long	204
	.long	304
	.long	404
	.long	504
	.long	604
	.long	103
	.long	203
	.long	303
	.long	403
	.long	503
	.long	603
	.long	103
	.long	203
	.long	303
	.long	403
	.long	503
	.long	603
	.long	102
	.long	202
	.long	302
	.long	402
	.long	502
	.long	602
	.long	102
	.long	202
	.long	302
	.long	402
	.long	502
	.long	602
	.long	101
	.long	201
	.long	301
	.long	401
	.long	501
	.long	601
	.long	101
	.long	201
	.long	301
	.long	401
	.long	501
	.long	601
	.long	100
	.long	200
	.long	300
	.long	400
	.long	500
	.long	600
	.long	100
	.long	200
	.long	300
	.long	400
	.long	500
	.long	600
	.long	105
	.long	205
	.long	305
	.long	405
	.long	505
	.long	605
	.long	105
	.long	205
	.long	305
	.long	405
	.long	505
	.long	605
	.long	104
	.long	204
	.long	304
	.long	404
	.long	504
	.long	604
	.long	104
	.long	204
	.long	304
	.long	404
	.long	504
	.long	604
	.long	103
	.long	203
	.long	303
	.long	403
	.long	503
	.long	603
	.long	103
	.long	203
	.long	303
	.long	403
	.long	503
	.long	603
	.long	102
	.long	202
	.long	302
	.long	402
	.long	502
	.long	602
	.long	102
	.long	202
	.long	302
	.long	402
	.long	502
	.long	602
	.long	101
	.long	201
	.long	301
	.long	401
	.long	501
	.long	601
	.long	101
	.long	201
	.long	301
	.long	401
	.long	501
	.long	601
	.long	100
	.long	200
	.long	300
	.long	400
	.long	500
	.long	600
	.long	100
	.long	200
	.long	300
	.long	400
	.long	500
	.long	600

# ascii pieces
ascii_pieces: .ascii "PNBRQKpnbrqk"

# promoted pieces
promoted_pieces:
	.asciz	""
	.asciz	"nbrq"
	.asciz	""
	.ascii	"nbrq"

# char pieces
char_pieces:
	.zero	264
	.long	2
	.zero	32
	.long	5
	.zero	8
	.long	1
	.zero	4
	.long	0
	.long	4
	.long	3
	.zero	60
	.long	8
	.zero	32
	.long	11
	.zero	8
	.long	7
	.zero	4
	.long	6
	.long	10
	.long	9


_printStrRank:              .asciz  "  %u "
_printStrFiles:        		.asciz  "\n     a  b  c  d  e  f  g  h\n"
_printStrFilesBlack:        .asciz  "\n     h  g  f  e  d  c  b  a\n"
_printStrBit:               .asciz  " %u"
_printBitboardStrBitboard:  .asciz  "     Bitboard: %llud\n\n"
_printBoardStrNoPiece:      .asciz	" "
_printBoardStrPiece:        .asciz  "%s %s %s"
_printBoardStrSideWhite:    .asciz	"white"
_printBoardStrSideBlack:    .asciz	"black"
_printBoardStrSide:         .asciz	"     Side:      %s\n"
_printBoardStrNoSq:         .asciz	"no_sq"
_printBoardStrEnpassant:    .asciz	"     Enpassant: %s\n"
_printBoardStrCastling:     .asciz	"     Castling:  %c%c%c%c\n\n"
_printMoveStrPromoted:		.asciz	"%s%s%c"
_printMoveStrNoPromoted:	.asciz	"%s%s"
_perftTestStrIntro:			.asciz	"     Performance test\n"
_perftTestBranchStr:		.asciz	"     move: %s%s%c  nodes: %ld\n"
_perftTestStrDepth: 		.asciz	"\n    Depth: %d\n"
_perftTestStrNodes:			.asciz	"    Nodes: %lld\n"
_printMoveScoresIntroStr:	.asciz	"     Move scores:\n"
_printMoveScoresMoveStr:	.asciz	"     move: "
_printMoveScoresScoreStr:	.asciz	" score: %d\n"
_printMovePromotionStr:		.asciz	"%s%s%c"
_printMoveMoveStr:			.asciz	"%s%s"
_ansiCyan:					.asciz	"\x1b[30;46m"
_ansiWhite:					.asciz	"\x1b[30;47m"
_ansiOff:					.asciz	"\x1b[0m"
_uci_depth:					.asciz	"depth"
uci_startpos:				.asciz	"startpos"
uci_fen:					.asciz	"fen"
uci_bestmove:				.asciz 	"bestmove "
uci_name:					.asciz	"id name Witek Cybulski"
uci_ok:						.asciz	"readyok"
uci_isready:				.asciz 	"isready"
uci_position:				.asciz	"position"
uci_quit:					.asciz 	"quit"
uci_q:						.asciz	"q"
uci_move:					.asciz	"move"
_uci_win:					.asciz 	"Congratulations! You beat the engine!"
_uci_moves:					.asciz 	"moves"
_uci_moves_illegal:			.asciz 	"One or move moves is illegal!\n"
_uci_move_illegal:			.asciz 	"This move is illegal!\n"
uci_go:						.asciz	"go"
uci_flip:					.asciz 	"flip"
uci_reset_teminal:			.asciz	"\033[H\033[2J"
_printInfoScore:			.asciz	"info score cp %d depth %d nodes %ld pv "
_printBestmove:				.asciz	"bestmove "

# --------------------------------------------

# system constants
.equ READ, 0
.equ WRITE, 1
.equ EXIT, 60

.equ max_ply, 64

.equ STDIN, 0
.equ STDOUT, 1

# side constants
.equ white, 0
.equ black, 1
.equ both, 2

# move flags
.equ all_moves, 0
.equ captures, 1

# pieces constants
.equ P, 0
.equ N, 1
.equ B, 2
.equ R, 3
.equ Q, 4
.equ K, 5
.equ p, 6
.equ n, 7
.equ b, 8
.equ r, 9
.equ q, 10
.equ k, 11
.equ no_piece, 12

# castling rights
.equ wk, 1
.equ wq, 2
.equ bk, 4
.equ bq, 8

# squares constants
.equ a8, 0
.equ b8, 1
.equ c8, 2
.equ d8, 3
.equ e8, 4
.equ f8, 5
.equ g8, 6
.equ h8, 7
.equ a7, 8
.equ b7, 9
.equ c7, 10
.equ d7, 11
.equ e7, 12
.equ f7, 13
.equ g7, 14
.equ h7, 15
.equ a6, 16
.equ b6, 17
.equ c6, 18
.equ d6, 19
.equ e6, 20
.equ f6, 21
.equ g6, 22
.equ h6, 23
.equ a5, 24
.equ b5, 25
.equ c5, 26
.equ d5, 27
.equ e5, 28
.equ f5, 29
.equ g5, 30
.equ h5, 31
.equ a4, 32
.equ b4, 33
.equ c4, 34
.equ d4, 35
.equ e4, 36
.equ f4, 37
.equ g4, 38
.equ h4, 39
.equ a3, 40
.equ b3, 41
.equ c3, 42
.equ d3, 43
.equ e3, 44
.equ f3, 45
.equ g3, 46
.equ h3, 47
.equ a2, 48
.equ b2, 49
.equ c2, 50
.equ d2, 51
.equ e2, 52
.equ f2, 53
.equ g2, 54
.equ h2, 55
.equ a1, 56
.equ b1, 57
.equ c1, 58
.equ d1, 59
.equ e1, 60
.equ f1, 61
.equ g1, 62
.equ h1, 63
.equ no_sq, 64
