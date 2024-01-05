module shift_left_26_28(
    input wire [4:0] rs,
    input wire [4:0] rt,
    input wire [15:0] immediate,
    output wire [27:0] shift_left_26_28_out
);

    assign shift_left_26_28_out = {rs, rt, immediate, 2'b00};

endmodule