.text

# evaluates current position based on material score end positional score
# 0 arguments
# returns 4-byte score
evaluate:
    # prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# make space on the stack
	subq	$32, %rsp

    # init score
	movl	$0, -4(%rbp)

    # loop over piece bitboards
	movl	$P, -20(%rbp)

_evaluateLoopBeg:
	cmpl	$k, -20(%rbp)
	jg		_evaluateLoopEnd

	# get loop piece
	movl	-20(%rbp), %eax

	# get bitboards array address
	movq	$bitboards, %rdx

	# get loop piece bitboard value
	movq	(%rdx,%rax,8), %rax

	# store bitboard
	movq	%rax, -16(%rbp)

_evaluateAttackLoopBeg:
	cmpq	$0, -16(%rbp)
	je		_evaluateAttackLoopEnd

    # get piece square that it is on
	movq	-16(%rbp), %rdi
	call	getLSB

	# get piece square 
	movl	%eax, -24(%rbp)

    # clculate score based on material
	movq	$material_score, %rdx
	movl	-20(%rbp), %eax
	movl	(%rdx,%rax,4), %eax
	addl	%eax, -4(%rbp)

    # switch piece
	cmpl	$k, -20(%rbp)
	jg	    _evaluateSwitchEnd

	# jumptable address
	movq	$_evaluatePieceJumpTable, %rdx

	# get piece
	movl	-20(%rbp), %eax

	# get address from jumtable
	movq	(%rdx,%rax,8), %rax

	jmp	    *%rax

_evaluateWhitePawn:
	# get pawn score position table address
	movq	$pawn_score, %rdx

	# get piece square 
	movl	-24(%rbp), %eax

	# get score based on the position of the pawn
	movl	(%rdx,%rax,4), %eax

	# add (because white) to score
	addl	%eax, -4(%rbp)

	# end
	jmp		_evaluateSwitchEnd

_evaluateWhiteKnight:
	# get knight score position table address
	movq	$knight_score, %rdx

	# get piece square 
	movl	-24(%rbp), %eax

	# get score based on the position of the knight
	movl	(%rdx,%rax,4), %eax

	# add (because white) to score
	addl	%eax, -4(%rbp)

	jmp		_evaluateSwitchEnd

_evaluateWhiteBishop:
	# get bishop score position table address
	movq	$bishop_score, %rdx

	# get piece square 
	movl	-24(%rbp), %eax

	# get score based on the position of the bishop
	movl	(%rdx,%rax,4), %eax

	# add (because white) to score
	addl	%eax, -4(%rbp)

	jmp	_evaluateSwitchEnd

_evaluateWhiteRook:
	# get rook score position table address
	movq	$rook_score, %rdx

	# get piece square 
	movl	-24(%rbp), %eax

	# get score based on the position of the rook
	movl	(%rdx,%rax,4), %eax

	# add (because white) to score
	addl	%eax, -4(%rbp)

	jmp	_evaluateSwitchEnd

_evaluateWhiteKing:
	# get king score position table address
	movq	$king_score, %rdx

	# get piece square 
	movl	-24(%rbp), %eax

	# get score based on the position of the king
	movl	(%rdx,%rax,4), %eax

	# add (because white) to score
	addl	%eax, -4(%rbp)

	jmp	_evaluateSwitchEnd

_evaluateBlackPawn:
	movq	$mirror_score, %rdx

	# get piece square 
	movl	-24(%rbp), %eax
	movl	(%rdx,%rax,4), %eax
	movq	$pawn_score, %rdx
	movl	(%rdx,%rax,4), %eax

	# sub (because black) to score
	subl	%eax, -4(%rbp)

	jmp	_evaluateSwitchEnd

_evaluateBlackKnight:
	movq	$mirror_score, %rdx

	# get piece square 
	movl	-24(%rbp), %eax
	movl	(%rdx,%rax,4), %eax
	movq	$knight_score, %rdx
	movl	(%rdx,%rax,4), %eax
	subl	%eax, -4(%rbp)

	jmp	_evaluateSwitchEnd

_evaluateBlackBishop:
	movq	$mirror_score, %rdx

	# get piece square 
	movl	-24(%rbp), %eax
	movl	(%rdx,%rax,4), %eax
	movq	$bishop_score, %rdx
	movl	(%rdx,%rax,4), %eax
	subl	%eax, -4(%rbp)

	jmp	_evaluateSwitchEnd

_evaluateBlackRook:
	movq	$mirror_score, %rdx

	# get piece square 
	movl	-24(%rbp), %eax
	movl	(%rdx,%rax,4), %eax
	movq	$rook_score, %rdx
	movl	(%rdx,%rax,4), %eax
	subl	%eax, -4(%rbp)

	jmp	_evaluateSwitchEnd

_evaluateBlackKing:
	movq	$mirror_score, %rdx

	# get piece square 
	movl	-24(%rbp), %eax
	movl	(%rdx,%rax,4), %eax
	movq	$king_score, %rdx
	movl	(%rdx,%rax,4), %eax
	subl	%eax, -4(%rbp)

_evaluateSwitchEnd:
	# remove piece from bitboard copy
	movl	-24(%rbp), %esi
	leaq	-16(%rbp), %rdi
	call	removeBit

	# repeat loop
	jmp		_evaluateAttackLoopBeg

_evaluateAttackLoopEnd:

	addl	$1, -20(%rbp)

	# repeat loop
	jmp		_evaluateLoopBeg

_evaluateLoopEnd:

	movl	side, %eax
	testl	%eax, %eax
	je		_evaluateReturnWhite

	movl	-4(%rbp), %eax
	negl	%eax

	jmp		_evaluateEnd

_evaluateReturnWhite:
	movl	-4(%rbp), %eax
	
_evaluateEnd:
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret


# --------------------------------------------


# TODO
# 1 argument: (1) movelist address
# returns void
enablePVScoring:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# store movelist address on the stack
	movq	%rdi, -24(%rbp)

	# disable following PV flag
	movl	$0, follow_pv

	# init count
	movl	$0, -4(%rbp)

	# loop over the moves within a move list
_enablePVScoringLoopBeg:
	# get count
	movq	-24(%rbp), %rax
	movl	1024(%rax), %eax

	cmpl	%eax, -4(%rbp)
	jge		_enablePVScoringLoopEnd

	# get ply
	movl	ply, %eax

	# get pv table address
	leaq	pv_table, %rdx

	# get PV move
	movl	(%rdx,%rax,4), %ecx

	# calculate move adderss 
	movq	-24(%rbp), %rax
	movl	-4(%rbp), %edx
	movl	(%rax,%rdx,4), %eax

	# check if PV move
	cmpl	%eax, %ecx
	jne		_enablePVScoringLoopNext

	# enable move scoring flag
	movl	$1, score_pv

	# enable following PV flag
	movl	$1, follow_pv

_enablePVScoringLoopNext:
	incl	-4(%rbp)
	jmp 	_enablePVScoringLoopBeg

_enablePVScoringLoopEnd:
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# scores a move
# 1 argument: (1) encoded move
# returns score
scoreMove:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# store move on the stack
	movl	%edi, -20(%rbp)

	# get score _pv flag
	movl	score_pv, %eax

	# check if score_pv flag is enabled
	testl	%eax, %eax
	je		_scoreMoveCapture

	# get ply
	movl	ply, %eax
	
	# get pv table address
	leaq	pv_table, %rdx

	# get the pv move
	movl	(%rdx,%rax,4), %eax

	# check if move is a pv move
	cmpl	%eax, -20(%rbp)
	jne		_scoreMoveCapture

	# disable score pv flag
	movl	$0, score_pv

	# return the highest score for PV move to search it first
	movl	$20000, %eax
	jmp		_scoreMoveEnd

_scoreMoveCapture:
	# get move
	movl	-20(%rbp), %edi
	call 	getMoveCapture
	
	# check if move is a capture
	testl	%eax, %eax
	je		_scoreMoveQuiet

	# init target piece
	movl	$0, -4(%rbp)

	# check if white to move
	movl	side, %eax
	testl	%eax, %eax
	jne		_scoreMoveBlack

	# assign black pieces when white to move
	movl	$p, -8(%rbp)
	movl	$k, -12(%rbp)
	jmp	_scoreMoveSideCheckEnd

_scoreMoveBlack:
	# assigne white pieces when black to move
	movl	$P, -8(%rbp)
	movl	$K, -12(%rbp)

_scoreMoveSideCheckEnd:
	# get starting piece
	movl	-8(%rbp), %eax
	
	# init loop piece at starting piece
	movl	%eax, -16(%rbp)

	# loop over bitboards opposite to the current side to move
_scoreMoveLoopBeg:
	# get loop piece 
	movl	-16(%rbp), %eax
	cmpl	-12(%rbp), %eax
	jg		_scoreMoveLoopEnd

	# get move
	movl	-20(%rbp), %eax
	andl	$0xFC0, %eax
	shrl	$6, %eax

	// movl	-20(%rbp), %edi
	// call	getMoveTrg
	
	movl	%eax, %ecx

   	# get loop piece
	movl	-16(%rbp), %eax
	
	# get bitboards array address
	leaq	bitboards, %rdx

	// # get loop piece bitboard
	// movq	(%rdx,%rax,8), %rdi
	
	// call	getBit

	# get loop piece bitboard
	movq	(%rdx,%rax,8), %rdx
	
	# check if piece on target square
	shrq	%cl, %rdx
	movq	%rdx, %rax
	andl	$1, %eax

	# check if there is a piece on the target square
	testq	%rax, %rax
	je		_scoreMoveLoopNext

	# assign found piece to target piece
	movl	-16(%rbp), %eax
	movl	%eax, -4(%rbp)

	# exit the loop
	jmp		_scoreMoveLoopEnd

_scoreMoveLoopNext:
	incl	-16(%rbp)
	jmp	 	_scoreMoveLoopBeg

_scoreMoveLoopEnd:
	# score move by MVV LVA lookup [source piece][target piece]
	# get move
	movl	-20(%rbp), %eax

	shrl	$12, %eax
	andl	$15, %eax
	movl	%eax, %edx

	# get target piece
	movl	-4(%rbp), %ecx

	# %rax * 2
	shlq	$1, %rax

	# %rax + %rdx = 3 * %rdx
	addq	%rdx, %rax

	# 4 * %rax = 12 * %rdx (offset by 12)
	shlq	$2, %rax

	# merge together
	addq	%rcx, %rax

	# get mvv lva table address
	leaq	mvv_lva, %rdx

	# get mvvlva score + 10000
	movl	(%rdx,%rax,4), %eax

	addl	$10000, %eax

	# return value
	jmp	_scoreMoveEnd

_scoreMoveQuiet:
	# get ply
	movl	ply, %eax

	# get killer moves table address
	leaq	killer_moves, %rdx

	# get 1st killer move
	movl	(%rdx,%rax,4), %eax

	# check if killer move
	cmpl	%eax, -20(%rbp)
	jne		_scoreMoveSecKiller

	# return 9000 (1st killer move)
	movl	$9000, %eax
	jmp		_scoreMoveEnd

_scoreMoveSecKiller:
	# get ply 
	movl	ply, %eax

	# offset ply 
	addq	$64, %rax

	# get killer moves table address
	leaq	killer_moves, %rdx

	# get 2nd killer move 
	movl	(%rdx,%rax,4), %eax

	# check if 2nd killer move
	cmpl	%eax, -20(%rbp)
	jne		_scoreMoveHistory

	# return 8000 (2nd killer move)
	movl	$8000, %eax
	jmp		_scoreMoveEnd

_scoreMoveHistory:
	# get move target 
	movl	-20(%rbp), %edi
	call	getMoveTrg
	
	# relocate
	movl	%eax, %edx

	# get piece
	movl	-20(%rbp), %edi
	call	getMovePiece

	# calculate index
	shlq	$6, %rax
	addq	%rdx, %rax
	
	# get history moves table address
	leaq	history_moves, %rdx

	# return value
	movl	(%rdx,%rax,4), %eax

_scoreMoveEnd:
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp
	ret

# --------------------------------------------

# prints move scores
# 1 argument: (1) move list address
# returns void
printMoveScores:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp
	
	# make space on the stack
	subq	$32, %rsp

	# store move list address
	movq	%rdi, -24(%rbp)
	
	# print intro
	leaq	_printMoveScoresIntroStr, %rdi
	call	puts

	# init move counter at 0
	movl	$0, -4(%rbp)

_printMoveScoresLoopBeg:
	# get move list address
	movq	-24(%rbp), %rax

	# get move list count
	movl	1024(%rax), %eax

	# check if not out of bounds
	cmpl	%eax, -4(%rbp)
	jge		_printMoveScoresLoopEnd

	# print move string
	leaq	_printMoveScoresMoveStr, %rdi
	call	puts

	# get move list address
	movq	-24(%rbp), %rax

	# get move counter
	movl	-4(%rbp), %edx
	
	# get move at counter
	movl	(%rax,%rdx,4), %edi

	# print move at counter
	call	printMove

	# get move list address
	movq	-24(%rbp), %rax

	# get move counter
	movl	-4(%rbp), %edx
	
	# get move at counter
	movl	(%rax,%rdx,4), %edi

	# score move at counter
	call	scoreMove

	# get move score
	movl	%eax, %esi
	leaq	_printMoveScoresScoreStr, %rdi
	movl	$0, %eax

	# print move score
	call	printf

	# increment move counter
	addl	$1, -4(%rbp)

_printMoveScoresLoopEnd:
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# sorts moves in the movelist based on the score
# 1 argument: (1) movelist address
# returns void
sortMoves:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# make space on stack
	subq	$72, %rsp

	# store movellist address on the stack
	movq	%rdi, -72(%rbp)

	# store %rsp in %rbp
	movq	%rsp, %rax
	movq	%rax, %rbx

    # get move list address
	movq	-72(%rbp), %rax

	# get movelist count
	movl	1024(%rax), %edi

	# multiply by 4
	shll	$2, %edi

	# allocate enough memory on the heap
	call 	malloc

	# store pointer to memory on the heap
	movq	%rax, -48(%rbp)

	# init move counter
	movl	$0, -28(%rbp)

_sortMovesScoreLoopBeg:
	# get move list address
	movq	-72(%rbp), %rax

	# get movelist count
	movl	1024(%rax), %eax

	# check if not out of bounds
	cmpl	%eax, -28(%rbp)
	jge		_sortMovesScoreLoopEnd

	# get move list address
	movq	-72(%rbp), %rax

	# get move counter
	movl	-28(%rbp), %edx
	
	# get move from move list
	movl	(%rax,%rdx,4), %edi

	# score move
	call	scoreMove

	# get score array address
	movq	-48(%rbp), %rdx

	# get move counter
	movl	-28(%rbp), %ecx
	
	# assign score to score array at move counter
	movl	%eax, (%rdx,%rcx,4)

	# increase move counter
	addl	$1, -28(%rbp)

	# repeat loop
	jmp		_sortMovesScoreLoopBeg

_sortMovesScoreLoopEnd:

	# init current move counter
	movl	$0, -24(%rbp)

_sortMovesCurrentLoopBeg:
	# get move list address
	movq	-72(%rbp), %rax

	# get move list count
	movl	1024(%rax), %eax

	# check if not at the end
	cmpl	%eax, -24(%rbp)
	jge		_sortMovesCurrentLoopEnd

	# get current move counter
	movl	-24(%rbp), %eax
	addl	$1, %eax

	# init next move counter
	movl	%eax, -20(%rbp)

_sortMovesNextLoopBeg:
	# get move list address
	movq	-72(%rbp), %rax

	# get move list count
	movl	1024(%rax), %eax

	# check if not at the end
	cmpl	%eax, -20(%rbp)
	jge		_sortMovesNextLoopEnd

	# get score array address
	movq	-48(%rbp), %rdx

	# get current move counter
	movl	-24(%rbp), %eax
	
	movl	(%rdx,%rax,4), %ecx

	# get next move counter
	movl	-20(%rbp), %eax
	
	movl	(%rdx,%rax,4), %eax

	# compare current and next move scores
	cmpl	%eax, %ecx
	jge		_sortMovesNextLoopNext

	# get current move counter
	movl	-24(%rbp), %eax
	
	# get current move score
	movl	(%rdx,%rax,4), %eax

	# init temp score
	movl	%eax, -52(%rbp)

	# get next move counter
	movl	-20(%rbp), %eax
	
	# get next move score
	movl	(%rdx,%rax,4), %ecx

	# get current move counter
	movl	-24(%rbp), %eax
	
	# assign next move score to current move score
	movl	%ecx, (%rdx,%rax,4)

	# get next move counter
	movl	-20(%rbp), %eax
	
	# get temp score
	movl	-52(%rbp), %ecx

	# assign temp score to next move score
	movl	%ecx, (%rdx,%rax,4)

	# get move list address
	movq	-72(%rbp), %rdx

	# get current move counter
	movl	-24(%rbp), %eax
	
	# get current move
	movl	(%rdx,%rax,4), %eax

	# init temp move
	movl	%eax, -56(%rbp)

	# get next move counter
	movl	-20(%rbp), %eax
	
	# get next move
	movl	(%rdx,%rax,4), %ecx

	# get current move counter
	movl	-24(%rbp), %eax
	
	# assign next move to current move
	movl	%ecx, (%rdx,%rax,4)

	# get next move counter
	movl	-20(%rbp), %eax
	
	# get temp move 
	movl	-56(%rbp), %ecx

	# assign temp move to next move
	movl	%ecx, (%rdx,%rax,4)

_sortMovesNextLoopNext:
	# increment next move counter
	addl	$1, -20(%rbp)

	# repeat loop
	jmp		_sortMovesNextLoopBeg

_sortMovesNextLoopEnd:
	# increment current move counter
	addl	$1, -24(%rbp)

	# repeat loop
	jmp		_sortMovesCurrentLoopBeg

_sortMovesCurrentLoopEnd:

	movq	-48(%rbp), %rdi

	call	free

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp
    
	ret

# --------------------------------------------
