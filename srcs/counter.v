module counter (
    input clk,
    input rst_n,
    output[15:0] count_val,
    input[15:0] period,
    input en,
    input count_reset,
    input upnotdown,
    input[7:0] prescale
);

reg [15:0] counter_reg;

reg [7:0] prescale_cnt;

wire [7:0] prescale_threshold = (1 << prescale) - 1;

wire prescale_tick = (prescale_cnt == prescale_threshold);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_reg <= 16'd0;
        prescale_cnt <= 8'd0;
    end else if (count_reset) begin
        counter_reg <= 16'd0;
        prescale_cnt <= 8'd0;
    end else if (en) begin
        if (prescale_tick) begin
            prescale_cnt <= 8'd0;
            
            if (upnotdown) begin
                if (counter_reg >= period) begin
                    counter_reg <= 16'd0;
                end else begin
                    counter_reg <= counter_reg + 1'b1;
                end
            end else begin
                if (counter_reg == 16'd0) begin
                    counter_reg <= period;
                end else begin
                    counter_reg <= counter_reg - 1'b1;
                end
            end
        end else begin
            prescale_cnt <= prescale_cnt + 1'b1;
        end
    end
end

assign count_val = counter_reg;

endmodule
