# CRC-16-CCITT Transmitter & Receiver on FPGA

A bit-serial CRC-16 link — transmitter, memory, error-injecting channel and receiver — written in
Verilog and running on an Avnet **ZedBoard** (Xilinx Zynq-7000 `xc7z020clg484-1`). The receiver
verifies by **polynomial residue**, not by recomputing and comparing, so it detects corruption in a
codeword it has never seen before.

Built for *Reconfigurable Computing*, Lab Assignment 2 (Q2), Delhi Technological University.

![Architecture](images/crc16_architecture.png)

---

## What it does

Type a message into the VIO, press a button, and the transmitter serialises it one bit per clock
through a Galois LFSR, appends the 16-bit remainder and stores the codeword. Press another button
and the codeword streams through a channel that can flip any bit you name, into a receiver that
divides the whole thing by the same generator and lights **RECEIVED** or **CORRUPTED**.

A second input path lets you type a codeword *by hand* and feed it straight to the receiver,
bypassing the transmitter entirely — which is how you prove the receiver is doing real division and
how you inject burst errors the single-bit channel can't produce.

```
G(x) = x^16 + x^12 + x^5 + 1   (0x1021)
INIT = 0xFFFF,  MSB-first,  no reflection,  no final XOR
```

**Features**

- Variable message length, 1–32 bits, set at runtime — no rebuild
- Bit-serial interface into the transmitter, per the assignment's requirement
- FSMD throughout: control FSM + separate datapath in every block
- Runtime single-bit error injection by index, in flight, without modifying stored data
- OVERRIDE multiplexer selecting transmitter output or a user-supplied codeword
- No IP cores other than the Xilinx VIO
- 350 self-checking simulation assertions against an independent long-division golden model

---

## Results

Implemented in Vivado 2025.2 on `xc7z020clg484-1`. All timing constraints met, fully routed,
no DRC violations in user logic.

| | |
|---|---|
| Throughput (CRC engine) | 1 bit/clock — **100 Mbit/s** @ 100 MHz |
| End-to-end latency, 32-bit message | 87 cycles — **870 ns** |
| Latency, load phase | *L* + 5 cycles |
| Latency, transmit + verify | *L* + 18 cycles |
| **WNS** | **+3.684 ns** on a 10 ns constraint |
| **Fmax** | **158.3 MHz** (58 % headroom) |
| Slice LUTs | 1197 total — **271 are user logic** (0.51 %) |
| Slice Registers | 2006 total — **332 are user logic** (0.31 %) |
| BRAM / DSP | **0 / 0** |
| Total on-chip power | 0.119 W (0.013 W dynamic) |
| Simulation checks | 350 pass / 0 fail |

Two numbers worth reading together. The whole CRC design (`crc_core` + synchronisers) is
**271 LUTs and 332 flip-flops**. The VIO core and JTAG debug hub that Vivado inserts come to
**926 LUTs and 1674 flip-flops** — the debug infrastructure is 3.4× the logic and 5× the
registers of the circuit it observes. Within the design, one CRC engine is 16 flip-flops
and 3 XOR gates.

And the critical path is not the CRC. It runs `par_len[3] → sr_reg[39]` through five LUTs of the
serializer's variable left-shift `par_data << (WIDTH - par_len)` — the barrel shifter is
simultaneously the largest and the slowest block in the design.

## Repository layout

```
rtl/
  CRC16.v              shared Galois LFSR primitive (16 FFs, 1 bit/clk)
  SERIALIZER.v         48-bit shift register, parallel in -> serial out
  CRC_TX.v             transmitter FSMD: LOAD -> APPEND -> DONE
  MSG_MEM.v            codeword store, parallel write / serial read
  CustomBuff.v         second input path, user-supplied codeword
  CRC_RX.v             receiver FSMD: RECV -> CHECK -> DONE
  CRC_CORE.v           structural glue, channel, OVERRIDE mux
  CRC_TOP.v            pins, synchronisers, VIO, LEDs
constraints/
  CRC_CONSTRAINTS.xdc  ZedBoard pin + timing constraints
sim/
  CRC_REF.v            golden model by explicit long division (non-synthesisable)
  TB_CRC16.v           249 checks on the LFSR primitive
  TB_CRC_CORE.v        101 checks on the full system
  TB_LATENCY.v         cycle-count instrumentation
images/
  crc16_architecture.svg / .png
vivado/
  collect_reports.tcl  dumps utilisation / timing / power reports
REPORT.md              full write-up: theory, architecture, results
```

---

## Build

**Vivado**

1. Create an RTL project, part `xc7z020clg484-1` (or board *ZedBoard Zynq Evaluation and Development Kit*).
2. Add `rtl/*.v` as **design sources**, `sim/*.v` as **simulation sources**, `constraints/CRC_CONSTRAINTS.xdc` as a constraint.
3. Set `crc_top` as top.
4. IP Catalog → **VIO (Virtual Input/Output) 3.0** → name it `vio_0`:

   | | Width | Signal |
   |---|---|---|
   | `probe_in0` | 48 | `codeword` |
   | `probe_in1` | 16 | `crc_out` |
   | `probe_in2` | 16 | `residue` |
   | `probe_in3` | 6 | `cw_len` |
   | `probe_in4` | 6 | `msg_len` |
   | `probe_in5` | 6 | `cust_len` |
   | `probe_in6` | 3 | `tx_state` |
   | `probe_out0` | 1 | `clr` |
   | `probe_out1` | 1 | `err_en` |
   | `probe_out2` | 6 | `err_idx` |
   | `probe_out3` | 48 | `par_data` |
   | `probe_out4` | 6 | `par_len` |

5. Run Synthesis → Implementation → Generate Bitstream.
6. Open Hardware Manager, program the device with **both** `crc_top.bit` and `crc_top.ltx`
   (without the `.ltx` the probes come up unnamed).

**Simulation with Icarus Verilog**

```bash
iverilog -o crc_tb sim/TB_CRC16.v sim/CRC_REF.v rtl/CRC16.v && vvp crc_tb
iverilog -o core_tb sim/TB_CRC_CORE.v sim/CRC_REF.v rtl/*.v && vvp core_tb
```

---

## Board controls

| Control | Pin | Function |
|---|---|---|
| **BTNL** | N15 | `par_load` — load the VIO word into the selected destination |
| **BTNR** | R18 | `start_tx` — stream the selected source to the receiver |
| **BTND** | R16 | `rst` |
| **SW0** | F22 | `override` — 0 = transmitter's codeword, 1 = custom buffer |
| **SW1** | G22 | `load_sel` — 0 = load into transmitter, 1 = load into custom buffer |

| LED | Meaning |
|---|---|
| LD0 | RECEIVED |
| LD1 | CORRUPTED |
| LD2 | `tx_ready` |
| LD3 | `rx_done` |
| LD4 | `override` |
| LD5 | `load_sel` |

Set the VIO radixes to **Hex** for `par_data`, `codeword`, `crc_out`, `residue` and **Unsigned
Decimal** for `par_len`, `err_idx`, `msg_len`, `cw_len`, `cust_len`.

> Press `clr` once after programming. Flip-flops power up to 0, so `crc_out` and `residue` must read
> `FFFF` before the first load.

---

## Try it

**Clean transmission** — SW0 down, SW1 down:

```
par_data = D,  par_len = 4     ->  BTNL
   msg_len 4 | crc_out DFB2 | cw_len 20 | codeword DDFB2 | LD2 on
BTNR
   LD0 RECEIVED | residue 0000
```

**Inject a single-bit error** — leave the codeword loaded, set `err_en = 1`:

| `err_idx` | Residue | Verdict |
|---:|---|---|
| 19 | `A9A1` | CORRUPTED |
| 15 | `1B98` | CORRUPTED |
| 3 | `8108` | CORRUPTED |
| 0 | `1021` | CORRUPTED |

`codeword` stays `DDFB2` throughout — the memory is never modified, the bit is flipped in flight.

**The burst boundary** — SW1 up, type a codeword into the custom buffer, SW1 down, SW0 up, BTNR:

| Input | Error | Verdict | Residue |
|---|---|---|---|
| `DDFB2` | none | RECEIVED | `0000` |
| `DDFB3` | 1 bit | CORRUPTED | `1021` |
| `22042` | 16-bit burst | CORRUPTED | `C0D1` |
| `55EBA` | 4 bits spanning 17 | **RECEIVED** | `0000` |

The last row is not a bug. `55EBA = DDFB2 ⊕ (G << 3)` — the error pattern is an exact multiple of
the generator, so it divides evenly and the check passes. Sixteen-wide bursts are always caught;
seventeen is one past the guarantee.

---

## How the receiver works

It does not recompute the CRC and compare. It runs the identical LFSR over message *and* CRC
together and checks for a zero remainder. Since the transmitted word $T(x)$ is a multiple of $G(x)$
by construction, a received word $T'(x) = T(x) + E(x)$ satisfies

$$T'(x) \bmod G(x) = E(x) \bmod G(x)$$

The syndrome depends only on which bits flipped, never on the data — which is exactly what the table
above shows: `err_idx = 3` gives `8108` for a 4-bit, an 8-bit and a 32-bit message alike. An error
escapes if and only if $E(x)$ is itself a multiple of $G(x)$.

Full derivation, resource breakdown and timing analysis in **[REPORT.md](REPORT.md)**.

---

## Verification

| Bench | Checks | What it proves |
|---|---:|---|
| `TB_CRC16` | 249 | `"123456789"` → `0x29B1` (published CCITT vector); 200 random messages vs. an independent long-division model |
| `TB_CRC_CORE` | 101 | Clean/corrupt paths, custom stream both directions, variable lengths, the blind spot |
| `TB_LATENCY` | — | Cycle counts quoted above |
| Hardware | 11 tests | All pass on ZedBoard |

The golden model in `CRC_REF.v` is written as explicit polynomial long division, deliberately a
*different algorithm* from the LFSR under test — agreement between two implementations of the same
mathematics is evidence; agreement between two copies of the same code is not.

---

## Known limitation

The push buttons are not debounced. This is harmless on the transmitter path — `crc_tx` accepts
bits only in `T_LOAD` and `go` is gated by `~busy`. `custom_buff` is the exception: it appends
unconditionally, so a bounced press can load the same word twice. **Read back `cust_len` after every
custom load.** A `cust_loaded` latch in `crc_core.v` would fix it properly.

---

## License

MIT
