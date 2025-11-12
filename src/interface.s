.text

# parse user move string input (ex. "e2e4")
# 1 argument: (1) address of move string
# returns 4-byte encoded move
parseMove:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp
	
	# make space on stack
	subq	$1064, %rsp

	# store move string address on the stack
	movq	%rdi, -1064(%rbp)

	# get move list address
	leaq	-1056(%rbp), %rdi

	# generate moves and populate the move list
	call	genMoves

	# move string address
	movq	-1064(%rbp), %rax

	# get only 1-byte char
	movzbl	(%rax), %ecx

	# get numeric value of file (substract 97('a'))
	subl	$97, %ecx
	
	# copy string address
	movq	-1064(%rbp), %rax

	# get only 1-byte char at index 1
	movzbl	1(%rax), %edx

	# 8 + 48('0') = 56
	movl	$56, %eax

	# substract to get rank
	subl	%edx, %eax

	# shif left (mul 3)
	shll	$3, %eax

	# combine file and rank to get source square
	addl	%ecx, %eax

	# store source square
	movl	%eax, -8(%rbp)

	# move string address
	movq	-1064(%rbp), %rax

	# get only 1-byte char ata index 2
	movzbl	2(%rax), %ecx

	# get numeric value of file (substract 97('a'))
	subl	$97, %ecx

	# move string address
	movq	-1064(%rbp), %rax

	# get only 1-byte char at index 3
	movzbl	3(%rax), %edx

	# 8 + 48('0') = 56
	movl	$56, %eax

	# substract to get rank
	subl	%edx, %eax

	# shif left (mul 3)
	shll	$3, %eax

	# combine file and rank to get target square
	addl	%ecx, %eax

	# store target square
	movl	%eax, -12(%rbp)

	# init move counter at 0
	movl	$0, -4(%rbp)

	# loop over all the moves in the move list to match the source square and target square
_parseMoveLoopBeg:
	# get move count
	movl	-32(%rbp), %eax

	cmpl	%eax, -4(%rbp)
	jge		_parseMoveLoopEnd

	# get move counter
	movl	-4(%rbp), %eax

	# get move at counter position
	movl	-1056(%rbp,%rax,4), %eax

	# store move 
	movl	%eax, -16(%rbp)

	# get move
	movl	%eax, %edi

	# get source square
	call	getMoveSrc

	# check if source squares match
	cmpl	%eax, -8(%rbp)
	jne		_parseMoveLoopNext

	# get move
	movl	-16(%rbp), %edi

	# get target square
	call	getMoveTrg

	# check if target squares match
	cmpl	%eax, -12(%rbp)
	jne		_parseMoveLoopNext

	# get move
	movl	-16(%rbp), %edi

	# get promoted piece
	call 	getMovePromoted

	# store promoted piece
	movl	%eax, -20(%rbp)

	# check if there is promotion
	cmpl	$0, -20(%rbp)
	je		_parseMoveNoPromotion

	# check if promotion piece is white queen
	cmpl	$Q, -20(%rbp)
	je		_parseMovePromotionQueen

	# check if promotion piece is black queen
	cmpl	$q, -20(%rbp)
	jne		_parseMovePromotionCheckRook

_parseMovePromotionQueen:
	# get move string address
	movq	-1064(%rbp), %rax

	# increment address by 4 to get the 5th char
	addq	$4, %rax

	# get only 1-byte char
	movzbl	(%rax), %eax

	# check if char is 'q'
	cmpb	$113, %al
	jne		_parseMovePromotionCheckRook

	# return move
	movl	-16(%rbp), %eax
	jmp		_parseMoveEnd

_parseMovePromotionCheckRook:
	# check if promotion piece is white rook
	cmpl	$R, -20(%rbp)
	je		_parseMovePromotionRook

	# check if promotion piece is black rook
	cmpl	$r, -20(%rbp)
	jne		_parseMovePromotionCheckBishop

_parseMovePromotionRook:
	# get move string address
	movq	-1064(%rbp), %rax

	# increment address by 4 to get the 5th char
	addq	$4, %rax

	# get only 1-byte char
	movzbl	(%rax), %eax

	# check if char is 'r'
	cmpb	$114, %al
	jne		_parseMovePromotionCheckBishop

	# return move
	movl	-16(%rbp), %eax
	jmp		_parseMoveEnd

_parseMovePromotionCheckBishop:
	# check if promotion piece is white bishop
	cmpl	$B, -20(%rbp)
	je		_parseMovePromotionBishop

	# check if promotion piece is black bishop
	cmpl	$b, -20(%rbp)
	jne		_parseMovePromotionCheckKnight

_parseMovePromotionBishop:
	# get move string address
	movq	-1064(%rbp), %rax

	# increment address by 4 to get the 5th char
	addq	$4, %rax

	# get only 1-byte char
	movzbl	(%rax), %eax

	# check if char is 'b'
	cmpb	$98, %al
	jne		_parseMovePromotionCheckKnight

	# return move
	movl	-16(%rbp), %eax
	jmp	_parseMoveEnd

_parseMovePromotionCheckKnight:
	# check if promotion piece is white knight
	cmpl	$N, -20(%rbp)
	je		_parseMovePromotionKnight
	
	# check if promotion piece is black knight
	cmpl	$n, -20(%rbp)
	jne		_parseMoveLoopNext

_parseMovePromotionKnight:
	# get move string address
	movq	-1064(%rbp), %rax

	# increment address by 4 to get the 5th char
	addq	$4, %rax

	# get only 1-byte char
	movzbl	(%rax), %eax

	# check if char is 'n'
	cmpb	$110, %al
	jne		_parseMoveLoopNext

	# return move
	movl	-16(%rbp), %eax
	jmp		_parseMoveEnd

_parseMoveNoPromotion:
	# return move
	movl	-16(%rbp), %eax
	jmp		_parseMoveEnd
	
_parseMoveLoopNext:
	# increment move counter
	incl	-4(%rbp)

	# repeat move loop
	jmp		_parseMoveLoopBeg

_parseMoveLoopEnd:

	# return illegal move
	movl	$0, %eax

_parseMoveEnd:
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp
	
	ret

# --------------------------------------------

# parse user position string input (ex. "startpos")
# 1 argument: (1) address of move string
# returns void
parsePosition:
    # prologue
	pushq	%rbp
	movq	%rsp, %rbp

    # make space so the stack
    subq    $32, %rsp

    # store address of move string
    movq    %rdi, -8(%rbp)

    # check if startpos
    movq    $uci_startpos, %rsi
    movq    $8, %rdx
    call    strncmp

    testl   %eax, %eax
    jne     _parsePositionFEN

_parsePositionStartpos:
    movq    $start_pos, %rdi
    call    parseFEN

    jmp     _parsePositionMoves


_parsePositionFEN:
    # check if fen
    movq    -8(%rbp), %rdi
    movq    $uci_fen, %rsi
    movq    $3, %rdx
    call    strncmp

    # go to startpos if not fen
    testl   %eax, %eax
    jne     _parsePositionStartpos

    addq    $4, -8(%rbp)
    movq    -8(%rbp), %rdi
    call    parseFEN

_parsePositionMoves:
    # get moves string address
	leaq	_uci_moves, %rsi

    # get position string address
	movq	-8(%rbp), %rdi

    # get moves string address in position string
	call	strstr

    # store moves string address
    movq    %rax, -16(%rbp)

    # check if moves string address is available
    cmpq    $0, -16(%rbp)
    je      _parsePositionEnd

    # skip "moves " string 
    addq    $6, -16(%rbp)

_parsePositionMovesLoopBeg:
    # get moves address
    movq	-16(%rbp), %rax

    # get char from moves address
	movzbl	(%rax), %eax

    # check if any move moves left to handle
	testb	%al, %al
	je	    _parsePositionEnd

    # get move string address
    movq	-16(%rbp), %rdi

    # get encoded move 
	call	parseMove

    # store move
	movl	%eax, -20(%rbp)

    # check if no more moves
    cmpl	$0, -20(%rbp)
    je	    _parsePositionMovesIllegal

    # make move 
    movl    $all_moves, %esi
    movl    %eax, %edi
    call    makeMove

    testl   %eax, %eax
    je      _parsePositionMovesIllegal

    # we checked if the move is legal so no need to check it again
_parsePositionMovesGoNextLoopBeg:
    # get moves string address
    movq	-16(%rbp), %rax

    # get 1-byte char
	movzbl	(%rax), %eax

    # check if not end of string
	testb	%al, %al
	je	    _parsePositionEnd

    # get moves string address
    movq	-16(%rbp), %rax

    # get 1-byte char
	movzbl	(%rax), %eax

    # check if space char
    cmpb	$32, %al
    je      _parsePositionMovesGoNextLoopEnd

    # increment moves string address
    incq    -16(%rbp)  

    jmp      _parsePositionMovesGoNextLoopBeg

_parsePositionMovesGoNextLoopEnd:
    # increment moves string address
    incq    -16(%rbp)

    jmp     _parsePositionMovesLoopBeg

_parsePositionMovesIllegal:
    # print illegal moves
    movq    _uci_moves_illegal, %rdi
    call    puts

_parsePositionEnd:
    # epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# parse go command (makes egine pick best move)
# 1 argument: (1) address of move string
# returns void
parseGo:
    # prologue
	pushq	%rbp
	movq	%rsp, %rbp

    # make space on the stack
    subq    $16, %rsp

    # store go command string 
    movq    %rdi, -12(%rbp)

    # set default depth as 6
    movl    $6, -4(%rbp)

    # check if depth explicit
    movq    $_uci_depth, %rsi
    movq    $5, %rdx
    call    strncmp

    # check if specified depth
    testl   %eax, %eax
    jne     _parseGoCheckEnd

    # skip "depth" string
    addq    $6, -12(%rbp)

    # get depth as integer
    movq    -12(%rbp), %rdi
    call    atoi

    # store depth
    movl    %eax, -4(%rbp)

_parseGoCheckEnd:   
    # get depth
    movl    -4(%rbp), %edi

    # search position
    call    searchPosition

    # epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# main loop
# 0 arguments
# returns void
uci:
    # prologue
	pushq	%rbp
	movq	%rsp, %rbp

    # make space on the stack
    subq    $512, %rsp

    # print engine info
    movq    $uci_name, %rdi
    call    puts
    movq    $uci_ok, %rdi
    call    puts


_uciLoopBeg:
    # set input array to 0
    movq    $496, %rdx
    movq    $0, %rsi
    leaq    -496(%rbp), %rdi
    call    memset

    # buffer address
    leaq    -496(%rbp), %rax
    movq    %rax, -504(%rbp)

    # set buffer size
    movq    $496, -512(%rbp)

    # get input line from stdin
    movq    stdin, %rdx
    leaq    -512(%rbp), %rsi
    leaq    -504(%rbp), %rdi
    call    getline

_uciMove:
    # check if move command
    movq    $4, %rdx
    movq    $uci_move, %rsi
    movq    -504(%rbp), %rdi
    call    strncmp

    testl   %eax, %eax
    jne     _uciPosition

    # skip "move " string
    addq    $5, -504(%rbp)

    # parse position from string
    movq    -504(%rbp), %rdi
    call    parseMove

    # check if illegal
    testl   %eax, %eax
    je      _uciMoveIllegal

    movl    $all_moves, %esi
    movl    %eax, %edi
    call    makeMove

    # reset terminal
    movq    $uci_reset_teminal, %rdi
    movq    $0, %rax
    call    printf

    # print board
    call printBoard

    # get engine move
    movl    $7, %edi
    call    search

    # make engine move
    movl    $all_moves, %esi
    movl    %eax, %edi
    call    makeMove

    testl   %eax, %eax
    je      _uciMoveWin

    # reset terminal
    movq    $uci_reset_teminal, %rdi
    movq    $0, %rax
    call    printf

    # print board
    call printBoard

    jmp     _uciLoopNext

_uciMoveIllegal:
    # print illegal move message
    movq    $_uci_move_illegal, %rdi
    call    puts

    jmp     _uciLoopNext

_uciMoveWin:

    leaq    _uci_win, %rdi
    call    puts

    jmp     _uciLoopNext

_uciPosition:
    # check if position command
    movq    $8, %rdx
    movq    $uci_position, %rsi
    movq    -504(%rbp), %rdi
    call    strncmp

    testl   %eax, %eax
    jne     _uciFlip

    # skip "position " string
    addq    $9, -504(%rbp)

    # parse position from string
    movq    -504(%rbp), %rdi
    call    parsePosition

    # reset terminal
    movq    $uci_reset_teminal, %rdi
    movq    $0, %rax
    call    printf

    # print board
    call printBoard

    jmp     _uciLoopNext

_uciFlip:
    # check if position command
    movq    $4, %rdx
    movq    $uci_flip, %rsi
    movq    -504(%rbp), %rdi
    call    strncmp

    testl   %eax, %eax
    jne     _uciGo

    # change the fliped value
    xorb    $1, fliped

    # reset terminal
    movq    $uci_reset_teminal, %rdi
    movq    $0, %rax
    call    printf

    # print board
    call printBoard

    jmp     _uciLoopNext

_uciGo:
    # check if position command
    movq    $2, %rdx
    movq    $uci_go, %rsi
    movq    -504(%rbp), %rdi
    call    strncmp

    testl   %eax, %eax
    jne     _uciIsready

    # skip "position " string
    addq    $3, -504(%rbp)

    # parse position from string
    movq    -504(%rbp), %rdi
    call    parseGo

    jmp     _uciLoopNext

_uciIsready:
    # check if isready command
    movq    $7, %rdx
    movq    $uci_isready, %rsi
    movq    -504(%rbp), %rdi
    call    strncmp

    testl   %eax, %eax
    jne     _uciQuit

    # print readyok
    movq    $uci_ok, %rdi
    call    puts

    jmp     _uciLoopNext

_uciQuit:
    # check if quit command
    movq    $4, %rdx
    movq    $uci_quit, %rsi
    movq    -504(%rbp), %rdi
    call    strncmp

    testl   %eax, %eax
    je     _uciEnd

    # check if q command
    movq    $1, %rdx
    movq    $uci_q, %rsi
    movq    -504(%rbp), %rdi
    call    strncmp

    testl   %eax, %eax
    jne     _uciLoopNext

    jmp     _uciEnd

_uciLoopNext:
    jmp     _uciLoopBeg


_uciEnd:
    # epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

