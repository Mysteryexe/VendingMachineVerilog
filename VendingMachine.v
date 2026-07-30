module vendingMachine (
    input C_5, // coin 5 sensor
    input C_10, // coin 10 sensor
    input C_25, // coin 25 sensor
    input P_35, // product 35 request
    input P_50, // product 50 request
    input cancel, // cancel request
    input clk, // clock signal
    input reset, // reset signal
    output reg P_35_out, // product 35 output
    output reg P_50_out, // product 50 output
    output reg C_5_out, // coin 5 output
    output reg C_10_out, // coin 10 output
    output reg C_25_out, // coin 25 output
    output reg [6:0] balance_seg_1, // balance segment 1
    output reg [6:0] balance_seg_2, // balance segment 2
    output reg idle_led, // idle light
    output reg dispense_led, // dispensing product light
    output reg return_led // returning coins light
);

    parameter IDLE = 2'b00; // waiting for input(coin/product request)
    parameter DISPENSE = 2'b01; // dispensing product
    parameter INSUFFICIENT = 2'b10; // insufficient balance for product
    parameter RETURN = 2'b11; // returning coins

    reg [1:0] current_state; // one of the 4 states
    reg [7:0] balance; // balance in cents
endmodule