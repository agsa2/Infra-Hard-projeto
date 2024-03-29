module Control_Unit (
    input wire Clock,
    input wire Reset,

    // Wires from ALU
    input wire GT,
    input wire LT,
    input wire EQ,
    input wire Z,

    // Wire from IR
    input wire [5:0] OP_Code,
    input wire [5:0] Funct,

    // Wire from Exception Control Unit
    input wire Exception_Signal,

    // Control Outputs
    // Reset
    output reg Reset_Signal,

    // Math control
    output reg Div_Control,
    output reg Mult_Control,

    // Shift Control
    output reg [2:0] Shift_Control,

    // Data Size Control
    output reg [1:0] LS_Control,
    output reg [1:0] SS_Control,

    // Muxes controls
    output reg [2:0] PC_Src,
    output reg [1:0] IorD,
    output reg [2:0] Reg_Dst,
    output reg [3:0] MemToReg,
    output reg ALU_SrcA,
    output reg [1:0] ALU_SrcB,
    output reg HI_Src,
    output reg LO_Src,
    output reg Shift_Src,
    output reg [1:0] Shift_Amt,

    // Registers controls
    output reg PC_Write,
    output reg PC_Write_Cond,
    output reg Mem_WR,
    output reg MDR_Write,
    output reg IR_Write,
    output reg Reg_Write,
    output reg A_Write,
    output reg B_Write,
    output reg HI_Write,
    output reg LO_Write,
    output reg ALUOut_Write,
    output reg EPC_Write,

    // ALU control
    output reg [2:0] ALU_Op,

    // Exception
    output reg AllowException,
    output reg OPCode_Error
);

reg [5:0] State;
reg [5:0] Counter;

// Estados
// General
parameter State_Common = 6'b000000;
parameter State_Reset  = 6'b111111;
parameter State_Exception = 6'b111110;

// R Type
parameter State_Add    = 6'b000001;
parameter State_And    = 6'b000010;
parameter State_Div    = 6'b000011;
parameter State_Mult   = 6'b000100;
parameter State_Jr     = 6'b000101;
parameter State_Mfhi   = 6'b000110;
parameter State_Mflo   = 6'b000111;
parameter State_Sll    = 6'b001000;
parameter State_Sllv   = 6'b001001;
parameter State_Slt    = 6'b001010;
parameter State_Sra    = 6'b001011;
parameter State_Srav   = 6'b001100;
parameter State_Srl    = 6'b001101;
parameter State_Sub    = 6'b001110;
parameter State_Break  = 6'b001111;
parameter State_Rte    = 6'b010000;
parameter State_Xchg   = 6'b010001;

// I Type
parameter State_Addi   = 6'b010010;
parameter State_Addiu  = 6'b010011;
parameter State_Beq    = 6'b010100;
parameter State_Bne    = 6'b010101;
parameter State_Ble    = 6'b010110;
parameter State_Bgt    = 6'b010111;
parameter State_Sram   = 6'b011000;
parameter State_Lb     = 6'b011001;
parameter State_Lh     = 6'b011010;
parameter State_Lui    = 6'b011011;
parameter State_Lw     = 6'b011100;
parameter State_Sb     = 6'b011101;
parameter State_Sh     = 6'b011110;
parameter State_Slti   = 6'b011111;
parameter State_Sw     = 6'b100000;

// J Type
parameter State_J      = 6'b100001;
parameter State_Jal    = 6'b100010;

// OPCode parameters
// R Type
parameter OPCode_R     = 6'b000000;
parameter R_Add        = 6'b100000;
parameter R_And        = 6'b100100;
parameter R_Div        = 6'b011010;
parameter R_Mult       = 6'b011000;
parameter R_Jr         = 6'b001000;
parameter R_Mfhi       = 6'b010000;
parameter R_Mflo       = 6'b010010;
parameter R_Sll        = 6'b000000;
parameter R_Sllv       = 6'b000100;
parameter R_Slt        = 6'b101010;
parameter R_Sra        = 6'b000011;
parameter R_Srav       = 6'b000111;
parameter R_Srl        = 6'b000010;
parameter R_Sub        = 6'b100010;
parameter R_Break      = 6'b001101;
parameter R_Rte        = 6'b010011;
parameter R_Xchg       = 6'b000101;

// I Type
parameter OPCode_Addi  = 6'b001000;
parameter OPCode_Addiu = 6'b001001;
parameter OPCode_Beq   = 6'b000100;
parameter OPCode_Bne   = 6'b000101;
parameter OPCode_Ble   = 6'b000110;
parameter OPCode_Bgt   = 6'b000111;
parameter OPCode_Sram  = 6'b000001;
parameter OPCode_Lb    = 6'b100000;
parameter OPCode_Lh    = 6'b100001;
parameter OPCode_Lui   = 6'b001111;
parameter OPCode_Lw    = 6'b100011;
parameter OPCode_Sb    = 6'b101000;
parameter OPCode_Sh    = 6'b101001;
parameter OPCode_Slti  = 6'b001010;
parameter OPCode_Sw    = 6'b101011;

// J Type
parameter OPCode_J     = 6'b000010;
parameter OPCode_Jal   = 6'b000011;

initial begin
    State = State_Reset;
    Reset_Signal = 1'b1;

    Shift_Control = 2'b0;

    LS_Control = 2'b0;
    SS_Control = 2'b0;

    PC_Src = 3'b000;
    IorD = 2'b0;
    Reg_Dst = 3'b0;
    MemToReg = 4'b0;
    ALU_SrcA = 1'b0;
    ALU_SrcB = 2'b00;
    HI_Src = 1'b0;
    LO_Src = 1'b0;
    Shift_Src = 2'b0;
    Shift_Amt = 3'b0;

    PC_Write = 1'b0;
    PC_Write_Cond = 1'b0;
    Mem_WR = 1'b0;
    IR_Write = 1'b0;
    Reg_Write = 1'b0;
    A_Write = 1'b0;
    B_Write = 1'b0;
    HI_Write = 1'b0;
    LO_Write = 1'b0;
    ALUOut_Write = 1'b0;
    EPC_Write = 1'b0;

    ALU_Op = 3'b000;

    AllowException = 1'b0;
    OPCode_Error = 1'b0;
end

always @(posedge Clock) begin
    if (Reset) begin
        if (State != State_Reset) begin
            State = State_Reset;

            Reset_Signal = 1'b1;
            Counter = 6'b0;

            Shift_Control = 3'b0;

            PC_Src = 3'b001;
            IorD = 2'b0;
            Reg_Dst = 3'b0;
            MemToReg = 4'b0;
            ALU_SrcA = 1'b0;
            ALU_SrcB = 2'b0;
            HI_Src = 1'b0;
            LO_Src = 1'b0;
            Shift_Src = 1'b0;
            Shift_Amt = 2'b0;

            PC_Write = 1'b0;
            PC_Write_Cond = 1'b0;
            Mem_WR = 1'b0;
            IR_Write = 1'b0;
            Reg_Write = 1'b0;
            A_Write = 1'b0;
            B_Write = 1'b0;
            HI_Write = 1'b0;
            LO_Write = 1'b0;
            ALUOut_Write = 1'b0;
            EPC_Write = 1'b0;

            ALU_Op = 3'b0;

            AllowException = 1'b0;
            OPCode_Error = 1'b0;
        end
        else begin
            State = State_Common;
            
            Reset_Signal = 1'b0;
            Counter = 6'b0;

            Shift_Control = 3'b0;

            PC_Src = 3'b001;
            IorD = 2'b0;
            Reg_Dst = 3'b0;
            MemToReg = 4'b0;
            ALU_SrcA = 1'b0;
            ALU_SrcB = 2'b0;
            HI_Src = 1'b0;
            LO_Src = 1'b0;
            Shift_Src = 1'b0;
            Shift_Amt = 2'b0;

            PC_Write = 1'b0;
            PC_Write_Cond = 1'b0;
            Mem_WR = 1'b0;
            IR_Write = 1'b0;
            Reg_Write = 1'b0;
            A_Write = 1'b0;
            B_Write = 1'b0;
            HI_Write = 1'b0;
            LO_Write = 1'b0;
            ALUOut_Write = 1'b0;
            EPC_Write = 1'b0;

            ALU_Op = 3'b0;

            AllowException = 1'b0;
            OPCode_Error = 1'b0;
        end
    end
    else begin
        case (State)
            State_Common: begin
                if (Counter == 6'b000000 || Counter == 6'b000001) begin
                    State = State_Common;
                    MemToReg = 4'b0;

                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b01;
                    ALU_Op = 3'b001;

                    Reg_Write = 1'b0;
                    Mem_WR = 1'b0;
                    IorD = 2'b00;
                    MDR_Write = 1'b0;

                    PC_Src = 3'b000;
                    PC_Write = 1'b0;
                    
                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Common;
                    MemToReg = 4'b0;        //
                    ALU_SrcA = 1'b0;        //
                    ALU_SrcB = 2'b01;       //

                    PC_Write = 1'b1;        // <----------
                    Mem_WR = 1'b0;          //
                    IR_Write = 1'b1;        // <----------

                    ALU_Op = 3'b001;        //
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;
                    MemToReg = 4'b0;        //
                    ALU_SrcA = 1'b0;        //
                    ALU_SrcB = 2'b00;       // <----------

                    PC_Write = 1'b0;        // <----------
                    Mem_WR = 1'b0;          //
                    IR_Write = 1'b0;        // <----------
                    Reg_Write = 1'b0;
                    A_Write = 1'b1;         // <----------
                    B_Write = 1'b1;         // <----------

                    ALU_Op = 3'b000;        //

                    AllowException = 1'b0;
                    OPCode_Error = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000100) begin
                    case (OP_Code)
                        OPCode_R:  begin
                            case (Funct)
                                R_Add: begin
                                    State = State_Add;
                                    OPCode_Error = 1'b0;
                                end
                                R_And: begin
                                    State = State_And;
                                    OPCode_Error = 1'b0;
                                end
                                R_Div: begin
                                    State = State_Div;
                                    OPCode_Error = 1'b0;
                                end
                                R_Mult: begin
                                    State = State_Mult;
                                    OPCode_Error = 1'b0;
                                end
                                R_Jr: begin
                                    State = State_Jr;
                                    OPCode_Error = 1'b0;
                                end
                                R_Mfhi: begin
                                    State = State_Mfhi;
                                    OPCode_Error = 1'b0;
                                end
                                R_Mflo: begin
                                    State = State_Mflo;
                                    OPCode_Error = 1'b0;
                                end
                                R_Sll: begin
                                    State = State_Sll;
                                    OPCode_Error = 1'b0;
                                end
                                R_Sllv: begin
                                    State = State_Sllv;
                                    OPCode_Error = 1'b0;
                                end
                                R_Slt: begin
                                    State = State_Slt;
                                    OPCode_Error = 1'b0;
                                end
                                R_Sra: begin
                                    State = State_Sra;
                                    OPCode_Error = 1'b0;
                                end
                                R_Srav: begin
                                    State = State_Srav;
                                    OPCode_Error = 1'b0;
                                end
                                R_Srl: begin
                                    State = State_Srl;
                                    OPCode_Error = 1'b0;
                                end
                                R_Sub: begin
                                    State = State_Sub;
                                    OPCode_Error = 1'b0;
                                end
                                R_Break: begin
                                    State = State_Break;
                                    OPCode_Error = 1'b0;
                                end
                                R_Rte: begin
                                    State = State_Rte;
                                    OPCode_Error = 1'b0;
                                end
                                R_Xchg: begin
                                    State = State_Xchg;
                                    OPCode_Error = 1'b0;
                                end
                                default: begin
                                    State = State_Exception;

                                    OPCode_Error = 1'b1;
                                    
                                    Counter =  6'b000000;
                                end
                            endcase
                        end
                        OPCode_Addi: begin
                            State = State_Addi;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Addiu: begin
                            State = State_Addiu;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Beq: begin
                            State = State_Beq;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Bne: begin
                            State = State_Bne;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Ble: begin
                            State = State_Ble;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Bgt: begin
                            State = State_Bgt;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Sram: begin
                            State = State_Sram;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Lb: begin
                            State = State_Lb;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Lh: begin
                            State = State_Lh;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Lui: begin
                            State = State_Lui;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Lw: begin
                            State = State_Lw;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Sb: begin
                            State = State_Sb;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Sh: begin
                            State = State_Sh;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Slti: begin
                            State = State_Slti;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Sw: begin
                            State = State_Sw;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_J: begin
                            State = State_J;
                            OPCode_Error = 1'b0;
                        end
                        OPCode_Jal: begin
                            State = State_Jal;
                            OPCode_Error = 1'b0;
                        end
                        default: begin
                            State = State_Exception;

                            OPCode_Error = 1'b1;
                            
                            Counter =  6'b000000;
                        end
                    endcase
                    
                    Reset_Signal = 1'b0;

                    Shift_Control = 2'b0;

                    LS_Control = 2'b0;
                    SS_Control = 2'b0;

                    PC_Src = 3'b000;
                    IorD = 2'b0;
                    Reg_Dst = 3'b0;
                    MemToReg = 4'b0;        //
                    ALU_SrcA = 1'b0;        //
                    ALU_SrcB = 2'b01;       // <----------
                    HI_Src = 1'b0;
                    LO_Src = 1'b0;
                    Shift_Src = 2'b0;
                    Shift_Amt = 3'b0;

                    PC_Write = 1'b0;
                    PC_Write_Cond = 1'b0;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    Reg_Write = 1'b0;
                    A_Write = 1'b0;         // <----------
                    B_Write = 1'b0;         // <----------
                    HI_Write = 1'b0;
                    LO_Write = 1'b0;
                    ALUOut_Write = 1'b0;
                    EPC_Write = 1'b0;

                    ALU_Op = 3'b001;        // <----------
                    
                    Counter =  6'b000000;
                end
            end
            State_Reset: begin
                State = State_Common;
                
                Reset_Signal = 1'b1;
                Counter = 6'b0;

                Shift_Control = 3'b0;

                PC_Src = 3'b000;
                IorD = 2'b0;
                Reg_Dst = 3'b010;
                MemToReg = 4'b0101;
                ALU_SrcA = 1'b0;
                ALU_SrcB = 2'b0;
                HI_Src = 1'b0;
                LO_Src = 1'b0;
                Shift_Src = 2'b0;
                Shift_Amt = 3'b0;

                PC_Write = 1'b0;
                PC_Write_Cond = 1'b0;
                Mem_WR = 1'b0;
                IR_Write = 1'b0;
                Reg_Write = 1'b1;
                A_Write = 1'b0;
                B_Write = 1'b0;
                HI_Write = 1'b0;
                LO_Write = 1'b0;
                ALUOut_Write = 1'b0;
                EPC_Write = 1'b0;

                ALU_Op = 3'b0;

                AllowException = 1'b0;
                OPCode_Error = 1'b0;
            end
            State_Add: begin
                if (Counter == 6'b000000) begin
                    State = State_Add;

                    Reg_Dst = 3'b100;       //
                    MemToReg = 4'b0000;     //
                    ALU_SrcA = 1'b1;        // <----------
                    ALU_SrcB = 2'b00;       // <----------

                    Reg_Write = 1'b0;       //
                    ALUOut_Write = 1'b1;    //

                    ALU_Op = 3'b001;        // <----------

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin

                    ALU_SrcA = 1'b0;        //
                    ALU_SrcB = 2'b00;       //
                    ALUOut_Write = 1'b0;    //

                    ALU_Op = 3'b001;        //

                    AllowException = 1'b0;
                    
                    if (Exception_Signal) begin
                        State = State_Exception;
                        Reg_Write = 1'b0;       // <----------
                    end
                    else begin
                        State = State_Common;
                        Reg_Write = 1'b1;       // <----------
                    end
                    
                    Counter = 6'b000000;
                end
            end
            State_And: begin
                if (Counter == 6'b000000) begin
                    State = State_And;

                    Reg_Dst = 3'b100;       //
                    MemToReg = 4'b0000;     //
                    ALU_SrcA = 1'b1;        // <----------
                    ALU_SrcB = 2'b00;       // <----------

                    Reg_Write = 1'b0;       //
                    ALUOut_Write = 1'b1;    //

                    ALU_Op = 3'b011;        // <----------

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    ALU_SrcA = 1'b0;        //
                    ALU_SrcB = 2'b00;       //
                    Reg_Write = 1'b1;       // <----------
                    ALUOut_Write = 1'b0;    //

                    ALU_Op = 3'b011;        //

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Div: begin
                if (Counter <= 6'b100001) begin

                    AllowException = 1'b0;
                    
                    if (Exception_Signal) begin
                        State = State_Exception;
                        Div_Control = 1'b0;
                        Counter = 6'b000000;
                    end
                    else begin
                        State = State_Div;
                        Div_Control = 1'b1;
                        Counter = Counter + 1;
                    end
                end
                else if (Counter == 6'b100010) begin
                    State = State_Common;

                    Div_Control = 1'b0;

                    HI_Src = 1'b1;
                    LO_Src = 1'b1;
                    HI_Write = 1'b1;
                    LO_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Mult: begin
                if (Counter <= 6'b100000) begin
                    State = State_Mult;

                    Mult_Control = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b100001) begin
                    State = State_Common;

                    Mult_Control = 1'b0;

                    HI_Src = 1'b0;
                    LO_Src = 1'b0;
                    HI_Write = 1'b1;
                    LO_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Jr: begin
                if (Counter == 6'b000000) begin
                    State = State_Jr;

                    ALU_SrcA = 1'b1;
                    ALU_Op = 3'b000;
                    PC_Src = 3'b000;
                    PC_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    ALU_SrcA = 1'b0;       
                    ALU_Op = 3'b000;     
                    PC_Src = 3'b000;       
                    PC_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Mfhi: begin
                if (Counter == 6'b000000) begin
                    State = State_Mfhi;

                    Reg_Dst = 3'b100;       //
                    MemToReg = 4'b0011;     //

                    Reg_Write = 1'b1;       //

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    Reg_Dst = 3'b100;       //
                    MemToReg = 4'b0011;     //

                    Reg_Write = 1'b0;       //

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Mflo: begin
                if (Counter == 6'b000000) begin
                    State = State_Mflo;

                    Reg_Dst = 3'b100;       //
                    MemToReg = 4'b0100;     //

                    Reg_Write = 1'b1;       //

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    Reg_Dst = 3'b100;       //
                    MemToReg = 4'b0100;     //

                    Reg_Write = 1'b0;       //

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Sll: begin
                 if (Counter == 6'b000000) begin
                    State = State_Sll;

                    Shift_Control  = 3'b001;
                    Shift_Src = 2'b00;

                    Shift_Amt = 3'b000;
                   
                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Sll;

                    Shift_Src = 2'b00;

                    Shift_Amt = 3'b000;
                    Shift_Control = 3'b010;

                    MemToReg = 4'b0111;
                    Reg_Dst = 3'b100;
                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Sll;

                    Shift_Amt = 3'b000;
                    Shift_Control = 3'b010;

                    MemToReg = 4'b0111;
                    Reg_Dst = 3'b100;
                    Reg_Write = 1'b1;

                    AllowException = 1'b0;
                    
                     Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;

                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Sllv: begin
                if (Counter == 6'b000000) begin
                    State = State_Sllv;

                    Shift_Control  = 3'b001;
                    Shift_Src = 2'b01;

                    Shift_Amt = 3'b010;
                   
                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Sllv;

                    Shift_Src = 2'b01;

                    Shift_Amt = 3'b010;
                    Shift_Control = 3'b110;

                    MemToReg = 4'b0111;
                    Reg_Dst = 3'b100;
                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State =State_Sllv;

                    Shift_Amt = 3'b010;
                    Shift_Control = 3'b110;

                    MemToReg = 4'b0111;
                    Reg_Dst = 3'b100;
                    Reg_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;

                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Slt: begin
                if (Counter == 6'b000000) begin
                    State = State_Slt;

                    ALU_SrcA  = 1'b1;
                    ALU_SrcB = 2'b00;
                    ALU_Op = 3'b111;

                    MemToReg = 4'b1010;
                    Reg_Dst = 3'b100;

                    Reg_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Sra: begin
                if (Counter == 6'b000000) begin
                    State = State_Sra;

                    Shift_Control  = 3'b001;
                    Shift_Src = 2'b00;

                    Shift_Amt = 3'b000;
                   
                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Sra;

                    Shift_Src = 2'b00;

                    Shift_Amt = 3'b000;
                    Shift_Control = 3'b100;

                    MemToReg = 4'b0111;
                    Reg_Dst = 3'b100;
                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Sra;

                    Shift_Amt = 3'b000;
                    Shift_Control = 3'b100;

                    MemToReg = 4'b0111;
                    Reg_Dst = 3'b100;
                    Reg_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;

                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Srav: begin
                if (Counter == 6'b000000) begin
                    State = State_Srav;

                    Shift_Control  = 3'b001;
                    Shift_Src = 2'b01;

                    Shift_Amt = 3'b010;
                   
                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Srav;

                    Shift_Src = 2'b01;

                    Shift_Amt = 3'b010;
                    Shift_Control = 3'b100;

                    MemToReg = 4'b0111;
                    Reg_Dst = 3'b100;
                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Srav;

                    Shift_Amt = 3'b010;
                    Shift_Control = 3'b100;

                    MemToReg = 4'b0111;
                    Reg_Dst = 3'b100;
                    Reg_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;

                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Srl: begin
                if (Counter == 6'b000000) begin
                    State = State_Srl;

                    Shift_Control  = 3'b001;
                    Shift_Src = 2'b00;

                    Shift_Amt = 3'b000;
                   
                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Srl;

                    Shift_Src = 2'b00;

                    Shift_Amt = 3'b000;
                    Shift_Control = 3'b011;

                    MemToReg = 4'b0111;
                    Reg_Dst = 3'b100;
                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Srl;

                    Shift_Amt = 3'b000;
                    Shift_Control = 3'b011;

                    MemToReg = 4'b0111;
                    Reg_Dst = 3'b100;
                    Reg_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;

                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Sub: begin
                if (Counter == 6'b000000) begin
                    State = State_Sub;

                    Reg_Dst = 3'b100;       //
                    MemToReg = 4'b0000;     //
                    ALU_SrcA = 1'b1;        // <----------
                    ALU_SrcB = 2'b00;       // <----------

                    Reg_Write = 1'b0;       //
                    ALUOut_Write = 1'b1;    //

                    ALU_Op = 3'b010;        // <----------

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin

                    ALU_SrcA = 1'b0;        //
                    ALU_SrcB = 2'b00;       //
                    ALUOut_Write = 1'b0;    //

                    ALU_Op = 3'b010;        //

                    AllowException = 1'b0;
                    
                    if (Exception_Signal) begin
                        State = State_Exception;
                        Reg_Write = 1'b0;       // <----------
                    end
                    else begin
                        State = State_Common;
                        Reg_Write = 1'b1;       // <----------
                    end
        
                    Counter = 6'b000000;
                end
            end
            State_Break: begin
                if (Counter == 6'b000000) begin
                    State = State_Break;

                    ALU_SrcA = 1'b0;        // <----------
                    ALU_SrcB = 2'b01;       // <----------

                    ALU_Op = 3'b010;        // <----------

                    PC_Src = 3'b000;        // <----------
                    PC_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    ALU_SrcA = 1'b0;        // <----------
                    ALU_SrcB = 2'b01;       // <----------

                    ALU_Op = 3'b010;        // <----------

                    PC_Src = 3'b000;        // <----------
                    PC_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Rte: begin
                if (Counter == 6'b000000) begin
                    State = State_Rte;

                    EPC_Write = 1'b0;
                    PC_Src = 3'b011;
                    PC_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    EPC_Write = 1'b0;      
                    PC_Src = 3'b000;       
                    PC_Write = 1'b0;       

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end 
            end
            State_Xchg: begin
                if (Counter == 6'b000000) begin
                    State = State_Xchg;

                    Reg_Dst = 3'b000;
                    MemToReg = 4'b1001;
                    Reg_Write = 1'b1;
                
                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Xchg;

                    Reg_Dst = 3'b001;
                    MemToReg = 4'b1000;
                    Reg_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Common;

                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Addi: begin
                if (Counter == 6'b000000) begin
                    State = State_Addi;

                    Reg_Dst = 3'b000;       //
                    MemToReg = 4'b0000;     //
                    ALU_SrcA = 1'b1;        // <----------
                    ALU_SrcB = 2'b10;       // <----------

                    Reg_Write = 1'b0;       //
                    ALUOut_Write = 1'b1;    //

                    ALU_Op = 3'b001;        // <----------

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin

                    ALU_SrcA = 1'b0;        //
                    ALU_SrcB = 2'b00;       //
                    ALUOut_Write = 1'b0;    //

                    ALU_Op = 3'b001;        //

                    AllowException = 1'b0;
                    
                    if (Exception_Signal) begin
                        State = State_Exception;
                        Reg_Write = 1'b0;       // <----------
                    end
                    else begin
                        Reg_Write = 1'b1;       // <----------
                        State = State_Common;
                    end
                    
                    Counter = 6'b000000;
                end
            end
            State_Addiu: begin
                if (Counter == 6'b000000) begin
                    State = State_Addiu;

                    Reg_Dst = 3'b000;       //
                    MemToReg = 4'b0000;     //
                    ALU_SrcA = 1'b1;        // <----------
                    ALU_SrcB = 2'b10;       // <----------

                    Reg_Write = 1'b0;       //
                    ALUOut_Write = 1'b1;    //

                    ALU_Op = 3'b001;        // <----------

                    AllowException = 1'b1;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    ALU_SrcA = 1'b0;        //
                    ALU_SrcB = 2'b00;       //
                    Reg_Write = 1'b1;       // <----------
                    ALUOut_Write = 1'b0;    //

                    ALU_Op = 3'b001;        //

                    AllowException = 1'b1;
                    
                    Counter = 6'b000000;
                end
            end
            State_Beq: begin
                if (Counter == 6'b000000) begin
                    State = State_Beq;

                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b11;
                    ALU_Op = 3'b001;
                    ALUOut_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Beq;
                    
                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b00;
                    ALU_Op = 3'b111;
                    AllowException = 1'b0;
                    ALUOut_Write = 1'b0;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    if (EQ) begin
                        PC_Src = 3'b001;
                        PC_Write = 1'b1;
                    end
                    else begin
                        PC_Src = 3'b000;
                        PC_Write = 1'b0;
                    end
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;
                    
                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b00;
                    ALU_Op = 3'b000;
                    PC_Src = 3'b000;
                    PC_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Bne: begin
                if (Counter == 6'b000000) begin
                    State = State_Bne;

                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b11;
                    ALU_Op = 3'b001;
                    ALUOut_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Bne;
                    
                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b00;
                    ALU_Op = 3'b111;
                    AllowException = 1'b0;
                    ALUOut_Write = 1'b0;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    if (!EQ) begin
                        PC_Src = 3'b001;
                        PC_Write = 1'b1;
                    end
                    else begin
                        PC_Src = 3'b000;
                        PC_Write = 1'b0;
                    end
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;
                    
                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b00;
                    ALU_Op = 3'b000;
                    PC_Src = 3'b000;
                    PC_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Ble: begin
                if (Counter == 6'b000000) begin
                    State = State_Ble;

                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b11;
                    ALU_Op = 3'b001;
                    ALUOut_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Ble;
                    
                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b00;
                    ALU_Op = 3'b111;
                    AllowException = 1'b0;
                    ALUOut_Write = 1'b0;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    if (!GT) begin
                        PC_Src = 3'b001;
                        PC_Write = 1'b1;
                    end
                    else begin
                        PC_Src = 3'b000;
                        PC_Write = 1'b0;
                    end
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;
                    
                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b00;
                    ALU_Op = 3'b000;
                    PC_Src = 3'b000;
                    PC_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Bgt: begin
                if (Counter == 6'b000000) begin
                    State = State_Bgt;

                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b11;
                    ALU_Op = 3'b001;
                    ALUOut_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Bgt;
                    
                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b00;
                    ALU_Op = 3'b111;
                    ALUOut_Write = 1'b0;
                    AllowException = 1'b0;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    if (GT) begin
                        PC_Src = 3'b001;
                        PC_Write = 1'b1;
                    end
                    else begin
                        PC_Src = 3'b000;
                        PC_Write = 1'b0;
                    end
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;
                    
                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b00;
                    ALU_Op = 3'b000;
                    PC_Src = 3'b000;
                    PC_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Sram: begin
                if (Counter == 6'b000000 || Counter == 6'b000001) begin
                    State = State_Sram;

                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b10;
                    ALU_Op = 3'b001;
                    
                    IorD = 2'b10;
                    Mem_WR = 1'b0;
                    MDR_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Sram;

                    Mem_WR = 1'b0;
                    MDR_Write = 1'b1;
                    LS_Control = 2'b00;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Sram;

                    LS_Control = 2'b00;
                    MDR_Write = 1'b0;

                    Shift_Src = 2'b00;
                    Shift_Amt = 2'b01;
                    Shift_Control = 3'b001;
                    Reg_Dst = 3'b000;
                    MemToReg = 4'b0111;
                    Reg_Write = 1'b0;
                   
                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000100) begin
                    State = State_Sram;

                    LS_Control = 2'b00;
                    MDR_Write = 1'b0;

                    Shift_Amt = 2'b01;
                    Shift_Control = 3'b100;
                    Reg_Dst = 3'b000;
                    MemToReg = 4'b0111;
                    Reg_Write = 1'b0;
                   
                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000101) begin
                    State = State_Common;

                    LS_Control = 2'b00;
                    MDR_Write = 1'b0;

                    Shift_Amt = 2'b01;
                    Shift_Control = 3'b100;
                    Reg_Dst = 3'b000;
                    MemToReg = 4'b0111;
                    Reg_Write = 1'b1;
                   
                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Lb: begin
                if (Counter == 6'b000000 || Counter == 6'b000001) begin
                    State = State_Lb;

                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b10;
                    ALU_Op = 3'b001;
                    MDR_Write = 1'b0;
                    IorD = 2'b10;
                    Mem_WR = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Lb;
                    
                    Mem_WR = 1'b0;
                    MDR_Write = 1'b1;
                    LS_Control = 2'b10;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;

                    LS_Control = 2'b10;
                    MDR_Write = 1'b1;

                    Reg_Dst = 3'b000;
                    MemToReg = 4'b0001;
                    Reg_Write = 1'b1;
                   
                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Lh: begin
                if (Counter == 6'b000000 || Counter == 6'b000001) begin
                    State = State_Lh;

                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b10;
                    ALU_Op = 3'b001;
                    MDR_Write = 1'b0;
                    IorD = 2'b10;
                    Mem_WR = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Lh;
                    
                    Mem_WR = 1'b0;
                    MDR_Write = 1'b1;
                    LS_Control = 2'b01;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;

                    LS_Control = 2'b01;
                    MDR_Write = 1'b1;

                    Reg_Dst = 3'b000;
                    MemToReg = 4'b0001;
                    Reg_Write = 1'b1;
                   
                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Lui: begin
                if (Counter == 6'b000000) begin
                    State = State_Lui;

                    Reg_Dst = 3'b000;
                    MemToReg = 4'b0010;
                    Reg_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    Reg_Dst = 3'b000;
                    MemToReg = 4'b0000;
                    Reg_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Lw: begin
                if (Counter == 6'b000000 || Counter == 6'b000001) begin
                    State = State_Lw;

                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b10;
                    ALU_Op = 3'b001;
                    MDR_Write = 1'b0;
                    IorD = 2'b10;
                    Mem_WR = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Lw;
                    
                    Mem_WR = 1'b0;
                    MDR_Write = 1'b1;
                    LS_Control = 2'b00;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;

                    LS_Control = 2'b00;
                    MDR_Write = 1'b1;

                    Reg_Dst = 3'b000;
                    MemToReg = 4'b0001;
                    Reg_Write = 1'b1;
                   
                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Sb: begin
                  if (Counter == 6'b000000) begin
                    State = State_Sb;

                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b10;
                    ALU_Op = 3'b001;
                    MDR_Write = 1'b0;
                    
                    IorD = 2'b10;
                    Mem_WR = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001 || Counter == 6'b000010) begin
                    State = State_Sb;

                    MDR_Write = 1'b1;

                    SS_Control = 2'b10;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;

                    SS_Control = 2'b10;
                    Mem_WR = 1'b1;
                    MDR_Write = 1'b0;
                   
                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Sh: begin
                  if (Counter == 6'b000000) begin
                    State = State_Sh;

                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b10;
                    ALU_Op = 3'b001;
                    MDR_Write = 1'b0;
                    
                    IorD = 2'b10;
                    Mem_WR = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001 || Counter == 6'b000010) begin
                    State = State_Sh;

                    MDR_Write = 1'b1;

                    SS_Control = 2'b01;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;

                    SS_Control = 2'b01;
                    Mem_WR = 1'b1;
                    MDR_Write = 1'b0;
                   
                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Slti: begin
                if (Counter == 6'b000000) begin
                    State = State_Slti;

                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b10;
                    ALU_Op = 3'b111;
                    
                    MemToReg = 4'b1010;
                    Reg_Dst = 3'b000;
                    Reg_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    Reg_Write = 1'b0;
                   
                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Sw: begin
                 if (Counter == 6'b000000) begin
                    State = State_Sw;

                    ALU_SrcA = 1'b1;
                    ALU_SrcB = 2'b10;
                    ALU_Op = 3'b001;
                    MDR_Write = 1'b0;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Sw;
                    
                    IorD = 2'b10;
                    Mem_WR = 1'b0;
                    MDR_Write = 1'b1;

                    SS_Control = 2'b00;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000010) begin
                    State = State_Common;

                    SS_Control = 2'b00;
                    Mem_WR = 1'b1;
                    MDR_Write = 1'b0;
                   
                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_J: begin
                if (Counter == 6'b000000) begin
                    State = State_J;

                    PC_Src = 3'b010;
                    PC_Write = 1'b1;
                    
                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b01;
                    ALU_Op = 3'b001;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;
                    
                    PC_Src = 3'b010;
                    PC_Write = 1'b0;
                   
                    AllowException = 1'b0;
                    
                    Counter = 6'b000000;
                end
            end
            State_Jal: begin
                 if (Counter == 6'b000000) begin
                    State = State_Jal;

                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b01;
                    
                    ALU_Op = 3'b000;
                    Reg_Dst = 3'b011;
                    ALUOut_Write = 1'b1;
                    
                    PC_Src = 3'b010;
                    PC_Write = 1'b1;

                    AllowException = 1'b0;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001) begin
                    State = State_Common;

                    PC_Src = 3'b000;
                    PC_Write = 1'b0;
                    
                    Reg_Write = 1'b1;
                    Reg_Dst = 3'b011;
                    MemToReg = 4'b0000;
                    
                    Counter = 6'b000000;
                end
            end
            State_Exception: begin
                if (Counter == 6'b000000) begin
                    State = State_Exception;

                    IorD = 2'b11;
                    Mem_WR = 1'b0;
                    
                    ALU_SrcA = 1'b0;
                    ALU_SrcB = 2'b01;
                    ALU_Op = 3'b010;
                    
                    EPC_Write = 1'b1;
                    
                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000001 || Counter == 6'b000010) begin
                    State = State_Exception;
                    
                    IorD = 2'b11;
                    Mem_WR = 1'b0;

                    MDR_Write = 1'b1;
                    LS_Control = 2'b10;

                    PC_Src = 3'b100;
                    EPC_Write = 1'b0;

                    Counter = Counter + 1;
                end
                else if (Counter == 6'b000011) begin
                    State = State_Common;
                    
                    IorD = 2'b11;
                    Mem_WR = 1'b0;

                    MDR_Write = 1'b0;
                    LS_Control = 2'b10;

                    PC_Src = 3'b100;
                    PC_Write = 1'b1;
                    
                    OPCode_Error = 1'b0;

                    Counter = 6'b000000;
                end
            end
        endcase
    end
    Reset_Signal = Reset;
end
    
endmodule