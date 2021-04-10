//Version 0.1
module ALU(	
  input signed [31:0] ALU_A_in, ALU_B_in,
  input [4:0] opcode,
  output logic [31:0] ALUOut
);

logic [2:0] op_type;
//Determine ALU operation type
always_comb begin
	case(opcode) 
		5'b0001x: begin //SUB
			op_type = 3'b001;
			break;
		end
		5'b00100: begin //LSR
			op_type = 3'b110;
			break;
		end
		5'b00101: begin //ASR
			op_type = 3'b111;
			break;
		end
		5'b00110: begin //SL
			op_type = 3'b101;
			break;
		end
		5'b00111: begin //AND
			op_type = 3'b011;
			break;
		end
		5'b01000: begin //OR
			op_type = 3'b010;
			break;
		end
		5'b01001: begin //NOT
			op_type = 3'b100;
			break;
		end
		default: begin //Default to add op
			op_type = 3'b000;
			break;
		end
	endcase
end

//Determine ALU ouput
always_comb begin
	case(op_type) 
		3'b000: begin //Add
			ALUOut = ALU_A_in + ALU_B_in;
			break;
		end
		3'b001: begin //Subtract
			ALUOut = ALU_A_in - ALU_B_in;
			break;
		end
		3'b010: begin //OR
			ALUOut = ALU_A_in | ALU_B_in;
			break;
		end
		3'b011: begin //AND
			ALUOut = ALU_A_in & ALU_B_in;
			break;
		end
		3'b100: begin //NOT
			ALUOut = ~ALU_A_in;
			break;
		end
		3'b101: begin //Shift left
			ALUOut = ALU_A_in << ALU_B_in;
			break;
		end
		3'b110: begin //LSR
			ALUOut = ALU_A_in >> ALU_B_in;
			break;
		end
		3'b111: begin //ASR (signed shift)
			ALUOut = ALU_A_in >>> ALU_B_in;
			break;
		end
		default: break;
	endcase
end

endmodule

