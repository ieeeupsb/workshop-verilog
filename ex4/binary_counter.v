module binary_counter
   #(parameter N=4)
   (
    input wire clk, reset,
    output wire [N-1:0] binary
   );
 
   reg [N-1:0] r_reg;
   wire [N-1:0] r_next;
 
   always @(posedge clk, negedge reset)
   begin
      if (~reset)
         r_reg <= 0;
      else
         r_reg <= r_next;
	end	
	assign binary  = r_reg;
		assign r_next = r_reg+1;
endmodule