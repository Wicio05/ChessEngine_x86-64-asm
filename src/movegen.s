.text

# checks if any of the pieces in the current position attacks given square
# 2 arguments: (1) 4-byte square, (2) 4-byte side
# returns 4-byte
isSquareAttacked:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp
	
	# make space on stack
	subq	$8, %rsp

	# store args on the stack
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)

_isSquareAttackedPawnWhite:
	# check if side is white
	cmpl	$white, -8(%rbp)
	jne	_isSquareAttackedPawnBlack

	# get black pawn mask
	movl	-4(%rbp), %eax
	addq	$64, %rax
	leaq	0(,%rax,8), %rdx
	leaq	pawn_attacks, %rax
	movq	(%rdx,%rax), %rdx

	# white pawn bitboard
	movq	bitboards, %rax
	andq	%rdx, %rax

	# check if white pawns in black mask
	testq	%rax, %rax
	je		_isSquareAttackedPawnBlack
	
	# return positive
	movl	$1, %eax
	jmp		_isSquareAttackedEnd

_isSquareAttackedPawnBlack:
	# check if side is black
	cmpl	$black, -8(%rbp)
	jne		_isSquareAttackedKnight
	
	# get white pawn mask
	movl	-4(%rbp), %eax
	leaq	0(,%rax,8), %rdx
	leaq	pawn_attacks, %rax
	movq	(%rdx,%rax), %rdx

	# black pawn bitboard
	movq	48+bitboards, %rax
	andq	%rdx, %rax

	# check if black pawns in white mask
	testq	%rax, %rax
	je		_isSquareAttackedKnight

	# return positive
	movl	$1, %eax
	jmp	_isSquareAttackedEnd

_isSquareAttackedKnight:
	# get knight attack mask 
	movl	-4(%rbp), %eax
	leaq	0(,%rax,8), %rdx
	leaq	knight_attacks, %rax
	movq	(%rdx,%rax), %rdx

	# check if side is white
	cmpl	$white, -8(%rbp)
	jne		_isSquareAttackedKnightBlack

	# white knight
	movq	8+bitboards, %rax
	jmp		_isSquareAttackedKnightAt
	
_isSquareAttackedKnightBlack:
	# black knight
	movq	56+bitboards, %rax

_isSquareAttackedKnightAt:
	# check knight in the mask
	andq	%rdx, %rax
	testq	%rax, %rax
	je	_isSquareAttackedBishop

	# return positive
	movl	$1, %eax
	jmp	_isSquareAttackedEnd

_isSquareAttackedBishop:
	# get bishop attack mask
	movq	16+occupancies, %rsi
	movl	-4(%rbp), %edi
	call	getBishopAttacks

	movq	%rax, %rdx

	# check if side is white
	cmpl	$white, -8(%rbp)
	jne		_isSquareAttackedBishopBlack

	# white bishop
	movq	16+bitboards, %rax
	jmp	_isSquareAttackedBishopAt

_isSquareAttackedBishopBlack:
	# black bishop
	movq	64+bitboards, %rax

_isSquareAttackedBishopAt:
	# check bishop in the mask
	andq	%rdx, %rax
	testq	%rax, %rax
	je		_isSquareAttackedRook

	# return positive
	movl	$1, %eax
	jmp		_isSquareAttackedEnd

_isSquareAttackedRook:
	# get rook attack mask
	movq	16+occupancies, %rsi
	movl	-4(%rbp), %edi
	call	getRookAttacks

	movq	%rax, %rdx

	# check if side is white
	cmpl	$white, -8(%rbp)
	jne	    _isSquareAttackedRookBlack

	# white rook
	movq	24+bitboards, %rax
	jmp	    _isSquareAttackedRookAt

_isSquareAttackedRookBlack:	
	# black rook
	movq	72+bitboards, %rax

_isSquareAttackedRookAt:
	# check rook in the mask
	andq	%rdx, %rax
	testq	%rax, %rax
	je	    _isSquareAttackedQueen

	# return positive
	movl	$1, %eax
	jmp	    _isSquareAttackedEnd

_isSquareAttackedQueen:
	# get queen attack mask
	movq	16+occupancies, %rsi
	movl	-4(%rbp), %edi
	call	getQueenAttacks

	movq	%rax, %rdx

	# check if side is white
	cmpl	$white, -8(%rbp)
	jne		_isSquareAttackedQueenBlack

	# white queen
	movq	32+bitboards, %rax
	jmp		_isSquareAttackedQueenAt

_isSquareAttackedQueenBlack:
	# black queen
	movq	80+bitboards, %rax

_isSquareAttackedQueenAt:
	# check queen in the mask
	andq	%rdx, %rax
	testq	%rax, %rax
	je		_isSquareAttackedKing

	# return positive
	movl	$1, %eax
	jmp		_isSquareAttackedEnd

_isSquareAttackedKing:
	# get king attack mask
	movl	-4(%rbp), %eax
	leaq	0(,%rax,8), %rdx
	leaq	king_attacks, %rax
	movq	(%rdx,%rax), %rdx

	# check if side is white
	cmpl	$white, -8(%rbp)
	jne	    _isSquareAttackedKingBlack

	# white king
	movq	40+bitboards, %rax
	jmp	    _isSquareAttackedKingAt

_isSquareAttackedKingBlack:	
	# black king
	movq	88+bitboards, %rax

_isSquareAttackedKingAt:
	# check king in the mask
	andq	%rdx, %rax
	testq	%rax, %rax
	je	_isSquareAttackedFalse
	
	# return positive
	movl	$1, %eax
	jmp	_isSquareAttackedEnd

_isSquareAttackedFalse:
	# return negative
	movl	$0, %eax

_isSquareAttackedEnd:
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# prints attacked squares in the current position by the given side with rank and file markings
# (1) argument: (1) 4-byte side
# returns void
printAttackedSquares:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # allocate memory on the stack
    subq	$8, %rsp
	movl	%edi, -8(%rbp)

    # print new line char ('\n')
	movl    $10, %edi
	call    putchar

    # init rank at 0
    movb    $0, -1(%rbp)

    # loop over 8 ranks
_printAttackedSquaresRankLoopBeg:
    cmpb    $8, -1(%rbp)
	jae     _printAttackedSquaresRankLoopEnd

    # init file at 0
    movb    $0, -2(%rbp)

    # loop over 8 files
_printAttackedSquaresFileLoopBeg:
    cmpb    $8, -2(%rbp)
	jae     _printAttackedSquaresFileLoopEnd

    # calculate square
    movb    -1(%rbp), %al
    shlb    $3, %al
    addb    -2(%rbp), %al
    movb    %al, -3(%rbp)

    # check if begining of file
_printAttackedSquaresNotFileIf:
    cmpb    $0, -2(%rbp)
    jne      _printAttackedSquaresNotFileIfEnd

    # calculate rank marking
    movzbl  -1(%rbp), %edx
    movl    $8, %eax
    subl    %edx, %eax

    # print rank marking
    movl    %eax, %esi
    movq    $_printStrRank, %rdi
    movq    $0, %rax
    call    printf

_printAttackedSquaresNotFileIfEnd:
    movzbl  -3(%rbp), %edi
    movl    -8(%rbp), %esi
    call    isSquareAttacked

    # print bit
    movl    %eax, %esi
    movq    $_printStrBit, %rdi
    movq    $0, %rax
    call    printf

    # increment file 
    incb    -2(%rbp)

    # repeat file loop
    jmp     _printAttackedSquaresFileLoopBeg

_printAttackedSquaresFileLoopEnd:
    # print new line char ('\n')
	movl    $10, %edi
	call    putchar

    #increment rank
    incb    -1(%rbp)

    # repeat rank loop
    jmp     _printAttackedSquaresRankLoopBeg

_printAttackedSquaresRankLoopEnd:
    # print file markings
    movq    $_printStrFiles, %rdi
    call    puts

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# MOVELIST
# make place on the stack (255 * 4 + 1 * 4) 
# subq	$1024, %rsp
# 
# init count at 0
# movl      $0, -4(%rbp)
# movl	    -4(%rbp), %eax
# 
#
# insert 1 at position count (-1024 - first element in the array offset,
#                    %rax - count, 4 - size in bytes of each element) 
# movl	    $1, -1024(%rbp,%rax,4)
#
# increment count
# incl      -4(%rbp)

# adds encoded move to the movelist
# 2 arguments: (1) movelist address, (2) encoderd move
# returns void
addMove:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp
	
    # get count
    movl    1024(%rdi), %edx

    # add move on positino count
    movl    %esi, (%rdi, %rdx, 4)

    # increment count
    incl    1024(%rdi)
	
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp
	ret

# --------------------------------------------

# makes move on the chess board
# 2 arguments: (1) 4-byte encoded move, (2) move flag [all moves, captures]
# returns 4-byte (1 legal move, 0 illegal move)
makeMove:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp
	
	# preserve calle saved register
	pushq	%rbx

	# make space on the stack
	subq	$216, %rsp

	# store args on the stack
	movl	%edi, -212(%rbp)
	movl	%esi, -216(%rbp)

	# check if only captures or all moves flag
	cmpl	$all_moves, -216(%rbp)
	jne		_makeMoveOnlyCaptures

	# preserve bitboards
	movq	bitboards, %rax
	movq	8+bitboards, %rdx
	movq	%rax, -208(%rbp)
	movq	%rdx, -200(%rbp)
	movq	16+bitboards, %rax
	movq	24+bitboards, %rdx
	movq	%rax, -192(%rbp)
	movq	%rdx, -184(%rbp)
	movq	32+bitboards, %rax
	movq	40+bitboards, %rdx
	movq	%rax, -176(%rbp)
	movq	%rdx, -168(%rbp)
	movq	48+bitboards, %rax
	movq	56+bitboards, %rdx
	movq	%rax, -160(%rbp)
	movq	%rdx, -152(%rbp)
	movq	64+bitboards, %rax
	movq	72+bitboards, %rdx
	movq	%rax, -144(%rbp)
	movq	%rdx, -136(%rbp)
	movq	80+bitboards, %rax
	movq	88+bitboards, %rdx
	movq	%rax, -128(%rbp)
	movq	%rdx, -120(%rbp)

	# preserve occupancies
	movq	occupancies, %rax
	movq	8+occupancies, %rdx
	movq	%rax, -112(%rbp)
	movq	%rdx, -104(%rbp)
	movq	16+occupancies, %rax
	movq	%rax, -96(%rbp)

	# preserve side
	movl	side, %eax
	movl	%eax, -40(%rbp)

	# preserve enpassant
	movl	enpassant, %eax
	movl	%eax, -44(%rbp)

	# preserve castling rights
	movl	castle, %eax
	movl	%eax, -48(%rbp)


	# get src square
	movl	-212(%rbp), %edi
	call	getMoveSrc

	# store src square
	movl	%eax, -52(%rbp)

	# get target square
	movl	-212(%rbp), %edi
	call	getMoveTrg

	# strore target square
	movl	%eax, -56(%rbp)

	# get move piece
	movl	-212(%rbp), %edi
	call 	getMovePiece

	# store piece
	movl	%eax, -60(%rbp)

	# get promoted piece
	movl	-212(%rbp), %edi
	call	getMovePromoted

	# store promoted piece
	movl	%eax, -64(%rbp)

	# get capture flag
	movl	-212(%rbp), %edi
	call	getMoveCapture

	# store capture flag
	movl	%eax, -68(%rbp)

	# get double pawn push flag
	movl	-212(%rbp), %edi
	call 	getMoveDouble

	# store double pawn push flag
	movl	%eax, -72(%rbp)

	# get enpassant flag
	movl	-212(%rbp), %edi
	call	getMoveEnpassant

	# store enpassant flag
	movl	%eax, -76(%rbp)

	# get castling flag
	movl	-212(%rbp), %edi
	call 	getMoveCastling

	# store castlling flag
	movl	%eax, -80(%rbp)

	# get piece
	movl	-60(%rbp), %eax

	# get bitboard address
	leaq	bitboards, %rdx
	leaq	(%rdx,%rax,8), %rdi	# arg 1

	# get src square
	movl	-52(%rbp), %esi		# arg 2

	# remove piece from src square
	call	removeBit

	# get piece
	movl	-60(%rbp), %eax

	# get bitboard address
	leaq	bitboards, %rdx
	leaq	(%rdx,%rax,8), %rdi	# arg 1

	# get target square
	movl	-56(%rbp), %esi		# arg 2

	# set piece on target square
	call	setBit

	# check if capture move
	cmpl	$0, -68(%rbp)
	je		_makeMoveNoCapture

	# check is white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_makeMoveCaptureBlack

	# set black pawn as start piece if white to move
	movl	$p, -20(%rbp)

	# set black king as end piece if white to move
	movl	$k, -24(%rbp)

	jmp		_makeMoveCaptureLoopBeg

_makeMoveCaptureBlack:
	# set white pawn as start piece if black to move
	movl	$P, -20(%rbp)

	# set white king as end piece if black to move
	movl	$K, -24(%rbp)

	# loop over all opponent's pieces to find which piece was captured
_makeMoveCaptureLoopBeg:
	movl	-20(%rbp), %eax
	cmpl	-24(%rbp), %eax
	jg		_makeMoveNoCapture

	# get piece (loop)
	movl	-20(%rbp), %eax

	# get bitboard
	leaq	bitboards, %rdx
	movq	(%rdx,%rax,8), %rdi

	# get target square
	movl	-56(%rbp), %esi

	call 	getBit

	# check if there is a piece on target square
	testq	%rax, %rax
	je		_makeMoveCaptureLoopNext

	# get piece (loop)
	movl	-20(%rbp), %eax

	# get bitboard address
	leaq	bitboards, %rdx
	leaq	(%rdx,%rax,8), %rdi

	# get target square
	movl	-56(%rbp), %esi

	# remove opponent's piece from the bitboard
	call 	removeBit

	# exit the loop as the piece was found
	jmp		_makeMoveNoCapture

_makeMoveCaptureLoopNext:
	incl	-20(%rbp)

	jmp		_makeMoveCaptureLoopBeg

_makeMoveNoCapture:
	# check if promotion 
	cmpl	$0, -64(%rbp)
	je		_makeMoveEnpassant

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_makeMovePromotionBlack

	# get white pawn bitboard
	leaq	bitboards, %rdi

	# get target square
	movl	-56(%rbp), %esi

	# remove white pawn from target square
	call	removeBit

	jmp		_makeMovePromotionPiece

_makeMovePromotionBlack:
	# get black pawn bitboard
	leaq	48+bitboards, %rdi

	# get target square
	movl	-56(%rbp), %esi

	# remove black pawn from target square
	call	removeBit

_makeMovePromotionPiece:
	# get target square
	movl	-56(%rbp), %esi

	# get promoted piece
	movl	-64(%rbp), %eax

	# get promoted piece bitboard address
	leaq	bitboards, %rdx
	leaq	(%rdx, %rax,8), %rdi

	# place promoted piece on the board
	call	setBit

_makeMoveEnpassant:
	# check if enpassant flag is on
	cmpl	$0, -76(%rbp)
	je		_makeMoveNoEnpassant

	movl	side, %eax

	# check if side is white
	testl	%eax, %eax
	jne		_makeMoveEnpassantBlack
	
	# remove black pawn after enpassant capture
	leaq	48+bitboards, %rdi
	movl	-56(%rbp), %esi
	addl	$8, %esi
	call	removeBit

	jmp	_makeMoveNoEnpassant

_makeMoveEnpassantBlack:
	# remove white pawn after enpassant capture
	leaq	bitboards, %rdi
	movl	-56(%rbp), %esi
	subl	$8, %esi
	call 	removeBit

_makeMoveNoEnpassant:
	# reset enpassant square
	movl	$no_sq, enpassant

	# check double pawn push flag
	cmpl	$0, -72(%rbp)
	je	_makeMoveCastling

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_makeMoveDoubleBlack

	# set enpassant square closer to the 1st rank
	movl	-56(%rbp), %eax
	addl	$8, %eax
	movl	%eax, enpassant

	jmp		_makeMoveCastling

_makeMoveDoubleBlack:
	# set enpassant square closer to the 8th rank
	movl	-56(%rbp), %eax
	subl	$8, %eax
	movl	%eax, enpassant

_makeMoveCastling:
	cmpl	$0, -80(%rbp)
	je		_makeMoveCastlingEnd

	cmpl	$g1, -56(%rbp)
	je		_makeMoveCastlingWhiteKing

	cmpl	$g1, -56(%rbp)
	jg		_makeMoveCastlingEnd

	cmpl	$c1, -56(%rbp)
	je		_makeMoveCastlingWhiteQueen

	cmpl	$c1, -56(%rbp)
	jg		_makeMoveCastlingEnd

	cmpl	$c8, -56(%rbp)
	je		_makeMoveCastlingBlackQueen

	cmpl	$g8, -56(%rbp)
	je		_makeMoveCastlingBlackKing

	jmp		_makeMoveCastlingEnd

_makeMoveCastlingWhiteKing:
	# remove white rook from h1 square
	leaq	24+bitboards, %rdi
	movl	$h1, %esi
	call	removeBit

	# set white rook on f1 square
	leaq	24+bitboards, %rdi
	movl	$f1, %esi
	call	setBit

	jmp		_makeMoveCastlingEnd

_makeMoveCastlingWhiteQueen:
	# remove white rook from a1 square
	leaq	24+bitboards, %rdi
	movl	$a1, %esi
	call	removeBit

	# set white rook on d1 square
	leaq	24+bitboards, %rdi
	movl	$d1, %esi
	call	setBit

	jmp		_makeMoveCastlingEnd

_makeMoveCastlingBlackKing:
	# remove black rook from h8 square
	leaq	72+bitboards, %rdi
	movl	$h8, %esi
	call	removeBit

	# set white rook on f8 square
	leaq	72+bitboards, %rdi
	movl	$f8, %esi
	call	setBit
	
	jmp		_makeMoveCastlingEnd

_makeMoveCastlingBlackQueen:
	# remove black rook from a8 square
	leaq	72+bitboards, %rdi
	movl	$a8, %esi
	call	removeBit

	# set white rook on d8 square
	leaq	72+bitboards, %rdi
	movl	$d8, %esi
	call	setBit
	
	jmp		_makeMoveCastlingEnd
	
_makeMoveCastlingEnd:
	# get source square
	movl	-52(%rbp), %eax

	# get castling rights address
	leaq	castling_rights, %rdx

	# get castling rights based on src square
	movl	(%rdx,%rax,4), %edx

	# update castling rights 
	andl	%edx, castle


	# get target square
	movl	-56(%rbp), %eax

	# get castling rights address
	leaq	castling_rights, %rdx

	# get castling rights based on target square
	movl	(%rdx,%rax,4), %edx

	# update castling rights
	andl	%edx, castle

	# reset occupancies (set 24 bytes to 0)
	movl	$24, %edx
	movl	$0, %esi
	leaq	occupancies, %rdi
	call	memset

	# init starting piece as white pawn
	movl	$P, -32(%rbp)
_makeMoveWhiteOccupanciesLoopBeg:
	cmpl	$K, -32(%rbp)
	jg		_makeMoveWhiteOccupanciesLoopEnd

	# get piece
	movl	-32(%rbp), %eax

	# get bitboad address
	leaq	bitboards, %rdx

	# get piece bitboard value
	movq	(%rdx,%rax,8), %rax

	# add each bitboard to white occupancy
	orq		%rax, occupancies

	# increment piece
	incl	-32(%rbp)

	# repeat white piece loop
	jmp 	_makeMoveWhiteOccupanciesLoopBeg

_makeMoveWhiteOccupanciesLoopEnd:
	# init starting piece as black pawn
	movl	$p, -36(%rbp)

	# loop over all black piece bitboards
_makeMoveBlackOccupanciesLoopBeg:
	cmpl	$k, -36(%rbp)
	jg	_makeMoveBlackOccupanciesLoopEnd
	
	# get piece
	movl	-36(%rbp), %eax

	# get bitboad address
	leaq	bitboards, %rdx

	# get piece bitboard value
	movq	(%rdx,%rax,8), %rax

	# add each bitboard to black occupancy
	orq		%rax, 8+occupancies

	# increment piece
	incl	-36(%rbp)

	# repeat black piece loop
	jmp 	_makeMoveBlackOccupanciesLoopBeg

_makeMoveBlackOccupanciesLoopEnd:
	# add white occupancy to both occupancies
	movq	occupancies, %rax
	orq		%rax, 16+occupancies

	# add black occupancy to both occupancies
	movq	8+occupancies, %rax
	orq		%rax, 16+occupancies

	# change side
	xorl	$1, side
	movl	side, %ebx
	movl	side, %eax

	# check if white to move
	testl	%eax, %eax
	jne		_makeMoveKingCkeckBlack

	# get black king bitboard
	movq	88+bitboards, %rdi
	call	getLSB

	jmp	_makeMoveKingCkeck

_makeMoveKingCkeckBlack:
	# get white king bitboard
	movq	40+bitboards, %rdi
	call	getLSB

_makeMoveKingCkeck:
	# get side
	movl	%ebx, %esi

	# get king source  square
	movl	%eax, %edi

	# ckeck if king's square is under attack
	call	isSquareAttacked

	# check if king's square is under attack
	testl	%eax, %eax
	je	_makeMoveLegal

	# restore bitboards
	movq	-208(%rbp), %rax
	movq	-200(%rbp), %rdx
	movq	%rax, bitboards
	movq	%rdx, 8+bitboards
	movq	-192(%rbp), %rax
	movq	-184(%rbp), %rdx
	movq	%rax, 16+bitboards
	movq	%rdx, 24+bitboards
	movq	-176(%rbp), %rax
	movq	-168(%rbp), %rdx
	movq	%rax, 32+bitboards
	movq	%rdx, 40+bitboards
	movq	-160(%rbp), %rax
	movq	-152(%rbp), %rdx
	movq	%rax, 48+bitboards
	movq	%rdx, 56+bitboards
	movq	-144(%rbp), %rax
	movq	-136(%rbp), %rdx
	movq	%rax, 64+bitboards
	movq	%rdx, 72+bitboards
	movq	-128(%rbp), %rax
	movq	-120(%rbp), %rdx
	movq	%rax, 80+bitboards
	movq	%rdx, 88+bitboards

	# restore occupancies
	movq	-112(%rbp), %rax
	movq	-104(%rbp), %rdx
	movq	%rax, occupancies
	movq	%rdx, 8+occupancies
	movq	-96(%rbp), %rax
	movq	%rax, 16+occupancies

	# restore side
	movl	-40(%rbp), %eax
	movl	%eax, side

	# restore enpassant
	movl	-44(%rbp), %eax
	movl	%eax, enpassant

	# restore castling rights
	movl	-48(%rbp), %eax
	movl	%eax, castle

	# return illegal move
	movl	$0, %eax
	jmp	_makeMoveEnd

_makeMoveLegal:
	# return legal move
	movl	$1, %eax
	jmp	_makeMoveEnd

_makeMoveOnlyCaptures:
	# get move
	movl	-212(%rbp), %esi

	# get capture flag
	call 	getMoveCapture

	# check if capture
	testl	%eax, %eax

	# return illegal
	je		_makeMoveIllegal

	# get move
	movl	-212(%rbp), %edi
	movl	$all_moves, %esi

	# make move with all_moves flag as we know that the move is a capture
	call	makeMove

	jmp		_makeMoveEnd
	
_makeMoveIllegal:
	# return illegal
	movl	$0, %eax

_makeMoveEnd:
	# restore callee saved register
	movq	-8(%rbp), %rbx

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# populates movelist with possible moves in current position
# 1 argument: (1) movlist address
# retuns void
genMoves:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# make space on the stack
	subq	$72, %rsp

	# store movelist address
	movq	%rdi, -72(%rbp)

	# set count to 0
	movq	-72(%rbp), %rax
	movl	$0, 1024(%rax)

	# set white pawn as starting piece
	movl	$P, -20(%rbp)

	# loop over all the pieces
_genMovesPieceLoopBeg:
	cmpl	$k, -20(%rbp)
	jg		_genMovesPieceLoopEnd

	# get piece
	movl	-20(%rbp), %eax

	# get bitboard value
	leaq	bitboards, %rdx
	movq	(%rdx,%rax,8), %rax

	# copy piece bitboard
	movq	%rax, -8(%rbp)

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackPawnsAndCastling

	# check if white pawn
	cmpl	$P, -20(%rbp)
	jne		_genMovesWhiteCastling

	# loop over all the white pawns within the bitboard
_genMovesWhitePawnLoopBeg:
	# check if the bitboard copy is empty
	cmpq	$0, -8(%rbp)
	je		_genMovesPieceLoopNext

	# get next pawn's source square
	movq	-8(%rbp), %rdi
	call	getLSB

	# store source square
	movl	%eax, -24(%rbp)

	# calculate target square
	subl	$8, %eax

	# store target square
	movl	%eax, -28(%rbp)

	# check if target square is empty (there is no other piece there)
	movq	16+occupancies, %rdi
	movl	-28(%rbp), %esi
	call	getBit

	# actual check
	testq	%rax, %rax
	jne		_genMovesWhitePawnCapture

	# get source square
	movl	-24(%rbp), %ecx

	# set source square on the bitboard register
	movq	$1, %rax
	shlq	%cl, %rax

	# bit wise and with rank 7
	andq	rank7, %rax

	# check if source square is on rank 7
	testq	%rax, %rax
	je		_genMovesWhitePawnNoPromotion

	# add white pawn quiet move promotion to queen
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $Q, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add white pawn quiet move promotion to rook
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $R, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add white pawn quiet move promotion to bishop
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $B, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add white pawn quiet move promotion to knight
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $N, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 4 * 2 * 8 = 64
    addq    $64, %rsp

	jmp		_genMovesWhitePawnCapture

_genMovesWhitePawnNoPromotion:
	# add white pawn quiet move no promotion
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

	# get source square
	movl	-24(%rbp), %ecx

	# set source square on the bitboard register
	movq	$1, %rax
	shlq	%cl, %rax

	# bit wise and with rank 2
	andq	rank2, %rax

	# check if source square is on rank 2
	testq	%rax, %rax
	je	_genMovesWhitePawnCapture

	# get occupancies of all pieces (both)
	movq	16+occupancies, %rdi

	# get target square
	movl	-28(%rbp), %esi

	# substract 8 to make double pawn push for white
	subl	$8, %esi

	# get occupancy on double push square
	call	getBit

	# check if double push square is free
	testq	%rax, %rax
	jne		_genMovesWhitePawnCapture

	# add white pawn double push
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $1, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    subl    $8, %esi			# trg square to double push square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

_genMovesWhitePawnCapture:
	# get source square
	movl	-24(%rbp), %eax

	# get white pawn attack mask address
	leaq	pawn_attacks, %rdx

	# get white pawn mask attack mask value for given source square 
	movq	(%rdx,%rax,8), %rax

	# update pawn attack mask making sure there is a black piece on diagonal
	andq	8+occupancies, %rax

	# store altered pawn attack mask copy
	movq	%rax, -16(%rbp)

_genMovesWhitePawnCaptureLoopBeg:
	# chech if any possible attacks
	cmpq	$0, -16(%rbp)
	je		_genMovesWhitePawnCaptureLoopEnd

	# get attack mask copy
	movq	-16(%rbp), %rdi

	# get target square
	call	getLSB

	# store target square
	movl	%eax, -28(%rbp)

	# get source square
	movl	-24(%rbp), %ecx

	# set source square on the bitboard register
	movq	$1, %rax
	shlq	%cl, %rax

	# bit wise and with rank 7
	andq	rank7, %rax

	# check if source square is on rank 7
	testq	%rax, %rax
	je		_genMovesWhitePawnCaptureNoPromotion

	# add white pawn capture promotion to queen
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $Q, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add white pawn capture promotion to rook
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $R, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add white pawn capture promotion to bishop
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $B, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add white pawn capture promotion to knight
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $N, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 4 * 2 * 8 = 64
    addq    $64, %rsp

	jmp		_genMovesWhitePawnCaptureRemove

_genMovesWhitePawnCaptureNoPromotion:
	# add white pawn capture no promotion
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 
    addq    $16, %rsp

_genMovesWhitePawnCaptureRemove:
	# get target square
	movl	-28(%rbp), %esi

	# get white pawn attack mask copy
	leaq	-16(%rbp), %rdi

	# remove attack from the attack mask copy
	call	removeBit

	# repeat loop
	jmp 	_genMovesWhitePawnCaptureLoopBeg

_genMovesWhitePawnCaptureLoopEnd:
	# check if enpassant square is not no_sq
	cmpl	$no_sq, enpassant
	je		_genMovesWhitePawnNoEnpassant

	# get source square
	movl	-24(%rbp), %eax

	# get white pawn attack mask address
	leaq	pawn_attacks, %rdx

	# get white pawn mask attack mask value for given source square 
	movq	(%rdx,%rax,8), %rdx

	# place enpassant square on a bitboard
	movl	enpassant, %ecx
	movl	$1, %eax
	shlq	%cl, %rax

	# update attack mask copy with enpassant square 
	andq	%rdx, %rax

	# check if enpassant captures are possible
	testq	%rax, %rax
	je		_genMovesWhitePawnNoEnpassant

	# add white pawn capture no promotion
    pushq   $0					# castling flag
    pushq   $1					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $P, %edx			# piece
    movl    enpassant, %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 
    addq    $16, %rsp

_genMovesWhitePawnNoEnpassant:
	# get source square
	movl	-24(%rbp), %esi

	# get white pawn bitboard copy address
	leaq	-8(%rbp), %rdi

	# remove white pawn from the bitboard copy
	call	removeBit

	jmp		_genMovesWhitePawnLoopBeg

_genMovesWhiteCastling:
	# check if piece is white king
	cmpl	$K, -20(%rbp)
	jne		_genMovesKnight
	
	# check if castling rights allow white king side castling
	movl	castle, %eax
	andl	$wk, %eax
	testl	%eax, %eax
	je		_genMovesWhiteCastlingQueenSide

	# get f1 square occupancy
	movq	16+occupancies, %rdi
	movl	$f1, %esi
	call	getBit

	# check if f1 square is empty
	testq	%rax, %rax
	jne		_genMovesWhiteCastlingQueenSide

	# get g1 square occupancy
	movq	16+occupancies, %rdi
	movl	$g1, %esi
	call	getBit

	# check if g1 square is empty
	testq	%rax, %rax
	jne		_genMovesWhiteCastlingQueenSide

	# check if e1 square is attacked by black
	movl	$black, %esi
	movl	$e1, %edi
	call	isSquareAttacked

	# check if e1 square (king square) is attacked by black
	testl	%eax, %eax
	jne		_genMovesWhiteCastlingQueenSide

	# check if f1 square is attacked by black
	movl	$black, %esi
	movl	$f1, %edi
	call	isSquareAttacked

	# check if f1 square is attacked by black
	testl	%eax, %eax
	jne		_genMovesWhiteCastlingQueenSide

	# add white king side castling
    pushq   $1					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $K, %edx			# piece
    movl    $g1, %esi			# trg square
    movl    $e1, %edi			# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 
    addq    $16, %rsp

_genMovesWhiteCastlingQueenSide:
	# check if castling rights allow white queen side castling
	movl	castle, %eax
	andl	$wq, %eax
	testl	%eax, %eax
	je	_genMovesKing					# go to moves king

	# get d1 square occupancy
	movq	16+occupancies, %rdi
	movl	$d1, %esi
	call	getBit

	# check if d1 square is empty
	testq	%rax, %rax
	jne	_genMovesKing

	# get c1 square occupancy
	movq	16+occupancies, %rdi
	movl	$c1, %esi
	call	getBit

	# check if c1 square is empty
	testq	%rax, %rax
	jne	_genMovesKing

	# get b1 square occupancy
	movq	16+occupancies, %rdi
	movl	$b1, %esi
	call	getBit

	# check if b1 square is empty
	testq	%rax, %rax
	jne	_genMovesKing

	# check if e1 square is attacked by black
	movl	$black, %esi
	movl	$e1, %edi
	call	isSquareAttacked

	# check if e1 square is attacked by black
	testl	%eax, %eax
	jne	_genMovesKing

	# check if d1 square is attacked by black
	movl	$black, %esi
	movl	$d1, %edi
	call	isSquareAttacked

	# check if d1 square is attacked by black
	testl	%eax, %eax
	jne	_genMovesKing

	# add white queen side castling
    pushq   $1					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $K, %edx			# piece
    movl    $c1, %esi			# trg square
    movl    $e1, %edi			# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 
    addq    $16, %rsp

	jmp	_genMovesKing

_genMovesBlackPawnsAndCastling:
	cmpl	$p, -20(%rbp)
	jne		_genMovesBlackCastling
	
	# loop over all the black pawns within the bitboard
_genMovesBlackPawnLoopBeg:
	# check if the bitboard copy is empty
	cmpq	$0, -8(%rbp)
	je		_genMovesPieceLoopNext

	# get next pawn's source square
	movq	-8(%rbp), %rdi
	call	getLSB

	# store source square
	movl	%eax, -24(%rbp)
	
	# calculate target square
	addl	$8, %eax

	# store target square
	movl	%eax, -28(%rbp)

	# check if target square is empty (there is no other piece there)
	movq	16+occupancies, %rdi
	movl	-28(%rbp), %esi
	call	getBit

	# actual check
	testq	%rax, %rax
	jne		_genMovesBlackPawnCapture

	# get source square
	movl	-24(%rbp), %ecx

	# set source square on the bitboard register
	movq	$1, %rax
	shlq	%cl, %rax

	# bit wise and with rank 2
	andq	rank2, %rax

	# check if source square is on rank 2
	testq	%rax, %rax
	je		_genMovesBlackPawnNoPromotion

	# add black pawn quiet move promotion to queen
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $q, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add black pawn quiet move promotion to rook
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $r, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add black pawn quiet move promotion to bishop
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $b, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add black pawn quiet move promotion to knight
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $n, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 4 * 2 * 8 = 64
    addq    $64, %rsp

	jmp	_genMovesBlackPawnCapture

_genMovesBlackPawnNoPromotion:
	# add black pawn quiet move no promotion
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

	# get source square
	movl	-24(%rbp), %ecx

	# set source square on the bitboard register
	movq	$1, %rax
	shlq	%cl, %rax

	# bit wise and with rank 7
	andq	rank7, %rax

	# check if source square is on rank 7
	testq	%rax, %rax
	je		_genMovesBlackPawnCapture

	# get occupancies of all pieces (both)
	movq	16+occupancies, %rdi

	# get target square
	movl	-28(%rbp), %esi

	# add 8 to make double pawn push for black
	addl	$8, %esi

	# get occupancy on double push square
	call	getBit

	# check if double push square is free
	testq	%rax, %rax
	jne		_genMovesBlackPawnCapture

	# add black pawn double push
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $1, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    addl    $8, %esi			# trg square to double push square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

_genMovesBlackPawnCapture:
	# side (black = 1) << 6 = 2^6 = 64
	movl	$64, %eax

	# get source square
	movl	-24(%rbp), %edx

	# calculate index
	addq	%rdx, %rax

	# get black pawn attack mask address
	leaq	pawn_attacks, %rdx

	# get black pawn mask attack mask value for given source square 
	movq	(%rdx,%rax,8), %rax

	# update pawn attack mask making sure there is a white piece on diagonal
	andq	occupancies, %rax
	
	# store altered pawn attack mask copy
	movq	%rax, -16(%rbp)

_genMovesBlackPawnCaptureLoopBeg:
	cmpq	$0, -16(%rbp)
	je	_genMovesBlackPawnCaptureLoopEnd

	# get attack mask copy
	movq	-16(%rbp), %rdi

	# get target square
	call	getLSB

	# store target square
	movl	%eax, -28(%rbp)

	# get source square
	movl	-24(%rbp), %ecx

	# set source square on the bitboard register
	movq	$1, %rax
	shlq	%cl, %rax

	# bit wise and with rank 2
	andq	rank2, %rax

	# check if source square is on rank 2
	testq	%rax, %rax
	je		_genMovesBlackPawnCaptureNoPromotion

	# add black pawn capture promotion to queen
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $q, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add black pawn capture promotion to rook
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $r, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add black pawn capture promotion to bishop
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $b, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move llist address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# add black pawn capture promotion to knight
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $n, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 4 * 2 * 8 = 64
    addq    $64, %rsp

	jmp		_genMovesBlackPawnCaptureRemove

_genMovesBlackPawnCaptureNoPromotion:
	# add black pawn capture no promotion
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 
    addq    $16, %rsp

_genMovesBlackPawnCaptureRemove:
	# get target square
	movl	-28(%rbp), %esi

	# get black pawn attack mask copy
	leaq	-16(%rbp), %rdi

	# remove attack from the attack mask copy
	call	removeBit

	# repeat loop
	jmp		_genMovesBlackPawnCaptureLoopBeg

_genMovesBlackPawnCaptureLoopEnd:
	# check if enpassant square is not no_sq
	cmpl	$no_sq, enpassant
	je	_genMovesBlackPawnNoEnpassant

	# side (black = 1) << 6 = 2^6 = 64
	movl	$64, %eax

	# get source square
	movl	-24(%rbp), %edx

	# calculate index
	addq	%rdx, %rax

	# get black pawn attack mask address
	leaq	pawn_attacks, %rdx

	# get black pawn mask attack mask value for given source square 
	movq	(%rdx,%rax,8), %rdx

	# place enpassant square on a bitboard
	movl	enpassant, %ecx
	movl	$1, %eax
	shlq	%cl, %rax
	
	# update attack mask copy with enpassant square 
	andq	%rdx, %rax

	testq	%rax, %rax
	je	_genMovesBlackPawnNoEnpassant

	# add black pawn capture no promotion
    pushq   $0					# castling flag
    pushq   $1					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $p, %edx			# piece
    movl    enpassant, %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 
    addq    $16, %rsp

_genMovesBlackPawnNoEnpassant:
	# get source square
	movl	-24(%rbp), %esi

	# get black pawn bitboard copy address
	leaq	-8(%rbp), %rdi

	# remove black pawn from the bitboard copy
	call	removeBit

	jmp		_genMovesBlackPawnLoopBeg

_genMovesBlackCastling:
	# check if piece is black king
	cmpl	$k, -20(%rbp)
	jne		_genMovesKnight

	# check if castling rights allow black king side castling
	movl	castle, %eax
	andl	$bk, %eax
	testl	%eax, %eax
	je		_genMovesBlackCastlingQueenSide

	# get f8 square occupancy
	movq	16+occupancies, %rdi
	movl	$f8, %esi
	call	getBit

	# check if f8 square is empty
	testq	%rax, %rax
	jne		_genMovesBlackCastlingQueenSide

	# get g8 square occupancy
	movq	16+occupancies, %rdi
	movl	$g8, %esi
	call	getBit

	# check if g8 square is empty
	testq	%rax, %rax
	jne		_genMovesBlackCastlingQueenSide

	# check if e8 square is attacked by white
	movl	$white, %esi
	movl	$e8, %edi
	call	isSquareAttacked

	# check if e8 square (king square) is attacked by white
	testl	%eax, %eax
	jne	_genMovesBlackCastlingQueenSide

	# check if f8 square is attacked by white
	movl	$white, %esi
	movl	$f8, %edi
	call	isSquareAttacked

	# check if f8 square is attacked by white
	testl	%eax, %eax
	jne	_genMovesBlackCastlingQueenSide

	# add black king side castling
    pushq   $1					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $k, %edx			# piece
    movl    $g8, %esi			# trg square
    movl    $e8, %edi			# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 
    addq    $16, %rsp

_genMovesBlackCastlingQueenSide:
	# check if castling rights allow black queen side castling
	movl	castle, %eax
	andl	$bq, %eax
	testl	%eax, %eax
	je	_genMovesKing

	# get d8 square occupancy
	movq	16+occupancies, %rdi
	movl	$d8, %esi
	call getBit

	# check if d8 square is empty
	testq	%rax, %rax
	jne	_genMovesKing

	# get c8 square occupancy
	movq	16+occupancies, %rdi
	movl	$c8, %esi
	call	getBit

	# check if c1 square is empty
	testq	%rax, %rax
	jne	_genMovesKing

	# get b8 square occupancy
	movq	16+occupancies, %rdi
	movl	$b8, %esi
	call	getBit

	# check if b8 square is empty
	testq	%rax, %rax
	jne	_genMovesKing

	# check if e8 square is attacked by white
	movl	$white, %esi
	movl	$e8, %edi
	call	isSquareAttacked

	# check if e8 square is attacked by white
	testl	%eax, %eax
	jne	_genMovesKing
	
	# check if d8 square is attacked by white
	movl	$white, %esi
	movl	$d8, %edi
	call	isSquareAttacked

	# check if d8 square is attacked by white
	testl	%eax, %eax
	jne	_genMovesKing

	# add black queen side castling
    pushq   $1					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    $k, %edx			# piece
    movl    $c8, %esi			# trg square
    movl    $e8, %edi			# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer 
    addq    $16, %rsp

_genMovesKnight:
	# check if side is white 
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackKnight

	# check if piece is white knight
	cmpl	$N, -20(%rbp)
	je 		_genMovesKnightLoopBeg

	# go to bishop move generation
	jmp 	_genMovesBishop

_genMovesBlackKnight:
	# check if piece is black knight
	cmpl	$n, -20(%rbp)
	je		_genMovesKnightLoopBeg

	# go to bishop move generation
	jmp		_genMovesBishop

_genMovesKnightLoopBeg:
	# check if the bitboard copy is empty (are there any knight left)
	cmpq	$0, -8(%rbp)
	je		_genMovesBishop

	# get next knight's source square
	movq	-8(%rbp), %rdi
	call	getLSB

	# store source square
	movl	%eax, -24(%rbp)

	# get knight attack mask address
	leaq	knight_attacks, %rdx

	# get knight attack mask value for given source square
	movq	(%rdx,%rax,8), %rdx

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackKnightOccupancy

	# get white occupancy
	movq	occupancies, %rax

	# flip the bits
	notq	%rax

	jmp		_genMovesKnightOccupancyHandling

_genMovesBlackKnightOccupancy:
	# get black occupancy
	movq	8+occupancies, %rax

	# flip the bits
	notq	%rax

_genMovesKnightOccupancyHandling:
	# remove squares from the attack mask where are pieces of the same color
	andq	%rdx, %rax

	# store the posiible moves
	movq	%rax, -16(%rbp)

_genMovesKnightAttackLoopBeg:
	cmpq	$0, -16(%rbp)
	je		_genMovesKnightAttackLoopEnd

	# get attack mask copy
	movq	-16(%rbp), %rdi

	# get target square
	call	getLSB

	# store target square
	movl	%eax, -28(%rbp)

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackKnightCapture

	# get black occupancy
	movq	8+occupancies, %rdi

	jmp		_genMovesKnightCaptureHandling

_genMovesBlackKnightCapture:
	# get white occupancy
	movq	occupancies, %rdi

_genMovesKnightCaptureHandling:
	# get target square
	movl	-28(%rbp), %esi

	# check if target square occupancy
	call	getBit

	# check if on target square is a opponents piece
	testq	%rax, %rax
	jne		_genMovesKnightCapture

	# add knight quiet move
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    -20(%rbp), %edx		# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp
	
	jmp		_genMovesKnightAttackRemove

_genMovesKnightCapture:
	# add knight capture move
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
	movl    -20(%rbp), %edx		# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

_genMovesKnightAttackRemove:
	# get target square
	movl	-28(%rbp), %esi

	# get knight attack mask copy
	leaq	-16(%rbp), %rdi

	# remove attack from the attack mask copy
	call	removeBit

	# repeat attack loop
	jmp		_genMovesKnightAttackLoopBeg

_genMovesKnightAttackLoopEnd:
	# get source square
	movl	-24(%rbp), %esi

	# get knight bitboard copy address
	leaq	-8(%rbp), %rdi

	# remove knight from the bitboard copy
	call	removeBit

	# repeat knight loop
	jmp 	_genMovesKnightLoopBeg

_genMovesBishop:
	# check if side is white 
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackBishop

	# check if piece is white bishop
	cmpl	$B, -20(%rbp)
	je 		_genMovesBishopLoopBeg

	# go to rook move generation
	jmp		_genMovesRook

_genMovesBlackBishop:
	# check if piece is black bishop
	cmpl	$b, -20(%rbp)
	je 		_genMovesBishopLoopBeg

	# go to rook move generation
	jmp		_genMovesRook

_genMovesBishopLoopBeg:
	# check if the bitboard copy is empty (are there any bishops left)
	cmpq	$0, -8(%rbp)
	je		_genMovesRook

	# get next bishop's source square
	movq	-8(%rbp), %rdi
	call	getLSB

	# store source square
	movl	%eax, -24(%rbp)

	# get occupancy of the board
	movq	16+occupancies, %rsi

	# get bishop's source square
	movl	%eax, %edi

	# get appropriate attack mask for current occupancy
	call	getBishopAttacks

	# move attack mask
	movq	%rax, %rdx

	# check side
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackBishopOccupancy

	# get white occupancy
	movq	occupancies, %rax

	# flip the bits
	notq	%rax

	jmp		_genMovesBishopOccupancyHandling

_genMovesBlackBishopOccupancy:
	# get black occupacny
	movq	8+occupancies, %rax

	# flip the bits
	notq	%rax

_genMovesBishopOccupancyHandling:
	# remove squares from the attack mask where are pieces of the same color
	andq	%rdx, %rax

	# store the posiible moves
	movq	%rax, -16(%rbp)

_genMovesBishopAttackLoopBeg:
	cmpq	$0, -16(%rbp)
	je		_genMovesBishopAttackLoopEnd

	# get attack mask copy
	movq	-16(%rbp),  %rdi

	# get target square
	call	getLSB

	# store target square
	movl	%eax, -28(%rbp)

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackBishopCapture

	# get black occupancy
	movq	8+occupancies, %rdi

	jmp		_genMovesBishopCaptureHandling

_genMovesBlackBishopCapture:
	# get white occupancy
	movq	occupancies, %rdi

_genMovesBishopCaptureHandling:
	# get target square
	movl	-28(%rbp), %esi

	# check if target square occupancy
	call	getBit

	# check if on target square is a opponents piece
	testq	%rax, %rax
	jne		_genMovesBishopCapture

	# add bishop quiet move
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    -20(%rbp), %edx		# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

	jmp		_genMovesBishopAttackRemove

_genMovesBishopCapture:
	# add bishop capture move
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
	movl    -20(%rbp), %edx		# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp
	
_genMovesBishopAttackRemove:
	# get target square
	movl	-28(%rbp), %esi

	# get bishop attack mask copy
	leaq	-16(%rbp), %rdi

	# remove attack from the attack mask copy
	call	removeBit

	# repeat attack loop
	jmp 	_genMovesBishopAttackLoopBeg

_genMovesBishopAttackLoopEnd:
	# get source square
	movl	-24(%rbp), %esi

	# get bishop bitboard copy address
	leaq	-8(%rbp), %rdi

	# remove bishop from the bitboard copy
	call	removeBit
	
	# repeat bishop loop
	jmp		_genMovesBishopLoopBeg

_genMovesRook:
	# check if side is white 
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackRook

	# check if piece is white rook
	cmpl	$R, -20(%rbp)
	je 		_genMovesRookLoopBeg

	# go to queen move generation
	jmp		_genMovesQueen

_genMovesBlackRook:
	# check if piece is black rook
	cmpl	$r, -20(%rbp)
	je 		_genMovesRookLoopBeg

	# go to queen move generation
	jmp		_genMovesQueen

_genMovesRookLoopBeg:
	# check if the bitboard copy is empty (are there any rooks left)
	cmpq	$0, -8(%rbp)
	je		_genMovesQueen

	# get next rook's source square
	movq	-8(%rbp), %rdi
	call	getLSB

	# store source square
	movl	%eax, -24(%rbp)

	# get occupancy of the board
	movq	16+occupancies, %rsi

	# get rook's source square
	movl	-24(%rbp), %edi

	# get appropriate attack mask for current occupancy
	call	getRookAttacks

	# move attack mask
	movq	%rax, %rdx

	# check side
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackRookOccupancy

	# get white occupancy
	movq	occupancies, %rax

	# flip the bits
	notq	%rax

	jmp		_genMovesRookOccupancyHandling

_genMovesBlackRookOccupancy:
	# get black occupacny
	movq	8+occupancies, %rax

	# flip the bits 
	notq	%rax

_genMovesRookOccupancyHandling:
	# remove squares from the attack mask where are pieces of the same color
	andq	%rdx, %rax

	# store the posiible moves
	movq	%rax, -16(%rbp)

_genMovesRookAttackLoopBeg:
	cmpq	$0, -16(%rbp)
	je		_genMovesRookAttackLoopEnd

	# get attack mask copy
	movq	-16(%rbp),  %rdi

	# get target square
	call	getLSB

	# store target square
	movl	%eax, -28(%rbp)

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackRookCapture

	# get black occupancy
	movq	8+occupancies, %rdi

	jmp		_genMovesRookCaptureHandling

_genMovesBlackRookCapture:
	# get white occupancy
	movq	occupancies, %rdi

_genMovesRookCaptureHandling:
	# get target square
	movl	-28(%rbp), %esi

	# check if target square occupancy
	call	getBit

	# check if on target square is a opponents piece
	testq	%rax, %rax
	jne		_genMovesRookCapture

	# add rook quiet move
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    -20(%rbp), %edx		# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

	jmp		_genMovesRookAttackRemove

_genMovesRookCapture:
	# add rook capture move
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
	movl    -20(%rbp), %edx		# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

_genMovesRookAttackRemove:
	# get target square
	movl	-28(%rbp), %esi

	# get rook attack mask copy
	leaq	-16(%rbp), %rdi

	# remove attack from the attack mask copy
	call	removeBit

	# repeat attack loop
	jmp 	_genMovesRookAttackLoopBeg

_genMovesRookAttackLoopEnd:
	# get source square
	movl	-24(%rbp), %esi

	# get rook bitboard copy address
	leaq	-8(%rbp), %rdi

	# remove rook from the bitboard copy
	call	removeBit	

	# repeat rook loop
	jmp		_genMovesRookLoopBeg

_genMovesQueen:
	# check if side is white 
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackQueen

	# check if piece is white queen
	cmpl	$Q, -20(%rbp)
	je 		_genMovesQueenLoopBeg

	# go to king move generation
	jmp		_genMovesKing

_genMovesBlackQueen:
	# check if piece is black queen
	cmpl	$q, -20(%rbp)
	je 		_genMovesQueenLoopBeg

	# go to king move generation
	jmp		_genMovesKing

_genMovesQueenLoopBeg:
	cmpq	$0, -8(%rbp)
	je		_genMovesKing

	# get next queen's source square
	movq	-8(%rbp), %rdi
	call	getLSB

	# store source square
	movl	%eax, -24(%rbp)

	# get occupancy of the board
	movq	16+occupancies, %rsi

	# get queen's source square
	movl	%eax, %edi

	# get appropriate attack mask for current occupancy
	call	getQueenAttacks

	# move attack mask
	movq	%rax, %rdx

	# check side
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackQueenOccupancy

	# get white occupancy
	movq	occupancies, %rax

	# flip the bits
	notq	%rax

	jmp		_genMovesQueenOccupancyHandling
_genMovesBlackQueenOccupancy:
	# get black occupacny
	movq	8+occupancies, %rax

	# flip the bits
	notq	%rax

_genMovesQueenOccupancyHandling:
	# remove squares from the attack mask where are pieces of the same color
	andq	%rdx, %rax

	# store the posiible moves
	movq	%rax, -16(%rbp)

_genMovesQueenAttackLoopBeg:
	cmpq	$0, -16(%rbp)
	je	_genMovesQueenAttackLoopEnd

	# get attack mask copy
	movq	-16(%rbp),  %rdi

	# get target square
	call	getLSB

	# store target square
	movl	%eax, -28(%rbp)

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackQueenCapture

	# get black occupancy
	movq	8+occupancies, %rdi

	jmp		_genMovesQueenCaptureHandling

_genMovesBlackQueenCapture:
	# get white occupancy
	movq	occupancies, %rdi

_genMovesQueenCaptureHandling:
	# get target square
	movl	-28(%rbp), %esi

	# check if target square occupancy
	call	getBit

	# check if on target square is a opponents piece
	testq	%rax, %rax
	jne		_genMovesQueenCapture

	# add queen quiet move
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    -20(%rbp), %edx		# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

	jmp		_genMovesQueenAttackRemove

_genMovesQueenCapture:
	# add queen capture move
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
	movl    -20(%rbp), %edx		# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

_genMovesQueenAttackRemove:
	# get target square
	movl	-28(%rbp), %esi

	# get queen attack mask copy
	leaq	-16(%rbp), %rdi

	# remove attack from the attack mask copy
	call	removeBit

	# repeat attack loop
	jmp 	_genMovesQueenAttackLoopBeg

_genMovesQueenAttackLoopEnd:
	# get source square
	movl	-24(%rbp), %esi

	# get queen bitboard copy address
	leaq	-8(%rbp), %rdi

	# remove quenn from the bitboard copy
	call	removeBit
	
	# repeat queen loop
	jmp		_genMovesQueenLoopBeg

_genMovesKing:
	# check if side is white 
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackKing

	# check if piece is white king
	cmpl	$K, -20(%rbp)
	je 		_genMovesKingLoopBeg

	# go to bishop move generation
	jmp 	_genMovesPieceLoopNext

_genMovesBlackKing:
	# check if piece is black king
	cmpl	$k, -20(%rbp)
	je		_genMovesKingLoopBeg

	# go to next piece 
	jmp		_genMovesPieceLoopNext

_genMovesKingLoopBeg:
	cmpq	$0, -8(%rbp)
	je		_genMovesPieceLoopNext

	# get next king's source square
	movq	-8(%rbp), %rdi
	call	getLSB

	# store source square
	movl	%eax, -24(%rbp)

	# get king attack mask address
	leaq	king_attacks, %rdx

	# get king attack mask value for given source square
	movq	(%rdx,%rax,8), %rdx

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackKingOccupancy

	# get white occupancy
	movq	occupancies, %rax

	# flip the bits
	notq	%rax

	jmp		_genMovesKingOccupancyHandling

_genMovesBlackKingOccupancy:
	# get black occupancy
	movq	8+occupancies, %rax

	# flip the bits
	notq	%rax

_genMovesKingOccupancyHandling:
	# remove squares from the attack mask where are pieces of the same color
	andq	%rdx, %rax

	# store the posiible moves
	movq	%rax, -16(%rbp)

_genMovesKingAttackLoopBeg:
	cmpq	$0, -16(%rbp)
	je		_genMovesKingAttackLoopEnd

	# get attack mask copy
	movq	-16(%rbp), %rdi

	# get target square
	call	getLSB

	# store target square
	movl	%eax, -28(%rbp)

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_genMovesBlackKingCapture

	# get black occupancy
	movq	8+occupancies, %rdi

	jmp		_genMovesKingCaptureHandling

_genMovesBlackKingCapture:
	# get white occupancy
	movq	occupancies, %rdi

_genMovesKingCaptureHandling:
	# get target square
	movl	-28(%rbp), %esi

	# check if target square occupancy
	call	getBit

	# check if on target square is a opponents piece
	testq	%rax, %rax
	jne		_genMovesKingCapture

	# add king quiet move
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $0, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
    movl    -20(%rbp), %edx		# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

	jmp		_genMovesKingAttackRemove

_genMovesKingCapture:
	# add king capture move
    pushq   $0					# castling flag
    pushq   $0					# enapssant flag
    movl    $0, %r9d			# double pawn push flag
    movl    $1, %r8d			# capture flag
    movl    $0, %ecx			# promotion piece
	movl    -20(%rbp), %edx		# piece
    movl    -28(%rbp), %esi		# trg square
    movl    -24(%rbp), %edi		# src square

	# encode move
    call    encodeMove

	# get move
	movl	%eax, %esi

	# get move list address
	movq	-72(%rbp), %rdi

	# add move to the move list
	call	addMove

	# restore stack pointer
    addq    $16, %rsp

_genMovesKingAttackRemove:
	# get target square
	movl	-28(%rbp), %esi

	# get king attack mask copy
	leaq	-16(%rbp), %rdi

	# remove attack from the attack mask copy
	call	removeBit

	jmp		_genMovesKingAttackLoopBeg

_genMovesKingAttackLoopEnd:
	# get source square
	movl	-24(%rbp), %esi

	# get king bitboard copy address
	leaq	-8(%rbp), %rdi

	# remove king from the bitboard copy
	call	removeBit	

	jmp		_genMovesKingLoopBeg

_genMovesPieceLoopNext:
	# increment piece
	incl	-20(%rbp)

	# repeat piece loop
	jmp		_genMovesPieceLoopBeg

_genMovesPieceLoopEnd:
    # epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# makes moves to the given depth (checking if all moves were correctly generated)
# 1 argument: 4-byte depth
# returns void
perft_driver:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp
	
	# make space on the stack
	subq	$1200, %rsp

	# store depth
	movl	%edi, -1188(%rbp)

	# check if depth is 0
	cmpl	$0, -1188(%rbp)
	jne		_perftDriverContinue

	# increment nodes
	addq	$1, nodes

	# exit
	jmp		_perftDriverEnd

_perftDriverContinue:
	# get movelist address
	leaq	-1056(%rbp), %rdi

	# generate moves and populate the movelist
	call	genMoves

	# init move counter
	movl	$0, -4(%rbp)

_perftDriverLoopBeg:
	# get move list count
	movl	-32(%rbp), %eax

	# check if move counter is bigger or equal to movelist count
	cmpl	%eax, -4(%rbp)
	jge		_perftDriverEnd

	# copy bitboards
	movq	bitboards, %rax
	movq	8+bitboards, %rdx
	movq	%rax, -1184(%rbp)
	movq	%rdx, -1176(%rbp)
	movq	16+bitboards, %rax
	movq	24+bitboards, %rdx
	movq	%rax, -1168(%rbp)
	movq	%rdx, -1160(%rbp)
	movq	32+bitboards, %rax
	movq	40+bitboards, %rdx
	movq	%rax, -1152(%rbp)
	movq	%rdx, -1144(%rbp)
	movq	48+bitboards, %rax
	movq	56+bitboards, %rdx
	movq	%rax, -1136(%rbp)
	movq	%rdx, -1128(%rbp)
	movq	64+bitboards, %rax
	movq	72+bitboards, %rdx
	movq	%rax, -1120(%rbp)
	movq	%rdx, -1112(%rbp)
	movq	80+bitboards, %rax
	movq	88+bitboards, %rdx
	movq	%rax, -1104(%rbp)
	movq	%rdx, -1096(%rbp)

	# copy occupancies
	movq	occupancies, %rax
	movq	8+occupancies, %rdx
	movq	%rax, -1088(%rbp)
	movq	%rdx, -1080(%rbp)
	movq	16+occupancies, %rax
	movq	%rax, -1072(%rbp)

	# copy board state
	movl	side, %eax
	movl	%eax, -8(%rbp)
	movl	enpassant, %eax
	movl	%eax, -12(%rbp)
	movl	castle, %eax
	movl	%eax, -16(%rbp)

	# get move counter
	movl	-4(%rbp), %eax

	# get move from movelist at move counter
	movl	-1056(%rbp,%rax,4), %edi
	movl	$all_moves, %esi

	# make move
	call	makeMove

	# check if move is legal
	testl	%eax, %eax
	je		_perftDriverLoopNext

	# get depth
	movl	-1188(%rbp), %edi

	# decrement depth copy
	subl	$1, %edi

	# call perft driver recursively
	call	perft_driver

	# restore bitboards
	movq	-1184(%rbp), %rax
	movq	-1176(%rbp), %rdx
	movq	%rax, bitboards
	movq	%rdx, 8+bitboards
	movq	-1168(%rbp), %rax
	movq	-1160(%rbp), %rdx
	movq	%rax, 16+bitboards
	movq	%rdx, 24+bitboards
	movq	-1152(%rbp), %rax
	movq	-1144(%rbp), %rdx
	movq	%rax, 32+bitboards
	movq	%rdx, 40+bitboards
	movq	-1136(%rbp), %rax
	movq	-1128(%rbp), %rdx
	movq	%rax, 48+bitboards
	movq	%rdx, 56+bitboards
	movq	-1120(%rbp), %rax
	movq	-1112(%rbp), %rdx
	movq	%rax, 64+bitboards
	movq	%rdx, 72+bitboards
	movq	-1104(%rbp), %rax
	movq	-1096(%rbp), %rdx
	movq	%rax, 80+bitboards
	movq	%rdx, 88+bitboards
	
	# restore occupancies
	movq	-1088(%rbp), %rax
	movq	-1080(%rbp), %rdx
	movq	%rax, occupancies
	movq	%rdx, 8+occupancies
	movq	-1072(%rbp), %rax
	movq	%rax, 16+occupancies

	# restore board state
	movl	-8(%rbp), %eax
	movl	%eax, side
	movl	-12(%rbp), %eax
	movl	%eax, enpassant
	movl	-16(%rbp), %eax
	movl	%eax, castle

_perftDriverLoopNext:
	# increment move counter
	addl	$1, -4(%rbp)

	# repeat loop
	jmp		_perftDriverLoopBeg

_perftDriverEnd:
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

#--------------------------------------------

# prints nodes for every move in current position (bug find helper)
# 1 argument: (1) depth
# returns void
perft_test:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp
	
	# make space on the stack
	subq	$1232, %rsp

	# store depth on the stack
	movl	%edi, -1220(%rbp)

	# print intro
	movq	$_perftTestStrIntro, %rdi
	call	puts

	# get move list address
	leaq	-1088(%rbp), %rdi

	# generate moves and populate the move list
	call	genMoves

	# init move counter	
	movl	$0, -4(%rbp)

_perftTestLoopBeg:
	# get movelist count
	movl	-64(%rbp), %eax

	# check if move count bigger or equal to movelist count
	cmpl	%eax, -4(%rbp)
	jge		_perftTestLoopEnd

	# copy bitboards
	movq	bitboards, %rax
	movq	8+bitboards, %rdx
	movq	%rax, -1216(%rbp)
	movq	%rdx, -1208(%rbp)
	movq	16+bitboards, %rax
	movq	24+bitboards, %rdx
	movq	%rax, -1200(%rbp)
	movq	%rdx, -1192(%rbp)
	movq	32+bitboards, %rax
	movq	40+bitboards, %rdx
	movq	%rax, -1184(%rbp)
	movq	%rdx, -1176(%rbp)
	movq	48+bitboards, %rax
	movq	56+bitboards, %rdx
	movq	%rax, -1168(%rbp)
	movq	%rdx, -1160(%rbp)
	movq	64+bitboards, %rax
	movq	72+bitboards, %rdx
	movq	%rax, -1152(%rbp)
	movq	%rdx, -1144(%rbp)
	movq	80+bitboards, %rax
	movq	88+bitboards, %rdx
	movq	%rax, -1136(%rbp)
	movq	%rdx, -1128(%rbp)

	# copy occupancies
	movq	occupancies, %rax
	movq	8+occupancies, %rdx
	movq	%rax, -1120(%rbp)
	movq	%rdx, -1112(%rbp)
	movq	16+occupancies, %rax
	movq	%rax, -1104(%rbp)

	# copy boards state
	movl	side, %eax
	movl	%eax, -20(%rbp)
	movl	enpassant, %eax
	movl	%eax, -24(%rbp)
	movl	castle, %eax
	movl	%eax, -28(%rbp)

	# get move counter
	movl	-4(%rbp), %eax

	# get move from move list at move counter
	movl	-1088(%rbp,%rax,4), %edi
	movl	$0, %esi

	# make move
	call	makeMove

	# check if move is legal
	testl	%eax, %eax
	je		_perftTestLoopNext

	# init cummulative nodes
	movq	nodes, %rax
	movq	%rax, -40(%rbp)

	# get depth 
	movl	-1220(%rbp), %edi

	# decrement depth copy
	subl	$1, %edi

	# call perft driver
	call	perft_driver

	# calculate old nodes
	movq	nodes, %rax
	subq	-40(%rbp), %rax
	movq	%rax, -48(%rbp)


	# restore bitboards
	movq	-1216(%rbp), %rax
	movq	-1208(%rbp), %rdx
	movq	%rax, bitboards
	movq	%rdx, 8+bitboards
	movq	-1200(%rbp), %rax
	movq	-1192(%rbp), %rdx
	movq	%rax, 16+bitboards
	movq	%rdx, 24+bitboards
	movq	-1184(%rbp), %rax
	movq	-1176(%rbp), %rdx
	movq	%rax, 32+bitboards
	movq	%rdx, 40+bitboards
	movq	-1168(%rbp), %rax
	movq	-1160(%rbp), %rdx
	movq	%rax, 48+bitboards
	movq	%rdx, 56+bitboards
	movq	-1152(%rbp), %rax
	movq	-1144(%rbp), %rdx
	movq	%rax, 64+bitboards
	movq	%rdx, 72+bitboards
	movq	-1136(%rbp), %rax
	movq	-1128(%rbp), %rdx
	movq	%rax, 80+bitboards
	movq	%rdx, 88+bitboards

	# restore occupancies
	movq	-1120(%rbp), %rax
	movq	-1112(%rbp), %rdx
	movq	%rax, occupancies
	movq	%rdx, 8+occupancies
	movq	-1104(%rbp), %rax
	movq	%rax, 16+occupancies

	# restore board state
	movl	-20(%rbp), %eax
	movl	%eax, side
	movl	-24(%rbp), %eax
	movl	%eax, enpassant
	movl	-28(%rbp), %eax
	movl	%eax, castle

	# get move counter
	movl	-4(%rbp), %eax

	# get move from movelist at move counter
	movl	-1088(%rbp,%rax,4), %edi


	call	getMovePromoted

	# check if promotion
	testl	%eax, %eax
	je		_perftTestNoPromotion

	# get promoted pieces array address
	leaq	promoted_pieces, %rdx

	# get promoted piece char
	movzbl	(%rax,%rdx), %eax
	
	jmp		_perftTestPrint

_perftTestNoPromotion:
	# ' ' - 32
	movl	$32, %eax

_perftTestPrint:
	# get move counter
	movl	-4(%rbp), %edx

	# get move from movelist at move counter
	movl	-1088(%rbp,%rdx,4), %edx

	# calculate target square (manualy)
	shrl	$6, %edx
	andl	$63, %edx

	# get sq to coord table address
	leaq	square_to_coordinates, %rcx

	# get string coord
	movq	(%rcx,%rdx,8), %rdx

	# get move counter
	movl	-4(%rbp), %ecx

	# get move from movelist at move counter
	movl	-1088(%rbp,%rcx,4), %ecx

	# calculate source square (manualy)
	andl	$63, %ecx

	# get sq to coord table address
	leaq	square_to_coordinates, %rsi

	# get string coord
	movq	(%rsi,%rcx,8), %rsi

	# get old nodes
	movq	-48(%rbp), %r8

	# get promoted piece char
	movl	%eax, %ecx
	leaq	_perftTestBranchStr, %rdi
	movl	$0, %eax

	# print result
	call	printf

_perftTestLoopNext:
	# increment move counter
	addl	$1, -4(%rbp)

	# repeat loop
	jmp		_perftTestLoopBeg

_perftTestLoopEnd:
	# get depth
	movl	-1220(%rbp), %esi
	leaq	_perftTestStrDepth, %rdi
	movl	$0, %eax
	call	printf

	# print nodes
	movq	nodes, %rsi
	leaq	_perftTestStrNodes, %rdi
	movl	$0, %eax
	call	printf

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

#--------------------------------------------
