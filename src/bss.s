# uninitialised data, variables
.bss

# piece bitboards (12 * 8) [pawn, knight, bishop, rook, queen, king] * 2 colors
bitboards:      .zero	96

# occupancy bitboards (3 * 8) [white, black, both]
occupancies:    .zero   24

# side to move [white = 0, black = 1, (both = 2)]
side:           .zero   4

# enpassant square [0 - 64] (64 = no_square)
enpassant:      .zero   4

# castling rights (0000 - white king side, white queen side, 
#                    black king side, black queen side)
castle:         .zero   4

# specifies if the board shold be printed fliped
fliped:         .zero   1

# pawn attack bitboards for every square (both sides) (2 * 64 * 8)
pawn_attacks:   .zero	1024

# knight attacks bitboards for every suare (64 * 8)
knight_attacks: .zero	512

# king attacks bitboards for every suare (64 * 8)
king_attacks:   .zero	512

# bishop attacks bitboards for every square (no occupancy) (64 * 8)
bishop_masks:   .zero   512

# rook attacks bitboards for every square (no occupancy) (64 * 8)
rook_masks:     .zero   512

# bishop attack table [square][occupancy]
bishop_attacks: .zero   262144

# rook attack table [square][occupancy]
rook_attacks:   .zero   2097152

# leaf nodes (number of positions reached during the test of the move generator at a given depth)
nodes:          .zero   8

# half move counter
ply:            .zero   4

# PV length [ply] (max_ply(64) * 4)
pv_length:      .zero   256

# PV table [ply][ply] (max_ply(64) * max_ply(64) * 4)
pv_table:       .zero   16384

# follow PV flag
follow_pv:      .zero   4

# score PV move flag
score_pv:       .zero   4

# history moves [piece][square]
history_moves:  .zero	3072

# killer moves [id][ply]
killer_moves:   .zero	512



