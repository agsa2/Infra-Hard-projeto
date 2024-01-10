module mdr(

    input wire [31:0] memData,
    output wire [31:0] mdr_out
);

    assign mdr_out = memData;

endmodule