module mux_RegDest (
    input  wire [2:0]  RegDest,
    input  wire [4:0] rt,
    input  wire [4:0] rs,
    input  wire [4:0] rd,
    output wire [4:0] RegDest_Out
);

//   input 0 (000): rt
//   input 1 (001): rs
//   input 2 (010): 29
//   input 3 (011): 31
//   input 4 (100): rd

    wire [4:0] aux1;
    wire [4:0] aux2;
    wire [4:0] aux3;

    assign aux1 = (RegDest[0]) ? rs : rt;
    assign aux2 = (RegDest[0]) ? 5'b11111 : 5'b11101;
    assign aux3 = (RegDest[1]) ? aux2 : aux1;

    assign RegDest_Out = (RegDest[2]) ? rd : aux3;

endmodule
    