`include "vendingMachine.v"
`timescale 1ns / 1ps

module vending_machine_tests();
    reg C_5;
    reg C_10;
    reg C_25;
    reg P_35;
    reg P_50;
    reg cancel;
    reg clk;
    reg reset;
    wire P_35_out;
    wire P_50_out;
    wire C_5_out;
    wire C_10_out;
    wire C_25_out;
    wire [6:0] balance_seg_1;
    wire [6:0] balance_seg_2;
    wire idle_led;
    wire dispense_led;
    wire return_led;
    wire insufficient_led;

    vending_machine vendingMachine (
        .C_5(C_5),
        .C_10(C_10),
        .C_25(C_25),
        .P_35(P_35),
        .P_50(P_50),
        .cancel(cancel),
        .clk(clk),
        .reset(reset),
        .P_35_out(P_35_out),
        .P_50_out(P_50_out),
        .C_5_out(C_5_out),
        .C_10_out(C_10_out),
        .C_25_out(C_25_out),
        .balance_seg_1(balance_seg_1),
        .balance_seg_2(balance_seg_2),
        .idle_led(idle_led),
        .dispense_led(dispense_led),
        .return_led(return_led),
        .insufficient_led(insufficient_led)
    );

    // clk
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, vending_machine_tests);

        // init
        clk = 0; reset = 0;
        C_5 = 0; C_10 = 0; C_25 = 0;
        P_35 = 0; P_50 = 0; cancel = 0;

        reset = 1;
        #15 reset = 0; 
        #10;

        // test 1: exact change
        // insert 35c, buy 35c
        // should return the product and idle
        @(posedge clk) C_25 = 1;
        @(posedge clk) C_25 = 0;
        #10;
        @(posedge clk) C_10 = 1;
        @(posedge clk) C_10 = 0;
        #20;
        @(posedge clk) P_35 = 1;
        @(posedge clk) P_35 = 0;
        #40; 

        // test 2: needs change back
        // insert 50c, buy 35c
        // should return 10c then 5c
        @(posedge clk) C_25 = 1;
        @(posedge clk) C_25 = 0;
        #10;
        @(posedge clk) C_25 = 1;
        @(posedge clk) C_25 = 0;
        #20;
        @(posedge clk) P_35 = 1;
        @(posedge clk) P_35 = 0;
        #60; 

        // test 3: not enough money
        // insert 10c, try to buy 50c
        // should turn on insufficient led
        @(posedge clk) C_10 = 1;
        @(posedge clk) C_10 = 0;
        #20;
        @(posedge clk) P_50 = 1;
        @(posedge clk) P_50 = 0;
        #30; 
        
        // test 4: cancel operation
        // balance is 10c from prev test, add 25c then cancel
        // should return 25c then 10c
        @(posedge clk) C_25 = 1;
        @(posedge clk) C_25 = 0;
        #20;
        @(posedge clk) cancel = 1;
        @(posedge clk) cancel = 0;
        #60; 

        $finish;
    end

endmodule