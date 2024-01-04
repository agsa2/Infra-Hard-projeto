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
    output wire [31:0] MemToReg_Out,
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

    wire [31:0] aux1;
    wire [31:0] aux2;
    wire [31:0] aux3;
    wire [31:0] aux4;
    wire [31:0] aux5;
    wire [31:0] aux6;
    wire [31:0] aux7;
    wire [31:0] aux8;

    assign aux1 = (MemToReg[0]) ? LSControl_Out : ALUOut;
    assign aux2 = (MemToReg[0]) ? HI_Out : Imm_SL16;
    assign aux3 = (MemToReg[0]) ? 32'b00000000000000000000000011100011 : LO_Out;
    assign aux4 = (MemToReg[0]) ? ShiftReg_Out : Imm_SignExt;
    assign aux5 = (MemToReg[1]) ? aux2 : aux1;
    assign aux6 = (MemToReg[1]) ? aux4 : aux3;
    assign aux7 = (MemToReg[2]) ? aux6 : aux5;

    assign aux8 = (MemToReg[0]) ? A_Out : B_Out;

    assign MemToReg_Out = (MemToReg[3]) ? aux8 : aux7;

endmodule
    