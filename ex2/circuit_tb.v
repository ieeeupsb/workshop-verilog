`include "circuit.v"
module circuit_tb();
 
  reg [3:0] a, b;
  wire [3:0] out;
 
  circuit random_name_here(.a(a),.b(b),.out(out)  ) ;
 
  initial begin
    $monitor("a=%4b, b=%4b, out=%4b", a, b, out);
    a = 4'b0000;
    b = 4'b0000;
    #20
    a = 4'b1111;
    b = 4'b0101;
    #20
    a = 4'b1100;
    b = 4'b1111;
    #20
    a = 4'b1100;
    b = 4'b0011;
    #20
    a = 4'b1100;
    b = 4'b1010;
    #20
    $finish;
  end
 
endmodule
