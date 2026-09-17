# VendingMachineVerilog

A small synchronous Verilog vending-machine controller with coin accumulation, two product prices, cancellation, change return, status LEDs, and a two-digit seven-segment balance display.

## Design

`vending_machine` is a four-state controller:

- `IDLE` accepts 5-, 10-, and 25-cent sensor pulses and product requests.
- `DISPENSE` emits a one-cycle product pulse and decides whether leftover balance must be returned.
- `INSUFFICIENT` indicates that a product request was below the required balance while still accepting coins.
- `RETURN` emits change one coin at a time, preferring 25 cents, then 10 cents, then 5 cents.

Product prices are 35 cents (`P_35`) and 50 cents (`P_50`). The balance is exposed as separate tens and units through `binary_to_segmented.v`. Product and coin outputs are pulse-style registers; the four LED outputs are combinational views of the current state.

## Files

- `VendingMachine.v` — top-level controller and decoder instantiation.
- `binary_to_segmented.v` — combinational decoder for decimal digits 0–9.
- `tests.v` — clocked testbench covering exact payment, change, insufficient balance, and cancellation.
- `waveform.vcd` — checked-in waveform produced by the testbench.
- `tests.v.out` — checked-in Icarus Verilog output artifact.

## Simulate

The testbench is written for a simulator such as Icarus Verilog:

```sh
iverilog -o vending_machine_sim tests.v
vvp vending_machine_sim
```

The testbench writes `waveform.vcd`, which can be inspected with GTKWave.

## Interface

Inputs are `C_5`, `C_10`, `C_25`, `P_35`, `P_50`, `cancel`, `clk`, and `reset`. Outputs are `P_35_out`, `P_50_out`, `C_5_out`, `C_10_out`, `C_25_out`, `balance_seg_1`, `balance_seg_2`, `idle_led`, `dispense_led`, `return_led`, and `insufficient_led`.

## Notes

This is a simulation-oriented module; no FPGA constraint files, synthesis project, or CI configuration is included.