module load_size_control(
    input wire [1:0] LS_control,
    input wire [31:0] mdr_input,
    output wire [31:0] LS_out
);

    wire [31:0] LWH;

    // se o bit mais a direita for 1, é lh, se não lw
    assign LWH = (LS_control[0]) ? {{16'd0}, mdr_input[15:0]} : mdr_input;

    // se o bit mais a esquerda for 1 é lb
    assign LS_out = (LS_control[1]) ? {{24'd0}, mdr_input[7:0]} : LWH;

endmodule