import bitstring, random
from enum import Enum
from math import floor

span = 10000000
class FPUoperation(Enum):
    ADD = 0b0000
    SUB = 0b0001


def ieee754(flt):
    b = bitstring.BitArray(float=flt, length=32)
    return b

def generate_add_case():
    a = ieee754(random.uniform(-span, span))
    b = ieee754(random.uniform(-span, span))
    ab = ieee754(floor(a.float + b.float))
    return a, b, ab, FPUoperation.ADD

def generate_sub_case():
    a = ieee754(random.uniform(-span, span))
    b = ieee754(random.uniform(-span, span))
    ab = ieee754(floor(a.float - b.float))
    return a, b, ab, FPUoperation.SUB
