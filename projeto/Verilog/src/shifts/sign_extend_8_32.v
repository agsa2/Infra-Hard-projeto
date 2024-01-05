module extend_8_32(
    input wire [7:0] immediate,
    input wire [31:0] extend_out
);

    assign extend_out = (immediate[7]) ? {{24{1'b1}}, immediate} : {{24{1'b0}}, immediate};

endmodule