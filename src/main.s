.global main

.include "constants.s"
.include "bss.s"
.include "data.s"
.include "init.s"
.include "position.s"
.include "move.s"
.include "movegen.s"
.include "evaluate.s"
.include "search.s"
.include "interface.s"

.text

# counts bits in a 8-byte bitboard
# 1 argument: (1) bitboard value
# returns 4-byte(%eax)
countBits:
	# prologue
	pushq   %rbp
	movq    %rsp, %rbp

	# put bitboard and counter on the stack
	subq    $16, %rsp
	movq    %rdi, -8(%rbp)
	movl    $0, -12(%rbp)

	# begining of the loop
_countBitsLoopBeg:
	# check if bitboard value is 0
	cmpq    $0, -8(%rbp)

	# exit when bitboard equals 0
	je      _countBitsLoopEnd

	# increment counter
	incl    -12(%rbp)

	# bitwise and bitboard with bitboard - 1
	movq    -8(%rbp), %rax
	decq    %rax
	andq    %rax, -8(%rbp)

	# repeat the loop
	jmp     _countBitsLoopBeg


_countBitsLoopEnd:
	# move counter to %eax
	movl    -12(%rbp), %eax

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# returns 8-byte ineger(%eax)
getBit:
	# prologue
	pushq   %rbp
	movq    %rsp, %rbp

	# set %rax to 1
	movq    $1, %rax

	# move square value to %ecx (%rcx) registor (this register is used for shifting)
	movl    %esi, %ecx

	# shift left to the square position
	# using only lowest 8 bits of %rcx regiter for shifting 
	shlq    %cl, %rax

	# check if square bit on the bitboard was 1
	andq    %rax, %rdi

	# move result to %rax
	movq    %rdi, %rax

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# sets square bit to 1 on the bitboard (counting from 0)
# 2 arguments: (1) bitboard address, (2) square value
# returns void
setBit:
	# prologue
	pushq   %rbp
	movq    %rsp, %rbp

	# set %rax to 1
	movq    $1, %rax

	# move square value to %ecx (%rcx) registor (this register is used for shifting)
	movl    %esi, %ecx

	# shift left to the square position
	# using only lowest 8 bits of %rcx regiter for shifting 
	shlq    %cl, %rax

	# set bit on the bitboard
	orq     %rax, (%rdi)

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# sets square bit to 0 on the bitboard  
# 2 arguments: (1) bitboard address, (2) square value
# returns void
removeBit:
	# prologue
	pushq   %rbp
	movq    %rsp, %rbp

	# set %rax to 1
	movq    $1, %rax

	# move square value to %ecx (%rcx) registor (this register is used for shifting)
	movl    %esi, %ecx

	# shift left to the square position
	# using only lowest 8 bits of %rcx regiter for shifting 
	shlq    %cl, %rax

	# flip all bits ex. from 0 to 1 and from 1 to 0
	notq    %rax

	andq    %rax, (%rdi)

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# returns least significant bit index
# 1 argument: (1) 8-byte bitboard
# returns 4-byte
getLSB:
	# prologue
	pushq   %rbp
	movq    %rsp, %rbp

	subq    $8, %rsp

	# store bitboard value
	movq    %rdi, -8(%rbp)

	# check if board is not 0
	testq   %rdi, %rdi
	je      _getLSBIllegal

	# get bitboard value
	movq	-8(%rbp), %rdi

	# flip bits and substract 1
	negq	%rdi

	# get matching bits
	andq	-8(%rbp), %rdi

	# substract 1
	subq	$1, %rdi

	# count bits
	call    countBits

	jmp     _getLSBValid

_getLSBIllegal:
	movl    $no_sq, %eax

_getLSBValid:

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret

# --------------------------------------------

# get bishop attacks
# 2 arguments: (1) 4-byte square, (2) 8-byte occupancy
# returns 8-byte attack mask for given occupancy
getBishopAttacks:
	# prologue
	pushq   %rbp
	movq    %rsp, %rbp
	
	subq    $12, %rsp

	movl    %edi, -4(%rbp)
	movq    %rsi, -12(%rbp)

	# get bishop attacks assuming current board occupancy, get occupancy index
	# bitwisse and occupancy bitboard with attack mask on given square
	# get bishop attack mask table address
	leaq    bishop_masks, %rdx

	# get square
	movl    -4(%rbp), %eax
	
	# get bshop attack mask
	movq    (%rdx,%rax,8), %rax

	# get relevant occupancy
	andq    %rax, -12(%rbp)

	# multiply magic number on given sauare with occupancy bitboard
	movq    $bishop_magic_numbers, %rcx

	# get square
	movl    -4(%rbp), %eax
	shlq    $3, %rax
	addq    %rax, %rcx
	movq    -12(%rbp), %rax

	# mul by magic number on given square
	mulq    (%rcx)
	movq    %rax, -12(%rbp)

	# shift right by (64 - relevant bits)
	movq    $bishop_relevant_bits, %rdx

	# get square
	movl    -4(%rbp), %eax

	# get bishop relevnt bits for given square
	movl    (%rdx,%rax,4), %eax
	movl    $64, %ecx
	subl    %eax, %ecx
	shrq    %cl, -12(%rbp)

	leaq    bishop_attacks, %rdx

	# get sqare
	movl    -4(%rbp), %eax

	# 512 * 8 - offset by square
	shlq    $12, %rax
	addq    %rax, %rdx

	movq    -12(%rbp), %rax
	shlq    $3, %rax
	addq    %rax, %rdx

	movq    (%rdx), %rax

	# epilogue 
	movq %rbp, %rsp
	popq %rbp
	ret

# --------------------------------------------

# get rook attacks
# 2 arguments: (1) 4-byte square, (2) 8-byte occupancy
# returns 8-byte attack mask for given occupancy
getRookAttacks:
	# prologue
	pushq   %rbp
	movq    %rsp, %rbp
	
	# make space on the stack
	subq    $12, %rsp

	# store square and occupancy
	movl    %edi, -4(%rbp)
	movq    %rsi, -12(%rbp)

	# get rook attacks assuming current board occupancy, get occupancy index
	# bitwisse and occupancy bitboard with attack mask on given square
	# get rook attack mask table address
	leaq    rook_masks, %rdx

	# get square
	movl    -4(%rbp), %eax
	movq    (%rdx,%rax,8), %rax

	# get occupancy blocks
	andq    %rax, -12(%rbp)

	# multiply magic number on given square with occupancy bitboard
	leaq    rook_magic_numbers, %rcx

	# get square
	movl    -4(%rbp), %eax
	movq    (%rcx,%rax,8), %rcx
	movq    -12(%rbp), %rax

	# mul by magic number on given square
	mulq    %rcx
	movq    %rax, -12(%rbp)

	# shift right by (64 - relevant bits)
	leaq    rook_relevant_bits, %rdx

	# get square
	movl    -4(%rbp), %eax

	# get rook relevnt bits for given square
	movl    (%rdx,%rax,4), %eax
	movl    $64, %ecx
	subl    %eax, %ecx
	shrq    %cl, -12(%rbp)

	# get rook attack table address
	leaq    rook_attacks, %rdx

	# get sqare
	movl    -4(%rbp), %eax

	# 4096 * 8 - offset by square
	shlq    $15, %rax
	addq    %rax, %rdx

	# get occupancy
	movq    -12(%rbp), %rax

	movq    (%rdx,%rax,8), %rax

	# epilogue 
	movq %rbp, %rsp
	popq %rbp
	ret

# --------------------------------------------

# get queen attacks - combine bishop and rook attacks
# 2 arguments: (1) 4-byte square, (2) 8-byte occupancy
# returns 8-byte attack mask for given occupancy
getQueenAttacks:
	# prologue
	pushq   %rbp
	movq    %rsp, %rbp
	
	subq    $20, %rsp

	movl    %edi, -4(%rbp)
	movq    %rsi, -12(%rbp)

	# get bishop attacks
	call    getBishopAttacks

	movq    %rax, -20(%rbp)

	movq    -12(%rbp), %rsi
	movl    -4(%rbp), %edi

	# get rook attacks
	call    getRookAttacks

	# cobmine both to get queen attaks
	orq     -20(%rbp), %rax

	# epilogue 
	movq %rbp, %rsp
	popq %rbp
	ret

# --------------------------------------------



main:
	# prologue
	pushq	%rbp	
	movq	%rsp, %rbp
	
	subq	$16, %rsp

	call	initAll

	// movq	$0xFF000000000000, %rdi
	// call	printBitboard

	movl	$0, -4(%rbp)
	cmpl	$0, -4(%rbp)
	je	uciLoop

	leaq	tricky_pos, %rdi
	call	parseFEN

	call	printBoard

	// movl	$5, %edi
	// call	perft_test

	// movl	$white, %edi
	// call 	printAttackedSquares

	movl	$7, %edi
	call	searchPosition

	// movl	$6, %edi
	// call	search

	// movl	%eax, %edi
	// call	print_move

	jmp		end
uciLoop:
	// movl	$0, %eax
	call	uci
	
end:
	movl	$0, %eax

	# epilogue 
	movq    %rbp, %rsp
	popq    %rbp

	ret
