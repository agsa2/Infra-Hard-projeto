module Mult (
    input wire Clock,
    input wire Reset,

    input wire Mult_Control,

    input wire [31:0] A,
    input wire [31:0] B,

    output reg [31:0] HI_Out,
    output reg [31:0] LO_Out
);

reg Controle;

reg [31:0] Multiplicador;
reg [63:0] Multiplicando;
reg [63:0] Produto;
reg [5:0] Contador;

initial begin
    Multiplicando[31:0] = A;
    Multiplicando[63:32] = 32'b00000000000000000000000000000000;
    Multiplicador = B;
    Produto = 64'b00000;
    Contador = 6'b000000;
    Controle = Mult_Control;
    HI_Out = 32'b000;
    LO_Out = 32'b000;
end

always @(negedge Clock) begin
    if (Reset) begin
        Multiplicando = 64'b00000;
        Multiplicador = 32'b00000;
        Produto = 64'b00000;
        Contador = 6'b000000;
        Controle = 1'b0;
        HI_Out = 32'b000;
        LO_Out = 32'b000;
    end
    else begin
        if (Controle) begin
            if (Multiplicador[0]) begin
                Produto = Produto + Multiplicando;
            end
            Multiplicando = Multiplicando << 1;
            Multiplicador = Multiplicador >> 1;

            Contador = Contador + 1;
            if (Contador == 6'b011111) begin    // 32 ciclos
                HI_Out = Produto[63:32];
                LO_Out = Produto[31:0];
                Controle = 1'b0;
            end
        end
        if (Mult_Control != Controle) begin
            Controle = Mult_Control;
            if (Controle) begin
                Multiplicando[31:0] = A;
                Multiplicando[63:32] = 32'b00000000000;
                Multiplicador = B;
            end
        end
    end
end

// Test
// 00000000000100000000010000000000
// 00000000000000000000010000100000

// 00000000000000000000000000000010
// 00000000000000000000000000000011

endmodule