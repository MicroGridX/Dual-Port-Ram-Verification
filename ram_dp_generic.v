// Code your design here
`timescale 1ns/10ps

/*
 * Dual-port RAM with asynchronous clocks.
 * Port A used for writing, Port B used for reading.
 */
module ram_dp_generic #(
    parameter DataWidth = 32,
    parameter DataDepth = 256,
    parameter AddrWidth = 8,
    parameter MaskEnable = 0,
    parameter InitFile = "",
    parameter InitValue = 0,
    parameter InitCount = 0
) (
    // Write Port (Port A)
    input wire write_clk,
    input wire write_en,
    input wire [AddrWidth-1:0] write_addr,
    input wire [DataWidth-1:0] write_data,
    input wire [DataWidth-1:0] write_mask,

    // Read Port (Port B)
    input wire read_clk,
    input wire read_en,
    input wire [AddrWidth-1:0] read_addr,
    output reg [DataWidth-1:0] read_data
);

    // Memory array declaration
    reg [DataWidth-1:0] mem [0:DataDepth-1];

    // Initialization block
    generate
        if(InitCount > 0) begin
            integer i;
            initial begin
                if(InitFile != "") begin
                    $readmemh(InitFile, mem, 0, InitCount-1);
                end else begin
                    for(i = 0; i < InitCount && i < DataDepth; i = i + 1)
                        mem[i] = InitValue[DataWidth-1:0];
                end
                read_data <= mem[0];
            end
        end
    endgenerate

    // Write port logic
    generate
        if(MaskEnable == 0) begin
            always @(posedge write_clk) begin
                if(write_en == 1'b1) mem[write_addr] <= write_data;
            end
        end else begin 
            always @(posedge write_clk) begin
                if(write_en == 1'b1) begin
                    mem[write_addr] <= (mem[write_addr] & write_mask) | (write_data & ~write_mask);
                end
            end
        end
    endgenerate

    // Read port logic
    always @(posedge read_clk) begin
        if(read_en == 1'b1) read_data <= mem[read_addr];
    end

endmodule
