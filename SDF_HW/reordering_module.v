module reordering_module
 #(
   parameter LOG_L_FFT = 7,
   parameter N_REG = 128,
   parameter B_RE = 41  
)
(
    input wire clk,                          
    input wire nrst,
    input wire [2*B_RE-1:0] in,
    input wire [2*N_REG-1:0] en_reg_out_bus,
    input wire [LOG_L_FFT-1:0] sel_out,
    input wire sel_bank_out,
    output wire [2*B_RE-1:0] out
);

/////////////////////////////////////
/////////* Edit code below */////////

reg [2*B_RE-1:0] bank0 [0:N_REG-1]; // 뱅크 0
reg [2*B_RE-1:0] bank1 [0:N_REG-1]; // 뱅크 1

wire [N_REG-1:0] w_en_bank0 = en_reg_out_bus[2*N_REG-1 : N_REG]; // 뱅크 0에 대한 활성화 신호
wire [N_REG-1:0] w_en_bank1 = en_reg_out_bus[N_REG-1 : 0]; // 뱅크 1에 대한 활성화 신호

reg [2*B_RE-1:0] _out;

genvar i;
generate //* Write to banks */
    for (i = 0; i < N_REG; i = i + 1) begin : g_write
        always @(posedge clk or negedge nrst) begin
            if (!nrst) begin
                bank0[i] <= 0; // 초기화
                bank1[i] <= 0;
            end else begin
                if (w_en_bank0[i]) bank0[i] <= in; // bank0에 쓰기   
                if (w_en_bank1[i]) bank1[i] <= in; // bank1에 쓰기
            end
        end
    end
endgenerate

always @(posedge clk) begin //* Read from banks */
    if (!nrst) begin
        _out <= 0; // 초기화
    end else if (sel_bank_out) begin
        _out <= bank1[sel_out];  // bank1 읽기
    end else begin
        _out <= bank0[sel_out];  // bank0 읽기
    end
end

assign out = _out;

/////////* Edit code above */////////
/////////////////////////////////////
endmodule
