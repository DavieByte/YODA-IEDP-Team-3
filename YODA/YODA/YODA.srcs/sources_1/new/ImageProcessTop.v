`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Setting up the top module
//////////////////////////////////////////////////////////////////////////////////


module ImageProcessTop(
input axi_clk,
input axi_reset_n,
// slave interface
input i_data_valid,
input [7:0] i_data,
output o_data_ready,
// master interface
output o_data_valid,
output [7:0] o_data,
input i_data_ready,
// interupt
output intr
    );


    
// instantiating control module
imageControl IC(
.width(),
.i_clk(axi_clk),
.i_rst(!axi_reset_n),
.i_pixel_data(i_data),
.i_pixel_data_valid(i_data_valid),
.o_pixel_data(),
.o_pixel_data_valid()
);    

// still need to make convolution module which is the median filter and sobel operator
// instantiating median filter module


// instantiating sobel operator module


endmodule
