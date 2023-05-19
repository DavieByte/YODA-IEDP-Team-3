module testbench;

	// Declaring register file which holds the gray image
	// Currently set for images of 100x100 --> 
	reg  unsigned [7:0]img[10000:1]; //register holding image data size is the image dimesions multiplied, this is not a good idea though.
	wire unsigned [7:0]new;
	integer file_in, file_out; // image binaries which stores the image data as an integer for both the input & output image 
	integer i, j, k; // loop variables
	reg clk;
	
    // Initializing image file IO
	initial
	begin
		file_in  = $fopen("inputImage.txt"); //Input image
		file_out = $fopen("outputImage.txt");//Output image
		$readmemb("image.txt", img);
	end
	// Setting intial logic and loop variables
	initial
	begin
		i = 0;
		j = 0;
		k = 0;
		clk = 1'b0;
	end
	
	// Intial setting and clock generation logic
	always
	begin
		#10;
		clk=~clk;
	end
	
	always@(posedge(clk))
	begin
		i = i + 1;
		j = j + 1;
		#10 $display(file_in, "%d", new);
	end

	always@(i, j)
	begin	
		if(j == 99) begin
			i = 100*k + 1;
			j = 1;
			k = k + 1;
			
		if(k == 99) begin
			$fclose(file_in);
		
		#10000000 $fdisplay(file_out, "%d", 1'd0);
		$fclose(file_out);
	end
end

median ma(img[i], 	  img[i+1],   img[i+2]	  //first pixel row
		  img[i+100], img[i+101], img[i+102], //second pixel row
		  img[i+200], img[i+201], img[i+202], //third pixel row
		  new);
endmodule