.text


# sets bitboards, occupancies, enpassant square and castling rights 
#       based on the FEN string
# 1 argument: (1) address of FEN string
# returns void
parseFEN:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $64, %rsp
    movq    %rdi, -56(%rbp)

    # empty bitboards and occupancies
    movl    $96, %edx
	movl    $0, %esi
	movq    $bitboards, %rdi
    call    memset

    movl    $24, %edx
	movl    $0, %esi
	movq    $occupancies, %rdi
	call    memset

    # empty board state
    movl    $0, side
    movl    $no_sq, enpassant
    movl    $0, castle

# iterate through each ranks
    movl    $0, -4(%rbp)
_parseFENRankLoopBeg:
    cmpl    $8, -4(%rbp)
    jge     _parseFENRankLoopEnd

# iterate through each file 
    movl    $0, -8(%rbp)
_parseFENFileLoopBeg:
    cmpl    $8, -8(%rbp)
    jge     _parseFENFileLoopEnd

    # init curret square
    movl    -4(%rbp), %eax

    # mul 8 rank
    shll    $3, %eax

    # calculate square
    addl    -8(%rbp), %eax

    # store square
    movl    %eax, -36(%rbp)

    #check if FEN char is an lowers case letter
_parseFENLowerCaseIf:
    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax

    # make sure char is a lowercase letter
    # 'a' = 97, 'z' = 122
    cmpb    $97, %al
    jl      _parseFENUpperCaseIf
    cmpb    $122, %al
    jle     _parseFENCharCaseBody

     #check if FEN char is an upper case letter
_parseFENUpperCaseIf:
    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax

    # make sure char is an uppercase letter
    # 'A' = 65, 'Z' = 90
    cmpb    $65, %al
    jl      _parseFENCharCaseIfEnd
    cmpb    $90, %al
    jg      _parseFENCharCaseIfEnd

_parseFENCharCaseBody:
    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax
    
    # get char pieces table address
    leaq    char_pieces, %rdx
    
    # get piece numeric
    movl    (%rdx,%rax,4), %eax

    # store piece
    movl    %eax, -40(%rbp)
    
    # mul 8
    shlq    $3, %rax

    # get bitboard table address
    leaq    bitboards, %rdx
    
    # calculate piece's bitboard address 
    addq    %rax, %rdx

    # get square
    movl    -36(%rbp), %esi

    # get piece's bitboad 
    movq    %rdx, %rdi
    call    setBit

    # increment FEN address
    incq    -56(%rbp)

_parseFENCharCaseIfEnd:
    # check if FEN char is a number
_parseFENCharNumIf:
    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax

    # '0' = 48, '9' = 57
	cmpb    $48, %al
    jl      _parseFENCharNumIfEnd
    cmpb    $57, %al
    jg      _parseFENCharNumIfEnd

_parseFENCharNumIfBody:
    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax

    # get numeric value - '0' = 48
    subl	$48, %eax

    # store offset
    movl	%eax, -44(%rbp)

    # init piece final
    movl    $-1, -12(%rbp) # piece

    # init looping piece
    movl    $P, -16(%rbp)

    # loop over all pieces and check if empty squares after piece
    # on new rank it breaks - prevent it 
_parseFENPieceLoopBeg:
    cmpl    $k, -16(%rbp)
    jg      _parseFENPieceLoopEnd

    # get looping piece  
    movl	-16(%rbp), %eax
	
    # get bitboard table address
    leaq    bitboards, %rdx

    # get piece's bitboard
    movq    (%rdx,%rax,8), %rdi

    # get square
    movl    -36(%rbp), %esi
    call    getBit

    # check if piece on the square
    testq	%rax, %rax
    je      _parseFENPieceLoopNext

    # piece found, store in final piece
    movl	-16(%rbp), %eax
	movl	%eax, -12(%rbp)

_parseFENPieceLoopNext:
    # increment looping piece
    incl    -16(%rbp)
    jmp     _parseFENPieceLoopBeg

_parseFENPieceLoopEnd:
_parseFENPieceFoundIf:
    cmpl    $-1, -12(%rbp)
    jne     _parseFENPieceFoundIfEnd

    # decrement file (because new rank)
    decl    -8(%rbp)

_parseFENPieceFoundIfEnd:
    # file += offset
    movl	-44(%rbp), %eax
	addl	%eax, -8(%rbp)

    # increment fen string
    incq    -56(%rbp)

_parseFENCharNumIfEnd:
_parseFENNewRankIf:
    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax

    # check if '/' = 47 (end of rank)
    cmpb	$47, %al
    jne     _parseFENNewRankIfEnd

    # increment fen string
    incq    -56(%rbp)

_parseFENNewRankIfEnd:
    # increment file 
    incl    -8(%rbp)

    # repeat file loop
    jmp     _parseFENFileLoopBeg

_parseFENFileLoopEnd:
    # increment rank
    incl    -4(%rbp)

    # repeat rank loop
    jmp     _parseFENRankLoopBeg

_parseFENRankLoopEnd:
    # increment FEN address
    incq    -56(%rbp)

    # set side
_parseFENSideIf:
    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax

    # check if 'w' - 119
	cmpb	$119, %al
    jne     _parseFENSideIfElse

    # set side to white
    movl    $white, side
    jmp     _parseFENSideIfEnd

_parseFENSideIfElse:
    # set side to black
    movl	$black, side

_parseFENSideIfEnd:
    # increment FEN address by 2
    addq    $2, -56(%rbp)

    # set castling rights
_parseFENCastlingLoopBeg:
    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax

    # check if ' ' (space) - 32
	cmpb	$32, %al
    je      _parseFENCastlingLoopEnd

_parseFENCastlingIf:
    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax

    # check if 'q' - 113
	cmpl	$113, %eax
    je      _parseFENCastlingIfBQ

    # check if 'q' - 113
    cmpl	$113, %eax
    jg      _parseFENCastlingLoopEnd

    # check if 'k' - 107
    cmpl    $107, %eax
	je      _parseFENCastlingIfBK

    # check if 'k' - 107
	cmpl    $107, %eax
	jg      _parseFENCastlingIfEnd

    # check if 'Q' - 81
    cmpl	$81, %eax
	je      _parseFENCastlingIfWQ

    # check if 'Q' - 81
	cmpl	$81, %eax
	jg      _parseFENCastlingIfEnd

    # check if 'K' - 75
    cmpl    $75, %eax
    je      _parseFENCastlingIfWK
    jmp     _parseFENCastlingIfEnd

_parseFENCastlingIfBQ:
    # add black queen side castling
    movl    castle, %eax
    orl     $bq, %eax
    movl    %eax, castle

    jmp     _parseFENCastlingIfEnd

_parseFENCastlingIfBK:
    # add black king side castling
    movl    castle, %eax
    orl     $bk, %eax
    movl    %eax, castle

    jmp     _parseFENCastlingIfEnd

_parseFENCastlingIfWQ:
    # add white queen side castling
    movl    castle, %eax
    orl     $wq, %eax
    movl    %eax, castle

    jmp     _parseFENCastlingIfEnd

_parseFENCastlingIfWK:
    # add white king side castling
    movl    castle, %eax
    orl     $wk, %eax
    movl    %eax, castle

_parseFENCastlingIfEnd:
    # increment FEN address
    incq    -56(%rbp)

    # repeat the catling right loop
    jmp     _parseFENCastlingLoopBeg

_parseFENCastlingLoopEnd:
    # increment FEN address
    incq    -56(%rbp)

_parseFENEnpassantIf:
    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax

    # check if '-' char (no enpassant)
	cmpb	$45, %al
    je      _parseFENEnpassantIfElse

_parseFENEnpassantIfBody:

    # get fen string address
    movq	-56(%rbp), %rax

    # get fen string char
	movzbl	(%rax), %eax
    
    # calculate enpasant file - 'a' = 97
    subl	$97, %eax

    # file number
    movl	%eax, -28(%rbp)

    # get fen string address
    movq	-56(%rbp), %rax

    # skip file char and get rank number
	addq	$1, %rax

    # get fen string char
	movzbl	(%rax), %eax
    
    # calculate enpasant rank
    # 8 - (rank - '0') = 56, '0' = 48
    movl	$56, -32(%rbp)
	subl	%eax, -32(%rbp)

    # get rank
	movl	-32(%rbp), %eax

    # mul 8 - every rank is 8 square
    shlq    $3, %rax

    # get file
    movl    -28(%rbp), %edx

    # calculate enpasant square
    addl    %edx, %eax
    movl    %eax, enpassant

    jmp     _parseFENEnpassantIfEnd

_parseFENEnpassantIfElse:
    # set enpassant to no_sq
    movl    $no_sq, enpassant

_parseFENEnpassantIfEnd:

    # init white occupancy piece
    movl    $P, -20(%rbp)

    # loop over all white pieces
_parseFENWhiteOccupanciesLoopBeg:
    cmpl    $K, -20(%rbp)
    jg      _parseFENWhiteOccupanciesLoopEnd

    # get piece bitboard 
	movl	-20(%rbp), %eax
    
    # get bitboard table address
    leaq    bitboards, %rdx

    # get piece's bitboard
    movq    (%rdx,%rax,8), %rax

    # add bitboard to occupancy
    orq     %rax, occupancies

    # increment white occupancy piece
    incl    -20(%rbp)

    # repeat the white occupancies loop
    jmp     _parseFENWhiteOccupanciesLoopBeg

_parseFENWhiteOccupanciesLoopEnd:

    # init black occupancy piece
    movl    $p, -24(%rbp)

    # loop over all black pieces
_parseFENBlackOccupanciesLoopBeg:
    cmpl    $k, -24(%rbp)
    jg      _parseFENBlackOccupanciesLoopEnd

    # get piece bitboard
	movl	-24(%rbp), %eax
    
    # get bitboard table address
    leaq    bitboards, %rcx

    # get piece's bitboard
    movq    (%rdx,%rax,8), %rax

    # add bitboard to occupancy
    orq     %rax, 8+occupancies

    # increment black occupancy piece
    incl    -24(%rbp)

    # repeat the black occupancies loop
    jmp     _parseFENBlackOccupanciesLoopBeg

    # set occupancies for both
_parseFENBlackOccupanciesLoopEnd:
    # white occupancy
    movq	16+occupancies, %rdx
	movq	occupancies, %rax
	orq	    %rdx, %rax
	movq	%rax, 16+occupancies

    # black occupancy
    movq	16+occupancies, %rdx
	movq	8+occupancies, %rax
	orq	    %rdx, %rax
	movq	%rax, 16+occupancies

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# determins the square color
# 2 arguments: (1) rank, (2) file
# returns (8-byte) string adderss
getANSI:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $8, %rsp

    movl    %edi, -4(%rbp)
    movl    %esi, -8(%rbp)

    # check if rank is even or odd
    andl    $1, %edi

    testl   %edi, %edi
    jne     _getANSIRankOdd

    # check if file is even or odd
    andl    $1, %esi

    testl   %esi, %esi
    jne     _getANSIRankEvenFileOdd

    # return white
    movq    $_ansiWhite, %rax

    jmp     _getANSIEnd

_getANSIRankEvenFileOdd:
    # return cyan
    movq    $_ansiCyan, %rax

    jmp     _getANSIEnd

_getANSIRankOdd:
    # check if file is even or odd
    andl    $1, %esi

    testl   %esi, %esi
    jne     _getANSIRankOddFileOdd

    # return cyan
    movq    $_ansiCyan, %rax

    jmp     _getANSIEnd

_getANSIRankOddFileOdd:
    # return white
    movq    $_ansiWhite, %rax

_getANSIEnd:
    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# prints board either from white perspective or black perspective
#   based on "fliped" value
# 0 arguments
# returns void
printBoard:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    movzbl  fliped, %eax
    testl   %eax, %eax

    jne     _printBoardBlack

    call    printBoardWhite

    jmp     _printBoardEnd

_printBoardBlack:
    call    printBoardBlack

_printBoardEnd:
    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# prints cuurent state of the board from white perspective
# 0 arguments
# returns void
printBoardWhite:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # allocate 16 bytes on the stack
    subq	$16, %rsp

    # print new line char ('\n')
	movl	$10, %edi
	call	putchar

    # init rank at 0
    movb    $0, -1(%rbp)
_printBoardWhiteRankLoopBeg:
    cmpb    $8, -1(%rbp)
	jae     _printBoardWhiteRankLoopEnd

    # init file at 0
    movb    $0, -2(%rbp)

_printBoardWhiteFileLoopBeg:
    cmpb    $8, -2(%rbp)
	jae     _printBoardWhiteFileLoopEnd

    # calculate square
    movb    -1(%rbp), %al
    shlb    $3, %al
    addb    -2(%rbp), %al
    movb    %al, -3(%rbp)

    # check if begining of the file
_printBoardWhiteNotFileIf:
    cmpb    $0, -2(%rbp)
    jne      _printBoardWhiteNotFileIfEnd

    # calculate rank marking
    movzbl  -1(%rbp), %edx
    movl    $8, %esi
    subl    %edx, %esi

    # print rank marking
    movq    $_printStrRank, %rdi
    movq    $0, %rax
    call    printf

_printBoardWhiteNotFileIfEnd:
    #init piece holder
    movb    $no_piece, -4(%rbp)

    # init piece
    movb    $P, -5(%rbp)

    # loop over all pieces
_printBoardWhitePieceLoopBeg:
    cmpb    $k, -5(%rbp)
    ja      _printBoardWhitePieceLoopEnd

    # check if piece on current square
    movzbl  -5(%rbp), %eax
    
    shlq    $3, %rax
    movq    $bitboards, %rdx
    add     %rax, %rdx
    movzbl  -3(%rbp), %esi
    movq    (%rdx), %rdi
    call    getBit

    # check if equals 0
    testq   %rax, %rax
    je      _printBoardWhiteCheckPieceIfEnd

    # move piece to piece holder
    movb    -5(%rbp), %al
    movb    %al, -4(%rbp)
    jmp     _printBoardWhitePieceLoopEnd

_printBoardWhiteCheckPieceIfEnd:

    # increment piece
    incb    -5(%rbp)

    # repeat piece loop
    jmp     _printBoardWhitePieceLoopBeg

_printBoardWhitePieceLoopEnd:
    movzbl  -1(%rbp), %edi
    movzbl  -2(%rbp), %esi
    call    getANSI
    movq    %rax, -16(%rbp)


    # check if no piece
_printBoardWhitePrintPieceIf:
    cmpb    $no_piece, -4(%rbp)
    je      _printBoardWhitePrintPieceIfElse

    # get unicode piece value
    movzbl	-4(%rbp), %eax
	
	shlq	$3, %rax
	movq	$unicode_pieces, %rdx
    addq    %rdx, %rax
	movq	(%rax), %rdx

    jmp     _printBoardWhitePrintPieceIfEnd

_printBoardWhitePrintPieceIfElse:
    movq    $_printBoardStrNoPiece, %rdx

_printBoardWhitePrintPieceIfEnd:
    # print unicode piece
    movq    $_ansiOff, %rcx
    movq    -16(%rbp), %rsi
    movq    $_printBoardStrPiece, %rdi
    movq    $0, %rax
    call    printf

    # increment file
    incb    -2(%rbp)

    # repeat file loop
    jmp     _printBoardWhiteFileLoopBeg

_printBoardWhiteFileLoopEnd:
    # print new line char ('\n')
	movl	$10, %edi
	call	putchar

    # increment rank
    incb    -1(%rbp)

    # repeat file loop
    jmp     _printBoardWhiteRankLoopBeg

_printBoardWhiteRankLoopEnd:
    # print file markings
    movq    $_printStrFiles, %rdi
    call    puts

_printBoardWhiteSideIf:
    # get side
    movl    side, %eax
    testl   %eax, %eax
    jne     _printBoardWhiteSideIfElse
    movq    $_printBoardStrSideWhite, %rsi

    jmp     _printBoardWhiteSideIfEnd

_printBoardWhiteSideIfElse:
    movq    $_printBoardStrSideBlack, %rsi

_printBoardWhiteSideIfEnd:
    # print side
    movq    $_printBoardStrSide, %rdi
    movq    $0, %rax
    call    printf

    # check if enpassant is no_sq
    movl    enpassant, %eax
    cmpl    $no_sq, %eax
    je      _printBoardWhiteEnpassantNoSq

    # get enpassant coodinate
    movl    enpassant, %eax
    shll    $3, %eax
    
    movq    $square_to_coordinates, %rdx
    addq    %rax, %rdx
    movq    (%rdx), %rsi

    jmp     _printBoardWhiteEnpassantEnd

_printBoardWhiteEnpassantNoSq:
    movq    $_printBoardStrNoSq, %rsi

_printBoardWhiteEnpassantEnd:
    # print enpassant coordinate
    movq    $_printBoardStrEnpassant, %rdi
    movq    $0, %rax
    call    printf

    # print castling rights
_printBoardWhiteCastlingBQ:
    movl    castle, %eax
    andl    $bq, %eax
    testl   %eax, %eax
    je      _printBoardWhiteNoCastllingBQ
    movl    $113, %r8d
    jmp     _printBoardWhiteCastlingBK

_printBoardWhiteNoCastllingBQ:
    movl	$45, %r8d

_printBoardWhiteCastlingBK:
    movl    castle, %eax
    andl    $bk, %eax
    testl   %eax, %eax
    je      _printBoardWhiteNoCastllingBK
    movl    $107, %ecx
    jmp     _printBoardWhiteCastlingWQ

_printBoardWhiteNoCastllingBK:
	movl	$45, %ecx

_printBoardWhiteCastlingWQ:
    movl    castle, %eax
    andl    $wq, %eax
    testl   %eax, %eax
    je      _printBoardWhiteNoCastllingWQ
    movl    $81, %edx
    jmp     _printBoardWhiteCastlingWK

_printBoardWhiteNoCastllingWQ:
    movl	$45, %edx

_printBoardWhiteCastlingWK:
    movl    castle, %eax
    andl    $wk, %eax
    testl   %eax, %eax
    je      _printBoardWhiteNoCastllingWK
    movl    $75, %esi
    jmp     _printBoardWhiteCastlingEnd

_printBoardWhiteNoCastllingWK:
    movl	$45, %esi

_printBoardWhiteCastlingEnd:
    movq    $_printBoardStrCastling, %rdi
    movq    $0, %rax
    call    printf

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# prints cuurent state of the board from black perspective
# 0 arguments
# returns void
printBoardBlack:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # allocate 16 bytes on the stack
    subq	$16, %rsp

    # print new line char ('\n')
	movl	$10, %edi
	call	putchar

    # init rank at 7
    movb    $7, -1(%rbp)
_printBoardBlackRankLoopBeg:
    cmpb    $0, -1(%rbp)
	jl     _printBoardBlackRankLoopEnd

    # init file at 0
    movb    $7, -2(%rbp)

_printBoardBlackFileLoopBeg:
    cmpb    $0, -2(%rbp)
	jl     _printBoardBlackFileLoopEnd

    # calculate square
    movb    -1(%rbp), %al
    shlb    $3, %al
    addb    -2(%rbp), %al
    movb    %al, -3(%rbp)

    # check if begining of the file
_printBoardBlackNotFileIf:
    cmpb    $7, -2(%rbp)
    jne      _printBoardBlackNotFileIfEnd

    # calculate rank marking
    movzbl  -1(%rbp), %edx
    movl    $8, %esi
    subl    %edx, %esi

    # print rank marking
    movq    $_printStrRank, %rdi
    movq    $0, %rax
    call    printf

_printBoardBlackNotFileIfEnd:
    #init piece holder
    movb    $no_piece, -4(%rbp)

    # init piece
    movb    $P, -5(%rbp)

    # loop over all pieces
_printBoardBlackPieceLoopBeg:
    cmpb    $k, -5(%rbp)
    ja      _printBoardBlackPieceLoopEnd

    # check if piece on current square
    movzbl  -5(%rbp), %eax
    
    shlq    $3, %rax
    movq    $bitboards, %rdx
    add     %rax, %rdx
    movzbl  -3(%rbp), %esi
    movq    (%rdx), %rdi
    call    getBit

    # check if equals 0
    testq   %rax, %rax
    je      _printBoardBlackCheckPieceIfEnd

    # move piece to piece holder
    movb    -5(%rbp), %al
    movb    %al, -4(%rbp)
    jmp     _printBoardBlackPieceLoopEnd

_printBoardBlackCheckPieceIfEnd:

    # increment piece
    incb    -5(%rbp)

    # repeat piece loop
    jmp     _printBoardBlackPieceLoopBeg

_printBoardBlackPieceLoopEnd:

    movzbl  -1(%rbp), %edi
    movzbl  -2(%rbp), %esi
    call    getANSI
    
    movq    %rax, -16(%rbp)

    # check if no piece
_printBoardBlackPrintPieceIf:
    cmpb    $no_piece, -4(%rbp)
    je      _printBoardBlackPrintPieceIfElse

    # get unicode piece value
    movzbl	-4(%rbp), %eax
	
	shlq	$3, %rax
	movq	$unicode_pieces, %rdx
    addq    %rdx, %rax
	movq	(%rax), %rdx

    jmp     _printBoardBlackPrintPieceIfEnd

_printBoardBlackPrintPieceIfElse:
    movq    $_printBoardStrNoPiece, %rdx

_printBoardBlackPrintPieceIfEnd:
    # print unicode piece
    movq    $_ansiOff, %rcx
    movq    -16(%rbp), %rsi
    movq    $_printBoardStrPiece, %rdi
    movq    $0, %rax
    call    printf

    # increment file
    decb    -2(%rbp)

    # repeat file loop
    jmp     _printBoardBlackFileLoopBeg

_printBoardBlackFileLoopEnd:
    # print new line char ('\n')
	movl	$10, %edi
	call	putchar

    # increment rank
    decb    -1(%rbp)

    # repeat file loop
    jmp     _printBoardBlackRankLoopBeg

_printBoardBlackRankLoopEnd:
    # print file markings
    movq    $_printStrFilesBlack, %rdi
    call    puts

_printBoardBlackSideIf:
    # get side
    movl    side, %eax
    testl   %eax, %eax
    jne     _printBoardBlackSideIfElse
    movq    $_printBoardStrSideWhite, %rsi

    jmp     _printBoardBlackSideIfEnd

_printBoardBlackSideIfElse:
    movq    $_printBoardStrSideBlack, %rsi

_printBoardBlackSideIfEnd:
    # print side
    movq    $_printBoardStrSide, %rdi
    movq    $0, %rax
    call    printf

    # check if enpassant is no_sq
    movl    enpassant, %eax
    cmpl    $no_sq, %eax
    je      _printBoardBlackEnpassantNoSq

    # get enpassant coodinate
    movl    enpassant, %eax
    shll    $3, %eax
    movq    $square_to_coordinates, %rdx
    addq    %rax, %rdx
    movq    (%rdx), %rsi

    jmp     _printBoardBlackEnpassantEnd

_printBoardBlackEnpassantNoSq:
    movq    $_printBoardStrNoSq, %rsi

_printBoardBlackEnpassantEnd:
    # print enpassant coordinate
    movq    $_printBoardStrEnpassant, %rdi
    movq    $0, %rax
    call    printf

    # print castling rights
_printBoardBlackCastlingBQ:
    movl    castle, %eax
    andl    $bq, %eax
    testl   %eax, %eax
    je      _printBoardBlackNoCastllingBQ
    movl    $113, %r8d
    jmp     _printBoardBlackCastlingBK

_printBoardBlackNoCastllingBQ:
    movl	$45, %r8d

_printBoardBlackCastlingBK:
    movl    castle, %eax
    andl    $bk, %eax
    testl   %eax, %eax
    je      _printBoardBlackNoCastllingBK
    movl    $107, %ecx
    jmp     _printBoardBlackCastlingWQ

_printBoardBlackNoCastllingBK:
	movl	$45, %ecx

_printBoardBlackCastlingWQ:
    movl    castle, %eax
    andl    $wq, %eax
    testl   %eax, %eax
    je      _printBoardBlackNoCastllingWQ
    movl    $81, %edx
    jmp     _printBoardBlackCastlingWK

_printBoardBlackNoCastllingWQ:
    movl	$45, %edx

_printBoardBlackCastlingWK:
    movl    castle, %eax
    andl    $wk, %eax
    testl   %eax, %eax
    je      _printBoardBlackNoCastllingWK
    movl    $75, %esi
    jmp     _printBoardBlackCastlingEnd

_printBoardBlackNoCastllingWK:
    movl	$45, %esi

_printBoardBlackCastlingEnd:
    movq    $_printBoardStrCastling, %rdi
    movq    $0, %rax
    call    printf

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# prints bitboad bit by bit with rank and file markings
# (1) argument: (1) bitboard value
# returns voids
printBitboard:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # allocate memory on the stack
    subq	$32, %rsp
	movq	%rdi, -24(%rbp)

    # print new line char ('\n')
	movl    $10, %edi
	call    putchar

    # init rank at 0
    movb    $0, -1(%rbp)

    # loop over 8 ranks
_printBitboardRankLoopBeg:
    cmpb    $8, -1(%rbp)
	jae     _printBitboardRankLoopEnd

    # init file at 0
    movb    $0, -2(%rbp)

    # loop over 8 files
_printBitboardFileLoopBeg:
    cmpb    $8, -2(%rbp)
	jae     _printBitboardFileLoopEnd

    # calculate square
    movb    -1(%rbp), %al
    shlb    $3, %al
    addb    -2(%rbp), %al
    movb    %al, -3(%rbp)

    # check if begining of file
_printBitboardNotFileIf:
    cmpb    $0, -2(%rbp)
    jne      _printBitboardNotFileIfEnd

    # calculate rank marking
    movzbl  -1(%rbp), %edx
    movl    $8, %eax
    subl    %edx, %eax

    # print rank marking
    movl    %eax, %esi
    movq    $_printStrRank, %rdi
    movq    $0, %rax
    call    printf

_printBitboardNotFileIfEnd:
    # check if current bit is on
    movl    -3(%rbp), %esi
    movq    -24(%rbp), %rdi
    call    getBit

_printBitboardCheckBitIf:
    # check if 0 or any other value
    testq   %rax, %rax

    # jump if 0
    je      _printBitboardCheckBitIfElse

    movl    $1, %esi

    # go to the end of check bit if 
    jmp     _printBitboardCheckBitIfEnd
 
_printBitboardCheckBitIfElse:
    movl    $0, %esi

_printBitboardCheckBitIfEnd:
    # print bit
    movq    $_printStrBit, %rdi
    movq    $0, %rax
    call    printf

    # increment file 
    incb    -2(%rbp)

    # repeat file loop
    jmp     _printBitboardFileLoopBeg

_printBitboardFileLoopEnd:
    # print new line char ('\n')
	movl    $10, %edi
	call    putchar

    #increment rank
    incb    -1(%rbp)

    # repeat rank loop
    jmp     _printBitboardRankLoopBeg

_printBitboardRankLoopEnd:
    # print file markings
    movq    $_printStrFiles, %rdi
    call    puts

    # print decimal bitboard value
    movq    -24(%rbp), %rsi
    movq    $_printBitboardStrBitboard, %rdi
    movq    $0, %rax
    call    printf

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret
