# Boingus ISA

## Registers

32 general-purpose 32-bit registers with 5-bit register fields. `R0` is hardwired to
zero; `R29`–`R31` have fixed roles.

| Encoding | Dec | Name | Alias | Notes |
|---|---|---|---|---|
| `00000` |  0 | `ZERO` | `R0` | Hardwired zero: reads as 0, writes are discarded |
| `00001` |  1 | `R1` | | |
| `00010` |  2 | `R2` | | |
| `00011` |  3 | `R3` | | |
| `00100` |  4 | `R4` | | |
| `00101` |  5 | `R5` | | |
| `00110` |  6 | `R6` | | |
| `00111` |  7 | `R7` | | |
| `01000` |  8 | `R8` | | |
| `01001` |  9 | `R9` | | |
| `01010` | 10 | `R10` | | |
| `01011` | 11 | `R11` | | |
| `01100` | 12 | `R12` | | |
| `01101` | 13 | `R13` | | |
| `01110` | 14 | `R14` | | |
| `01111` | 15 | `R15` | | |
| `10000` | 16 | `R16` | | |
| `10001` | 17 | `R17` | | |
| `10010` | 18 | `R18` | | |
| `10011` | 19 | `R19` | | |
| `10100` | 20 | `R20` | | |
| `10101` | 21 | `R21` | | |
| `10110` | 22 | `R22` | | |
| `10111` | 23 | `R23` | | |
| `11000` | 24 | `R24` | | |
| `11001` | 25 | `R25` | | |
| `11010` | 26 | `R26` | | |
| `11011` | 27 | `R27` | | |
| `11100` | 28 | `R28` | | |
| `11101` | 29 | `SP` | `R29` | Stack pointer |
| `11110` | 30 | `FP` | `R30` | Frame pointer |
| `11111` | 31 | `LR` | `R31` | Link register (return address) |

There are no sub-registers. 16-bit (and 8-bit) data lives in full registers: loads
zero-extend to 32 bits (use `SX8`/`SX16` to sign-extend), stores write the low bits.

## Program counter

`PC` is not a general-purpose register and has no register encoding. Code reaches it
only through:

- **branches and jumps**, which write it,
- **jump-and-link** (`BL`, `BLR`), which writes the return address (`PC` + 4) into a
  register (`LR` for `BL`),
- **`ADR`**, which computes `PC` + offset into a general register, for
  position-independent code and constant/global access.

## Calling Convention - BoingusCC


| Registers | ABI name | Role | Saved by |
|---|---|---|---|
| `R0` | `ZERO` | hardwired zero | n/a |
| `R1`–`R8` | `A0`–`A7` | arguments; `A0`/`A1` also return values | caller |
| `R9`–`R16` | `T0`–`T7` | temporaries | caller |
| `R17`–`R28` | `S0`–`S11` | saved | callee |
| `R29` | `SP` | stack pointer | preserved |
| `R30` | `FP` | frame pointer | callee |
| `R31` | `LR` | return address | caller (every call overwrites it) |

That's 16 caller-saved general registers (`A`, `T`), plus `LR`, and 13 callee-saved (`S`, `FP`).

- **Caller-saved** (`A`, `T`): a called function may overwrite them. A caller that
  needs one of these values after a call must save it first.
- **Callee-saved** (`S`, `FP`): a function that uses one must restore its original
  value before returning, so values in them survive calls.
- **Return values** go in `A0`, or in `A0`/`A1` for 64-bit values (low half in `A0`).
- `A`, `T` and `S` are assembler aliases for the `R` numbers

## Instructions

All instructions are 32 bits. Registers take up 5 bits of encoding.

### Encoding formats

| Prefix | Format | Operands | Used for | Sub-encoding bits | Max instructions |
|---|---|---|---|---|---|
| `000` | rrr | 3 registers | general purpose binary, comparisons | 14 | 16384 |
| `001` | rr | 2 registers | unary, register jumps | 19 | 524288 |
| `01` | rru12 | 2 registers + 12-bit immediate | loads, stores | 8 | 256 |
| `10` | rru16 | 2 registers + 16-bit immediate | binary with wider immediate, shifts by a constant, conditional branches | 4 | 16 |
| `110` | ru16u5 | 1 register + 16-bit immediate + 5-bit shift | arithmetic with shifted immediate | 3 | 8 |
| `111` | j28 | 28-bit offset (counted in 4-byte instructions, ±512 MiB) | jumps and calls | 1 | 2 |

Sub-encoding bits = 32 − prefix − (5 per register) − immediate and shift bits.

### Instruction list

The Sub-encoding column shows the whole instruction: `(prefix)`, then the
sub-encoding bits, then the operand fields.

Operand names: `r` = destination register, `n`, `m` = source registers, `a` = register
holding an address, `i` = immediate, `o` = shift amount. Immediates are zero-extended,
except offsets (loads, stores, branches, jumps, `ADR`), which are signed. Mnemonics can repeat across formats (e.g.
`ADD`); the operands tell the assembler which form is meant.

#### rrr : 000
| Mnemonic | Sub-encoding | What it does | Notes |
|---|---|---|---|
| ADD | (000)0 0000 0000 0000 0(r, n, m) | r = n + m | wrapping |
| SUB | (000)0 0000 0000 0000 1(r, n, m) | r = n - m | wrapping |
| LSL | (000)0 0000 0000 0001 0(r, n, m) | r = n << m | logical shift left (fills with 0); uses the low 5 bits of m |
| LSR | (000)0 0000 0000 0001 1(r, n, m) | r = n >> m | logical shift right (fills with 0); uses the low 5 bits of m |
| AND | (000)0 0000 0000 0010 0(r, n, m) | r = n & m | |
| OR | (000)0 0000 0000 0010 1(r, n, m) | r = n \| m | |
| XOR | (000)0 0000 0000 0011 0(r, n, m) | r = n ^ m | |
| LD64 | (000)0 0000 0000 0100 0(r, n, a) | r = word at a, n = word at (a + 4) | little endian: r gets the low half, n the high half |
| ST64 | (000)0 0000 0000 0100 1(r, n, a) | word at a = r, word at (a + 4) = n | little endian: r is the low half, n the high half |
| ASR | (000)0 0000 0000 0101 0(r, n, m) | r = n >> m | arithmetic shift right (fills with copies of bit 31); uses the low 5 bits of m |
| SEQ | (000)0 0000 0010 0000 0(r, n, m) | r = 1 if n == m, else 0 |  |
| SNE | (000)0 0000 0010 0000 1(r, n, m) | r = 1 if n != m, else 0 |  |
| SLT | (000)0 0000 0010 0001 0(r, n, m) | r = 1 if n < m, else 0 | signed compare |
| SGE | (000)0 0000 0010 0001 1(r, n, m) | r = 1 if n >= m, else 0 | signed compare |
| SLTU | (000)0 0000 0010 0010 0(r, n, m) | r = 1 if n < m, else 0 | unsigned compare |
| SGEU | (000)0 0000 0010 0010 1(r, n, m) | r = 1 if n >= m, else 0 | unsigned compare |

Comparisons use their own block of 8 sub-encodings (64–71). The low 3 bits give the
condition, in the same order as the `rru16` branches: EQ, NE, LT, GE, LTU, GEU
(110 and 111 are free). For `>` and `<=`, swap the operands: `SGT r, n, m` =
`SLT r, m, n`.

#### rr : 001
| Mnemonic | Sub-encoding | What it does | Notes |
|---|---|---|---|
| NOT | (001)0 0000 0000 0000 0000 00(r, n) | r = ~n | |
| SX8 | (001)0 0000 0000 0000 0000 01(r, n) | r = low 8 bits of n, sign-extended | bits 31:8 copy bit 7 |
| SX16 | (001)0 0000 0000 0000 0000 10(r, n) | r = low 16 bits of n, sign-extended | bits 31:16 copy bit 15 |
| ZX8 | (001)0 0000 0000 0000 0000 11(r, n) | r = low 8 bits of n, zero-extended | bits 31:8 are 0 |
| ZX16 | (001)0 0000 0000 0000 0001 00(r, n) | r = low 16 bits of n, zero-extended | bits 31:16 are 0 |
| BLR | (001)0 0000 0000 0000 0001 01(r, n) | r = PC + 4, then jump to the address in n | call through a register; `BR n` = `BLR ZERO, n`, `RET` = `BLR ZERO, LR` |

#### rru12 : 01
| Mnemonic | Sub-encoding | What it does | Notes |
|---|---|---|---|
| LD8 | (01)00 0000 00(r, a, i) | r = byte at a + i | rest of r is zeroed; i is signed (±2 KiB) |
| LD16 | (01)00 0000 01(r, a, i) | r = half-word at a + (i << 1) | rest of r is zeroed; i is signed (±4 KiB) |
| LD32 | (01)00 0000 10(r, a, i) | r = word at a + (i << 2) | i is signed (±8 KiB) |
| ST32 | (01)00 0001 00(n, a, i) | word at a + (i << 2) = n | i is signed (±8 KiB) |
| ST8 | (01)00 0001 01(n, a, i) | byte at a + i = low 8 bits of n | i is signed (±2 KiB) |
| ST16 | (01)00 0001 10(n, a, i) | half-word at a + (i << 1) = low 16 bits of n | i is signed (±4 KiB) |

#### rru16 : 10
| Mnemonic | Sub-encoding | What it does | Notes |
|---|---|---|---|
| ADD | (10)0000(r, n, i) | r = n + i | wrapping |
| SUB | (10)0001(r, n, i) | r = n - i | wrapping |
| AND | (10)0010(r, n, i) | r = n & i | the top 16 bits of r are cleared |
| OR | (10)0011(r, n, i) | r = n \| i | the top 16 bits of n pass through |
| XOR | (10)0100(r, n, i) | r = n ^ i | the top 16 bits of n pass through |
| LSL | (10)0101(r, n, i) | r = n << i | uses the low 5 bits of i |
| LSR | (10)0110(r, n, i) | r = n >> i | logical (fills with 0); uses the low 5 bits of i |
| ASR | (10)0111(r, n, i) | r = n >> i | arithmetic (fills with copies of bit 31); uses the low 5 bits of i |
| BEQ | (10)1000(n, m, i) | if n == m, jump to PC + (i << 2) | i is signed (±128 KiB) |
| BNE | (10)1001(n, m, i) | if n != m, jump to PC + (i << 2) | i is signed (±128 KiB) |
| BLT | (10)1010(n, m, i) | if n < m, jump to PC + (i << 2) | signed compare; i is signed (±128 KiB) |
| BGE | (10)1011(n, m, i) | if n >= m, jump to PC + (i << 2) | signed compare; i is signed (±128 KiB) |
| BLTU | (10)1100(n, m, i) | if n < m, jump to PC + (i << 2) | unsigned compare; i is signed (±128 KiB) |
| BGEU | (10)1101(n, m, i) | if n >= m, jump to PC + (i << 2) | unsigned compare; i is signed (±128 KiB) |

#### ru16u5 : 110
| Mnemonic | Sub-encoding | What it does | Notes |
|---|---|---|---|
| ADDSH | (110)000(r, i, o) | r = r + (i << o) | a 32-bit constant: `ADD r, ZERO, lo` (rru16) then `ADDSH r, hi, 16` |
| ANDSH | (110)001(r, i, o) | r = r & (i << o) | |
| ORSH | (110)010(r, i, o) | r = r \| (i << o) | |
| ADR | (110)011(r, i, o) | r = PC + (i << o) | PC-relative address; i is signed, so it can point backwards |

#### j28 : 111
| Mnemonic | Sub-encoding | What it does | Notes |
|---|---|---|---|
| B | (111)0(i) | jump to PC + (i << 2) | i is signed |
| BL | (111)1(i) | LR = PC + 4, then jump to PC + (i << 2) | function call; i is signed |
