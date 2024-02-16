module mux_ShiftAmt (
    input wire [1:0] ShiftAmt,
    input wire [4:0] Shamt,
    input wire [4:0] MDR_Out,
    input wire [4:0] B_Out,
    output wire [4:0] ShiftAMt_Out
);

//   input 0 (00): Shamt
//   input 1 (01): memory data register
//   input 2 (10): B

    wire [4:0] aux1;
    
    assign aux1 = (ShiftAmt[0]) ? MDR_Out : Shamt;

    assign ShiftAMt_Out = (ShiftAmt[1]) ? B_Out : aux1;

endmodule