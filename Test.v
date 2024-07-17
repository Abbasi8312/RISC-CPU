// Testbench for the CPU and Memory
module testbench;
    reg clk;                   // Clock signal
    wire [14:0] memory_in;     // Memory input connections
    wire [7:0] memory_out;     // Memory output connections

    // Memory instance
    memory_16_8bit memory (
        .data_out(memory_out),
        .data_in(memory_in[14:7]),
        .address(memory_in[6:3]),
        .ctrl(memory_in[2:0]),
        .clk(clk)
    );
 
    // CPU instance
    central_processing_unit cpu (
        .memory_out(memory_out),
        .memory_in(memory_in),
        .clk(clk)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #2 clk = ~clk;  // Toggle the clock every 2 nano seconds (4 nano second cycle)
    end
endmodule
