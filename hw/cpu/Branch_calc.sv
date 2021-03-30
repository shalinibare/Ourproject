module Branch_calc (
	input [31:0] PC, Reg0Out, Reg1Out, imm,
	input B, BEQ, JMP,
	output [31:0] BrPC,
	output Branch
);

assign BrPC = PC + imm;

always_comb begin
	if(B) begin
		Branch = Reg0Out != Reg1Out;
	end else if(BEQ) begin
		Branch = Reg0Out != Reg1Out;
	end else if(JMP) begin
		Branch = 1'b1;
	end else begin
		Branch = 1'b0;
	end
end

endmodule
