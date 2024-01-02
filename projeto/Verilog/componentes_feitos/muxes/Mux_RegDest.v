module mux_RegDest (
    input  wire [2:0]  RegDest,
    input  wire [31:0] rt,
    input  wire [31:0] rs,
    input  wire [31:0] rd,
    output wire [31:0] RegDest_Out,
);

//   input 0 (000): rt
//   input 1 (001): rs
//   input 2 (010): 29
//   input 3 (011): 31
//   input 4 (100): rd

    wire [31:0] aux1;
    wire [31:0] aux2;
    wire [31:0] aux3;

    assign aux1 = (RegDest[0]) ? rs : rt;
    assign aux2 = (RegDest[0]) ? 32'b00000000000000000000000000011111 : 32'b00000000000000000000000000011101;
    assign aux3 = (RegDest[1]) ? aux2 : aux1;

    assign RegDest_Out = (RegDest[2]) ? rd : aux3;

endmodule
    