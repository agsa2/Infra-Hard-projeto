module extend_1_32(
    input wire extend_in,
    output wire [31:0] extend_out
);

    assign extend_out = {{31{1'b0}},extend_in};

endmodule