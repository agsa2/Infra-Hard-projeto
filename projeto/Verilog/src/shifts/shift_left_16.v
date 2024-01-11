module shift_left_16(
    input wire [15:0] sign_in,
    output wire [31:0] sign_out 
);

    wire [31:0] aux = {16'b0, sign_in};

    assign sign_out = aux << 16;

endmodule