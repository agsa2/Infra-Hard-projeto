module mux_IorD (
    input  wire [1:0]  IorD,
    input  wire [31:0] PC,
    input  wire [31:0] ALUOut,
    input  wire [31:0] ALU_Result,
    input  wire [31:0] Excpt_Out,
    output wire [31:0] IorD_Out
);

//   input 0 (00): PC
//   input 1 (01): ALUOut
//   input 2 (10): ALU_Result
//   input 3 (11): Exception Control Output

    wire [31:0] aux1;
    wire [31:0] aux2;

    assign aux1 = (IorD[0]) ? ALUOut : PC;
    assign aux2 = (IorD[0]) ? Excpt_Out : ALU_Result;

    assign IorD_Out = (IorD[1]) ? aux2 : aux1;

endmodule
    