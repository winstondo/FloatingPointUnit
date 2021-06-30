//Winston Do	
//Noel Esqueda


module FP_Addition_Unit(
	input [31:0] A, B,
	output [31:0] sum
);


//exponenent part of the IEEE 754 is reperesented as a unsigned 8-bit val
wire [31:0] wr_A_operand, wr_B_operand;
wire [23:0] wr_A_significant, wr_B_significant; //24 bits account for leading 1
wire [7:0] wr_A_exp, wr_B_exp, wr_exp_diff;
wire wr_A_sign, wr_B_sign, wr_sum_sign;


wire [23:0] wr_shifted_B_significant; //used for nomalization
wire [7:0] wr_normalized_B_exp;	//normalized exponent of B operand

//sum of significants of the two operators, includes the hidden bit.
wire [23:0] wr_significand_sum;

//A wire is always the largest number, this will assign A and B inputs to their respective wires based on the exponent comparison

assign wr_A_operand = (A[30:23] < B[30:23]) ? B : A;
assign wr_B_operand = (A[30:23] < B[30:23]) ? A : B;


//assign wr_A_significant = {1'b1, wr_A_operand[22:0]}; //significants are appended with a leading one if the value is positive
//assign wr_B_significant = {1'b1, wr_B_operand[22:0]};

assign wr_A_significant = {!(wr_A_operand[31]), wr_A_operand[22:0]}; //significants are appended with a leading one if the value is positive
assign wr_B_significant = {!(wr_B_operand[31]), wr_B_operand[22:0]};

assign wr_A_exp = wr_A_operand[30:23];
assign wr_B_exp = wr_B_operand[30:23];
assign wr_sum_sign = wr_A_operand[31] || wr_B_operand[31];



//difference between exponents, used to shift
//should always yield a positive value as from this point on A operan > B operand
assign wr_exp_diff = wr_A_operand[30:23] - wr_B_operand[30:23];

//normalization

assign wr_shifted_B_significant = wr_B_significant >> wr_exp_diff; 
assign wr_normalized_B_exp = wr_B_operand[30:23] + wr_exp_diff;


//addition block-------------------------------------------------
//adds the two significants together
assign wr_significand_sum = wr_A_significant + wr_shifted_B_significant;

//output

assign sum = {wr_sum_sign, wr_A_exp, wr_significand_sum[22:0]}; //truncates the leading 1 bit

endmodule



module FP_Multiplication_Unit(
	input [31:0] A, B,
	output [31:0] product
	//, output overflow
);

wire [23:0] wr_A_significant, wr_B_significant; //24 bits account for leading 1
wire [7:0] wr_A_exp, wr_B_exp, wr_product_exp, wr_exp_sum;
wire [47:0] wr_product, wr_product_normalized; //48 Bits
wire wr_product_sign, wr_product_round, wr_normalized ;


wire [22:0] wr_product_significant;





assign wr_product_sign = A[31] ^ B[31]; //determines the sign of the products


assign wr_A_significant = {!(A[31]), A[22:0]}; //significants are appended with a leading one if the value is positive
assign wr_B_significant = {!(B[31]), B[22:0]};

assign wr_A_exp = A[30:23];
assign wr_B_exp = B[30:23];


//multiplication block
assign wr_exp_sum = A[30:23] + B[30:23]; //sum of the exponents

assign wr_product = wr_A_significant * wr_B_significant; //product of significants

assign wr_product_round = |wr_product_normalized[22:0];//rounding operation

assign wr_normalized = wr_product[47]; //extract first bit of product for normalization

assign wr_product_normalized = wr_normalized ? wr_product : wr_product <<1; //shifts for normilization based on product's MSB

assign wr_product_exp = wr_exp_sum - 8'd127 + wr_normalized;

assign wr_product_significant = wr_product_normalized[46:24] + {21'b0,(wr_product_normalized[23] & wr_product_round)};

assign product = {wr_product_sign, wr_product_exp, wr_product_significant};


endmodule


module FPU(
	input [31:0] A, B,
	input control,
	output [31:0] result
);

wire [31:0] product, sum;

FP_Multiplication_Unit FPMU(
	.A(A),
	.B(B),
	.product(product)
);

FP_Addition_Unit FPAU(
	.A(A),
	.B(B),
	.sum(sum)
);

assign result = control ? product : sum;
	
endmodule