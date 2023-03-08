`timescale 1ps/1ps
`include "FIR_Filter_Core.v"

module FIR_Filter_Core_TB();

    reg CLK = 0;
    always #5 CLK <= !CLK;

    reg areset_n = 1;
    reg en_FIR = 1;
    
    reg tap_Transfer = 0;
    reg [3:0] tap_Index = 0;
    reg [31:0] tap_Data = 0;

    reg [31:0] i_Data = 1;
    wire [63:0] o_Data;

    integer ii = 0;

    FIR_Filter_Core FIR_UUT(
        .CLK(CLK),
        .areset_n(areset_n),
        .en_FIR(en_FIR),
        .i_Data(i_Data),
        .tap_Transfer(tap_Transfer),
        .tap_Index(tap_Index),
        .tap_Value(tap_Data),
        .o_Data(o_Data)
    );

    task writeTap;
        input reg [3:0] i_tap_Index;
        input reg [31:0] i_tap_Data;
        begin
            tap_Transfer = 1;
            tap_Index = i_tap_Index;
            tap_Data = i_tap_Data;
            #15
            tap_Transfer = 0;
            tap_Index = 0;
            tap_Data = 0;
        end
    endtask

    task writeStimulus;
        input reg [31:0] data;
        begin
           #10
           i_Data = data; 
        end
    endtask

    initial begin

        $dumpfile("FIR_Filter.vcd");
        $dumpvars(0,CLK);
        $dumpvars(0,areset_n);
        $dumpvars(0,en_FIR);
        $dumpvars(0,tap_Transfer);
        $dumpvars(0,tap_Index);
        $dumpvars(0,tap_Data);
        $dumpvars(0,i_Data);
        $dumpvars(0,o_Data);
        
        #10 // Begin at 10 ps

        // Write Tap Values
        for(ii = 0; ii < 16; ii = ii + 1) begin
            writeTap(ii,32'hFFFF_FFFF);
        end

        writeStimulus(32'h0000_FFFF);
        writeStimulus(32'h0000_FFFF);
        writeStimulus(32'h0000_1111);
        writeStimulus(32'h000F_0000);
        writeStimulus(32'h0000_1111);
        writeStimulus(32'h0000_1111);
        writeStimulus(32'h0000_1111);
        writeStimulus(32'h0000_0000);
        writeStimulus(32'h000F_1111);
        writeStimulus(32'h0000_FFFF);
        writeStimulus(32'h0000_FFFF);
        writeStimulus(32'h0000_1111);
        writeStimulus(32'h000F_0000);
        writeStimulus(32'h0000_1111);
        writeStimulus(32'h0000_1111);
        writeStimulus(32'h0000_1111);
        writeStimulus(32'h0000_0000);
        writeStimulus(32'h000F_1111);
        writeStimulus(32'h0000_0000);
        writeStimulus(32'h000F_1111);
        #100

        $display("Simulation finished!");
        $finish;
        
    end

endmodule
