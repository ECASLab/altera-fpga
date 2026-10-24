// 16-bit LFSR pseudo-random number generator, Avalon-MM slave
// (word addressed, 1 read wait-cycle).
//
// Polynomial x^16 + x^14 + x^13 + x^11 + 1 (maximal, period 65535),
// Fibonacci form, shifting left.
//
// Registers (word address / byte offset):
//   0 / 0x0  REG_SEED   (W): [15:0] new state; 0 is replaced by DEFAULT_SEED
//   1 / 0x4  REG_CTRL   (W): bit0 = free-run (state shifts 1 bit every clock)
//   2 / 0x8  REG_DATA   (R): [15:0] random word. After each read the LFSR shifts
//                            16 clocks so the next word does not overlap this one.
//   3 / 0xC  REG_STATUS (R): bit0 = ready (0 while the 16 shifts are in progress)
//
// Without free-run the sequence is reproducible: the same seed gives the
// same series of reads.
//
// ADDR_WIDTH sets the width of the address bus (>= 2). To add or move
// registers, edit the localparam map below and the write/read case statements;
// unmapped addresses ignore writes and read as 0.
module lfsr_prng #(
	parameter ADDR_WIDTH   = 2,
	parameter DEFAULT_SEED = 16'hACE1
) (
	input [ADDR_WIDTH-1:0] address,
	input chipselect,
	input clk,
	input read,
	input reset_n,
	input write,
	input [31:0] writedata,
	output reg [31:0] readdata
);

	localparam [ADDR_WIDTH-1:0] REG_SEED   = 0;  // W
	localparam [ADDR_WIDTH-1:0] REG_CTRL   = 1;  // W
	localparam [ADDR_WIDTH-1:0] REG_DATA   = 2;  // R
	localparam [ADDR_WIDTH-1:0] REG_STATUS = 3;  // R

	reg [15:0] state;
	reg [4:0]  shifts_left;
	reg        free_run;

	wire feedback = state[15] ^ state[13] ^ state[12] ^ state[10];
	wire busy     = (shifts_left != 5'd0);

	// Write side and LFSR core: handles SEED/CTRL writes, and shifts the
	// state during the 16-clock advance after a data read or in free-run mode
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			state        <= DEFAULT_SEED;
			shifts_left <= 5'd0;
			free_run    <= 1'b0;
		end else begin
			if (chipselect & write & (address == REG_SEED)) begin
				state       <= (writedata[15:0] == 16'd0) ? DEFAULT_SEED : writedata[15:0];
				shifts_left <= 5'd0;
			end else begin
				if (busy | free_run)
					state <= {state[14:0], feedback};
				if (busy)
					shifts_left <= shifts_left - 5'd1;
				else if (chipselect & read & (address == REG_DATA))
					shifts_left <= 5'd16;
			end

			if (chipselect & write & (address == REG_CTRL))
				free_run <= writedata[0];
		end
	end

	// Read side: registers the selected register value onto readdata
	// (1 cycle read latency)
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n)
			readdata <= 32'd0;
		else if (chipselect & read) begin
			case (address)
				REG_DATA:   readdata <= {16'd0, state};
				REG_STATUS: readdata <= {31'd0, ~busy};
				default:    readdata <= 32'd0;
			endcase
		end
	end

endmodule
