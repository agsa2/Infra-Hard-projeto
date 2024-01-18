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

    wire Div_Control;
    wire Mult_Control;

    wire [2:0] Shift_Control;
    
    wire [1:0] LS_Control;
    wire [1:0] SS_Control;

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
    wire MDR_Write;
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

    // ALU
    wire Neg;
    wire Zero;
    wire Eq;
    wire Gt;
    wire Lt;

    wire [31:0] ALU_A;
    wire [31:0] ALU_B;
    wire [31:0] ALU_Result;

    // Exception
    wire OPCode_Error;
    wire Overflow;
    wire Div_Zero;
    wire Exception_Signal;
    wire [31:0] Exception_MemPosition;
    
    // Shift Register
    wire [4:0] ShiftReg_Amt;
    wire [31:0] ShiftReg_In;
    wire [31:0] ShiftReg_Out;
    
    // Data flow
    wire [31:0] PC_In;              // PC_In: Entrada do PC e Saída do mux PCSrc
    wire [31:0] PC_Out;             // PC_Out: Saída do PC e entrada dos muxes IorD, ALUSrcA e PCSrc
    wire [31:0] A_In;               // A_In: Entrada do registrador A e saída 1 do banco de registradores
    wire [31:0] A_Out;              // A_Out: Saída do registrador A e entrada dos muxes ALUSrcA, MemToReg e Shift_Src
    wire [31:0] B_In;               // B_In: Entrada do registrador B e saída 2 do banco de registradores
    wire [31:0] B_Out;              // B_Out: Saída do registrador B e entrada dos muxes ALUSrcB, MemToReg, Shift_Src e Shift_Amt
    wire [31:0] ALUOut_Result;      // ALUOut_Result: Saída do ALUOut e entrada dos muxes PCSrc, IorD e MemToReg
    wire [31:0] HI_In;              // HI_In: Entrada do registrador HI e saída do mux HI
    wire [31:0] HI_Out;             // HI_Out: Saída do registrador HI e entrada do mux MemToReg
    wire [31:0] LO_In;              // LO_In: Entrada do registrador LO e saída do mux LO
    wire [31:0] LO_Out;             // LO_Out: Saída do registrador LO e entrada do mux MemToReg
    wire [31:0] EPC_Out;            // EPC_Out: Saída do EPC e entrada do mux PCSrc

    wire [31:0] Mem_Address;        // Mem_Address: Saída do mux IorD e entrada da memória
    wire [31:0] Mem_Data;           // Mem_Data: Saída da memória e entrada do IR e do MDR

    wire [31:0] MDR_Out;            // MDR_Out: Saída do MDR e entrada dos modulos LSControl e SSControl

    wire [31:0] SSControl_Out;      // SSControl_Out: Saída do SSControl e entrada do banco da memória
    wire [31:0] LSControl_Out;      // LSControl_Out: Saída do LSControl e entrada do mux MemToReg e SignExt_8_32

    wire [4:0] Reg_WriteIn;         // Reg_WriteIn: Saída do mux Reg_Dst e entrada do banco de registradores
    wire [31:0] Reg_WriteData;      // Reg_WriteData: Saída do mux MemToReg e entrada do banco de registradores

    wire [31:0] Div_HIOut;          // Div_HIOut: Saída do Div e entrada dos muxes HI
    wire [31:0] Div_LOOut;          // Div_LOOut: Saída do Div e entrada dos muxes LO
    wire [31:0] Mult_HIOut;         // Mult_HIOut: Saída do Mult e entrada dos muxes HI
    wire [31:0] Mult_LOOut;         // Mult_LOOut: Saída do Mult e entrada dos muxes LO

    wire [31:0] Imm_SL16;           // Imm_SL16: Saída do ShiftL_16 e entrada do mux MemToReg
    wire [31:0] Imm_SignExt;        // Imm_SignExt: Saída do SignExt_16_32 e entrada do mux MemToReg
    wire [31:0] Imm_SignExtSL2;     // Imm_SignExtSL2: Saída do ShiftL_2 e entrada do mux MemToReg

    wire [31:0] SignExt_1_32_Out;

    wire [27:0] ShiftL_26_28_Out;   // ShiftL_26_28_Out: Saída do ShiftL_26_28 e parte do Jump_Address
    wire [31:0] Jump_Address;       // Jump_Address: Saída do ... e entrada do mux PCSrc

    Control_Unit Control_Unit(
        Clock,
        Reset,
        Gt,
        Lt,
        Eq,
        Zero,
        Instr_31_26,
        Instr_15_0[5:0],
        Exception_Signal,
        Reset_Signal,
        Div_Control,
        Mult_Control,
        Shift_Control,
        LS_Control,
        SS_Control,
        PC_Src,
        IorD,
        Reg_Dst,
        MemToReg,
        ALU_SrcA,
        ALU_SrcB,
        HI_Src,
        LO_Src,
        Shift_Src,
        Shift_Amt,
        PC_Write,
        PC_Write_Cond,
        Mem_WR,
        MDR_Write,
        IR_Write,
        Reg_Write,
        A_Write,
        B_Write,
        HI_Write,
        LO_Write,
        ALUOut_Write,
        EPC_Write,
        ALU_Op,
        AllowException,
        OPCode_Error
    );

    Ula32 ALU(
        ALU_A,
        ALU_B,
        ALU_Op,
        ALU_Result,
        Overflow,
        Neg,
        Zero,
        Eq,
        Gt,
        Lt
    );

    Memoria Mem(
        Mem_Address,
        Clock,
        Mem_WR,
        SSControl_Out,
        Mem_Data
    );

    Div Div(
        Clock,
        Reset_Signal,
        Div_Control,
        A_Out,
        B_Out,
        Div_Zero,
        Div_HIOut,
        Div_LOOut
    );

    Mult Mult(
        Clock,
        Reset_Signal,
        Mult_Control,
        A_Out,
        B_Out,
        Mult_HIOut,
        Mult_LOOut
    );

    Instr_Reg IR(
        Clock,
        Reset_Signal,
        IR_Write,
        Mem_Data,
        Instr_31_26,
        Instr_25_21,
        Instr_20_16,
        Instr_15_0
    );

    Banco_reg Regs(
        Clock,
        Reset_Signal,
        Reg_Write,
        Instr_25_21,
        Instr_20_16,
        Reg_WriteIn,
        Reg_WriteData,
        A_In,
        B_In
    );

    RegDesloc ShiftReg(
        Clock,
        Reset_Signal,
        Shift_Control,
        ShiftReg_Amt,
        ShiftReg_In,
        ShiftReg_Out
    );

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

    // MDR Modules
    // MDR
    Registrador MDR(
        Clock,
        Reset_Signal,
        MDR_Write,
        Mem_Data,
        MDR_Out
    );

    // LSControl
    load_size_control LSControl(
        LS_Control,
        MDR_Out,
        LSControl_Out
    );

    // SSControl
    store_size_control SSControl(
        SS_Control,
        B_Out,
        MDR_Out,
        SSControl_Out
    );

    // Exception Control
    Exception_Control Exception_Control(
        AllowException,
        OPCode_Error,
        Overflow,
        Div_Zero,
        Exception_Signal,
        Exception_MemPosition
    );

    // Muxes
    // PCSrc
    mux_PCSrc Mux_PCSrc(
        PC_Src,
        ALU_Result,
        ALUOut_Result,
        Jump_Address,
        EPC_Out,
        LSControl_Out,
        PC_In
    );

    // IorD
    mux_IorD Mux_IorD(
        IorD,
        PC_Out,
        ALUOut_Result,
        ALU_Result,
        Exception_MemPosition,
        Mem_Address
    );

    // Reg_Dst
    mux_RegDest Mux_Reg_Dst(
        Reg_Dst,
        Instr_20_16,
        Instr_25_21,
        Instr_15_0[15:11],
        Reg_WriteIn
    );

    // MemToReg
    mux_MemToReg Mux_MemToReg(
        MemToReg,
        ALUOut_Result,
        LSControl_Out,
        Imm_SL16,
        HI_Out,
        LO_Out,
        Imm_SignExt,
        ShiftReg_Out,
        B_Out,
        A_Out,
        Reg_WriteData
    );

    // ALUSrcA
    mux_01_32b Mux_ALUSrcA(
        ALU_SrcA,
        PC_Out,
        A_Out,
        ALU_A
    );

    // ALUSrcB
    mux_ALUSrcB Mux_ALUSrcB(
        ALU_SrcB,
        B_Out,
        Imm_SignExt,
        Imm_SignExtSL2,
        ALU_B
    );

    // HI
    mux_01_32b Mux_HI(
        HI_Src,
        Mult_HIOut,
        Div_HIOut,
        HI_In
    );

    // LO
    mux_01_32b Mux_LO(
        LO_Src,
        Mult_LOOut,
        Div_LOOut,
        LO_In
    );

    // Shift_Src
    mux_01_32b Mux_Shift_Src(
        Shift_Src,
        B_Out,
        A_Out,
        ShiftReg_In
    );

    // Shift_Amt
    mux_ShiftAmt Mux_Shift_Amt(
        Shift_Amt,
        Instr_15_0[10:6],
        MDR_Out,
        B_Out,
        ShiftReg_Amt
    );

    // Shifts
    // ShiftL_2
    shift_left_2 ShiftL_2(
        Imm_SignExt,
        Imm_SignExtSL2
    );

    // ShiftL_16
    shift_left_16 ShiftL_16(
        Instr_15_0,
        Imm_SL16
    );

    // ShiftL_26_28
    shift_left_26_28 ShiftL_26_28(
        Instr_25_21,
        Instr_20_16,
        Instr_15_0,
        ShiftL_26_28_Out
    );

    // Sign Extenders
    // SignExt_1_32
    extend_1_32 SignExt_1_32(
        Lt,
        SignExt_1_32_Out
    );

    // SignExt_16_32
    extend_16_32 SignExt_16_32(
        Instr_15_0,
        Imm_SignExt
    );

    // SignExt_28_32
    extend_28_32 SignExt_28_32(
        PC_Out,
        ShiftL_26_28_Out,
        Jump_Address
    );
endmodule