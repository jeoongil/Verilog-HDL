`timescale 1ns / 1ps

module stopwatch (
    input clk,
    input rst,
    input sw0,
    input btnL_clear,
    input btnR_runstop,
    output [3:0] fnd_com,
    output [7:0] fnd_data

);
    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire [5:0] w_min;
    wire [4:0] w_hour;
    wire w_clear, w_runstop;
    wire o_clear, o_runstop;

    btn_debounce U_BTNR_RUNSTOP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR_runstop),
        .o_btn(o_runstop)
    );

    btn_debounce U_BTNL_CLEAR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL_clear),
        .o_btn(o_clear)
    );

    stopwatch_cu U_StopWatch_CU (
        .clk(clk),
        .rst(rst),
        .i_clear(o_clear),
        .i_runstop(o_runstop),
        .o_clear(w_clear),
        .o_runstop(w_runstop)
    );

    stopwatch_dp U_StopWatch_DP (
        .clk(clk),
        .rst(rst),
        .run_stop(w_runstop),
        .clear(w_clear),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule

