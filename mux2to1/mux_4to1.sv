// 4-to-1 Multiplexer - SystemVerilog
// Selects one of 4 inputs based on 2-bit select signal

module mux_4to1
    import mux_pkg::*;
(
    input  logic [3:0] data_in,     // 4-bit input
    input  logic [1:0] select,      // 2-bit select signal
    output logic       data_out     // 1-bit output
);

    // Combinational logic for 4-to-1 multiplexer
    always_comb begin
        case (select)
            SEL_0: data_out = data_in[0];
            SEL_1: data_out = data_in[1];
            SEL_2: data_out = data_in[2];
            SEL_3: data_out = data_in[3];
            default: data_out = 1'b0;
        endcase
    end

endmodule
