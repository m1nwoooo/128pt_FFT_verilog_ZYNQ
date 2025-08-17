/******************************************************************************
Copyright (c) 2022-2025 SoC Design Laboratory, Konkuk University, South Korea
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

Authors: Taewoo Kim (banacbc1@konkuk.ac.kr),

2025.05.19: Changed for 64-pt by Hyeseong Shin
*******************************************************************************/
module stage
#(
    parameter N_SR = 4,                  // Number of Shift register stages
    parameter B_ST_IN   = 14,             // Bit-width of stage input data
    parameter B_ST_OUT  = 14              // Bit-width of stage output data
)
(
    input   clk,                          
    input   nrst,                         
    input   en,                           
    input   [2*B_ST_IN-1:0]  din_stage,   // Stage input data
    output  [2*B_ST_OUT-1:0] dout_stage,  // Stage output data
    input   [895:0]   w_bus,              
    input   sel_bf,                       
    input   [5:0]   sel_w                 
);
/////////////////////////////////////
/////////* Edit code below */////////

    reg  [2*B_ST_IN-1:0]   reg_in;
    wire [2*B_ST_OUT-1:0]  dout_reg_in;
    wire [2*B_ST_OUT-1:0]  dout_mux_bf_0;
    wire [2*B_ST_OUT-1:0]  dout_mux_bf_1;
    wire [13:0] dout_mux_w;
    
    wire [2*B_ST_OUT-1:0] dout_sr;
    wire [2*B_ST_OUT-1:0] dout0_bf;
    wire [2*B_ST_OUT-1:0] dout1_bf;
    wire [2*B_ST_OUT-1:0] dout_mult;
    
    // reg set
    always @(posedge clk) begin
        if (!nrst) reg_in <= 0;
        else if (en) reg_in <= din_stage;
        else reg_in <= reg_in;
    end

    // signed extension using shift operations
    wire [B_ST_OUT-1:0] re_extended, im_extended;

    //  ?      ? ?       ?      ?  ? 
    assign re_extended = ($signed(reg_in[2*B_ST_IN-1:B_ST_IN]) <<< (B_ST_OUT - B_ST_IN));

    //         ? ?       ?      ?  ? 
    assign im_extended = ($signed(reg_in[B_ST_IN-1:0]) <<< (B_ST_OUT - B_ST_IN));

    //              
    assign dout_reg_in = {re_extended[B_ST_OUT-1],re_extended[B_ST_OUT-1:1], im_extended[B_ST_OUT-1],im_extended[B_ST_OUT-1:1]};
    
    // mux_bf_1
    assign dout_mux_bf_1 = sel_bf ? dout1_bf : dout_reg_in;

    // mux_bf_0
    assign dout_mux_bf_0 = sel_bf ? dout0_bf : dout_sr;
    // mux_w     
    assign dout_mux_w = w_bus[14 * sel_w +:14];
   
    // dout_stage
    assign dout_stage = sel_bf ? dout_mux_bf_0 : dout_mult;

    // Submodules
    shift_reg #(2*B_ST_OUT,N_SR) shift_reg(nrst,clk,en,dout_mux_bf_1,dout_sr);

    bf #(B_ST_OUT) bf (
        .din0_bf_re(dout_sr[2*B_ST_OUT-1:B_ST_OUT]),     // sr re
        .din0_bf_im(dout_sr[B_ST_OUT-1:0]),              // sr im
        .din1_bf_re(dout_reg_in[2*B_ST_OUT-1:B_ST_OUT]), // reg_in re
        .din1_bf_im(dout_reg_in[B_ST_OUT-1:0]),          // reg_in im
        .dout0_bf(dout0_bf),                             // output
        .dout1_bf(dout1_bf)                              // output
    );

    mult #(B_ST_OUT) mult (
        .din0_mult_re(dout_mux_bf_0[2*B_ST_OUT-1:B_ST_OUT]), // mux_bf_0 re
        .din0_mult_im(dout_mux_bf_0[B_ST_OUT-1:0]),          // mux_bf_0 im
        .din1_mult_re(dout_mux_w[13:7]),                     // mux_w re (7-bit for simplicity, adjust if needed)
        .din1_mult_im(dout_mux_w[6:0]),                      // mux_w im (7-bit for simplicity, adjust if needed)
        .dout_mult(dout_mult)                                // output
    );
/////////* Edit code above */////////
/////////////////////////////////////
endmodule
