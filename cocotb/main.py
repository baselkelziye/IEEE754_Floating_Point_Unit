import cocotb
from cocotb.triggers import Timer
from helpers import generate_add_case, generate_sub_case, FPUoperation  # Assuming your helper script is named `helper.py`
import struct

def int_to_float(value):
    """
    Convert a 32-bit integer representing an IEEE-754 float back to a Python float.
    """
    return struct.unpack('f', struct.pack('I', value))[0]

@cocotb.test()
async def test_fpu_adder(dut):
    """
    Test the FPU adder module for correctness with random cases.
    """
    for i in range(100):  # Generate and test 100 random cases
        # Generate test case
        a, b, expected_result, op = generate_add_case()

        # Apply inputs
        dut.num1.value = int(a.hex, 16)  # Convert to integer for HDL compatibility
        dut.num2.value = int(b.hex, 16)
        dut.op.value = op.value

        # Wait for combinational delay
        await Timer(1, units="ns")  # Adjust the time and units if needed based on your simulator

        # Read and convert output
        result = dut.result.value.integer
        result_float = int_to_float(result)  # Convert DUT output to float

        # Convert expected_result (BitArray) to float for comparison
        expected_float = expected_result.float

        # Validate result
        if abs(expected_float - result_float) > 1.5:
            raise AssertionError(
                f"Test failed for inputs {a.float} + {b.float}:\n"
                f"Expected: {expected_float} (0x{expected_result.hex})\n"
                f"Got: {result_float} (0x{result:08x})"
            )

        # Print success (optional for debugging)
        dut._log.info(
            f"Test passed for inputs {a.float} + {b.float} = {expected_float}"
        )

@cocotb.test()
async def test_fpu_subtractor(dut):
    """
    Test the FPU subtractor module for correctness with random cases.
    """
    for i in range(100):  # Generate and test 100 random cases
        # Generate test case
        a, b, expected_result, op = generate_sub_case()

        # Apply inputs
        dut.num1.value = int(a.hex, 16)  # Convert to integer for HDL compatibility
        dut.num2.value = int(b.hex, 16)
        dut.op.value = op.value

        # Wait for combinational delay
        await Timer(1, units="ns")  # Adjust the time and units if needed based on your simulator

        # Read and convert output
        result = dut.result.value.integer
        result_float = int_to_float(result)  # Convert DUT output to float

        # Convert expected_result (BitArray) to float for comparison
        expected_float = expected_result.float

        # Validate result
        if abs(expected_float - result_float) > 2.1:
            raise AssertionError(
                f"Test failed for inputs {a.float} - {b.float}:\n"
                f"Expected: {expected_float} (0x{expected_result.hex})\n"
                f"Got: {result_float} (0x{result:08x})"
            )

        # Print success (optional for debugging)
        dut._log.info(
            f"Test passed for inputs {a.float} - {b.float} = {expected_float}"
        )
