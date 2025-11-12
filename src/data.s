# initialised variables
.data

# unicode pieces
_unicode_piece_0:   .asciz	"\342\231\231"
_unicode_piece_1:   .asciz	"\342\231\230"
_unicode_piece_2:   .asciz	"\342\231\227"
_unicode_piece_3:   .asciz	"\342\231\226"
_unicode_piece_4:   .asciz	"\342\231\225"
_unicode_piece_5:   .asciz	"\342\231\224"

_unicode_piece_6:   .asciz	"\342\231\237\357\270\216"
_unicode_piece_7:   .asciz	"\342\231\236"
_unicode_piece_8:   .asciz	"\342\231\235"
_unicode_piece_9:   .asciz	"\342\231\234"
_unicode_piece_10:  .asciz	"\342\231\233"
_unicode_piece_11:  .asciz	"\342\231\232"

unicode_pieces:
	.quad	_unicode_piece_0
	.quad	_unicode_piece_1
	.quad	_unicode_piece_2
	.quad	_unicode_piece_3
	.quad	_unicode_piece_4
	.quad	_unicode_piece_5
	.quad	_unicode_piece_6
	.quad	_unicode_piece_7
	.quad	_unicode_piece_8
	.quad	_unicode_piece_9
	.quad	_unicode_piece_10
	.quad	_unicode_piece_11

_coord_0:   .asciz	"a8"
_coord_1:   .asciz	"b8"
_coord_2:   .asciz	"c8"
_coord_3:   .asciz	"d8"
_coord_4:   .asciz	"e8"
_coord_5:   .asciz	"f8"
_coord_6:   .asciz	"g8"
_coord_7:   .asciz	"h8"
_coord_8:   .asciz	"a7"
_coord_9:   .asciz	"b7"
_coord_10:  .asciz	"c7"
_coord_11:  .asciz	"d7"
_coord_12:  .asciz	"e7"
_coord_13:  .asciz	"f7"
_coord_14:  .asciz	"g7"
_coord_15:  .asciz	"h7"
_coord_16:  .asciz	"a6"
_coord_17:  .asciz	"b6"
_coord_18:  .asciz	"c6"
_coord_19:  .asciz	"d6"
_coord_20:  .asciz	"e6"
_coord_21:  .asciz	"f6"
_coord_22:  .asciz	"g6"
_coord_23:  .asciz	"h6"
_coord_24:  .asciz	"a5"
_coord_25:  .asciz	"b5"
_coord_26:  .asciz	"c5"
_coord_27:  .asciz	"d5"
_coord_28:  .asciz	"e5"
_coord_29:  .asciz	"f5"
_coord_30:  .asciz	"g5"
_coord_31:  .asciz	"h5"
_coord_32:  .asciz	"a4"
_coord_33:  .asciz	"b4"
_coord_34:  .asciz	"c4"
_coord_35:  .asciz	"d4"
_coord_36:  .asciz	"e4"
_coord_37:  .asciz	"f4"
_coord_38:  .asciz	"g4"
_coord_39:  .asciz	"h4"
_coord_40:  .asciz	"a3"
_coord_41:  .asciz	"b3"
_coord_42:  .asciz	"c3"
_coord_43:  .asciz	"d3"
_coord_44:  .asciz	"e3"
_coord_45:  .asciz	"f3"
_coord_46:  .asciz	"g3"
_coord_47:  .asciz	"h3"
_coord_48:  .asciz	"a2"
_coord_49:  .asciz	"b2"
_coord_50:  .asciz	"c2"
_coord_51:  .asciz	"d2"
_coord_52:  .asciz	"e2"
_coord_53:  .asciz	"f2"
_coord_54:  .asciz	"g2"
_coord_55:  .asciz	"h2"
_coord_56:  .asciz	"a1"
_coord_57:  .asciz	"b1"
_coord_58:  .asciz	"c1"
_coord_59:  .asciz	"d1"
_coord_60:  .asciz	"e1"
_coord_61:  .asciz	"f1"
_coord_62:  .asciz	"g1"
_coord_63:  .asciz	"h1"

square_to_coordinates:
	.quad	_coord_0
	.quad	_coord_1
	.quad	_coord_2
	.quad	_coord_3
	.quad	_coord_4
	.quad	_coord_5
	.quad	_coord_6
	.quad	_coord_7
	.quad	_coord_8
	.quad	_coord_9
	.quad	_coord_10
	.quad	_coord_11
	.quad	_coord_12
	.quad	_coord_13
	.quad	_coord_14
	.quad	_coord_15
	.quad	_coord_16
	.quad	_coord_17
	.quad	_coord_18
	.quad	_coord_19
	.quad	_coord_20
	.quad	_coord_21
	.quad	_coord_22
	.quad	_coord_23
	.quad	_coord_24
	.quad	_coord_25
	.quad	_coord_26
	.quad	_coord_27
	.quad	_coord_28
	.quad	_coord_29
	.quad	_coord_30
	.quad	_coord_31
	.quad	_coord_32
	.quad	_coord_33
	.quad	_coord_34
	.quad	_coord_35
	.quad	_coord_36
	.quad	_coord_37
	.quad	_coord_38
	.quad	_coord_39
	.quad	_coord_40
	.quad	_coord_41
	.quad	_coord_42
	.quad	_coord_43
	.quad	_coord_44
	.quad	_coord_45
	.quad	_coord_46
	.quad	_coord_47
	.quad	_coord_48
	.quad	_coord_49
	.quad	_coord_50
	.quad	_coord_51
	.quad	_coord_52
	.quad	_coord_53
	.quad	_coord_54
	.quad	_coord_55
	.quad	_coord_56
	.quad	_coord_57
	.quad	_coord_58
	.quad	_coord_59
	.quad	_coord_60
	.quad	_coord_61
	.quad	_coord_62
	.quad	_coord_63
