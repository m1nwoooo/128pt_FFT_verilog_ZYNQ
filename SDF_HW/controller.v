/******************************************************************************
Copyright (c) 2025 SoC Design Laboratory, Konkuk University, South Korea
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met; and provided that prior written permission for any distribution
has been obtained from the copyright holder: redistributions of source
code must retain the above copyright notice, this list of conditions and
the following disclaimer; redistributions in binary form must reproduce 
the above copyright notice, this list of conditions and the following
disclaimer in the documentation and/or other materials provided with 
the distribution; neither the name of the copyright holders nor the 
names of its contributors may be used to endorse or promote products 
derived from this software without specific prior written permission;

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Authors: Taewoo Kim (banacbc1@konkuk.ac.kr)

Revision History
2025.05.19: Changed for 64-pt by Hyeseong Shin
2025.06.01: Changed for 128-pt w/ reoredering by Hyeseong Shin
*******************************************************************************/
 
module controller 
(
    input  wire clk,
    input  wire nrst,
    input  wire en,
    input  wire start,
    output wire [6:0] sel_bf,
    output wire [41:0] sel_w,
    output wire [255:0] en_reg_out_bus,
    output wire [6:0] sel_out,
    output wire sel_bank_out
);
/////////////////////////////////////
/////////* Edit code below */////////


reg     [6:0] reg_cnt;
wire    [6:0] cnt [6:0];
reg     reg_sel_bank_out;
wire    [6:0] _sel_bf;
wire    [5:0] _sel_w [0:6];

always @(posedge clk or negedge nrst) begin
    if (!nrst)
        reg_cnt <= 7'd127;             
    else if (en && start) begin
        if (reg_cnt == 7'd127)  reg_cnt <= 7'd0;
        else                    reg_cnt <= reg_cnt + 7'd1;
    end
end


// controll signal stage 0~6
assign cnt[0] = (reg_cnt + 7'd0) % 128;
assign cnt[1] = (reg_cnt + 7'd127) % 128;
assign cnt[2] = (reg_cnt + 7'd126) % 128;
assign cnt[3] = (reg_cnt + 7'd125) % 128;
assign cnt[4] = (reg_cnt + 7'd124) % 128;
assign cnt[5] = (reg_cnt + 7'd123) % 128;
assign cnt[6] = (reg_cnt + 7'd122) % 128;

// stage 0
assign _sel_bf[0]      =  cnt[0][6];
assign _sel_w[0]       = (cnt[0] & 6'b111111);
// stage 1
assign _sel_bf[1]      = cnt[1][5];
assign _sel_w[1]       = (cnt[1] & 5'b11111) << 1;
// stage 2 
assign _sel_bf[2]      = cnt[2][4];
assign _sel_w[2]       = (cnt[2] & 4'b1111) << 2;
// stage 3 
assign _sel_bf[3]      = cnt[3][3];
assign _sel_w[3]       = (cnt[3] & 3'b111) << 3;
// stage 4 
assign _sel_bf[4]      = cnt[4][2];
assign _sel_w[4]       = (cnt[4] & 2'b11) << 4;
// stage 5
assign _sel_bf[5]      = cnt[5][1];
assign _sel_w[5]       = (cnt[5] & 1'b1) << 5;
//stage 6
assign _sel_bf[6]      = cnt[6][0];
assign _sel_w[6]       = 6'd0;  

assign sel_bf = _sel_bf;
assign sel_out = cnt[5];


assign sel_w  = { _sel_w[6], _sel_w[5], _sel_w[4], _sel_w[3], _sel_w[2], _sel_w[1], _sel_w[0] };

always @(posedge clk or negedge nrst) begin
    if (!nrst)
        reg_sel_bank_out <= 1'b0;
    else if (en && start && (cnt[5] == 7'd127))
        reg_sel_bank_out <= ~reg_sel_bank_out;
end

assign sel_bank_out = reg_sel_bank_out;

wire [6:0] shift = { cnt[5][0], cnt[5][1], cnt[5][2], cnt[5][3], cnt[5][4], cnt[5][5], cnt[5][6] };

wire [127:0] select_signal = 128'b1 << shift;

assign en_reg_out_bus = (sel_bank_out) ? { select_signal, 128'd0 } : { 128'd0, select_signal };


/////////* Edit code above */////////
/////////////////////////////////////
endmodule
