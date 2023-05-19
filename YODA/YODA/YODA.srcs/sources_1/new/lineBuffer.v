`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Handles the functionality for reading/writing data to/from the kernel mask
// Kernel mask shifts to the right at the positive edge of the clk signal
// 
//////////////////////////////////////////////////////////////////////////////////


module lineBuffer(
input  [9:0]  width, // the number of pixels in the row
input         i_clk,
input         i_rst,
input  [7:0]  i_data,
input         i_data_valid,
output [23:0] o_data, // this is the 3 pixels in the kernel row
input         i_rd_data
);

reg [7:0] line [512:0]; //line buffer for the row of pixels, size must match the number of pixels in the row
reg [8:0] wrPntr; // points to the location of where the pixel value must be written to in memory, size of reg is log2(sizeOfMemory)
reg [8:0] rdPntr; // points to the location of where the pixel value must be read from in memory

// writing to the line buffer to the value located at wrPntr
always @(posedge i_clk)
begin
    if(i_data_valid)
        line[wrPntr] <= i_data;
end 

// setting reset conditions for wrPntr
always @(posedge i_clk)
begin
    if(i_rst)
        wrPntr <= 'd0;
    else if(i_data_valid)
        wrPntr <= wrPntr + 'd1;
end 

// pre-fetching data before clk, this should prevent any latency when the data is being read from
assign o_data = {line[rdPntr], line[rdPntr + 1], line[rdPntr + 2]}; // loading in the 3 pixels in the kernel row    

// setting reset conditions for rdPntr and
// shifting rdPntr to next pixel on posedge i_clk
always @(posedge i_clk)
begin
    if(i_rst)
        rdPntr <= 'd0;
    else if(i_rd_data)
        rdPntr <= rdPntr + 'd1;
end

endmodule
