`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Handling the functionality of loading in pixel values to the line buffers
// this is to be used for reading/writing to the line buffers
//////////////////////////////////////////////////////////////////////////////////

module imageControl(
input [9:0] width, // the number of pixels in the row
input i_clk,
input i_rst,
input [7:0] i_pixel_data,
input i_pixel_data_valid,
output reg [71:0] o_pixel_data,
output o_pixel_data_valid
);

// instantiating pixel counter variable
// keeps track of which pixel is being processed in the row
// size of the register must match the number of pixels in the row
reg [8:0] pixelCounter; // must cater for length of the row of pixels
reg [1:0] currentWrLineBuffer; // register that identifies the line buffers for writing data
reg [3:0] lineBufferDataValid; 
reg [8:0] rdCounter; // must cater for length of the row of pixels
reg [3:0] lineBufferRdData;
reg [1:0] currentRdLineBuffer; // register that identifies the line buffers for reading data
reg rd_line_buffer; // control signal for line buffers that are readable, since they are filled
reg [11:0] totalPixelCounter; // register that stores the amount of pixels in all the line buffers, log2(3 x lengthOfLineBuffer)
reg rdState;
// instantiating state machine values
localparam IDLE = 'b0,
           RD_BUFFER = 'b1;

// instantiating wires to be used for line buffers
wire [23:0] lb0data;
wire [23:0] lb1data;
wire [23:0] lb2data;
wire [23:0] lb3data;

assign o_pixel_data_valid = rd_line_buffer; //control signal for when a line buffer is ready to be read from

// setting conditions for pixel buffer
// incrementing when writing new data
// decrementing when reading data
always @(posedge i_clk)
begin
    if(i_rst)
        totalPixelCounter <= 0;
    else
    begin
        if(i_pixel_data_valid & !rd_line_buffer)
            totalPixelCounter <= totalPixelCounter + 1;
        else if(i_pixel_data_valid & rd_line_buffer)
            totalPixelCounter <= totalPixelCounter - 1;
    end
end

// setting logic for state machine for reading data
// this will be set to idle while waiting for pixels to 
// load into the line buffers
always @(posedge i_clk)
begin
    if(i_rst)
    begin
       rdState <= IDLE; 
       rd_line_buffer <= 1'b0;
    end
    else
    begin
        case(rdState)
            IDLE:begin
                if(totalPixelCounter >= 1536) // number of pixels in 3 rows
                begin
                    rd_line_buffer <= 1'b1;
                    rdState <= RD_BUFFER;
                end
            end
            RD_BUFFER:begin
                if(rdCounter == width - 1)
                begin
                    rdState <= IDLE;
                    rd_line_buffer <= 1'b0;
                end
            end
        endcase
    end
end

// setting reset conditions for pixelCounter
// and setting incremental conditions based on the clk signal
always @(posedge i_clk)
begin
    if(i_rst)
        pixelCounter  <= 0;
    else
        begin
            if(i_pixel_data_valid)
                pixelCounter <= pixelCounter + 1;
        end
end

// making de-multiplexor to determine where the pixel should go in memory,
// also handling functionality of what should happen 
// once the all the pixels in the row have been processed
always @(posedge i_clk)
begin
    if(i_rst)
        currentWrLineBuffer <= 0;
    else
        begin
            if(pixelCounter == width & i_pixel_data_valid) 
                currentWrLineBuffer <= currentWrLineBuffer + 1;
        end    
end

// determining which line buffers are active for processing
always @(*)
begin
    lineBufferDataValid <= 4'h0;
    lineBufferDataValid[currentWrLineBuffer] = i_pixel_data_valid;

end

// setting reset conditions for rdCounter
// and setting incremental conditions based on the clk signal
always @(posedge i_clk)
begin
    if(i_rst)
        rdCounter <= 0;
    else
        begin
            if(rd_line_buffer)
                rdCounter <= rdCounter + 1;
        end
end

// setting logic for which 3 line buffers can be used for processing
// and letting the 4th line buffer load in new pixel values
always @(posedge i_clk)
begin
    if(i_rst)
        begin
            currentRdLineBuffer <= 0;
        end
    else
        begin
            if(rdCounter == width & rd_line_buffer)
                currentRdLineBuffer <= currentRdLineBuffer + 1;
        end
end


// setting the logic that determines which line buffers can be read from
// readable line buffers rotate circularly
// processing occurs using 3 line buffers while the 4th line buffer
// is loading in new pixel values
always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            o_pixel_data = {lb2data, lb1data, lb0data};
        end
        1:begin
            o_pixel_data = {lb3data, lb2data, lb1data};
        end
        2:begin
            o_pixel_data = {lb0data, lb3data, lb2data};
        end
        3:begin
            o_pixel_data = {lb1data, lb0data, lb3data};
        end
    endcase
end

// Setting conditions for which line buffers can be read from
// while the other buffer is loading in new values
always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            lineBufferRdData[0] = rd_line_buffer;
            lineBufferRdData[1] = rd_line_buffer;
            lineBufferRdData[2] = rd_line_buffer;
            lineBufferRdData[3] = 1'b0;
        end
        1:begin
            lineBufferRdData[0] = 1'b0;
            lineBufferRdData[1] = rd_line_buffer;
            lineBufferRdData[2] = rd_line_buffer;
            lineBufferRdData[3] = rd_line_buffer;
        end
        2:begin
            lineBufferRdData[0] = rd_line_buffer;
            lineBufferRdData[1] = 1'b0;
            lineBufferRdData[2] = rd_line_buffer;
            lineBufferRdData[3] = rd_line_buffer;
        end
        3:begin
            lineBufferRdData[0] = rd_line_buffer;
            lineBufferRdData[1] = rd_line_buffer;
            lineBufferRdData[2] = 1'b0;
            lineBufferRdData[3] = rd_line_buffer;
        end
    
    endcase
end

// instantiating line buffers
lineBuffer lb_0(
.width(width),
.i_clk(i_clk),
.i_rst(i_rst),
.i_data(i_pixel_data),
.i_data_valid(lineBufferDataValid[0]),
.o_data(lb0data), 
.i_rd_data(lineBufferRdData[0])
);

lineBuffer lb_1(
.width(width),
.i_clk(i_clk),
.i_rst(i_rst),
.i_data(i_pixel_data),
.i_data_valid(lineBufferDataValid[1]),
.o_data(lb1data), 
.i_rd_data(lineBufferRdData[1])
);

lineBuffer lb_2(
.width(width),
.i_clk(i_clk),
.i_rst(i_rst),
.i_data(i_pixel_data),
.i_data_valid(lineBufferDataValid[2]),
.o_data(lb2data), 
.i_rd_data(lineBufferRdData[2])
);

lineBuffer lb_3(
.width(width),
.i_clk(i_clk),
.i_rst(i_rst),
.i_data(i_pixel_data),
.i_data_valid(lineBufferDataValid[3]),
.o_data(lb3data), 
.i_rd_data(lineBufferRdData[3])
);

endmodule
