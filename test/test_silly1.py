# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
            
    dut.ui_in[0].value = 1
    
    # Wait for two clock cycle to see the output values
    await ClockCycles(dut.clk, 2)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out[0].value == 1

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
    # Set the input values you want to test
            
    dut.ui_in[1].value = 1
    
    # Wait for four clock cycle to see the output values
    await ClockCycles(dut.clk, 4)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out[1].value == 1
    
    # Set the input values you want to test
            
    dut.ui_in[2].value = 1
    
    # Wait for eight clock cycle to see the output values
    await ClockCycles(dut.clk, 8)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out[2].value == 1
    # Set the input values you want to test
            
    dut.ui_in[3].value = 1
    
    # Wait for sixteen clock cycle to see the output values
    await ClockCycles(dut.clk, 16)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out[3].value == 1
    # Set the input values you want to test
            
    dut.ui_in[4].value = 1
    
    # Wait for thirty two clock cycle to see the output values
    await ClockCycles(dut.clk, 32)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out[4].value == 1
    # Set the input values you want to test
            
    dut.ui_in[5].value = 1
    
    # Wait for sixty four clock cycle to see the output values
    await ClockCycles(dut.clk, 64)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out[5].value == 1
    # Set the input values you want to test
            
    dut.ui_in[6].value = 1
    
    # Wait for one hundred twenty eight clock cycle to see the output values
    await ClockCycles(dut.clk, 128)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out[6].value == 1
    # Set the input values you want to test
            
    dut.ui_in[7].value = 1
    
    # Wait for two hundred fifty six clock cycle to see the output values
    await ClockCycles(dut.clk, 256)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out[7].value == 1
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
