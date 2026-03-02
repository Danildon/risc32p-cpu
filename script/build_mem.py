import re
import sys

if len(sys.argv) < 3:
    raise Exception("Usage: python build_mem.py program.asm program.mem")

in_file = sys.argv[1]
out_file = sys.argv[2]


# ==========================================================
# ISA OPCODES (must match control_unit.sv)
# ==========================================================

OPCODES = {
    "add":   "00000",
    "sub":   "00001",
    "and":   "00010",
    "swap":  "00011",
    "not":   "00100",
    "mov":   "00101",
    "inc":   "00110",
    "iadd":  "00111",
    "ldd":   "01000",
    "std":   "01001",
    "ldm":   "01010",
    "push":  "01011",
    "pop":   "01100",
    "out":   "01101",
    "in":    "01110",
    "jz":    "01111",
    "jn":    "10000",
    "jc":    "10001",
    "jmp":   "10010",
    "call":  "10011",
    "rti":   "10100",
    "int0":  "10101",
    "int1":  "10110",
    "int2":  "10111",
    "hlt":   "11000",
    "setc":  "11001",
    "ret":   "11010",
    "nop":   "11011"
}

MEM_SIZE = 4096


# ==========================================================
# Helpers
# ==========================================================

def reg_bin(r):
    if not r.startswith("r"):
        raise Exception(f"Invalid register {r}")
    return format(int(r[1:]), "03b")


def imm_bin(val):
    return format(int(val) & 0xFFFFFFFF, "032b")


def instr_word(fields):
    bits = "".join(fields)
    return bits + "0" * (32 - len(bits))


# ==========================================================
# Read source
# ==========================================================

with open(in_file) as f:
    lines = f.readlines()

mem = ["0"*32 for _ in range(MEM_SIZE)]
labels = {}


# ==========================================================
# PASS 1 — collect labels
# ==========================================================

pc = 0

for raw in lines:

    line = raw.split("#")[0].strip().lower()
    if not line:
        continue

    if line.startswith(".org"):
        pc = int(line.split()[1])
        continue

    if line.startswith(".start"):
        continue

    if ":" in line:
        label = line.split(":")[0]
        labels[label] = pc
        line = line.split(":")[1].strip()
        if not line:
            continue

    tokens = re.findall(r"-?\w+", line)
    inst = tokens[0]

    pc += 1

    if inst in [
        "iadd","ldm","ldd","std",
        "jmp","jz","jn","jc","call"
    ]:
        pc += 1


# ==========================================================
# PASS 2 — encode
# ==========================================================

pc = 0

for raw in lines:

    line = raw.split("#")[0].strip().lower()
    if not line:
        continue

    if line.startswith(".org"):
        pc = int(line.split()[1])
        continue


    # START VECTOR
    if line.startswith(".start"):
        mem[0] = imm_bin(line.split()[1])
        continue


    # LABEL
    if ":" in line:
        line = line.split(":")[1].strip()
        if not line:
            continue


    tokens = re.findall(r"-?\w+", line)
    inst = tokens[0]


    # ======================================================
    # simple instructions
    # ======================================================

    if inst in ["hlt","nop","ret","rti","setc"]:

        mem[pc] = instr_word([
            OPCODES[inst]
        ])

        pc += 1
        continue


    # ======================================================
    # OUT  (reads RS)
    # ======================================================

    if inst == "out":

        rs = tokens[1]

        mem[pc] = instr_word([
            OPCODES[inst],
            reg_bin(rs),
            reg_bin("r0"),
            reg_bin("r0")
        ])

        pc += 1
        continue


    # ======================================================
    # IN (writes RD)
    # ======================================================

    if inst == "in":

        rd = tokens[1]

        mem[pc] = instr_word([
            OPCODES[inst],
            reg_bin("r0"),
            reg_bin("r0"),
            reg_bin(rd)
        ])

        pc += 1
        continue


    # ======================================================
    # IADD
    # ======================================================

    if inst == "iadd":

        rd = tokens[1]
        rs = tokens[2]
        imm = tokens[3]

        mem[pc] = instr_word([
            OPCODES[inst],
            reg_bin(rs),
            reg_bin("r0"),
            reg_bin(rd)
        ])

        pc += 1

        mem[pc] = imm_bin(imm)

        pc += 1
        continue


    # ======================================================
    # LDM
    # ======================================================

    if inst == "ldm":

        rd = tokens[1]
        imm = tokens[2]

        mem[pc] = instr_word([
            OPCODES[inst],
            reg_bin("r0"),
            reg_bin("r0"),
            reg_bin(rd)
        ])

        pc += 1

        mem[pc] = imm_bin(imm)

        pc += 1
        continue


    # ======================================================
    # STD / LDD
    # ======================================================

    if inst in ["std","ldd"]:

        rd = tokens[1]
        offset = tokens[2]
        base = tokens[3]

        mem[pc] = instr_word([
            OPCODES[inst],
            reg_bin(base),
            reg_bin(rd),
            reg_bin("r0")
        ])

        pc += 1

        mem[pc] = imm_bin(offset)

        pc += 1
        continue


    # ======================================================
    # BRANCH / CALL
    # ======================================================

    if inst in ["jmp","jz","jn","jc","call"]:

        mem[pc] = instr_word([
            OPCODES[inst]
        ])

        pc += 1

        target = tokens[1]

        if target in labels:
            mem[pc] = imm_bin(labels[target])
        else:
            mem[pc] = imm_bin(target)

        pc += 1
        continue


    # ======================================================
    # 3-register instructions
    # ======================================================

    if inst in OPCODES:

        rd = tokens[1]
        rs = tokens[2]
        rt = tokens[3]

        mem[pc] = instr_word([
            OPCODES[inst],
            reg_bin(rs),
            reg_bin(rt),
            reg_bin(rd)
        ])

        pc += 1
        continue


    raise Exception(f"Unknown instruction {inst}")


# ==========================================================
# write file
# ==========================================================

with open(out_file,"w") as f:

    for word in mem:
        f.write(word+"\n")


print("program.mem generated successfully")