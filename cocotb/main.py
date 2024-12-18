import cocotb
from cocotb.triggers import Timer
from helpers import generate_add_case, generate_sub_case, generate_multiply_case, FPUoperation  # Assuming your helper script is named `helper.py`
import struct

def int_to_float(value):
    """
    Convert a 32-bit integer representing an IEEE-754 float back to a Python float.
    """
    return struct.unpack('f', struct.pack('I', value))[0]

async def bin_to_float(binary):
    return struct.unpack('!f',struct.pack('!I', int(binary, 2)))[0]

@cocotb.test()
async def test_fpu_adder(dut):
    """
    Test the FPU adder module for correctness with random cases.
    """
    for i in range(1000):  # Generate and test 100 random cases
        # Generate test case
        a, b, expected_result, op = generate_add_case()

        # Apply inputs
        dut.num1.value = int(a.hex, 16)  # Convert to integer for HDL compatibility
        dut.num2.value = int(b.hex, 16)
        dut.op.value = op.value

        # Wait for combinational delay
        await Timer(1, units="ns")  # Adjust the time and units if needed based on your simulator

        # Read and convert output
        result = dut.result.value
        dut_res_bin = result.binstr
        dut_res_float = await bin_to_float(dut_res_bin)
        expected_float = expected_result.float

        error_magnitude = abs(expected_float - dut_res_float)

        # Validate result
        if abs(error_magnitude) > 2.5:
            raise AssertionError(
                f"Test failed for inputs {a.float} + {b.float}:\n"
                f"Expected: {expected_float} (0x{expected_result.hex})\n"
                f"Got: {dut_res_float} (0x{result:08x})"
            )

        # Print success (optional for debugging)
        dut._log.info(
            f"Test passed for inputs {a.float} + {b.float} = {dut_res_float}"
            f"\nError magnitude {error_magnitude}"
        )


@cocotb.test()  
async def test_fpu_subtractor(dut):
    """
    Test the FPU subtractor module for correctness with random cases.
    """
    for i in range(1000):  # Generate and test 100 random cases
        # Generate test case
        a, b, expected_result, op = generate_sub_case()

        # Apply inputs
        dut.num1.value = int(a.hex, 16)  # Convert to integer for HDL compatibility
        dut.num2.value = int(b.hex, 16)
        dut.op.value = op.value

        # Wait for combinational delay
        await Timer(1, units="ns")  # Adjust the time and units if needed based on your simulator

        # Read and convert output
        result = dut.result.value
        dut_res_bin = result.binstr
        dut_res_float = await bin_to_float(dut_res_bin)
        expected_float = expected_result.float

        error_magnitude = abs(expected_float - dut_res_float)

        # Validate result
        if abs(error_magnitude) > 2.5:
            raise AssertionError(
                f"Test failed for inputs {a.float} - {b.float}:\n"
                f"Expected: {expected_float} (0x{expected_result.hex})\n"
                f"Got: {dut_res_float} (0x{result:08x})"
            )

        # Print success (optional for debugging)
        dut._log.info(
            f"Test passed for inputs {a.float} - {b.float} = {expected_float}"
            f"\nError magnitude {error_magnitude}"
        )

@cocotb.test()
async def test_fpu_multiplier(dut):
    """
    Test the FPU multiplier module for correctness with random cases.
    """
    for i in range(1000):  # Generate and test 100 random cases
        # Generate test case
        a, b, expected_result, op = generate_multiply_case()

        # Apply inputs
        dut.num1.value = int(a.hex, 16)  # Convert to integer for HDL compatibility
        dut.num2.value = int(b.hex, 16)
        dut.op.value = op.value

        # Wait for combinational delay
        await Timer(1, units="ns")  # Adjust the time and units if needed based on your simulator

        # Read and convert output
        result = dut.result.value
        dut_res_bin = result.binstr
        dut_res_float = await bin_to_float(dut_res_bin)
        expected_float = expected_result.float
        error_magnitude = abs(expected_float - dut_res_float)
        # Validate result
        if abs(error_magnitude) > 0.1:
            raise AssertionError(
                f"Test failed for inputs {a.float} * {b.float}:\n"
                f"Expected: {expected_float} (0x{expected_result.hex})\n"
                f"Got: {dut_res_float} (0x{result:08x})"
            )
        # Print success (optional for debugging)
        dut._log.info(
            f"Test passed for inputs {a.float} * {b.float} = {dut_res_float}"
            f"\nError magnitude {error_magnitude}"
        )
