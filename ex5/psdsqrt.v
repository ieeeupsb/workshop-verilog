// Module declaration
module psdsqrt(
		input clock,               // Master clock implemented in the module
		input reset,               // Synchronized reset activeted in the high level
		input start,               // Signal to start a new square root calculation
		input stop,                // Load output register
		input [31:0] xin,          // Operand (unsigned)
		output reg [15:0] sqrt     // Square root of the operand xin
    );

// Regs and wires declaration
reg  [31:0] xin_stored;       // Register that stores the input value to square root's argument
reg  [15:0] testbit;          // Testbit used in the algorithm application
reg  [15:0] testbit_mux;      // Result of testbit>>1, except in the start of the algorithm (testbit_mux = 1'b1000_..._0000)
reg  [15:0] tempsqrt;         // Holds the temporary value of sqrt(xin) -> is also the output originated by the application of the sqrt algorithm
reg  [15:0] tempsqrt_mux1;    // Selection beetween testsqrt and tempsqrt (this is based on the algorithm)
reg  [15:0] tempsqrt_mux2;    // Critical for the start of the algorithm: initializes the tempsqrt register in 16h'0000
wire [31:0] sqtestsqrt;       // Represents the provisional result with power 2 to be compareted with the original value xin
wire [15:0] testsqrt;         // Test value of each iteration that will be used for comparating testsqrt with xin (xin_stored)
wire [15:0] testbit_shift;    // Associated with testbit >> 1
wire comp_xin_sqtestsqrt;     // Indicates the logic result (represented by 1'b1 or 1'b0) of xin_stored >= testsqrt^2 (equals to sqtestsqrt)

// Store the operand that will be used to calculate the square root (register with FF type-D)
always @( posedge clock )           // Every time that is detected a rising edge relative to clock signal, this process is executed
begin
  if ( reset )                      // If reset high then...
    xin_stored <= 0;                // The reset is applied to the xin_stored register
  else                              // Else...
    if ( start )                    // If start...
      xin_stored <= xin;            // The value in xin is loaded to xin_stored
end

// Multiplier to generate the test result for the square root calculation of xin
assign sqtestsqrt = testsqrt * testsqrt;    // The result of testsqrt^2 is wired to sqtestsqrt

// Comparation between the operand xin and (test result)^2
assign comp_xin_sqtestsqrt = (xin_stored >= sqtestsqrt)? 1'b1 :    // Comparator >= -> TRUE
                                                         1'b0;     // Comparator >= -> FALSE

// Test bit generator
assign testbit_shift = (testbit >> 1);    // Discards the LSB of testbit

always @*                                 // COMBINATIONAL BLOCK - Multiplexer - This process is always "executed"
begin
  if ( start )                            // If start (-> is the select signal in the multiplexer)...
    testbit_mux = 16'h8000;               // testbit_mux holds the initial value for the algorithm relative to the testbit
  else                                    // Else...
    testbit_mux = testbit_shift;          // The multiplexer let it pass the iterations made on testbit (testbit>>1 at each iteration)
end

always @( posedge clock )                 // Every time that is detected a rising edge relative to clock signal, this process is executed
begin
  if ( reset )                            // If reset high then...
    testbit <= 0;                         // The reset is applied to the testbit register
  else                                    // Else...
    testbit <= testbit_mux;               // The value in testbit_mux is loaded to testbit
end

// Temporary end result generator (provisional value for the sqrt(xin))
always @*                             // COMBINATIONAL BLOCK - Multiplexer - This process is always "executed"
begin
  if ( comp_xin_sqtestsqrt )          // If comp_xin_sqtestsqrt (-> is the select signal in the multiplexer)...
    tempsqrt_mux1 = testsqrt;         // It means that the real sqrt value is closer to testsqrt
  else                                // Else...
    tempsqrt_mux1 = tempsqrt;         // It means that the real sqrt value is closer to tempsqrt
end

always @*                             // COMBINATIONAL BLOCK - Multiplexer - This process is always "executed"
begin
  if ( start )                        // If start (-> is the select signal in the multiplexer)...
    tempsqrt_mux2 = 0;                // tempsqrt_mux2 holds the initial value for the square root (due to still being unknown, is 0)
  else                                // Else...
    tempsqrt_mux2 = tempsqrt_mux1;    // The multiplexer let it pass the output of mux1
end

always @( posedge clock )         // Every time that is detected a rising edge relative to clock signal, this process is executed
begin
  if ( reset )                    // If reset high then...
    tempsqrt <= 0;                // The reset is applied to the tempsqrt register
  else                            // Else...
    tempsqrt <= tempsqrt_mux2;    // The value in tempsqrt_mux2 is loaded to tempsqrt
end

// Test of square root
assign testsqrt = (tempsqrt | testbit);    // Originates the test value to be comparated after some steps in each algorithm iteration

// Output relative to the sqrt(xin)
always @( posedge clock )    // Every time that is detected a rising edge relative to clock signal, this process is executed
begin
  if ( reset )               // If reset high then...
    sqrt <= 0;               // The reset is applied to the sqrt register
  else                       // Else...
    if ( stop )              // If stop...
      sqrt <= tempsqrt;      // The value in tempsqrt is loaded to sqrt (FINAL RESULT OF SQRT(xin))
end 

endmodule