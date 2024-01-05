module mux_01_32b (
    input  wire        signal,
    input  wire [31:0] data_1,
    input  wire [31:0] data_2,
    output wire [31:0] data_out
);

    assign data_out = (signal) ? data_2 : data_1;

endmodule
    