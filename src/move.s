.text

# encodes argument into a single 4-byte variable
#
#            binary move bits                            
#    0000 0000 0000 0000 0011 1111    source square      
#    0000 0000 0000 1111 1100 0000    target square      
#    0000 0000 1111 0000 0000 0000    piece              
#    0000 1111 0000 0000 0000 0000    promoted piece     
#    0001 0000 0000 0000 0000 0000    capture flag       
#    0010 0000 0000 0000 0000 0000    double push flag   
#    0100 0000 0000 0000 0000 0000    enpassant flag     
#    1000 0000 0000 0000 0000 0000    castling flag    
#      
# 8 arguments (6 - registors, 2 - stack): (1) 4-byte source square, (2) 4-byte target square, (3) 4-byte piece, (4) 4-byte promoted piece,
#                                   (5) 4-byte capture flag, (6) 4-byte double psuh flag, (7) 4-byte enpassant flag, (8) 4-byte castling flag
# returns 4-byte encoded move
encodeMove:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # rdi = src sq

    # encode target square
    shll    $6, %esi
    orl     %esi, %edi

    # encode piece
    shll    $12, %edx
    orl     %edx, %edi

    # encode promoted piece
    shll    $16, %ecx
    orl     %ecx, %edi

    # encode capture flag
    shll    $20, %r8d
    orl     %r8d, %edi

    # encode double pawn push
    shll    $21, %r9d
    orl     %r9d, %edi

    # + 8 old base pointer
    # + 8 return address
    # + 8 8th argument
    # + 8 7th argument

    # encode enpassant flag
    movl    16(%rbp), %eax
    shll    $22, %eax
    orl     %eax, %edi

    # encode castling flag
    movl    24(%rbp), %eax
    shll    $23, %eax
    orl     %edi, %eax

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# decodes source square from encoded move
# 1 argument: (1) 4-byte encoded move
# returns 4-byte src square
getMoveSrc:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # get only 6 first bits
    movl    %edi, %eax
    andl    $0x3F, %eax

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# decodes target square from encoded move
# 1 argument: (1) 4-byte encoded move
# returns 4-byte trg square
getMoveTrg:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # get only 6 target bits
    movl    %edi, %eax
    andl    $0xFC0, %eax
    shrl    $6, %eax

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# decodes piece from encoded move
# 1 argument: (1) 4-byte encoded move
# returns 4-byte piece
getMovePiece:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # get only 4 piece bits
    movl    %edi, %eax
    andl    $0xF000, %eax
    shrl    $12, %eax

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# decodes promoted piece from encoded move
# 1 argument: (1) 4-byte encoded move
# returns 4-byte piece
getMovePromoted:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # get only 4 piece bits
    movl    %edi, %eax
    andl    $0xF0000, %eax
    shrl    $16, %eax

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# decodes capture flag from encoded move
# 1 argument: (1) 4-byte encoded move
# returns 4-byte piece
getMoveCapture:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # get only 4 piece bits
    movl    %edi, %eax
    andl    $0x100000, %eax

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# decodes doublw push flag from encoded move
# 1 argument: (1) 4-byte encoded move
# returns 4-byte piece
getMoveDouble:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # get only 4 piece bits
    movl    %edi, %eax
    andl    $0x200000, %eax

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# decodes enpassant push flag from encoded move
# 1 argument: (1) 4-byte encoded move
# returns 4-byte piece
getMoveEnpassant:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # get only 4 piece bits
    movl    %edi, %eax
    andl    $0x400000, %eax

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# decodes castling push flag from encoded move
# 1 argument: (1) 4-byte encoded move
# returns 4-byte piece
getMoveCastling:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # get only 4 piece bits
    movl    %edi, %eax
    andl    $0x800000, %eax

    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret

# --------------------------------------------

# prints encoded move in a human friendly form
# 1 argument: (1) 4-byte encoded move
# returns void
printMove:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # make space on the stack
    subq    $16, %rsp

    # store encoded move
    movl    %edi, -4(%rbp)

    # get move source square
    call    getMoveSrc

    # store source square
    movl    %eax, -12(%rbp)

    # get move
    movl    -4(%rbp), %edi

    # get move target
    call    getMoveTrg

    # store target square
    movl    %eax, -16(%rbp)

    # get move
    movl    -4(%rbp), %edi

    # get move promoted piece
    call    getMovePromoted

    # store promoted piece
    movl    %eax, -8(%rbp)

    # check if promoted piece is not no_piece
    cmpl    $0, %eax
    je      _printMoveNoPromoted

    # get promotedp pieces char array address
    leaq    promoted_pieces, %rcx


    # get char (only 1 byte)
    movzbl  (%rcx,%rax), %ecx    

    # get source square
    movl    -12(%rbp), %eax
    
    # get square string table address
    leaq    square_to_coordinates, %rdx

    # get source square string
    movq    (%rdx,%rax,8), %rsi

    # get target square
    movl    -16(%rbp), %eax
    
    # get square string table address
    leaq    square_to_coordinates, %rdx

    # get target square string
    movq    (%rdx,%rax,8), %rdx

    # print move
    movq    $_printMoveStrPromoted, %rdi
    movq    $0, %rax
    call    printf

    jmp     _printMoveEnd

_printMoveNoPromoted:
    # get source square
    movl    -12(%rbp), %eax

    # get square string table address
    leaq    square_to_coordinates, %rdx
    
    # get source square string
    movq    (%rdx,%rax,8), %rsi

    # get target square
    movl    -16(%rbp), %eax
    
    # get square string table address
    leaq    square_to_coordinates, %rdx

    # get target square string
    movq    (%rdx,%rax,8), %rdx

    # print src square and trg square ([src][trg])
    movq    $_printMoveStrNoPromoted, %rdi
    movq    $0, %rax
    call    printf

_printMoveEnd:
    # epilogue 
    movq    %rbp, %rsp
    popq    %rbp

    ret
