module imm_extender (
	input [1:0] imm_sel,
	input [26:0] inst,
	output [31:0] imm_out
);

assign imm_out = imm_sel == 2'b00 ? ({15{ins[16]}, ins[16:0]}) :
					imm_sel == 2'b01 ? ({10{ins[21]}, ins[21:0]}) :
					({5{ins[26]}, ins[26:0]});

endmodule
