.text

# masks attack for pawns on given side and square
# 2 arguments: (1) side, (2) square to maks attaks
# returns 8-bytes
maskPawnAttacks:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # allocate 24 bytes on the stack
    subq	$24, %rsp
	movl	%edi, -20(%rbp)
	movl	%esi, -24(%rbp)

    #init attacks and bitboard
	movq	$0, -8(%rbp)
	movq	$0, -16(%rbp)

    # set square on the bitboard
    movl	-24(%rbp), %esi
	leaq	-16(%rbp), %rdi
    call    setBit

    # check if side is white
    movl    -20(%rbp), %eax
    testl   %eax, %eax
    jne     _maskPawnAttacksBlack

_maskPawnAttacksWhite:
    # check if on boundery file
    movq	-16(%rbp), %rax
    shrq	$7, %rax
    movq    not_a_file, %rdx
    andq    %rdx, %rax

    # check if not out of bounds
    testq   %rax, %rax
    je      _maskPawnAttacksWhiteNotExists1

    # add bitboard to attack
    movq	-16(%rbp), %rax
	shrq	$7, %rax
	orq	    %rax, -8(%rbp)

_maskPawnAttacksWhiteNotExists1:
    # check if on boundery file
    movq	-16(%rbp), %rax
	shrq	$9, %rax
	movq	not_h_file, %rdx
    andq    %rdx, %rax

    # check if not out of bounds
    testq   %rax, %rax
    je      _maskPawnAttacksBlackNotExists2

    # add bitboard to attack
    movq	-16(%rbp), %rax
	shrq	$9, %rax
	orq	    %rax, -8(%rbp)


_maskPawnAttacksWhiteNotExists2:

    jmp _maskPawnAttacksSideIfEnd

_maskPawnAttacksBlack:
    # check if on boundery file
    movq	-16(%rbp), %rax
    shlq	$7, %rax
    movq    not_h_file, %rdx
    andq    %rdx, %rax

    # check if not out of bounds
    testq   %rax, %rax
    je      _maskPawnAttacksBlackNotExists1

    # add bitboard to attack
    movq	-16(%rbp), %rax
	shlq	$7, %rax
	orq	    %rax, -8(%rbp)


_maskPawnAttacksBlackNotExists1:
    # check if on boundery file
    movq	-16(%rbp), %rax
	shlq	$9, %rax
	movq	not_a_file, %rdx
    andq    %rdx, %rax

    # check if not out of bounds
    testq   %rax, %rax
    je      _maskPawnAttacksBlackNotExists2

    # add bitboard to attack
    movq	-16(%rbp), %rax
	shlq	$9, %rax
	orq	    %rax, -8(%rbp)

_maskPawnAttacksBlackNotExists2:
_maskPawnAttacksSideIfEnd:
    movq    -8(%rbp), %rax

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# masks attacks for knight on given square
# 1 argument: (1) 4-byte square
# returns 8-byte
maskKnightAttacks:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $20, %rsp
    movl    %edi, -20(%rbp)

    # init attack and bitboard
    movq    $0, -8(%rbp)
    movq    $0, -16(%rbp)

    movl    -20(%rbp), %esi
    leaq    -16(%rbp), %rdi
    call    setBit

_maskKnightAttacks1:
    movq    -16(%rbp), %rax
    shrq    $17, %rax
    andq    not_h_file, %rax

    testq   %rax, %rax
    je     _maskKnightAttacks2

    movq    -16(%rbp), %rax
    shrq    $17, %rax
    orq     %rax, -8(%rbp)

_maskKnightAttacks2:
    movq    -16(%rbp), %rax
    shrq    $15, %rax
    andq    not_a_file, %rax
    
    testq   %rax, %rax
    je     _maskKnightAttacks3

    movq    -16(%rbp), %rax
    shrq    $15, %rax
    orq     %rax, -8(%rbp)

_maskKnightAttacks3:
    movq    -16(%rbp), %rax
    shrq    $10, %rax
    andq    not_hg_file, %rax
    
    testq   %rax, %rax
    je     _maskKnightAttacks4

    movq    -16(%rbp), %rax
    shrq    $10, %rax
    orq     %rax, -8(%rbp)

_maskKnightAttacks4:
    movq    -16(%rbp), %rax
    shrq    $6, %rax
    andq    not_ab_file, %rax
    
    testq   %rax, %rax
    je     _maskKnightAttacks5

    movq    -16(%rbp), %rax
    shrq    $6, %rax
    orq     %rax, -8(%rbp)

_maskKnightAttacks5:
    movq    -16(%rbp), %rax
    shlq    $17, %rax
    andq    not_a_file, %rax
    
    testq   %rax, %rax
    je     _maskKnightAttacks6

    movq    -16(%rbp), %rax
    shlq    $17, %rax
    orq     %rax, -8(%rbp)

_maskKnightAttacks6:
    movq    -16(%rbp), %rax
    shlq    $15, %rax
    andq    not_h_file, %rax
    
    testq   %rax, %rax
    je     _maskKnightAttacks7

    movq    -16(%rbp), %rax
    shlq    $15, %rax
    orq     %rax, -8(%rbp)

_maskKnightAttacks7:
    movq    -16(%rbp), %rax
    shlq    $10, %rax
    andq    not_ab_file, %rax
    
    testq   %rax, %rax
    je     _maskKnightAttacks8

    movq    -16(%rbp), %rax
    shlq    $10, %rax
    orq     %rax, -8(%rbp)

_maskKnightAttacks8:
    movq    -16(%rbp), %rax
    shlq    $6, %rax
    andq    not_hg_file, %rax
    
    testq   %rax, %rax
    je     _maskKnightAttacksEnd

    movq    -16(%rbp), %rax
    shlq    $6, %rax
    orq     %rax, -8(%rbp)

_maskKnightAttacksEnd:
    movq    -8(%rbp), %rax

    # epilogue 
    movq %rbp, %rsp
    popq %rbp
    ret

# --------------------------------------------

# masks attacks for king on given square
# 1 argument: (1) 4-byte square
# returns 8-byte
maskKingAttacks:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $20, %rsp
    movl    %edi, -20(%rbp)

    # init attack and bitboard
    movq    $0, -8(%rbp)
    movq    $0, -16(%rbp)

    movl    -20(%rbp), %esi
    leaq    -16(%rbp), %rdi
    call    setBit

_maskKingAttacks1:
    movq    -16(%rbp), %rax
    shrq    $8, %rax

    testq   %rax, %rax
    je     _maskKingAttacks2

    movq    -16(%rbp), %rax
    shrq    $8, %rax
    orq     %rax, -8(%rbp)

_maskKingAttacks2:
    movq    -16(%rbp), %rax
    shrq    $9, %rax
    andq    not_h_file, %rax
    
    testq   %rax, %rax
    je     _maskKingAttacks3

    movq    -16(%rbp), %rax
    shrq    $9, %rax
    orq     %rax, -8(%rbp)

_maskKingAttacks3:
    movq    -16(%rbp), %rax
    shrq    $7, %rax
    andq    not_a_file, %rax
    
    testq   %rax, %rax
    je     _maskKingAttacks4

    movq    -16(%rbp), %rax
    shrq    $7, %rax
    orq     %rax, -8(%rbp)

_maskKingAttacks4:
    movq    -16(%rbp), %rax
    shrq    $1, %rax
    andq    not_h_file, %rax
    
    testq   %rax, %rax
    je     _maskKingAttacks5

    movq    -16(%rbp), %rax
    shrq    $1, %rax
    orq     %rax, -8(%rbp)

_maskKingAttacks5:
    movq    -16(%rbp), %rax
    shlq    $8, %rax
    
    testq   %rax, %rax
    je     _maskKingAttacks6

    movq    -16(%rbp), %rax
    shlq    $8, %rax
    orq     %rax, -8(%rbp)

_maskKingAttacks6:
    movq    -16(%rbp), %rax
    shlq    $9, %rax
    andq    not_a_file, %rax
    
    testq   %rax, %rax
    je     _maskKingAttacks7

    movq    -16(%rbp), %rax
    shlq    $9, %rax
    orq     %rax, -8(%rbp)

_maskKingAttacks7:
    movq    -16(%rbp), %rax
    shlq    $7, %rax
    andq    not_h_file, %rax
    
    testq   %rax, %rax
    je     _maskKingAttacks8

    movq    -16(%rbp), %rax
    shlq    $7, %rax
    orq     %rax, -8(%rbp)

_maskKingAttacks8:
    movq    -16(%rbp), %rax
    shlq    $1, %rax
    andq    not_a_file, %rax
    
    testq   %rax, %rax
    je     _maskKingAttacksEnd

    movq    -16(%rbp), %rax
    shlq    $1, %rax
    orq     %rax, -8(%rbp)

_maskKingAttacksEnd:
    movq    -8(%rbp), %rax

    # epilogue 
    movq %rbp, %rsp
    popq %rbp
    ret

# --------------------------------------------

# masks attacks for bishop on given square (no occupancy)
# 1 argument: (1) 4-byte square
# returns 8-byte
maskBishopAttacks:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $24, %rsp

    movq    $0, -8(%rbp)

    # init target rank and file
    movl    $0, -12(%rbp)
    movl    $0, -16(%rbp)

    # retrive rank and file from square
    movq    $0, %rdx
    movl    %edi, %eax
    movq    $8, %rcx
    divq    %rcx

    movl    %eax, -20(%rbp)
    movl    %edx, -24(%rbp)


    # calculate initial target rank
    movl    -20(%rbp), %eax
    incl    %eax
    movl    %eax, -12(%rbp)

    # calculate initial target file
    movl    -24(%rbp), %eax
    incl    %eax
    movl    %eax, -16(%rbp)

    # mask diaonal +1 +1
_maskBishopAttacksLoop1Beg:
    # do not mask more than 7th rank and 7th file
    cmpl    $6, -12(%rbp)
    jg      _maskBishopAttacksLoop1End
    cmpl    $6, -16(%rbp)
    jg      _maskBishopAttacksLoop1End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    incl    -12(%rbp)
    incl    -16(%rbp)

    jmp _maskBishopAttacksLoop1Beg

_maskBishopAttacksLoop1End:

    # calculate initial target rank
    movl    -20(%rbp), %eax
    decl    %eax
    movl    %eax, -12(%rbp)

    # calculate initial target file
    movl    -24(%rbp), %eax
    incl    %eax
    movl    %eax, -16(%rbp)

    # mask diaonal -1 +1
_maskBishopAttacksLoop2Beg:
    # do not mask less than 1st rank and more than and 6th file
    cmpl    $1, -12(%rbp)
    jl      _maskBishopAttacksLoop2End
    cmpl    $6, -16(%rbp)
    jg      _maskBishopAttacksLoop2End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    decl    -12(%rbp)
    incl    -16(%rbp)

    jmp _maskBishopAttacksLoop2Beg

_maskBishopAttacksLoop2End:

    # calculate initial target rank
    movl    -20(%rbp), %eax
    incl    %eax
    movl    %eax, -12(%rbp)

    # calculate initial target file
    movl    -24(%rbp), %eax
    decl    %eax
    movl    %eax, -16(%rbp)

    # mask diaonal +1 -1
_maskBishopAttacksLoop3Beg:
    # do not mask more than and 6th rank and less than 1st file
    cmpl    $6, -12(%rbp)
    jg      _maskBishopAttacksLoop3End
    cmpl    $1, -16(%rbp)
    jl      _maskBishopAttacksLoop3End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    incl    -12(%rbp)
    decl    -16(%rbp)

    jmp _maskBishopAttacksLoop3Beg

_maskBishopAttacksLoop3End:

    # calculate initial target rank
    movl    -20(%rbp), %eax
    decl    %eax
    movl    %eax, -12(%rbp)

    # calculate initial target file
    movl    -24(%rbp), %eax
    decl    %eax
    movl    %eax, -16(%rbp)

    # mask diaonal -1 -1
_maskBishopAttacksLoop4Beg:
    # do not mask less than 1st rank and file
    cmpl    $1, -12(%rbp)
    jl      _maskBishopAttacksLoop4End
    cmpl    $1, -16(%rbp)
    jl      _maskBishopAttacksLoop4End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    decl    -12(%rbp)
    decl    -16(%rbp)

    jmp _maskBishopAttacksLoop4Beg

_maskBishopAttacksLoop4End:

    movq    -8(%rbp), %rax

    # epilogue 
    movq %rbp, %rsp
    popq %rbp
    ret

# --------------------------------------------

# masks attacks for rook on given square (no occupancy)
# 1 argument: (1) 4-byte square
# returns 8-byte
maskRookAttacks:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $24, %rsp

    movq    $0, -8(%rbp)

    # init target rank and file
    movl    $0, -12(%rbp)
    movl    $0, -16(%rbp)

    # retrive rank and file from square
    movq    $0, %rdx
    movl    %edi, %eax
    movq    $8, %rcx
    divq    %rcx

    movl    %eax, -20(%rbp)
    movl    %edx, -24(%rbp)


    # calculate initial target rank
    movl    -20(%rbp), %eax
    incl    %eax
    movl    %eax, -12(%rbp)

    # mask vertical +1
_maskRookAttacksLoop1Beg:
    # do not mask more than 6th rank
    cmpl    $6, -12(%rbp)
    jg      _maskRookAttacksLoop1End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -24(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    incl    -12(%rbp)

    jmp _maskRookAttacksLoop1Beg

_maskRookAttacksLoop1End:

    # calculate initial target rank
    movl    -20(%rbp), %eax
    decl    %eax
    movl    %eax, -12(%rbp)

    # mask vertical -1
_maskRookAttacksLoop2Beg:
    # do not mask less than 1st rank
    cmpl    $1, -12(%rbp)
    jl      _maskRookAttacksLoop2End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -24(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    decl    -12(%rbp)

    jmp _maskRookAttacksLoop2Beg

_maskRookAttacksLoop2End:

    # calculate initial target file
    movl    -24(%rbp), %eax
    incl    %eax
    movl    %eax, -16(%rbp)

    # mask horizontal +1
_maskRookAttacksLoop3Beg:
    # do not mask more than 6th file
    cmpl    $6, -16(%rbp)
    jg      _maskRookAttacksLoop3End

    # calculate the offset
    movl    -20(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    incl    -16(%rbp)

    jmp _maskRookAttacksLoop3Beg

_maskRookAttacksLoop3End:

    # calculate initial target file
    movl    -24(%rbp), %eax
    decl    %eax
    movl    %eax, -16(%rbp)

    # mask horizontal -1
_maskRookAttacksLoop4Beg:
    # do not mask less than 1st file
    cmpl    $1, -16(%rbp)
    jl      _maskRookAttacksLoop4End

    # calculate the offset
    movl    -20(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    decl    -16(%rbp)

    jmp _maskRookAttacksLoop4Beg

_maskRookAttacksLoop4End:

    movq    -8(%rbp), %rax

    # epilogue 
    movq %rbp, %rsp
    popq %rbp
    ret

# --------------------------------------------

# generates attacks on the fly for bishop on given square with occupancy
# 2 arguments: (1) 4-byte square, (2) 8-byte occupancy bitboard
# returns 8-byte
bishopAttacksOnTheFly:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $32, %rsp

    movq    %rsi, -32(%rbp)

    movq    $0, -8(%rbp)

    # init target rank and file
    movl    $0, -12(%rbp)
    movl    $0, -16(%rbp)

    # retrive rank and file from square
    movq    $0, %rdx
    movl    %edi, %eax
    movq    $8, %rcx
    divq    %rcx

    movl    %eax, -20(%rbp)
    movl    %edx, -24(%rbp)


    # calculate initial target rank
    movl    -20(%rbp), %eax
    incl    %eax
    movl    %eax, -12(%rbp)

    # calculate initial target file
    movl    -24(%rbp), %eax
    incl    %eax
    movl    %eax, -16(%rbp)

    # generate diaonal +1 +1
_bishopAttacksOnTheFlyLoop1Beg:
    cmpl    $7, -12(%rbp)
    jg      _bishopAttacksOnTheFlyLoop1End
    cmpl    $7, -16(%rbp)
    jg      _bishopAttacksOnTheFlyLoop1End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    # check if square occupied
_bishopAttacksOnTheFlyExit1:
    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx
    movq    -32(%rbp), %rax
    andq    %rdx, %rax
    
    testq   %rax, %rax
    jne     _bishopAttacksOnTheFlyLoop1End

    incl    -12(%rbp)
    incl    -16(%rbp)

    jmp _bishopAttacksOnTheFlyLoop1Beg

_bishopAttacksOnTheFlyLoop1End:

    # calculate initial target rank
    movl    -20(%rbp), %eax
    decl    %eax
    movl    %eax, -12(%rbp)

    # calculate initial target file
    movl    -24(%rbp), %eax
    incl    %eax
    movl    %eax, -16(%rbp)

    # mask diaonal -1 +1
_bishopAttacksOnTheFlyLoop2Beg:
    cmpl    $0, -12(%rbp)
    jl      _bishopAttacksOnTheFlyLoop2End
    cmpl    $7, -16(%rbp)
    jg      _bishopAttacksOnTheFlyLoop2End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    # check if square occupied
_bishopAttacksOnTheFlyExit2:
    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx
    movq    -32(%rbp), %rax
    andq    %rdx, %rax
    
    testq   %rax, %rax
    jne     _bishopAttacksOnTheFlyLoop2End

    decl    -12(%rbp)
    incl    -16(%rbp)

    jmp _bishopAttacksOnTheFlyLoop2Beg

_bishopAttacksOnTheFlyLoop2End:

    # calculate initial target rank
    movl    -20(%rbp), %eax
    incl    %eax
    movl    %eax, -12(%rbp)

    # calculate initial target file
    movl    -24(%rbp), %eax
    decl    %eax
    movl    %eax, -16(%rbp)

    # mask diaonal +1 -1
_bishopAttacksOnTheFlyLoop3Beg:
    cmpl    $7, -12(%rbp)
    jg      _bishopAttacksOnTheFlyLoop3End
    cmpl    $0, -16(%rbp)
    jl      _bishopAttacksOnTheFlyLoop3End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    # check if square occupied
_bishopAttacksOnTheFlyExit3:
    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx
    movq    -32(%rbp), %rax
    andq    %rdx, %rax
    
    testq   %rax, %rax
    jne     _bishopAttacksOnTheFlyLoop3End

    incl    -12(%rbp)
    decl    -16(%rbp)

    jmp _bishopAttacksOnTheFlyLoop3Beg

_bishopAttacksOnTheFlyLoop3End:

    # calculate initial target rank
    movl    -20(%rbp), %eax
    decl    %eax
    movl    %eax, -12(%rbp)

    # calculate initial target file
    movl    -24(%rbp), %eax
    decl    %eax
    movl    %eax, -16(%rbp)

    # mask diaonal -1 -1
_bishopAttacksOnTheFlyLoop4Beg:
    cmpl    $0, -12(%rbp)
    jl      _bishopAttacksOnTheFlyLoop4End
    cmpl    $0, -16(%rbp)
    jl      _bishopAttacksOnTheFlyLoop4End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    # check if square occupied
_bishopAttacksOnTheFlyExit4:
    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx
    movq    -32(%rbp), %rax
    andq    %rdx, %rax
    
    testq   %rax, %rax
    jne     _bishopAttacksOnTheFlyLoop4End

    decl    -12(%rbp)
    decl    -16(%rbp)

    jmp _bishopAttacksOnTheFlyLoop4Beg

_bishopAttacksOnTheFlyLoop4End:

    movq    -8(%rbp), %rax

    # epilogue 
    movq %rbp, %rsp
    popq %rbp
    ret

# --------------------------------------------

# generates attacks for rook on given square with occupancy
# 2 argument: (1) 4-byte square, (2) 8-byte occupancy bitboard
# returns 8-byte
rookAttacksOnTheFly:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $32, %rsp

    movq    %rsi, -32(%rbp)

    movq    $0, -8(%rbp)

    # init target rank and file
    movl    $0, -12(%rbp)
    movl    $0, -16(%rbp)

    # retrive rank and file from square
    movq    $0, %rdx
    movl    %edi, %eax
    movq    $8, %rcx
    divq    %rcx

    movl    %eax, -20(%rbp)
    movl    %edx, -24(%rbp)


    # calculate initial target rank
    movl    -20(%rbp), %eax
    incl    %eax
    movl    %eax, -12(%rbp)

    # mask vertical +1
_rookAttacksOnTheFlyLoop1Beg:
    # do not mask more than 6th rank
    cmpl    $7, -12(%rbp)
    jg      _rookAttacksOnTheFlyLoop1End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -24(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    # check if square occupieds
_rookAttacksOnTheFlyExit1:
    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -24(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx
    movq    -32(%rbp), %rax
    andq    %rdx, %rax

    testq   %rax, %rax
    jne     _rookAttacksOnTheFlyLoop1End

    incl    -12(%rbp)

    jmp _rookAttacksOnTheFlyLoop1Beg

_rookAttacksOnTheFlyLoop1End:

    # calculate initial target rank
    movl    -20(%rbp), %eax
    decl    %eax
    movl    %eax, -12(%rbp)

    # mask vertical -1
_rookAttacksOnTheFlyLoop2Beg:
    # do not mask less than 1st rank
    cmpl    $0, -12(%rbp)
    jl      _rookAttacksOnTheFlyLoop2End

    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -24(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    # check if square occupieds
_rookAttacksOnTheFlyExit2:
    # calculate the offset
    movl    -12(%rbp), %ecx
    shll    $3, %ecx
    addl    -24(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx
    movq    -32(%rbp), %rax
    andq    %rdx, %rax

    testq   %rax, %rax
    jne     _rookAttacksOnTheFlyLoop2End

    decl    -12(%rbp)

    jmp _rookAttacksOnTheFlyLoop2Beg

_rookAttacksOnTheFlyLoop2End:

    # calculate initial target file
    movl    -24(%rbp), %eax
    incl    %eax
    movl    %eax, -16(%rbp)

    # mask horizontal +1
_rookAttacksOnTheFlyLoop3Beg:
    # do not mask more than 6th file
    cmpl    $7, -16(%rbp)
    jg      _rookAttacksOnTheFlyLoop3End

    # calculate the offset
    movl    -20(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    # check if square occupieds
_rookAttacksOnTheFlyExit3:
    # calculate the offset
    movl    -20(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx
    movq    -32(%rbp), %rax
    andq    %rdx, %rax

    testq   %rax, %rax
    jne     _rookAttacksOnTheFlyLoop3End

    incl    -16(%rbp)

    jmp _rookAttacksOnTheFlyLoop3Beg

_rookAttacksOnTheFlyLoop3End:

    # calculate initial target file
    movl    -24(%rbp), %eax
    decl    %eax
    movl    %eax, -16(%rbp)

    # mask horizontal -1
_rookAttacksOnTheFlyLoop4Beg:
    # do not mask less than 1st file
    cmpl    $0, -16(%rbp)
    jl      _rookAttacksOnTheFlyLoop4End

    # calculate the offset
    movl    -20(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx

    # add the square to attack mask
    orq     %rdx, -8(%rbp)

    # check if square occupieds
_rookAttacksOnTheFlyExit4:
    # calculate the offset
    movl    -20(%rbp), %ecx
    shll    $3, %ecx
    addl    -16(%rbp), %ecx
    movq    $1, %rdx
    shlq    %cl, %rdx
    movq    -32(%rbp), %rax
    andq    %rdx, %rax

    testq   %rax, %rax
    jne     _rookAttacksOnTheFlyLoop4End


    decl    -16(%rbp)

    jmp _rookAttacksOnTheFlyLoop4Beg

_rookAttacksOnTheFlyLoop4End:

    movq    -8(%rbp), %rax

    # epilogue 
    movq %rbp, %rsp
    popq %rbp
    ret

# --------------------------------------------

# sets occupancies
# 3 arguments: (1) index (4-byte), (2) bits in mask (4-byte), (3) attack mask(8-bytes)
# returns 8-byte occupancy
setOccupancy:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $32, %rsp

    movl    %edi, -4(%rbp)
    movl    %esi, -8(%rbp)
    movq    %rdx, -16(%rbp)

    # occupancy map
    movq    $0, -24(%rbp)

    # init count
    movl    $0, -28(%rbp)

    # loop over the range of bits within attack mask
_setOccupancyLoopBeg:
    movl    -28(%rbp), %eax
    cmpl    -8(%rbp), %eax
    jge     _setOccupancyLoopEnd

    # get LS1B index of attacks mask
    movq    -16(%rbp), %rdi
    call    getLSB
    movl    %eax, -32(%rbp)

    # remove LS1B in attack map
    movl    %eax, %esi
    leaq    -16(%rbp), %rdi
    call    removeBit

    # make sure occupancy is on board
    movl    -28(%rbp), %ecx
    movq    $1, %rax
    shlq    %cl, %rax
    movl    -4(%rbp), %edx
    andq    %rdx, %rax
    testq   %rax, %rax
    je      _setOccupancyCheckIfOnBoardEnd

    # populate occupancy map
    movl    -32(%rbp), %ecx
    movq    $1, %rax
    shlq    %cl, %rax
    orq     %rax, -24(%rbp)

_setOccupancyCheckIfOnBoardEnd:

    incl    -28(%rbp)

    jmp     _setOccupancyLoopBeg

_setOccupancyLoopEnd:
    # return occupancy map
    movq    -24(%rbp), %rax

    # epilogue 
    movq %rbp, %rsp
    popq %rbp
    ret

# --------------------------------------------

# populates attack tables with masked bitboards
# 0 arguments
# returns void
initLeaperAttacks:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# make space on stack
	subq	$16, %rsp

	# init square 
	movl	$0, -4(%rbp)
	
_initLeaperAttacksSquareLoopBeg:
	cmpl	$63, -4(%rbp)
	jg	_initLeaperAttacksSquareLoopEnd

	# get attack mask for white pawn
	movl	-4(%rbp), %esi
	movl	$white, %edi
	call	maskPawnAttacks

	# assign mask to table
	movl	-4(%rbp), %edx
	leaq	0(,%rdx,8), %rcx
	leaq	pawn_attacks, %rdx
	movq	%rax, (%rcx,%rdx)

	# get attack mask for black pawn
	movl	-4(%rbp), %esi
	movl	$black, %edi
	call	maskPawnAttacks

	# assign mask to table
	movl	-4(%rbp), %edx
	addq	$64, %rdx
	leaq	0(,%rdx,8), %rcx
	leaq	pawn_attacks, %rdx
	movq	%rax, (%rcx,%rdx)

	# get attack mask for knight
	movl	-4(%rbp), %edi
	call	maskKnightAttacks

	# assign mask to table
	movl	-4(%rbp), %edx
	leaq	0(,%rdx,8), %rcx
	leaq	knight_attacks, %rdx
	movq	%rax, (%rcx,%rdx)

	# get attack mask for king
	movl	-4(%rbp), %edi
	call	maskKingAttacks

	# assign mask to table
	movl	-4(%rbp), %edx
	leaq	0(,%rdx,8), %rcx
	leaq	king_attacks, %rdx
	movq	%rax, (%rcx,%rdx)

	# increment square
	incl	-4(%rbp)
	
	# repeat loop
	jmp 	_initLeaperAttacksSquareLoopBeg

_initLeaperAttacksSquareLoopEnd:
	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp
	
	ret

# --------------------------------------------

# populates attacks with generated attacks on the fly with occupancies
# 0 arguments
# returns void
initBishopAttacks:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $32, %rsp

    # init square
    movl    $0, -4(%rbp)

    # loop over 64 board squares
_initBishopAttacksSquareLoopBeg:
    cmpl    $64, -4(%rbp)
    jge     _initBishopAttacksSquareLoopEnd

    # get square
    movl    -4(%rbp), %edi

    # init mask
    call    maskBishopAttacks

    # assign mask
    movq    $bishop_masks, %rdx
    movl    -4(%rbp), %ecx
    shlq    $3, %rcx
    addq    %rcx, %rdx
    movq    %rax, (%rdx)

    # movq    %rax, %rdi
    # call    printBitboard

    # init current mask
    movq    %rax, -12(%rbp)

    # get relevant bit count 
    movq    %rax, %rdi
    call    countBits

    # assign relevant bit count
    movl    %eax, -16(%rbp)

    # calculate occupancy indicies
    movl    $1, %edx
    movl    %eax, %ecx
    shll    %cl, %edx
    movl    %edx, -20(%rbp)

    movl    $0, -24(%rbp)

    # loop over occupancy indicies
_initBishopAttacksIndicesLoopBeg:
    movl    -24(%rbp), %eax
    cmpl    -20(%rbp), %eax
    jge     _initBishopAttacksIndicesLoopEnd

    # generate occupancy
    movq    -12(%rbp), %rdx
    movl    -16(%rbp), %esi
    movl    -24(%rbp), %edi
    call    setOccupancy

    # store occupancy
    movq    %rax, -32(%rbp)

    # get bishop magic number
    leaq    bishop_magic_numbers, %rdx
    
    # get square
    movl    -4(%rbp), %eax

    # get magic number
    movq    (%rdx,%rax,8), %rax

    movq    $0, %rdx
    mulq    -32(%rbp)

    # get bishop relevant bits table address
    leaq    bishop_relevant_bits, %rdx

    # get square
    movl    -4(%rbp), %ecx

    # get bishop relevant bits for given square
    movl    (%rdx,%rcx,4), %edx

    # calculate magic index
    movq    $64, %rcx
    subq    %rdx, %rcx
    shrq    %cl, %rax

    # get bishop attack table address
    leaq    bishop_attacks, %rdx

    # get square
    movl    -4(%rbp), %ecx
    shlq    $12, %rcx
    addq    %rcx, %rdx
    shlq    $3, %rax
    addq    %rax, %rdx

    pushq   %rdx

    # generate attack mask based on the square and occupancy
    movq    -32(%rbp), %rsi

    # get square
    movl    -4(%rbp), %edi
    call    bishopAttacksOnTheFly

    popq    %rdx

    movq    %rax, (%rdx)

    incl    -24(%rbp)

    jmp     _initBishopAttacksIndicesLoopBeg

_initBishopAttacksIndicesLoopEnd:
    # increment square
    incl    -4(%rbp)

    jmp     _initBishopAttacksSquareLoopBeg

_initBishopAttacksSquareLoopEnd:

    # epilogue 
    movq %rbp, %rsp
    popq %rbp
    ret

# --------------------------------------------

# populates attacks with generated attacks on the fly with occupancies
# 0 arguments
# returns void
initRookAttacks:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $32, %rsp

    # init square
    movl    $0, -4(%rbp)

    # loop over 64 board squares
_initRookAttacksSquareLoopBeg:
    cmpl    $64, -4(%rbp)
    jge     _initRookAttacksSquareLoopEnd

    # init mask
    movl    -4(%rbp), %edi
    call    maskRookAttacks

    # get rook attack mask table address
    leaq    rook_masks, %rdx

    # get square
    movl    -4(%rbp), %ecx
    
    # get rook attack mask
    movq    %rax, (%rdx,%rcx,8)

    # movq    %rax, %rdi
    # call    printBitboard

    # init current mask
    movq    %rax, -12(%rbp)

    # get relevant bit count 
    movq    %rax, %rdi
    call    countBits

    # assign relevant bit count
    movl    %eax, -16(%rbp)

    # calculate occupancy indicies
    movl    $1, %edx
    movl    %eax, %ecx
    shll    %cl, %edx
    movl    %edx, -20(%rbp)

    movl    $0, -24(%rbp)

    # loop over occupancy indicies
_initRookAttacksIndicesLoopBeg:
    movl    -24(%rbp), %eax
    cmpl    -20(%rbp), %eax
    jge     _initRookAttacksIndicesLoopEnd

    # set occupancy
    movq    -12(%rbp), %rdx
    movl    -16(%rbp), %esi
    movl    -24(%rbp), %edi
    call    setOccupancy

    # store occupancy
    movq    %rax, -32(%rbp)

    # get rook magic number
    movq    $rook_magic_numbers, %rdx

    # get square
    movl    -4(%rbp), %eax

    # get magic number
    movq    (%rdx,%rax,8), %rax

    movq    $0, %rdx
    mulq    -32(%rbp)

    # calculate magic index
    leaq    rook_relevant_bits, %rdx

    # get square
    movl    -4(%rbp), %ecx

    # get rook relevant bist for given square
    movl    (%rdx,%rcx,4), %edx
    movq    $64, %rcx
    subq    %rdx, %rcx
    shrq    %cl, %rax

    # get bishop attack table address
    leaq    rook_attacks, %rdx

    # get square
    movl    -4(%rbp), %ecx

    # 4096 * 8
    shlq    $15, %rcx
    addq    %rcx, %rdx
    shlq    $3, %rax
    addq    %rax, %rdx

    pushq   %rdx

    # generate attack mask based on the square and occupancy
    movq    -32(%rbp), %rsi

    # get square
    movl    -4(%rbp), %edi
    call    rookAttacksOnTheFly

    popq    %rdx

    movq    %rax, (%rdx)

    incl    -24(%rbp)

    jmp     _initRookAttacksIndicesLoopBeg

_initRookAttacksIndicesLoopEnd:
    # increment square
    incl    -4(%rbp)

    jmp     _initRookAttacksSquareLoopBeg

_initRookAttacksSquareLoopEnd:

    # epilogue 
    movq %rbp, %rsp
    popq %rbp
    ret

# --------------------------------------------

# calls all initialising subroutines
# 0 arguments
# returns void
initAll:
	# prologue
	pushq	%rbp
	movq	%rsp, %rbp

	call	initLeaperAttacks
	call 	initBishopAttacks
	call	initRookAttacks
	
    # epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret
