.text

# 2 arguments: (1) alpha, (2) beta
# returns score
quiescence:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# make space on stack
	subq	$1200, %rsp

	# store args on the stack
	movl	%edi, -1188(%rbp)
	movl	%esi, -1192(%rbp)
	
	# increment node count
	incq	nodes
	
	# evaluate position
	call	evaluate

	# check if beta cutoff
	movl	%eax, -8(%rbp)
	cmpl	-1192(%rbp), %eax
	jl		_quiescenceNoBetaCutoffEarly

	# return beta
	movl	-1192(%rbp), %eax
	jmp		_quiescenceEnd

_quiescenceNoBetaCutoffEarly:
	# check if move is better (than alpha)
	movl	-8(%rbp), %eax
	cmpl	-1188(%rbp), %eax
	jle		_quiescenceNotGreater

	# assign alpha to best current move
	movl	-8(%rbp), %eax
	movl	%eax, -1188(%rbp)

_quiescenceNotGreater:
	# generate moves
	leaq	-1056(%rbp), %rdi
	call	genMoves

	# sort moves in the movelist
	leaq	-1056(%rbp), %rdi
	call	sortMoves

	movl	$0, -4(%rbp)

_quiescenceMoveLoopBeg:
	movl	-32(%rbp), %eax
	cmpl	%eax, -4(%rbp)
	jge		_quiescenceMoveLoopEnd

	# preserve bitboards
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

	# preserve occupancies
	movq	occupancies, %rax
	movq	8+occupancies, %rdx
	movq	%rax, -1088(%rbp)
	movq	%rdx, -1080(%rbp)
	movq	16+occupancies, %rax
	movq	%rax, -1072(%rbp)

	# preserve board state
	movl	side, %eax
	movl	%eax, -12(%rbp)
	movl	enpassant, %eax
	movl	%eax, -16(%rbp)
	movl	castle, %eax
	movl	%eax, -20(%rbp)

	# increment ply
	incl 	ply

	# make the move
	movl	-4(%rbp), %eax
	movl	-1056(%rbp,%rax,4), %edi
	movl	$captures, %esi
	call	makeMove

	# check if the move is legal
	testl	%eax, %eax
	jne		_quiescenceMoveLegal

	# decrement ply if move is illegal
	decl	ply

	# go to the next move
	jmp		_quiescenceMoveLoopNext
	
_quiescenceMoveLegal:
	movl	-1188(%rbp), %esi
	negl	%esi
	movl	-1192(%rbp), %edi
	negl	%edi
	call	quiescence

	# store negative result of quiescence search
	negl	%eax
	movl	%eax, -24(%rbp)

	# decrement ply
	decl 	ply

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
	movl	-12(%rbp), %eax
	movl	%eax, side
	movl	-16(%rbp), %eax
	movl	%eax, enpassant
	movl	-20(%rbp), %eax
	movl	%eax, castle

	# check if beta cutoff
	movl	-24(%rbp), %eax
	cmpl	-1192(%rbp), %eax
	jl		_quiescenceNoBetaCutoffLate

	# return beta (fails hard)
	movl	-1192(%rbp), %eax
	jmp		_quiescenceEnd

_quiescenceNoBetaCutoffLate:
	# check if the move is greater than alpha
	movl	-24(%rbp), %eax
	cmpl	-1188(%rbp), %eax
	jle		_quiescenceMoveLoopNext

	# assign alpha to best current move 
	movl	-24(%rbp), %eax
	movl	%eax, -1188(%rbp)

_quiescenceMoveLoopNext:
	incl 	-4(%rbp)

	# repeat loop
	jmp 	_quiescenceMoveLoopBeg

_quiescenceMoveLoopEnd:
	# return alpha (fails low)
	movl	-1188(%rbp), %eax

_quiescenceEnd:
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# This algorithm relies on the fact that ⁠min(a, b) = -max(-b, -a)
# More precisely, the value of a position to player A in such a game is the negation of 
#	the value to player B. Thus, the player on move looks for a move that maximizes the 
# 	negation of the value resulting from the move
#		PV-nodes are nodes that have a score that ends up being inside the window. 
# 		Fail-high nodes, are nodes in which a beta-cutoff was performed.
# 		Fail-low nodes, are nodes in which no move's score exceeded alpha.
# 3 arguments: (1) alpha (), (2) beta, (3) depth
# returns score
negamax:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# preserve calle saved regiser 
	pushq	%rbx

	# make space on stack
	subq	$1224, %rsp

	# store args on stack
	movl	%edi, -1220(%rbp)
	movl	%esi, -1224(%rbp)
	movl	%edx, -1228(%rbp)

	# init flag if PV move found
	movl	$0, -20(%rbp)

	# init PV length
	movl	ply, %ecx
	movl	ply, %eax
	
	# get pv length table address
	leaq	pv_length, %rdx

	# set pv length to ply
	movl	%eax, (%rdx,%rcx,4)

	# check if depth is 0
	cmpl	$0, -1228(%rbp)
	jne	_negamaxDepthNotZero

	# run quiescence search
	movl	-1224(%rbp), %esi
	movl	-1220(%rbp), %edi
	call	quiescence

	# return quiescence search result
	jmp		_negamaxEnd

_negamaxDepthNotZero:
	# check if ply is not more than max_ply
	movl	ply, %eax
	cmpl	$max_ply, %eax
	jl		_negamaxPlyLessThanMax

	# call evaluation
	call	evaluate

	# return evaluation result
	jmp		_negamaxEnd

_negamaxPlyLessThanMax:
	# incremeant nodes
	incq	nodes

	# get the other side and store it in %ebx
	movl	side, %eax
	xorl	$1, %eax
	movl	%eax, %ebx

	movl	side, %eax

	# check if white to move
	testl	%eax, %eax
	jne	_negamaxBlackKing

	# get white king position
	movq	40+bitboards, %rdi
	call	getLSB

	jmp		_negamaxCheckIfKingIsAttacked

_negamaxBlackKing:
	# get black king position
	movq	88+bitboards, %rdi
	call	getLSB

_negamaxCheckIfKingIsAttacked:
	# get stored in ebx side
	movl	%ebx, %esi
	movl	%eax, %edi

	# check if king is attacked
	call	isSquareAttacked
	movl	%eax, -44(%rbp)
	
	# check if king is in check
	cmpl	$0, -44(%rbp)
	je		_negamaxKingNotInCheck
	
	# incremeant depth if king in check
	incl	-1228(%rbp)

_negamaxKingNotInCheck:
	# init legal moves counter
	movl	$0, -24(%rbp)

	# generate moves
	leaq	-1088(%rbp), %rdi
	call	genMoves

	# check if follow_pv flag is enabled
	movl	follow_pv, %eax
	testl	%eax, %eax
	je		_negamaxNotFollowingPV

	# enable PV scoring if follow_pv flag is enabled
	leaq	-1088(%rbp), %rdi
	call	enablePVScoring

_negamaxNotFollowingPV:
	# sort moves in the movelist
	leaq	-1088(%rbp), %rdi

	# sort moves
	call	sortMoves

	# init move searched counter
	movl	$0, -28(%rbp)

	# init move counter
	movl	$0, -32(%rbp)
	jmp		_negamaxMoveLoopEnd

_negamaxMoveLoopBeg:
	# preserve bitboards
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

	# preserve occupancies
	movq	occupancies, %rax
	movq	8+occupancies, %rdx
	movq	%rax, -1120(%rbp)
	movq	%rdx, -1112(%rbp)
	movq	16+occupancies, %rax
	movq	%rax, -1104(%rbp)

	# preserve board state
	movl	side, %eax
	movl	%eax, -48(%rbp)
	movl	enpassant, %eax
	movl	%eax, -52(%rbp)
	movl	castle, %eax
	movl	%eax, -56(%rbp)

	# increment ply
	incl	ply
	
	# get move counter
	movl	-32(%rbp), %eax
	
	# get move from move list at move counter
	movl	-1088(%rbp,%rax,4), %edi
	movl	$0, %esi
	
	# make move
	call	makeMove
	
	# check if move is legal
	testl	%eax, %eax
	jne		_negamaxMoveLegal
	
	# decrement ply
	decl 	ply

	# go to the next move in the movelist
	jmp		_negamaxMoveLoopNext

_negamaxMoveLegal:
	# increment legal move counter
	incl	-24(%rbp)

	# Principal variation search (PVS)
	cmpl	$0, -20(%rbp)
	je		_negamaxNotPVS

	# Once you've found a move with a score that is between alpha and beta,
    #           the rest of the moves are searched with the goal of proving that they are all bad.

	# get depth - arg 3
	movl	-1228(%rbp), %edx
	subl	$1, %edx

	# get alfa - arg 2
	movl	-1220(%rbp), %esi

	# negate alfa -> -alfa
	negl	%esi
	
	# get alfa - arg 1
	movl	-1220(%rbp), %edi

	# not alfa = ~alfa = -alfa -1 (2C)
	notl	%edi

	# call negamax recursively
	call	negamax

	# store negative result of negamax search
	negl	%eax
	movl	%eax, -36(%rbp)

	# check if move is bigger than alfa
	# If the algorithm finds out that it was wrong, and that one of the
    #           subsequent moves was better than the first PV move, it has to search again,
    #           in the normal alpha-beta manner.  This happens sometimes, and it's a waste of time,
    #           but generally not often enough to counteract the savings gained from doing the
    #           "bad move proof" search referred to earlier. 
	#		value = PVS(-(alpha+1),-alpha)
	#.		if(value > alpha && value < beta) {
	#			value = PVS(-beta,-alpha);
	#		}
	cmpl	-1220(%rbp), %eax
	jle	_negamaxFoundPVElseEnd

	# get score
	movl	-36(%rbp), %eax

	# check if less than beta
	cmpl	-1224(%rbp), %eax
	jge	_negamaxFoundPVElseEnd
	
	# re-search the move that has failed to be proved to be bad
    #               with normal alpha beta score bounds

	# get depth - arg 3
	movl	-1228(%rbp), %edx
	subl	$1, %edx

	# get alpha - arg 2
	movl	-1220(%rbp), %esi

	# negate alpha
	negl	%esi

	# get beta - arg 1
	movl	-1224(%rbp), %edi

	# negate beta
	negl	%edi

	# call negamax recursively
	call	negamax

	# store negated score
	negl	%eax
	movl	%eax, -36(%rbp)

	# skip
	jmp	_negamaxFoundPVElseEnd

	# all other movers 
_negamaxNotPVS:
	# check if move searched counter is zero
	cmpl	$0, -28(%rbp)
	jne		_negamaxMoveSearchCounterNotZero

	# full depth search
	# do normal alpha-beta search
	# get depth
	movl	-1228(%rbp), %edx
	subl	$1, %edx

	# get alpha - arg 2
	movl	-1220(%rbp), %esi

	# negate alpha
	negl	%esi

	# get beta - arg 1
	movl	-1224(%rbp), %edi

	# negate beta
	negl	%edi

	# call negamax recursively
	call	negamax

	# store negative result of negamax search
	negl	%eax
	movl	%eax, -36(%rbp)

	# go to the next move in the move list
	jmp	_negamaxFoundPVElseEnd

_negamaxMoveSearchCounterNotZero:
	# late move reduction (LMR)
	# check if applicable for LMR
	# check if moves searched is bigger or equal to 4 (full depth moves)
	cmpl	$4, -28(%rbp)
	jl		_negamaxNotLMR

	# check if depth is bigger or equal to 3 (reduction limit)
	cmpl	$3, -1228(%rbp)
	jl		_negamaxNotLMR

	# check if king is in check
	cmpl	$0, -44(%rbp)
	jne		_negamaxNotLMR

	# get move counter
	movl	-32(%rbp), %eax

	# get move from move list at move counter
	movl	-1088(%rbp,%rax,4), %edi

	# get move capture flag
	call	getMoveCapture
	
	# check if capture move
	testl	%eax, %eax
	jne		_negamaxNotLMR


	# get move counter
	movl	-32(%rbp), %eax
	
	# get move from move list at move counter
	movl	-1088(%rbp,%rax,4), %edi

	# get movepromoted piece
	call	getMovePromoted

	# check if move promotion
	testl	%eax, %eax
	jne		_negamaxNotLMR

	#search current move with reduced depth

	# get depth - arg 3
	movl	-1228(%rbp), %edx
	subl	$2, %edx

	# get alpha - arg 2
	movl	-1220(%rbp), %esi

	# negate alpha -> -alpha
	negl	%esi
	
	# get alpha - arg 1
	movl	-1220(%rbp), %edi

	# not alpha = ~alpha = -alpha -1 (2C)
	notl	%edi

	# call negamax recursively
	call	negamax

	# store negative result of negamax search
	negl	%eax
	movl	%eax, -36(%rbp)

	jmp		_negamaxLMREnd

_negamaxNotLMR:
	# hack to ensure that full-depth search is done
	# get alpha 
	movl	-1220(%rbp), %eax

	# increment alpha copy
	addl	$1, %eax

	# store it as score
	movl	%eax, -36(%rbp)

_negamaxLMREnd:
	# get move score
	movl	-36(%rbp), %eax

	# check if score bigger than alpha
	cmpl	-1220(%rbp), %eax
	jle		_negamaxFoundPVElseEnd

	# found a better move during LMR
	# re-search at full depth but with narrowed score bandwith
	# get depth - arg 3
	movl	-1228(%rbp), %edx
	subl	$1, %edx

	# get alpha - arg 2
	movl	-1220(%rbp), %esi

	# negate alpha -> -alpha
	negl	%esi
	
	# get alpha - arg 1
	movl	-1220(%rbp), %edi

	# not alpha = ~alpha = -alpha -1 (2C)
	notl	%edi

	# call negamax recursively
	call	negamax

	# store negative result of negamax search
	negl	%eax
	movl	%eax, -36(%rbp)

	# get score
	movl	-36(%rbp), %eax

	# check if LMR fails
	# check if score bigger than alpha
	cmpl	-1220(%rbp), %eax
	jle		_negamaxFoundPVElseEnd

	# re-search at full depth and full score bandwith

	# get score
	movl	-36(%rbp), %eax

	# check if score smaller than beta
	cmpl	-1224(%rbp), %eax
	jge		_negamaxFoundPVElseEnd

	# full depth search
	# do normal alpha-beta search
	# get depth
	movl	-1228(%rbp), %edx
	subl	$1, %edx

	# get alpha - arg 2
	movl	-1220(%rbp), %esi

	# negate alpha
	negl	%esi

	# get beta - arg 1
	movl	-1224(%rbp), %edi

	# negate beta
	negl	%edi

	# call negamax recursively
	call	negamax
	
	# store negative result of negamax search
	negl	%eax
	movl	%eax, -36(%rbp)

_negamaxFoundPVElseEnd:
	# decrement ply
	decl	ply

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
	movl	-48(%rbp), %eax
	movl	%eax, side
	movl	-52(%rbp), %eax
	movl	%eax, enpassant
	movl	-56(%rbp), %eax
	movl	%eax, castle

	# increment searched moves counter
	incl 	-28(%rbp)

	# check if beta cutoff
	movl	-36(%rbp), %eax
	cmpl	-1224(%rbp), %eax
	jl		_negamaxNoBetaCutoff 

	# get move counter
	movl	-32(%rbp), %eax

	# get move from the movelist at move counter
	movl	-1088(%rbp,%rax,4), %edi

	# get move capture flag
	call	getMoveCapture

	# check if capture
	testl	%eax, %eax
	jne	_negamaxFailsHigh

	# get ply
	movl	ply, %eax

	# get killer moves table address
	leaq	killer_moves, %rdx

	# get move at ply
	movl	(%rdx,%rax,4), %eax
	
	# get ply
	movl	ply, %ecx

	# skip 64 bytes
	addq	$64, %rcx

	# get killer moves table address
	leaq	killer_moves, %rdx

	# store move in killer move table with 64 byte offset
	movl	%eax, (%rdx,%rcx,4)

	# get ply
	movl	ply, %edx
	
	# get move counter
	movl	-32(%rbp), %eax
	
	# get move from move list at move counter
	movl	-1088(%rbp,%rax,4), %eax
	
	# get killer moves table address
	leaq	killer_moves, %rcx

	# store move in killer moves
	movl	%eax, (%rcx,%rdx,4)

_negamaxFailsHigh:
	# return beta
	movl	-1224(%rbp), %eax
	jmp		_negamaxEnd

_negamaxNoBetaCutoff:
	# get score 
	movl	-36(%rbp), %eax

	# check if score bigger than alpha
	cmpl	-1220(%rbp), %eax
	jle	_negamaxMoveLoopNext
	
	# get move counter
	movl	-32(%rbp), %eax
	
	# get move from move list at move counter
	movl	-1088(%rbp,%rax,4), %edi

	# get move capture flag
	call	getMoveCapture

	# check if capture
	testl	%eax, %eax
	jne		_negamaxCapture
	
	# get move counter
	movl	-32(%rbp), %eax
	
	# get move from move list at move counter
	movl	-1088(%rbp,%rax,4), %edi

	# get piece
	call	getMovePiece

	# relocate not to lose it
	movl	%eax, %edx

	# get move counter
	movl	-32(%rbp), %eax
	
	# get move from move list at move counter
	movl	-1088(%rbp,%rax,4), %eax

	# calculate target square (manualy)
	shrl	$6, %eax
	andl	$63, %eax

	# get depth
	movl	-1228(%rbp), %ecx

	# calculate index
	salq	$6, %rdx
	addq	%rdx, %rax

	# get history moves table address
	leaq	history_moves, %rdx

	# add depth to history moves table at piece, trg sq
	addl	%ecx, (%rdx,%rax,4)

_negamaxCapture:
	# assign score to alpha - PV node (move)
	movl	-36(%rbp), %eax
	movl	%eax, -1220(%rbp)

	# enable found PV flag
	movl	$1, -20(%rbp)

	# get move counter
	movl	-32(%rbp), %eax
	
	# get move from move list at move counter
	movl	-1088(%rbp,%rax,4), %eax

	# get ply
	movl	ply, %edx
	movl	ply, %ecx

	# calculate index
	salq	$6, %rdx
	addq	%rdx, %rcx

	# get pv length table address
	leaq	pv_table, %rdx

	# add move to pv table
	movl	%eax, (%rdx,%rcx,4)

	# get ply
	movl	ply, %eax

	# increment ply copy
	addl	$1, %eax

	# set next ply to ply + 1
	movl	%eax, -40(%rbp)

_negamaxPlyLoopBeg:
	# get ply
	movl	ply, %eax

	# increment ply copy
	addl	$1, %eax
	
	# get pv length table address
	leaq	pv_length, %rdx

	# get pv length
	movl	(%rdx,%rax,4), %eax

	# check if next ply is bigger ir equal to pv length at ply + 1
	cmpl	%eax, -40(%rbp)
	jge		_negamaxPlyLoopEnd

	# get ply
	movl	ply, %ecx

	# increment ply copy
	addl	$1, %ecx

	# get next ply
	movl	-40(%rbp), %edx
	movslq	%ecx, %rax

	# calculate address
	salq	$6, %rax
	addq	%rdx, %rax

	# get pv table address
	leaq	pv_table, %rdx

	# get move from pv table
	movl	(%rdx,%rax,4), %eax

	# get ply
	movl	ply, %edx

	# get next ply
	movl	-40(%rbp), %ecx

	# calculate index
	salq	$6, %rdx
	addq	%rdx, %rcx

	# get pv table address
	leaq	pv_table, %rdx

	# copy move from deeper ply into a current ply's line
	movl	%eax, (%rdx,%rcx,4)

	# increment next ply
	addl	$1, -40(%rbp)

	# repeat loop
	jmp		_negamaxPlyLoopBeg

_negamaxPlyLoopEnd:
	# adjust PV length
	# get ply
	movl	ply, %eax
	addl	$1, %eax

	# get pv length table address
	leaq	pv_length, %rdx

	# get pv length at ply + 1
	movl	(%rdx,%rax,4), %eax

	# get ply
	movl	ply, %ecx

	# get pv length table address
	leaq	pv_length, %rdx

	# adjust PV length at ply
	movl	%eax, (%rdx,%rcx,4)

_negamaxMoveLoopNext:
	# increment move counter
	incl	-32(%rbp)

_negamaxMoveLoopEnd:
	movl	-64(%rbp), %eax
	cmpl	%eax, -32(%rbp)
	jl		_negamaxMoveLoopBeg

	# check if any leagl moves available
	cmpl	$0, -24(%rbp)
	jne		_negamaxLegalMovesNotZero
	
	# check if king is in check
	cmpl	$0, -44(%rbp)
	je		_negamaxStalemate

	# return mating score
	movl	ply, %eax
	subl	$49000, %eax
	jmp		_negamaxEnd

_negamaxStalemate:
	# return stalemate score (draw)
	movl	$0, %eax
	jmp	_negamaxEnd

_negamaxLegalMovesNotZero:
	# return alpha
	movl	-1220(%rbp), %eax

_negamaxEnd:
	# restore calle reserved register
	movq	-8(%rbp), %rbx
	
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# searches for the best move in the position and displaying the results
# 1 argument: (1) 4-byte depth
# returns void
searchPosition:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# make space on stack
	subq	$32, %rsp

	# save args on stack
	movl	%edi, -20(%rbp)

	# init score
	movl	$0, -12(%rbp)

	# reset nodes
	movq	$0, nodes

	# reset follow_pv flag
	movl	$0, follow_pv

	# reset score_pv flag
	movl	$0, score_pv

	# reset killer_moves table
	movl	$512, %edx
	movl	$0, %esi
	leaq	killer_moves, %rdi
	call	memset

	# reset history_moves table
	movl	$3072, %edx
	movl	$0, %esi
	leaq	history_moves, %rdi
	call	memset

	# reset pv_table table
	movl	$16384, %edx
	movl	$0, %esi
	leaq	pv_table, %rdi
	call	memset

	# reset pv_length table
	movl	$256, %edx
	movl	$0, %esi
	leaq	pv_length, %rdi
	call	memset

	# start iterative deepening from 1 to specified depth
	movl	$1, -4(%rbp)

_searchPositionLoopBeg:
	movl	-4(%rbp), %eax
	cmpl	-20(%rbp), %eax
	jg		_searchPositionLoopEnd

	# enable follow_pv flag
	movl	$1, follow_pv

	# call negamax subroutine
	movl	-4(%rbp), %edx
	movl	$50000, %esi
	movl	$-50000, %edi
	call	negamax

	# store score from negamax search
	movl	%eax, -12(%rbp)

	# print search results
	movq	nodes, %rcx
	movl	-4(%rbp), %edx
	movl	-12(%rbp), %esi
	leaq	_printInfoScore, %rdi
	movl	$0, %eax
	call	printf

	# loop over PV moves
	movl	$0, -8(%rbp)
	
_searchPositionPVLoopBeg:
	movl	pv_length, %eax
	cmpl	%eax, -8(%rbp)
	jge		_searchPositionPVLoopEnd

	# print PV move
	movl	-8(%rbp), %eax
	leaq	0(,%rax,4), %rdx
	leaq	pv_table, %rax
	movl	(%rdx,%rax), %eax
	movl	%eax, %edi
	call	printMove

	# print space
	movl	$32, %edi
	call	putchar

	incl	-8(%rbp)
	jmp 	_searchPositionPVLoopBeg

_searchPositionPVLoopEnd:
	# print '\n'
	movl	$10, %edi
	call	putchar

	# increment depth
	incl	-4(%rbp)

	jmp		_searchPositionLoopBeg

_searchPositionLoopEnd:
	# print bestmove string
	leaq	_printBestmove, %rdi
	movl	$0, %eax
	call	printf

	# print the first move in pv_table
	movl	pv_table, %edi
	call	printMove

	# print '\n'
	movl	$10, %edi
	call	putchar

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp
	
	ret

# --------------------------------------------

# searches for the best move in the position and displaying the results
# 1 argument: (1) 4-byte depth
# returns 4-byte encoded move
search:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# make space on stack
	subq	$32, %rsp

	# save args on stack
	movl	%edi, -20(%rbp)

	# init score
	movl	$0, -12(%rbp)

	# reset nodes
	movq	$0, nodes

	# reset follow_pv flag
	movl	$0, follow_pv

	# reset score_pv flag
	movl	$0, score_pv

	# reset killer_moves table
	movl	$512, %edx
	movl	$0, %esi
	leaq	killer_moves, %rdi
	call	memset

	# reset history_moves table
	movl	$3072, %edx
	movl	$0, %esi
	leaq	history_moves, %rdi
	call	memset

	# reset pv_table table
	movl	$16384, %edx
	movl	$0, %esi
	leaq	pv_table, %rdi
	call	memset

	# reset pv_length table
	movl	$256, %edx
	movl	$0, %esi
	leaq	pv_length, %rdi
	call	memset

	# start iterative deepening from 1 to specified depth
	movl	$1, -4(%rbp)

_searchLoopBeg:
	movl	-4(%rbp), %eax
	cmpl	-20(%rbp), %eax
	jg		_searchLoopEnd

	# enable follow_pv flag
	movl	$1, follow_pv

	# call negamax subroutine
	movl	-4(%rbp), %edx
	movl	$50000, %esi
	movl	$-50000, %edi
	call	negamax

	# store score from negamax search
	movl	%eax, -12(%rbp)

	# increment depth
	incl	-4(%rbp)

	jmp		_searchLoopBeg

_searchLoopEnd:
	# return the first move in pv_table
	movl	pv_table, %eax

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp
	
	ret
