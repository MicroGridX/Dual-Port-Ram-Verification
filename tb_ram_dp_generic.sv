`timescale 1ns/10ps

module ram_dp_tb;

    reg clk = 0;
    reg we = 0, re = 0;
    reg [7:0] wa = 0, ra = 0;
    reg [31:0] wd = 0;
    wire [31:0] rd;

    integer i;
    integer errors;
    reg [31:0] expected;

    always #5 clk = ~clk;

    ram_dp_generic #(
        .DataWidth(32),
        .DataDepth(256),
        .AddrWidth(8),
        .MaskEnable(0)
    ) dut (
        .write_clk(clk),
        .write_en(we),
        .write_addr(wa),
        .write_data(wd),
        .write_mask(32'b0),

        .read_clk(clk),
        .read_en(re),
        .read_addr(ra),
        .read_data(rd)
    );

    // Waveform
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, ram_dp_tb);
    end

    // -------------------------------
    // Basic Write
    // -------------------------------
    task write_memory(input [7:0] addr, input [31:0] data);
        begin
            @(negedge clk);
            we = 1;
            wa = addr;
            wd = data;

            @(posedge clk);
            #1;
            we = 0;
        end
    endtask

    // -------------------------------
    // Basic Read
    // -------------------------------
    task read_memory(input [7:0] addr);
        begin
            @(negedge clk);
            re = 1;
            ra = addr;

            @(posedge clk);
            #1;

            $display("Address = %0d, Data = %08h", addr, rd);

            re = 0;
        end
    endtask

    // -------------------------------
    // Main Test
    // -------------------------------
    initial begin

        // ---------------------------
        // 3.1 Basic Test
        // ---------------------------
        $display("\n===== BASIC TEST =====");

        write_memory(8'd5, 32'hDEADBEEF);
        read_memory(8'd5);

        write_memory(8'd10, 32'h12345678);
        read_memory(8'd10);

        // Different addresses
        @(negedge clk);
        we = 1;
        wa = 8'd20;
        wd = 32'hAAAA5555;

        re = 1;
        ra = 8'd5;

        @(posedge clk);
        #1;

        $display("Write Address = 20, Read Address = 5, Read Data = %08h",
                 rd);

        we = 0;
        re = 0;


        // ---------------------------
        // 3.2 Automatic Memory Test
        // ---------------------------
        $display("\n===== MEMORY TEST =====");

        errors = 0;

        // Write 0 to 255
        for (i = 0; i < 256; i = i + 1) begin
            write_memory(i, i);
        end

        // Read 0 to 255
        for (i = 0; i < 256; i = i + 1) begin

            @(negedge clk);
            re = 1;
            ra = i;

            @(posedge clk);
            #1;

            expected = i;

            if (rd != expected) begin
                errors = errors + 1;

                $display("ERROR: Address=%0d Expected=%08h Received=%08h",
                         i, expected, rd);
            end

            re = 0;
        end

        $display("--------------------------------");
        $display("MEMORY TEST COMPLETE");
        $display("Addresses tested : 256");
        $display("Errors : %0d", errors);

        if (errors == 0)
            $display("RESULT : PASS");
        else
            $display("RESULT : FAIL");

        $display("--------------------------------");


        // ---------------------------
        // 3.4 Fault Injection
        // ---------------------------
        $display("\n===== FAULT TEST =====");

        errors = 0;

        @(negedge clk);
        re = 1;
        ra = 8'd100;

        @(posedge clk);
        #1;

        // Deliberately wrong expected value
        expected = 32'd101;

        if (rd != expected) begin
            errors = errors + 1;
            $display("FAULT DETECTED: Address=100 Expected=%08h Received=%08h",
                     expected, rd);
        end

        re = 0;

        $display("Errors : %0d", errors);
        $display("RESULT : FAULT DETECTED");


        // ---------------------------
        // End
        // ---------------------------
        #20;
        $finish;

    end

endmodule
