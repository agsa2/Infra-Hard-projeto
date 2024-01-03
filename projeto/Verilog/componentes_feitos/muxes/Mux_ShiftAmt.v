model mux_ShiftAmt (
    input wire [2:0] ShiftAmt,
    input wire [31:0] Shamt,
    input wire [31:0] MDR_Out,
    input wire [31:0] B_Out,
    output wire [31:0] ShiftAMt_Out,
);

//   input 0 (000): Shamt
//   input 1 (001): memory data register
//   input 2 (010): B

    wire [31:0] aux1;
    
    assign aux1 = (ShiftAmt[0]) ? MDR_Out : Shamt;

    assign ShiftAMt_Out = (ShiftAmt[0]) ? B_Out : aux1;

endmodule