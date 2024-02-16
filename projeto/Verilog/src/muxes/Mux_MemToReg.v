module mux_MemToReg (
    input  wire [3:0]  MemToReg,
    input  wire [31:0] ALUOut,
    input  wire [31:0] LSControl_Out,
    input  wire [31:0] Imm_SL16,
    input  wire [31:0] HI_Out,
    input  wire [31:0] LO_Out,
    input  wire [31:0] Imm_SignExt,
    input  wire [31:0] ShiftReg_Out,
    input  wire [31:0] B_Out,
    input  wire [31:0] A_Out,
    input  wire [31:0] LT_extended,
    output wire [31:0] MemToReg_Out
);

//   input 0 (0000): ALUOut
//   input 1 (0001): LSControl_Out
//   input 2 (0010): Imm_SL16
//   input 3 (0011): HI_Out
//   input 4 (0100): LO_Out
//   input 5 (0101): 227
//   input 6 (0110): Imm_SignExt
//   input 7 (0111): ShiftReg_Out
//   input 8 (1000): B_Out
//   input 9 (1001): A_Out
//   input 10(1010): LT_extended

    wire [31:0] w1xxx;
    wire [31:0] w0xxx;
    wire [31:0] w100x;
    wire [31:0] w01xx;
    wire [31:0] w00xx;
    wire [31:0] w011x;
    wire [31:0] w010x;
    wire [31:0] w001x;
    wire [31:0] w000x;

    assign w000x = (MemToReg[0]) ? LSControl_Out : ALUOut;
    assign w001x = (MemToReg[0]) ? HI_Out : Imm_SL16;
    assign w00xx = (MemToReg[1]) ? w001x : w000x;

    assign w010x = (MemToReg[0]) ? 32'b00000000000000000000000011100011 : LO_Out;
    assign w011x = (MemToReg[0]) ? ShiftReg_Out : Imm_SignExt;
    assign w01xx = (MemToReg[1]) ? w011x : w010x;

    assign w0xxx = (MemToReg[2]) ? w01xx : w00xx;

    assign w100x = (MemToReg[0]) ? A_Out : B_Out;
    assign w1xxx = (MemToReg[1]) ? LT_extended : w100x;

    assign MemToReg_Out = (MemToReg[3]) ? w1xxx : w0xxx;

endmodule
    