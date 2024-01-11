module Control_Unit (
    // Wires from ALU
    input wire GT;
    input wire LT;
    input wire EQ;
    input wire Z;

    // Wire from IR
    input wire [5:0] OP_Code;

    // Wire from Exception Control Unit
    input wire Exception_Signal;

    // Control Outputs

    // Muxes controls
    output wire [2:0] PC_Src;
    output wire [1:0] IorD;
    output wire [2:0] Reg_Dst;
    output wire [3:0] MemToReg;
    output wire ALU_SrcA;
    output wire [1:0] ALU_SrcB;
    output wire HI_Src;
    output wire LO_Src;
    output wire [1:0] Shift_Src;
    output wire [2:0] Shift_Amt;

    // Registers controls
    output wire PC_Write;
    output wire PC_Write_Cond;
    output wire Mem_WR;
    output wire IR_Write;
    output wire Reg_Write;
    output wire A_Write;
    output wire B_Write;
    output wire HI_Write;
    output wire LO_Write;
    output wire ALUOut_Write;
    output wire EPC_Write;

    // ALU control
    output wire [3:0] ALU_Op;

    // Exception
    output wire AllowException;
    output wire OPCode_Error;
);
    
endmodule