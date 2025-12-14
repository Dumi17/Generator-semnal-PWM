module pwm_gen (
    input clk,
    input rst_n,
    input pwm_en,
    input[15:0] period,
    input[7:0] functions,
    input[15:0] compare1,
    input[15:0] compare2,
    input[15:0] count_val,
    output pwm_out
);

wire align_right = functions[0];
wire unaligned   = functions[1];

reg pwm_out_comb;

always @(*) begin
    if (!pwm_en) begin
        pwm_out_comb = 1'b0;
    end else if (unaligned) begin
        if (compare1 >= compare2) begin
            pwm_out_comb = 1'b0;
        end else if (count_val >= compare1 && count_val < compare2) begin
            pwm_out_comb = 1'b1;
        end else begin
            pwm_out_comb = 1'b0;
        end
    end else if (align_right) begin
        if (compare1 > period) begin
            pwm_out_comb = 1'b0;
        end else if (compare1 == compare2 && compare1 != 16'd0) begin
            pwm_out_comb = 1'b0;
        end else if (count_val >= compare1) begin
            pwm_out_comb = 1'b1;
        end else begin
            pwm_out_comb = 1'b0;
        end
    end else begin
        if (compare1 == 16'd0) begin
            pwm_out_comb = 1'b0;
        end else if (count_val <= compare1) begin
            pwm_out_comb = 1'b1;
        end else begin
            pwm_out_comb = 1'b0;
        end
    end
end

assign pwm_out = pwm_out_comb;

endmodule
