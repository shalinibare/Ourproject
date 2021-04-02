module Forwarding_Unit(
  input [4:0] d_op, d_regIn0, d_regIn1,
  		x_op, x_regIn0, x_regIn1,
		m_op, m_regIn, m_regOut,
		w_op, w_regOut,
  output X_D_r0, X_D_r1, M_D_r0, M_D_r1,
	  X_X_r0, X_X_r1, M_X_stall,
	  M_X_r0, M_X_r1, M_M_r
);

endmodule

