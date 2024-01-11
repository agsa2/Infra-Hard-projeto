module cpu (
    input wire Clock,
    input wire Reset
);

    // Instrução
    wire [5:0] Instr_31_26;
    wire [4:0] Instr_25_21;
    wire [4:0] Instr_20_16;
    wire [15:0] Instr_15_0;

    // Control Unit
    wire Reset_Signal;

    wire [2:0] PC_Src;
    wire [1:0] IorD;
    wire [2:0] Reg_Dst;
    wire [3:0] MemToReg;
    wire ALU_SrcA;
    wire [1:0] ALU_SrcB;
    wire HI_Src;
    wire LO_Src;
    wire Shift_Src;
    wire [1:0] Shift_Amt;

    wire PC_Write;
    wire PC_Write_Cond;
    wire Mem_WR;
    wire IR_Write;
    wire Reg_Write;
    wire A_Write;
    wire B_Write;
    wire HI_Write;
    wire LO_Write;
    wire ALUOut_Write;
    wire EPC_Write;

    wire [2:0] ALU_Op;

    wire AllowException;
    wire OPCode_Error;

    // ALU
    wire Overflow;
    wire Neg;
    wire Zero;
    wire Eq;
    wire Gt;
    wire Lt;

    wire [31:0] ALU_A;
    wire [31:0] ALU_B;
    wire [31:0] ALU_Result;

    // Data flow
    wire [31:0] PC_In;          // PC_In: Entrada do PC e Saída do mux PCSrc
    wire [31:0] PC_Out;         // PC_Out: Saída do PC e entrada dos muxes IorD, ALUSrcA e PCSrc
    wire [31:0] A_In;           // A_In: Entrada do registrador A e saída 1 do banco de registradores
    wire [31:0] A_Out;          // A_Out: Saída do registrador A e entrada dos muxes ALUSrcA, MemToReg e Shift_Src
    wire [31:0] B_In;           // B_In: Entrada do registrador B e saída 2 do banco de registradores
    wire [31:0] B_Out;          // B_Out: Saída do registrador B e entrada dos muxes ALUSrcB, MemToReg, Shift_Src e Shift_Amt
    wire [31:0] ALUOut_Result;  // ALUOut_Result: Saída do ALUOut e entrada dos muxes PCSrc, IorD e MemToReg
    wire [31:0] HI_In;          // HI_In: Entrada do registrador HI e saída do mux HI
    wire [31:0] HI_Out;         // HI_Out: Saída do registrador HI e entrada do mux MemToReg
    wire [31:0] LO_In;          // LO_In: Entrada do registrador LO e saída do mux LO
    wire [31:0] LO_Out;         // LO_Out: Saída do registrador LO e entrada do mux MemToReg
    wire [31:0] EPC_Out;        // EPC_Out: Saída do EPC e entrada do mux PCSrc

    // Registradores
    // PC
    // PC_In: Entrada do PC e Saída do mux PCSrc
    // PC_Out: Saída do PC e entrada dos muxes IorD, ALUSrcA e PCSrc
    Registrador PC(
        Clock,
        Reset_Signal,
        PC_Write || PC_Write_Cond,
        PC_In,
        PC_Out
    );

    // A
    // A_In: Entrada do registrador A e saída 1 do banco de registradores
    // A_Out: Saída do registrador A e entrada dos muxes ALUSrcA, MemToReg e Shift_Src
    Registrador A(
        Clock,
        Reset_Signal,
        A_Write,
        A_In,
        A_Out
    );

    // B
    // B_In: Entrada do registrador B e saída 2 do banco de registradores
    // B_Out: Saída do registrador B e entrada dos muxes ALUSrcB, MemToReg, Shift_Src e Shift_Amt
    Registrador B(
        Clock,
        Reset_Signal,
        B_Write,
        B_In,
        B_Out
    );

    // ALUOut
    // ALUOut_Result: Saída do ALUOut e entrada dos muxes PCSrc, IorD e MemToReg
    Registrador ALUOut(
        Clock,
        Reset_Signal,
        ALUOut_Write,
        ALU_Result,
        ALUOut_Result
    );

    // HI
    // HI_In: Entrada do registrador HI e saída do mux HI
    // HI_Out: Saída do registrador HI e entrada do mux MemToReg
    Registrador HI(
        Clock,
        Reset_Signal,
        HI_Write,
        HI_In,
        HI_Out
    );

    // LO
    // LO_In: Entrada do registrador LO e saída do mux LO
    // LO_Out: Saída do registrador LO e entrada do mux MemToReg
    Registrador LO(
        Clock,
        Reset_Signal,
        LO_Write,
        LO_In,
        LO_Out
    );

    // EPC
    // EPC_Out: Saída do EPC e entrada do mux PCSrc
    Registrador EPC(
        Clock,
        Reset_Signal,
        EPC_Write,
        ALU_Result,
        EPC_Out
    );

endmodule