module FPU_tb_add;

reg [31:0] A, B;
reg ctrl;
wire [31:0] out;


parameter hold_interval = 10;

FPU DUT(
	.A(A),
	.B(B),
	.control(ctrl),
	.result(out)
);


initial
	begin
		//test adding
		//5.67 + 0.44
		ctrl = 0; A = 32'h40B570A4; B = 32'h3EE147AE; #hold_interval;
		
		//347.978 + 0.00078
		ctrl = 0;A = 32'h43ADFD2F; B = 32'h3A4C78EA; #hold_interval;
		
		//12 + 0.0487
		ctrl = 0; A = 32'h41400000; B = 32'h3D4779A7; #hold_interval;
		
		//test multiplication
		//5.67 * 0.44
		ctrl = 1; A = 32'h40B570A4; B = 32'h3EE147AE; #hold_interval;
		
		//347.978 * 0.00078
		ctrl = 1;A = 32'h43ADFD2F; B = 32'h3A4C78EA; #hold_interval;
		
		//12 * 0.0487
		ctrl = 1; A = 32'h41400000; B = 32'h3D4779A7; #hold_interval;
		
	end
endmodule