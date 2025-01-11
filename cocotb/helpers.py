import bitstring, random
from enum import Enum
from math import floor
import struct
span = 100
class FPUoperation(Enum):
    ADD = 0b0000
    SUB = 0b0001
    MUL = 0b0010
    DIV = 0b0011


def ieee754(flt):
    b = bitstring.BitArray(float=flt, length=32)
    return b

def generate_add_case():
    a = ieee754(random.uniform(-span, span))
    b = ieee754(random.uniform(-span, span))
    ab = ieee754(a.float + b.float)
    return a, b, ab, FPUoperation.ADD

def generate_sub_case():
    a = ieee754(random.uniform(-span, span))
    b = ieee754(random.uniform(-span, span))
    ab = ieee754(a.float - b.float)
    return a, b, ab, FPUoperation.SUB

def generate_multiply_case():
    a = ieee754(random.uniform(-100, 100))
    b = ieee754(random.uniform(-100, 100))
    ab = ieee754(a.float * b.float)
    return a, b, ab, FPUoperation.MUL

def generate_divide_case():
    a = ieee754(random.uniform(-100, 100))
    b = ieee754(random.uniform(-100, 100))
    ab = ieee754(a.float / b.float)
    return a, b, ab, FPUoperation.DIV

def bin_to_float(binary):
    return struct.unpack('!f',struct.pack('!I', int(binary, 2)))[0]

def main():
    binary_str = "01000001010110110001101000011100"
    float_res = bin_to_float(binary_str)
    print(f"Float Value: {float_res}")

if __name__ == "__main__":
    main()