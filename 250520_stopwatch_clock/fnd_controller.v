`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input rst,
    input sw0,
    input [6:0] msec,
    input [5:0] sec,
    input [5:0] min,
    input [4:0] hour,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [3:0] w_bcd, w_msec_1, w_msec_10, w_sec_1, w_sec_10;
    wire [3:0] w_min_1, w_min_10, w_hour_1, w_hour_10;
    wire [3:0] w_min_hour, w_msec_sec;
    wire [3:0] w_dp;
    wire w_oclk; 
    wire [2:0] fnd_sel;

    // fnd_sel 연결하기
    clk_devider U_CLK_Div (
        .clk  (clk),
        .rst  (rst),
        .o_clk(w_oclk)
    );

    counter_8 U_Counter_8 (
        .clk(w_oclk),
        .rst(rst),
        .fnd_sel(fnd_sel)
    );

    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel[1:0]),
        .fnd_com(fnd_com)
    );


    digit_splitter #(
        .BIT_WIDTH(7)
    ) U_DS_MSEC (
        .time_data(msec),
        .digit_1  (w_msec_1),
        .digit_10 (w_msec_10)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DS_SEC (
        .time_data(sec),
        .digit_1  (w_sec_1),
        .digit_10 (w_sec_10)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DS_MIN (
        .time_data(min),
        .digit_1  (w_min_1),
        .digit_10 (w_min_10)
    );

    digit_splitter #(
        .BIT_WIDTH(5)
    ) U_DS_HOUR (
        .time_data(hour),
        .digit_1  (w_hour_1),
        .digit_10 (w_hour_10)
    );

    mux_2x1 U_MUX_2x1 (
        .msec_sec(w_msec_sec),
        .min_hour(w_min_hour),
        .sel(sw0),
        .bcd(w_bcd)
    );

    mux_8x1 U_MUX_8x1_MIN_HOUR (
        .sel(fnd_sel),
        .digit_1(w_min_1),
        .digit_10(w_msin_10),
        .digit_100(w_hour_1),
        .digit_1000(w_hour_10),
        .dp(w_dp),
        .bcd(w_min_hour)
    );
    mux_8x1 U_MUX_8x1_MSEC_SEC (
        .sel(fnd_sel),
        .digit_1(w_msec_1),
        .digit_10(w_msec_10),
        .digit_100(w_sec_1),
        .digit_1000(w_sec_10),
        .dp(w_dp),
        .bcd(w_msec_sec)
    );

    comperator_onoff U_COMP_ONOFF (
        .msec(msec),
        .rst (rst),
        .dp  (w_dp)
    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

endmodule


module comperator_onoff (
    input [6:0] msec,
    input rst,
    output reg [3:0] dp
);
    always @(*) begin
        if (rst) begin
            dp <= 4'hf;
        end else begin
            if (msec > 49) begin
                dp <= 4'hA;
            end else begin
                dp <= 4'hf;
            end
        end
    end

endmodule



module mux_2x1 (
    input [3:0] msec_sec,
    input [3:0] min_hour,
    input sel,
    output [3:0] bcd
);

    assign bcd = (sel) ? min_hour : msec_sec;

endmodule



//clk divider
// ->1kHz
module clk_devider (
    input  clk,
    input  rst,
    output o_clk
);
    // clk 100_000_000, r_count 100_000 (1KHZ) -> 17bit 필요
    //reg [16:0] r_counter;  // 모듈안에서는 다른 모듈에서 선언한 변수 이름 사용 가능 (c와 같음)
    reg [$clog2(100_000)-1:0] r_counter;
    reg r_clk;

    assign o_clk = r_clk; // always 안에있는 r 클럭을 밖에 있는 아웃풋 O 클럭과 연결 이어줌.
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            r_clk <= 1'b0; // 신호 관련은 비트수를 나타내는 것으로 표현. 
        end else begin
            if (r_counter == 100_000 - 1) begin  // 1KHz preiod
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end
    end
endmodule

//4진 카운터
module counter_8 (  // 1KHz->1msec, 1MHz->1usec, 1GHz->1nsec
    input clk, // 100MHz(system clk), 25MHZ(4로나눈) 그래도 너무 빠름. clk 줄이고 싶음 -> 분주(2번 들어올 때마다 바꿔주고 싶음(2분주기). / 반복행위는 곧 순차회로로), clk devider를 4진 카운터 앞에 한 번 설계 (reset은  devider와 카운터에 각각들어감.) =>12.5MHZ당 값이 증가하는 카운터로 change
    input rst,
    output [2:0] fnd_sel
);
    reg [2:0] r_counter;
    assign fnd_sel = r_counter;
    //
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 3'b000;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule

module decoder_2x4 (
    input [1:0] fnd_sel,
    output reg [3:0] fnd_com
);
    always @(fnd_sel) begin
        case (fnd_sel)
            2'b00: begin
                fnd_com = 4'b1110;  // fnd 1의 자리 on,
            end
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end
endmodule

//mux는 입력과 출력의 비트수 동일함.
module mux_8x1 (
    input  [2:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    input  [3:0] dp,
    output [3:0] bcd
);

    //always문 출력 내보낼 때 reg 타입

    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    // 4:1 mux, always
    always @(*) begin
        case (sel)
            3'b000:  r_bcd = digit_1;
            3'b001:  r_bcd = digit_10;
            3'b010:  r_bcd = digit_100;
            3'b011:  r_bcd = digit_1000;
            3'b110:  r_bcd = dp;
            default: r_bcd = 4'h0B;
        endcase
    end

endmodule


module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH-1:0] time_data,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1  = time_data % 10;  // 연산할 때 보통 assig문
    assign digit_10 = (time_data / 10) % 10;

endmodule


module bcd (
    input  [3:0] bcd,
    output [7:0] fnd_data
);

    reg [7:0] r_fnd_data;

    assign fnd_data = r_fnd_data;

    always @(bcd) begin
        case (bcd)
            4'h00:   r_fnd_data = 8'hc0;
            4'h01:   r_fnd_data = 8'hf9;
            4'h02:   r_fnd_data = 8'ha4;
            4'h03:   r_fnd_data = 8'hb0;
            4'h04:   r_fnd_data = 8'h99;
            4'h05:   r_fnd_data = 8'h92;
            4'h06:   r_fnd_data = 8'h82;
            4'h07:   r_fnd_data = 8'hf8;
            4'h08:   r_fnd_data = 8'h80;
            4'h09:   r_fnd_data = 8'h90;
            4'h0A:   r_fnd_data = 8'h7f;
            default: r_fnd_data = 8'hff;
        endcase
    end

endmodule
