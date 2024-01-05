module mux_PCSrc (
    input  wire [3:0]  PCSource,
    input  wire [31:0] ALU_Result,
    input  wire [31:0] ALUOut,
    input  wire [31:0] Shift_28,
    input  wire [31:0] EPC_Out,
    input  wire [31:0] Sign_8_32,
    output wire [31:0] PCSource_Out
);

//   input 0 (000): ALU Result
//   input 1 (001): ALUOut
//   input 2 (010): Shift left 2 26_28
//   input 3 (011): EPC out
//   input 4 (100): Sign extend 8_32

    wire [31:0] aux1;
    wire [31:0] aux2;
    wire [31:0] aux3;

    assign aux1 = (PCSource[0]) ? ALUOut : ALU_Result;
    assign aux2 = (PCSource[0]) ? EPC_Out : Shift_28;
    assign aux3 = (PCSource[1]) ? aux2 : aux1;

    assign PCSource_Out = (PCSource[2]) ? Sign_8_32 : aux3;

endmodule