module extend_16_32(
    input wire [15:0] immediate,
    input wire [31:0] extend_out
);

    assign extend_out = (immediate[15]) ? {{16{1'b1}}, immediate} : {{16{1'b0}}, immediate};

endmodule