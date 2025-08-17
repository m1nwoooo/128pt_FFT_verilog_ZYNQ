//REFERENCE FOR UNDERSTAND FFT SDF LOGIC
//handwritten code
//not for implement, but for reference(verilog) 

// Performs Fast Fourier Transform operations
for (int clk = 0; clk < N_SET_64 * L_FFT_64 + OFFSET_64; clk++)
{
    //Counter signal assignment
    for (int stage = 0; stage < N_STAGE_64; stage++)
        cnt[stage] = (reg_cnt + L_FFT_64 - stage) % L_FFT_64;
    //Output assignment
    sel_out = cnt[N_STAGE_64 - 2];
    if (clk >= OFFSET_64)
        X[(clk - OFFSET_64) / L_FFT_64][(clk - OFFSET_64) % L_FFT_64] = reg_out[reg_sel_bank_out][sel_out];



    //stage 0
    sel_bf[0] = cnt[0] >> 5;
    sel_w[0] = cnt[0] % 32;

    //stage1
    sel_bf[1] = (cnt[1] >> 4) & 0x1;
    sel_w[1] = (cnt[1] & 15)<<1;

    //Stage 2
    sel_bf[2] = (cnt[2] >> 3) & 0x1;
    sel_w[2] = (cnt[2] & 7)<<2;

    //Stage 3
    sel_bf[3] = (cnt[3] >> 2) & 0x1;
    sel_w[3] = (cnt[3] &3)<<3;

    //Stage 4
    sel_bf[4] = (cnt[4] >> 1) & 0x1;
    sel_w[4] = (cnt[4] & 1)<<4;

    //Stgae 5
    sel_bf[5] = cnt[5] & 1;
    sel_w[5] = 0;

    reg_sel_bank_out = !reg_sel_bank_out;

    int shift = (cnt[4] & 0x1) << 5 |
        (cnt[4] & 0b000010) <<3|
        (cnt[4] & 0b000100)<<1 |
        (cnt[4] & 0b001000)>>1 |
        (cnt[4] & 0b010000)>>3 |
        (cnt[4] >> 5) & 0x1;

    // Enable only one location
    en_reg_out[reg_sel_bank_out][shift] = 1;

    // Wire assignment

    //stage0
    bf[0][0] = reg[0][31] + reg_in[0];               //bf2
    bf[0][1] = reg[0][31] - reg_in[0];

    mux_bf[0][0] = sel_bf[0] ? bf[0][0] : reg[0][31];   //mux0,mux1
    mux_bf[0][1] = sel_bf[0] ? bf[0][1] : reg_in[0];


    mux_w[0] = W[sel_w[0]];                        //mux2
    mult[0] = mux_bf[0][0] * mux_w[0];
    mux_bf[0][2] = sel_bf[0] ? mux_bf[0][0] : mult[0];   //mux3 sel_bf[1]? [0]?

    //stage1
    bf[1][0] = reg[1][15] + reg_in[1];               //bf2
    bf[1][1] = reg[1][15] - reg_in[1];

    mux_bf[1][0] = sel_bf[1] ? bf[1][0] : reg[1][15];   //mux0,mux1
    mux_bf[1][1] = sel_bf[1] ? bf[1][1] : reg_in[1];


    mux_w[1] = W[sel_w[1]];                        //mux2
    mult[1] = mux_bf[1][0] * mux_w[1];
    mux_bf[1][2] = sel_bf[1] ? mux_bf[1][0] : mult[1];   //mux3


    //stage 2

    bf[2][0] = reg[2][7] + reg_in[2];               //bf2
    bf[2][1] = reg[2][7] - reg_in[2];

    mux_bf[2][0] = sel_bf[2] ? bf[2][0] : reg[2][7];   //mux0,mux1
    mux_bf[2][1] = sel_bf[2] ? bf[2][1] : reg_in[2];

    mux_w[2] = W[sel_w[2]];                        //mux2
    mult[2] = mux_bf[2][0] * mux_w[2];
    mux_bf[2][2] = sel_bf[2] ? mux_bf[2][0] : mult[2];   //mux3

    //stage 3
    bf[3][0] = reg[3][3] + reg_in[3];               //bf2
    bf[3][1] = reg[3][3] - reg_in[3];

    mux_bf[3][0] = sel_bf[3] ? bf[3][0] : reg[3][3];   //mux0,mux1
    mux_bf[3][1] = sel_bf[3] ? bf[3][1] : reg_in[3];

    mux_w[3] = W[sel_w[3]];                        //mux2
    mult[3] = mux_bf[3][0] * mux_w[3];
    mux_bf[3][2] = sel_bf[3] ? mux_bf[3][0] : mult[3];   //mux3

    //stage 4
    bf[4][0] = reg[4][1] + reg_in[4];               //bf2
    bf[4][1] = reg[4][1] - reg_in[4];

    mux_bf[4][0] = sel_bf[4] ? bf[4][0] : reg[4][1];   //mux0,mux1
    mux_bf[4][1] = sel_bf[4] ? bf[4][1] : reg_in[4];


    mux_w[4] = W[sel_w[4]];                        //mux2
    mult[4] = mux_bf[4][0] * mux_w[4];

    mux_bf[4][2] = sel_bf[4] ? mux_bf[4][0] : mult[4];   //mux3

  
    //stage 5
    bf[5][0] = reg[5][0] + reg_in[5];               //bf2
    bf[5][1] = reg[5][0] - reg_in[5];

    mux_bf[5][0] = sel_bf[5] ? bf[5][0] : reg[5][0];   //mux0,mux1
    mux_bf[5][1] = sel_bf[5] ? bf[5][1] : reg_in[5];


    mux_w[5] = W[sel_w[5]];                        //mux2
    mult[5] = mux_bf[5][0] * mux_w[5];
    

    mux_bf[5][2] = sel_bf[5] ? mux_bf[5][0] : mult[5];   //mux3

    mux_out[0] = reg_out[0][sel_out];
    mux_out[1] = reg_out[1][sel_out];
    mux_bank_out = mux_out[reg_sel_bank_out];

    // Register update
    for (int bank = 0; bank < 2; bank++)
        for (int i = 0; i < L_FFT_64; i++)
            if (en_reg_out[bank][i] == 1) {
                reg_out[bank][i] = mux_bf[5][2];
                en_reg_out[bank][i] = 0;
            }

    for (int i = 31; i > 0; i--) {//stage0
        reg[0][i] = reg[0][i - 1];
    }

    reg[0][0] = mux_bf[0][1];

    reg_in[1] = mux_bf[0][2];//stage1
    
    for (int i = 15; i > 0; i--) {
        reg[1][i] = reg[1][i - 1];
    }
    reg[1][0] = mux_bf[1][1];

    reg_in[2] = mux_bf[1][2];//stage2
    for (int i = 7; i > 0; i--) {
        reg[2][i] = reg[2][i - 1];
    }

    reg[2][0] = mux_bf[2][1];

    reg_in[3] = mux_bf[2][2];//stage 3
    for (int i = 3; i > 0; i--) {
        reg[3][i] = reg[3][i - 1];
    }
    reg[3][0] = mux_bf[3][1];

    reg_in[4] = mux_bf[3][2];//stage4
    reg[4][1] = reg[4][0];
    reg[4][0] = mux_bf[4][1];

    reg_in[5] = mux_bf[4][2];//stage5
    reg[5][0] = mux_bf[5][1];

    reg_sel_bank_out = !reg_sel_bank_out;


    if (cnt[N_STAGE_64 - 2] == L_FFT_64 - 1) reg_sel_bank_out = !reg_sel_bank_out;
    //Counter 
    reg_cnt = (reg_cnt + 1) % L_FFT_64;
    //input assignment
    if (clk < N_SET_64 * L_FFT_64)
        reg_in[0] = x[clk / L_FFT_64][clk % L_FFT_64];
    else
        reg_in[0] = { 0,0 };
}
