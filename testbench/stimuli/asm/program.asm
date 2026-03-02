.start 10
.org 10

# Load constants
IADD R1, R0, 10
OUT R1

LDM R2, 20
LDM R3, 10
ADD R4, R2, R3
OUT R4

# Memory test
STD R4, 100(R0)
LDD R5, 100(R0)
SUB R6, R5, R4
JZ ZERO_OK
IADD R1, R0, 999
OUT R1
HLT

ZERO_OK:
IADD R1, R0, 5
OUT R1

# Loop test
IADD R7, R0, 3

LOOP:
SUB R7, R7, R1
JN LOOP_END
JMP LOOP

LOOP_END:
OUT R7
HLT