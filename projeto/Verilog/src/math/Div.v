module Div (
    input wire Clock,
    input wire Reset,

    input wire Div_Control,

    input wire [31:0] A,
    input wire [31:0] B,

    output reg [31:0] HI_Out,
    output reg [31:0] LO_Out
);

reg cond_checker;

reg Controle;

reg [31:0] Quociente;
reg [63:0] Divisor;
reg [63:0] Resto;
reg [5:0] Contador;


initial begin
    Divisor[63:32] = B;
    Divisor[31:0] = 32'b00000000000000000000000000000000;
    Resto[31:0] = A;
    Resto[63:32] = 32'b00000000000000000000000000000000;
    Quociente = 32'b00000000000000000000000000000000;
    Contador = 6'b000000;
    Controle = Div_Control;
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
        HI_Out = 32'b00000000000000000000000000000000;
        LO_Out = 32'b00000000000000000000000000000000;
    end
    else begin
        if (Controle) begin
            Resto = Resto - Divisor;
            if (Resto[63]) begin
                Resto = Resto + Divisor;
                Quociente[31:1] = Quociente[30:0];
                Quociente[0] = 1'b0;
                cond_checker = 1'b0;
            end
            else begin
                Quociente[31:1] = Quociente[30:0];
                Quociente[0] = 1'b1;
                cond_checker = 1'b1;
            end
            Divisor = Divisor >> 1;

            Contador = Contador + 1;
            if (Contador == 6'b100001) begin    // 32 ciclos
                LO_Out = Quociente[31:0];
                HI_Out = Resto[31:0];
                Quociente = 32'b00000000000000000000000000000000;
                Controle = 1'b0;
                Contador = 6'b000000;
            end
        end
        if (Div_Control != Controle) begin
            Controle = Div_Control;
            if (Controle) begin
                Divisor[63:32] = B;
                Divisor[31:0] = 32'b00000000000000000000000000000000;
                Resto[31:0] = A;
                Resto[63:32] = 32'b00000000000000000000000000000000;
                Contador = 6'b000000;
            end
        end
    end
end

// Test
// 00000000000000000000000000000110
// 00000000000000000000000000000010

endmodule