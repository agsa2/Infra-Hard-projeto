module Div (
    input wire Clock,
    input wire Reset,

    input wire Div_Control,

    input wire [31:0] A,
    input wire [31:0] B,

    output wire Div_Zero,

    output reg [31:0] HI_Out,
    output reg [31:0] LO_Out
);

reg Controle;
reg Div_Zero_Reg;

reg [1:0] Signal_Combination;

reg [31:0] Quociente;
reg [63:0] Divisor;
reg [63:0] Resto;
reg [5:0] Contador;


initial begin
    Signal_Combination[1] = A[31];
    Signal_Combination[0] = B[31];

    Divisor[63:32] = B;
    Divisor[31:0] = 32'b00000000000000000000000000000000;
    Resto[31:0] = A;
    Resto[63:32] = 32'b00000000000000000000000000000000;
    Quociente = 32'b00000000000000000000000000000000;
    Contador = 6'b000000;
    Controle = Div_Control;
    Div_Zero_Reg = 1'b0;
    HI_Out = 32'b00000000000000000000000000000000;
    LO_Out = 32'b00000000000000000000000000000000;
end

always @(posedge Clock) begin
    if (Reset) begin
        Divisor = 64'b00000000000000000000000000000000;
        Resto = 64'b00000000000000000000000000000000;
        Quociente = 32'b00000000000000000000000000000000;
        Contador = 6'b000000;
        Controle = 1'b0;
        Div_Zero_Reg = 1'b0;
        HI_Out = 32'b00000000000000000000000000000000;
        LO_Out = 32'b00000000000000000000000000000000;
    end
    else begin
        if (Div_Zero_Reg) begin
            Div_Zero_Reg = 1'b0;
        end
        if (Controle) begin
            if (A == 32'b0000000 || B == 32'b0000000) begin
                Div_Zero_Reg = 1'b1;
                Controle = 1'b0;
            end
            Resto = Resto - Divisor;
            if (Resto[63]) begin
                Resto = Resto + Divisor;
                Quociente[31:1] = Quociente[30:0];
                Quociente[0] = 1'b0;
            end
            else begin
                Quociente[31:1] = Quociente[30:0];
                Quociente[0] = 1'b1;
            end
            Divisor = Divisor >> 1;

            Contador = Contador + 1;
            if (Contador == 6'b100001) begin    // 32 ciclos
                if (Signal_Combination[1] != Signal_Combination[0]) begin
                    LO_Out = ~Quociente + 1;
                    HI_Out = Signal_Combination[1] ? ~Resto[31:0] : Resto[31:0];
                end
                else begin
                    LO_Out = Quociente;
                    HI_Out = Resto[31:0];
                end
                
                Controle = 1'b0;
                Contador = 6'b000000;
            end
        end
        if ((Div_Control != Controle) && (!Div_Zero_Reg)) begin
            Controle = Div_Control;
            if (Controle) begin
                Signal_Combination[1] = A[31];
                Signal_Combination[0] = B[31];

                Divisor[63:32] = B[31] ? ~B + 1 : B;
                Divisor[31:0] = 32'b00000000000000000000000000000000;
                Resto[31:0] = A[31] ? ~A + 1 : A;
                Resto[63:32] = 32'b00000000000000000000000000000000;
                Contador = 6'b000000;
                Quociente = 32'b00000000000000000000000000000000;
            end
        end
    end
end

// RD = 00 <=> Signal = 00
// RD = 01 <=> Signal = 10
// RD = 10 <=> Signal = 11
// RD = 11 <=> Signal = 01

assign Div_Zero = Div_Zero_Reg;

// Test
// 00000000000000000000000000000110
// 00000000000000000000000000000010

// 00000000000000000000000000001000
// 00000000000000000000000000000101

// 00000000000000000000000000000000

endmodule