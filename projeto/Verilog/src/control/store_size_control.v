module store_size_control(

    input wire [1:0] SS_control,
    input wire [31:0] B,
    input wire [31:0] mdr_input,
    output wire [31:0] SS_out
);

    wire [31:0] SWH;

    // SS_control = 00 -> sw
    // SS_control = 01 -> sh
    // SS_control = 1? -> sb

    // se o bit mais a direita for 1, é sh, caso contrario, é sw
    assign SWH = (SS_control[0]) ? {mdr_input[31:16], B[15:0]} : B;
   
    // se o bit mais a esquerda for 1 é sb
    assign SS_out = (SS_control[1]) ? {mdr_input[31:8], B[7:0]} : SWH;

endmodule