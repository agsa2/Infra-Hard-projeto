module shift_left_16(
    input wire [31:0] sign_in,
    output wire [31:0] sign_out 
);

    assign sign_out = sign_in << 16;

endmodule