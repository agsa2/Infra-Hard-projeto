module mux_ALUSrcB (
    input  wire [1:0]  ALUSrcB,
    input  wire [31:0] B,
    input  wire [31:0] Immediate,
    input  wire [31:0] ImmShifted,
    output wire [31:0] ALUSrcB_Out
);

//   input 0 (00): B
//   input 1 (01): 4
//   input 2 (10): data_1 = instr[15:0] ext
//   input 3 (11): data_2 = instr[15:0] ext sft

    wire [31:0] aux1;
    wire [31:0] aux2;

    assign aux1 = (ALUSrcB[0]) ? 32'b00000000000000000000000000000100 : B;
    assign aux2 = (ALUSrcB[0]) ? ImmShifted : Immediate;

    assign ALUSrcB_Out = (ALUSrcB[1]) ? aux2 : aux1;

endmodule
    