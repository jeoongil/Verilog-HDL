`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/16 12:44:28
// Design Name: 
// Module Name: tb_stopwatch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_stopwatch ();

    reg clk, rst;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    stopwatch dut(
        .clk(clk), .rst(rst), .fnd_com(fnd_com), .fnd_data(fnd_data)

    );
    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        #2;
        rst = 0;
        #10000;
        $stop;
    end


endmodule
