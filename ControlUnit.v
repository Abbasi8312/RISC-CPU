// Control Unit: Generates control signals for registers, memory and bus based on the instruction and Sequence Counter
module control_unit (
    output [23:0] reg_mem_ctrl, // Control signals for registers and memory
    output [2:0] bus_ctrl,      // Control signals for the bus
    input [3:0] instruction,    // Instruction opcode input
    input clk                   // Clock signal
);
    wire [7:0] t;               // Sequence counter decoded outputs
    wire sc_rst;                // Sequence counter reset signal

    // Sequence Counter
    sequence_counter sc (
        .t(t),
        .clk(clk),
        .clr(sc_rst)
    );

    // Memory direct/indirect access
    wire i;
    assign i = instruction[3];

    // Decoded instruction opcode
    wire [7:0] d;
    decoder dec (
        .out(d),
        .in(instruction)
    );

    // Decoded bus control
    wire [7:0] x;
    // Encoder to generate bus multiplexer control signals
    encoder bus_enc (
        .out(bus_ctrl),
        .in(x)
    );

    // Registers and memory control signals assignment
    // -
    assign reg_mem_ctrl[0] = 0;            // Nothing
    assign reg_mem_ctrl[1] = 0;            // Nothing
    assign reg_mem_ctrl[2] = 0;            // Nothing

    // AR: Address Register
    assign reg_mem_ctrl[3] = t[0] | t[2] | (i & t[3]); // Load
    assign reg_mem_ctrl[4] = 0;            // Increment
    assign reg_mem_ctrl[5] = 0;            // Clear

    // PC: Program Counter
    assign reg_mem_ctrl[6] = 0;            // Load
    assign reg_mem_ctrl[7] = t[1];         // Increment
    assign reg_mem_ctrl[8] = 0;            // Clear

    // DR: Data Register
    assign reg_mem_ctrl[9] = (d[0] | d[1] | d[2] | d[3] | d[4] | d[6]) & t[4]; // Load
    assign reg_mem_ctrl[10] = 0;           // Increment
    assign reg_mem_ctrl[11] = 0;           // Clear

    // AC: Accumulator
    assign reg_mem_ctrl[12] = (d[0] | d[1] | d[2] | d[3] | d[4] | d[6]) & t[5]; // Load
    assign reg_mem_ctrl[13] = 0;           // Increment
    assign reg_mem_ctrl[14] = 0;           // Clear

    // IR: Instruction Register
    assign reg_mem_ctrl[15] = t[1];        // Load
    assign reg_mem_ctrl[16] = 0;           // Nothing
    assign reg_mem_ctrl[17] = 0;           // Nothing

    // TR: Temporary Register
    assign reg_mem_ctrl[18] = 0;           // Load
    assign reg_mem_ctrl[19] = 0;           // Increment
    assign reg_mem_ctrl[20] = 0;           // Clear

    // Memory control signals
    assign reg_mem_ctrl[21] = t[1] | (i & t[3]) | ((d[0] | d[1] | d[2] | d[3] | d[4] | d[6]) & t[4]); // Read
    assign reg_mem_ctrl[22] = d[5] & t[4]; // Write
    assign reg_mem_ctrl[23] = 0;           // Nothing

    // Bus control signals
    assign x[0] = 0;                       // -
    assign x[1] = 0;                       // AR
    assign x[2] = t[0];                    // PC
    assign x[3] = d[4] & t[5];             // DR
    assign x[4] = d[5] & t[4];             // AC
    assign x[5] = t[2];                    // IR
    assign x[6] = 0;                       // TR
    assign x[7] = t[1] | (i & t[3]) | ((d[0] | d[1] | d[2] | d[3] | d[4] | d[6]) & t[4]); // Memory

    // Sequence counter reset
    assign sc_rst = ((d[0] | d[1] | d[2] | d[3] | d[4] | d[6]) & t[5]) | (d[5] & t[4]);

endmodule

// Sequence Counter: Generates sequence timing signals
module sequence_counter (
    output [7:0] t,  // Timing signals
    input clk,       // Clock signal
    input clr        // Clear signal
);
    wire [2:0] count;

    // Counter instance
    counter cnt (
        .count(count),
        .clk(clk),
        .clr(clr)
    );

    // Decoder instance
    decoder sc_dec (
        .out(t),
        .in(count)
    );

endmodule

// Counter: 3-bit counter with synchronous clear
module counter (
    output reg [2:0] count, // Counter value
    input clk,              // Clock signal
    input clr               // Clear signal
);
    initial count = 0;

    always @(posedge clk) begin
        if (clr) 
            count <= 3'b000;    // Reset counter
        else 
            count <= count + 1; // Increment counter
    end
endmodule

// Decoder: Decodes a 3-bit input into an 8-bit output
module decoder (
    output reg [7:0] out, // 8-bit decoded output
    input [2:0] in        // 3-bit input
);
    initial out = 0;

    always @(*) begin
        case (in)
            3'b000: out <= 8'b00000001;
            3'b001: out <= 8'b00000010;
            3'b010: out <= 8'b00000100;
            3'b011: out <= 8'b00001000;
            3'b100: out <= 8'b00010000;
            3'b101: out <= 8'b00100000;
            3'b110: out <= 8'b01000000;
            3'b111: out <= 8'b10000000;
            default: out <= 8'b00000000;
        endcase
    end
endmodule

// Encoder: Encodes an 8-bit input into a 3-bit output
module encoder (
    output reg [2:0] out, // 3-bit encoded output
    input [7:0] in        // 8-bit input
);
    initial out = 0;

    always @(*) begin
        case (in)
            8'b00000001: out = 3'b000;
            8'b00000010: out = 3'b001;
            8'b00000100: out = 3'b010;
            8'b00001000: out = 3'b011;
            8'b00010000: out = 3'b100;
            8'b00100000: out = 3'b101;
            8'b01000000: out = 3'b110;
            8'b10000000: out = 3'b111;
            default:     out = 3'b000;
        endcase
    end
endmodule
