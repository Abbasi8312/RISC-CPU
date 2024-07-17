// Memory Module: 16x8-bit memory
module memory_16_8bit (
    output reg [7:0] data_out,   // Data output
    input [7:0] data_in,         // Data input
    input [3:0] address,         // Memory address
    input [1:0] ctrl,            // Control signals (ctrl[0] = read, ctrl[1] = write)
    input clk                    // Clock signal
);
    reg [7:0] mem_array [0:15];  // Memory array of 16x8-bit words

    // Initialize memory with instructions and data
    initial begin
        
        // Test Instructions
        // Instructions
        mem_array[4'b0000] = 8'b0100_1100; // Load:  AC = 4
        mem_array[4'b0001] = 8'b0000_1101; // Add:   DR = 6, AC = AC + DR = 10
        mem_array[4'b0010] = 8'b0101_1111; // Store: M[15] = 10
        mem_array[4'b0011] = 8'b0001_1111; // ASHL:  DR = 10, AC = DR * 2 = 20 = 0001_0100

        mem_array[4'b0100] = 8'b0010_1101; // XNOR:  DR = 6 = 0000_0110, AC = XNOR(AC, DR) = 1110_1101 = -19
        mem_array[4'b0101] = 8'b0101_1111; // Store: M[15] = -19
        mem_array[4'b0110] = 8'b0011_1111; // DIV:   DR = -19, AC = DR / 2 = -10 = 1111_0110
        mem_array[4'b0111] = 8'b0110_1100; // 2CMP:  DR = 4, AC = -DR = -4 = 1111_1100

        mem_array[4'b1000] = 8'b0000_0000;
        mem_array[4'b1001] = 8'b0000_0000;
        mem_array[4'b1010] = 8'b0000_0000;
        mem_array[4'b1011] = 8'b0000_0000;

        // Data
        mem_array[4'b1100] = 8'b0000_0100; // 4
        mem_array[4'b1101] = 8'b0000_0110; // 6
        mem_array[4'b1110] = 8'b0010_0000; // 32
        mem_array[4'b1111] = 8'b0000_0000;
        
        /*
        // Rounding up algorithm part one
        // Instructions
        mem_array[4'b0000] = 8'b0100_1110; // Load -1
        mem_array[4'b0001] = 8'b0000_1111; // Add -1 to the input
        mem_array[4'b0010] = 8'b0101_1111; // Store result

        // Data
        mem_array[4'b1110] = 8'b1111_1111; // -1
        mem_array[4'b1111] = 8'b0001_0010; // Input
        */
        /*
        // Rounding up algorithm part two (execute 7 times with last result as input)
        // Instructions
        mem_array[4'b0000] = 8'b0011_1111; // Shift right
        mem_array[4'b0001] = 8'b0101_1110; // Store shifted operand
        mem_array[4'b0010] = 8'b0000_1111; // Add operand to shifted operand
        mem_array[4'b0011] = 8'b0101_1101; // Store operand+shifted

        mem_array[4'b0100] = 8'b0100_1111; // Load operand
        mem_array[4'b0101] = 8'b0010_1110; // Xnor operand with shifted
        mem_array[4'b0110] = 8'b0010_1100; // Xnor result with 0
        mem_array[4'b0111] = 8'b0000_1101; // Add result to the previous Add result

        mem_array[4'b1000] = 8'b0101_1111; // Store result and replace original value
        mem_array[4'b1001] = 8'b0011_1111; // Shift right
        mem_array[4'b1010] = 8'b0101_1111; // Store shifted result and replace the previous value
        mem_array[4'b1011] = 8'b0000_0000;

        // Data
        mem_array[4'b1100] = 8'b0000_0000; // 0
        mem_array[4'b1101] = 8'b0000_0000; // Add result
        mem_array[4'b1110] = 8'b0000_0000; // Shifted operand
        mem_array[4'b1111] = 8'b0000_0000; // Input: Operand value from previous execution
        */
        /*
        // Rounding up algorithm part three
        // Instructions
        mem_array[4'b0000] = 8'b0100_1110; // Load 1
        mem_array[4'b0001] = 8'b0000_1111; // Add 1 to result of the previous part
        mem_array[4'b0010] = 8'b0101_1111; // Store result

        // Data
        mem_array[4'b1110] = 8'b0000_0001; // 1
        mem_array[4'b1111] = 8'b0000_0000; // Input: result from previous part
        */
    end

    // Read operation
    always @(*) if (ctrl[0]) data_out <= mem_array[address];

    // Write operation
    always @(posedge clk) if (ctrl[1]) mem_array[address] <= data_in;

endmodule

