module FIR_Filter_Core(
    input wire CLK,
    input wire areset_n,
    input wire en_FIR,
    input wire signed tap_Transfer,
    input wire signed [3:0] tap_Index,
    input wire signed [31:0] tap_Value,
    input wire signed [31:0] i_Data,
    output reg signed [63:0] o_Data
);

reg signed [31:0] tap [16:0];
reg signed [31:0] buffer [16:0];
reg signed [63:0] calc_Val [16:0];
reg signed [63:0] r_Data;

integer ii = 0;
integer jj = 0;
integer kk = 0;

localparam s_IDLE = 0;
localparam s_GET_TAP = 1;
localparam s_CLEAN = 2;

reg [2:0] r_SM_GetTap = s_IDLE;

// Get Tap values
always @(posedge CLK) begin
    
    if(~areset_n) begin
        for(ii = 0; ii < 16; ii = ii+1) begin
            tap[ii] = 0;
        end
    end else begin
        
        case(r_SM_GetTap)

            s_IDLE:
            begin
                if(~tap_Transfer) r_SM_GetTap <= s_IDLE;
                else r_SM_GetTap <= s_GET_TAP;
            end

            s_GET_TAP:
            begin
                if(~tap_Transfer) begin
                    r_SM_GetTap <= s_CLEAN;
                end else begin
                    tap[tap_Index] <= tap_Value;
                    r_SM_GetTap <= s_CLEAN;
                end
            end

            s_CLEAN:
            begin
                r_SM_GetTap <= s_IDLE;
            end
            
        endcase

    end

end

// Buffer Pipeline
always @(posedge CLK) begin
    buffer[0] <= i_Data;
    for(jj = 1; jj < 16; jj = jj + 1) begin
        buffer[jj] <= buffer[jj - 1];
    end
end

// FIR Filter
always @(posedge CLK) begin
    for(kk = 0; kk < 16; kk = kk + 1) begin
        calc_Val[kk] <= tap[kk] * buffer[kk];
    end
end 

// Accumulate Output
always @(posedge CLK) begin
    if(~en_FIR) begin
        o_Data <= i_Data;
    end else begin
        o_Data <= buffer[0] + buffer [1] + buffer[2] + buffer[3] + buffer[4] + buffer[5] + buffer[6] + buffer[7] + buffer[8] + buffer[9] + buffer[10] + buffer[11] + buffer[12] + buffer[13] + buffer[14] + buffer[15];
    end
end

endmodule