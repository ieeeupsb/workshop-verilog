//simple example of AND gate
module and_gate(
    input a,
    input b, 
    output y
);

    assign y = a & b;
endmodule