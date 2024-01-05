module Exception_Control(
    input  wire AllowException,
    input  wire OPCodeError,
    input  wire OverflowError,
    input  wire DivisionByZeroError,
    output wire Exception_Signal,
    output wire [31:0] MemPosition
);

    // 253: 32'b00000000000000000000000011111101
    // 254: 32'b00000000000000000000000011111110
    // 255: 32'b00000000000000000000000011111111

    assign MemPosition = (OPCodeError) ? 32'b00000000000000000000000011111101 : 
                         (OverflowError) ? 32'b00000000000000000000000011111110 : 
                         (DivisionByZeroError) ? 32'b00000000000000000000000011111111 : 
                         32'b00000000000000000000000000000000;

    assign Exception_Signal = (!AllowException && (OPCodeError || OverflowError || DivisionByZeroError));

endmodule