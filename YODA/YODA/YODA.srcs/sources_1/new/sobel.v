`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module sobel(
input        i_clk,
input [71:0] i_pixel_data,
input        i_pixel_data_valid,
output reg [7:0] o_sobel_data,
output reg   o_sobel_data_valid
);

integer i; 
reg [7:0] kernel_gx [8:0];
reg [7:0] kernel_gy [8:0];
reg [10:0] gx[8:0];
reg [10:0] gy[8:0];
reg [10:0] sumGxInt;
reg [10:0] sumGyInt;
reg [10:0] sumGx;
reg [10:0] sumGy;
reg gValid;
reg sumValid;
reg sobel_data_valid;
reg [20:0] sobel_data_gxInt;
reg [20:0] sobel_data_gyInt;
wire [21:0] sobel_data_int;
reg sobel_data_int_valid;

initial
begin
    kernel_gx[0] =  1;
    kernel_gx[1] =  0;
    kernel_gx[2] = -1;
    kernel_gx[3] =  2;
    kernel_gx[4] =  0;
    kernel_gx[5] = -2;
    kernel_gx[6] =  1;
    kernel_gx[7] =  0;
    kernel_gx[8] = -1;
    
    kernel_gy[0] =  1;
    kernel_gy[1] =  2;
    kernel_gy[2] =  1;
    kernel_gy[3] =  0;
    kernel_gy[4] =  0;
    kernel_gy[5] =  0;
    kernel_gy[6] = -1;
    kernel_gy[7] = -2;
    kernel_gy[8] = -1;
end 

// mulitplying sobel kernel with pixel data kernel
always @(posedge i_clk)
begin
    for(i=0;i<9;i=i+1)
    begin
        gx[i] <= $signed(kernel_gx[i])*$signed({1'b0,i_pixel_data[i*8+:8]});
        gy[i] <= $signed(kernel_gy[i])*$signed({1'b0,i_pixel_data[i*8+:8]});
    end
    gValid <= i_pixel_data_valid;
end 

// Summing up gradient values
always @(*)
begin
    sumGxInt = 0;
    sumGyInt = 0;
    for(i=0;i<9;i=i+1)
    begin
        sumGxInt = $signed(sumGxInt) + $signed(gx[i]);
        sumGyInt = $signed(sumGyInt) + $signed(gy[i]);
    end
end

// Storing summed up values
always @(posedge i_clk)
begin
    sumGx <= sumGxInt;
    sumGy <= sumGyInt;
    sumValid <= gValid;
end

// Convolving calculated sobel kernls
always @(posedge i_clk)
begin
    sobel_data_gxInt <= $signed(sumGx)*$signed(sumGx);
    sobel_data_gyInt <= $signed(sumGy)*$signed(sumGy);
    sobel_data_int_valid <= sumValid;
end

assign sobel_data_int = sobel_data_gxInt + sobel_data_gyInt;

// limiting output values to something reasonable
always @(posedge i_clk)
begin
    if(sobel_data_int > 4000)
        o_sobel_data <= 8'hff;
    else
        o_sobel_data <= 8'h00;
    o_sobel_data_valid <= sobel_data_int_valid;
end

endmodule
