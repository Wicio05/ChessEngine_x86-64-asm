# Chess Engine in x86-64 Assembly

A lightweight, terminal-based chess engine built from scratch — no external libraries, just pure C and assembly. It supports a modified **UCI (Universal Chess Interface)** for human vs. engine interaction and features a fast, bitboard-based move generation system with evaluation and search capabilities.

---

## Author

**Individual Project**  
Developed by a single programmer with experience in **C**, **C++**, **Java**, and **C#**.  
This project marks the continuation of a 2-year journey in chess programming, starting from a basic "mailbox" implementation to a fully optimized bitboard engine.

---

## Description

This is a terminal-based chess bot that plays against a human player.  
It follows all standard chess rules:

- **Pieces:** 8 pawns, 2 knights, 2 bishops, 2 rooks, 1 queen, 1 king per side  
- **Objective:** Checkmate the opponent’s king  
- **Draw conditions:**  
  - Stalemate (no legal moves but not in check)  
  - Threefold repetition  

---

## OS Requirements

- **No specific OS requirements.**  
- The terminal **must support ANSI escape codes** for board rendering.  
- Tested and fully functional on **Linux terminals**.  

---

## Dependencies

- **No external libraries used.**  
- Implementation uses **pure C functions executed in assembly**.  

---

## Interface

The game runs entirely in the terminal.  
The chessboard:

- Uses **ANSI escape codes** to redraw and update the board dynamically.  
- Displays pieces as **Unicode characters** for readability.  
- May appear small — zoom in your terminal for a better view.  

---

## ⌨User Input (Modified UCI Commands)

The engine uses a **modified Universal Chess Interface** for interaction.  
Supported commands:

| Command | Description |
|----------|-------------|
| `position startpos` | Set the board to the standard chess starting position. |
| `position startpos moves e2e4 e7e5 ...` | Set the board after a sequence of moves. |
| `move [source target]` | Make a move manually, e.g., `move e2e4`. |
| `flip` | Flip the board orientation. Default: Player = White, Engine = Black. |
| `quit` | Exit the program. |
| `go [depth x]` | Start the engine to compute the best move. Default depth = 6. Example: `go depth 4`. |

---

## Data Representation

The engine uses **bitboards (64-bit variables)** for board representation, providing efficient manipulation and move generation.

### Move Encoding (24 bits total)
Each move is stored as a single integer using bitwise operations:

| Component | Bits | Description |
|------------|------|-------------|
| Source square | 6 | Value 0–63 |
| Target square | 6 | Value 0–63 |
| Moving piece | 4 | Value 0–11 |
| Promoted piece | 4 | Value 0–12 (`12` = no promotion) |
| Capture flag | 1 | 1 if capture |
| Double pawn push flag | 1 | 1 if double move |
| En passant flag | 1 | 1 if en passant capture |
| Castling flag | 1 | 1 if castling move |

---

## Move Generation

The engine employs:

- **Attack masks** for leaping pieces (knights, kings).  
- **Magic bitboards** for sliding pieces (rooks, bishops, queens).  

This allows efficient precomputation and retrieval of possible attacks per square.

---

## Evaluation

The evaluation function considers:

- **Material balance** (piece values).  
- **Piece activity** and **positional bonuses**, ensuring pieces occupy strong, active squares.

---

## Search Algorithm

The engine searches for the best moves using:

1. **Negamax Alpha-Beta Pruning**  
   - Alpha = minimum score guaranteed for maximizing player  
   - Beta = maximum score guaranteed for minimizing player  

2. **Quiescence Search**  
   - Extends the search for “quiet” positions  
   - Avoids evaluating unstable tactical positions (captures, checks, promotions)
