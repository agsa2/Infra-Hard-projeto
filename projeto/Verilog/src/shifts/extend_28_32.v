module extend_28_32(
    input wire [31:0] pc,
    input wire [27:0] extend_26_28,
    output wire [31:0] extend_28_32_out
);

    assign extend_28_32_out = {pc[31:28], extend_26_28};

endmodule