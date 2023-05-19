/*
The median is calculated by means of a merge sort algorithm
to sort the pixel values in ascending order and then,
the middle value provides the median value
The varibles relating to the pixels will refer to this encoding
format: VarXY, where X refers to the row of the pixel, and Y 
refers to the column of the pixel
*/

// Top module for processing the 3x3 kernel for median calculation		  
module median(p11, p12, p13,
			  p21, p22, p23,
			  p31, p32, p33,
			  med);
	input  [7:0] p11, p12, p13, p21, p22, p23, p31, p32, p33;
	output [7:0] med;
	wire   [7:0] w11, w12, w13, w21, w22, w23, w31, w32, w33;
	// Calling the sort module to sort the values in ascending order
	sorter s(p11, p12, p13, p21, p22, p23, p31, p32, p33,
		     w11, w12, w13, w21, w22, w23, w31, w32, w33);
	assign med = w22; // Needs to take the middle value (5th index) in the med array
end module

// Module for a 2-8bit sorter
module sorter(a, b, min, max);
	input [7:0] a;
	input [7:0] b;
	output [7:0] min;
	output [7:0] max;
	wire cmp;
	// calling compare module to determine which value is larger
	compare c(a, b, cmp); // calling compare module to determine which pixel is larger
	mux m1(a, b, cmp, min); // calling mux module to place the smaller value into the correct index
	mux m2(b, a, cmp, max); // calling mux module to place the larger value into the correct index
end module

// Module for multiplexer
module mux(a,b, s, out);
	input [7:0] a;
	input [7:0] b;
	input s;
	output [7:0] out;
	reg [7:0] out;
	// Based on the boolean value from sorter, this will return 
	// the larger value between the pixel a & b.
	always@(a, b, s)
	begin
		if(s == 1'b1) out = a;
		else out = b;
	end
end module

// Module for comparing pixel values
module compare(a, b, out);
	input [7:0] a;
	input [7:0] b;
	output out;
	reg out;
	// Determining which pixel is larger, then returns a boolean 
	// 1 if pixel b is larger, and 0 if pixel a is larger
	always@(a,b)
	begin
		if(a < b) out = 1'b1;
		else out = 1'b0;
	end
end module;