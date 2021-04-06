module execute(
  input clk, rst_n, wEn, SPwe_in, PC,
  input [31:0] inst, wData, SPin,
  output [31:0] ALU_A, ALU_B, BrPC,
  output reg [31:0] SPout,
  output ALU_A_SEL, Branch, MemInSel, memwr, WbDataSel, WbRegSel, SPwe_o,
  output [1:0] ALU_B_SEL
);

//Instantiate modules//
//Reg File

logic[4:0] Reg0In, Reg1In;
logic[31:0] Reg0Out, Reg1Out;
logic[1:0] Reg0Sel;
logic Reg1Sel;

//Determine RegFile inputs
always_comb begin
	case(Reg0Sel) begin
		(2'b00): begin //Rx
			Reg0In = inst[26:22];
			break;
		end
		(2'b01): begin //Ry
			Reg0In = inst[21:17];
			break;
		end
		(2'b10): begin //LR
			Reg0In = 5'b11110;
			break;
		end
		(2'b11): begin //ILR
			Reg0In = 5'b11111;
			break;
		end
		default: begin //default to Ry
			Reg0In = inst[21:17];
			break;
		end
	endcase
end

assign Reg1In = Reg1Sel ? (inst[21:17]) : (inst[16:12]); //Ry : Rz

RegisterFile regFile(.clk(clk), .rst_n(rst_n), .wEn(wEn), .Reg0(Reg0In),
			.Reg1(Reg1In), .Reg0Out(Reg0Out), .Reg1Out(Reg1Out));

//Immediate Extender
logic [31:0] imm_out;
logic [1:0] imm_sel;
imm_extender immExt(.imm_sel(imm_sel), .inst(inst[26:0]), .imm_out(imm_out));

//Branch
Branch br_mod(.Reg0Out(Reg0Out), .Reg1Out(Reg1Out), .PC(PC), .imm(imm_out), 
		.B(B), .BEQ(BEQ), .JMP(JMP), .BrPC(BrPC), .Branch(Branch));

//Control
Control con_sig(.opcode(inst[31:27]), .Reg1Sel(Reg1Sel), .wEn(wEn), 
	.ALU_A_SEL(ALU_A_SEL), .ALU_B_SEL(ALU_B_SEL), .B(B), .BEQ(BEQ), 
	.JMP(JMP), .MemInSel(MemInSel), .memwr(memwr), .WbDataSel(WbDataSel), 
	.WbRegSel(WbRegSel), .SPwe(SPwe_o), .Reg0Sel(Reg0Sel), .imm_sel(imm_sel));

//Stack Pointer
always_ff@(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		SPout <= 32'h00003000; //Start of stack
	end else if (SPwe) begin
		SPout <= SPin;
	end
end

endmodule

