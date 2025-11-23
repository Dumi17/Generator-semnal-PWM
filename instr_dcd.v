module instr_dcd (
    // peripheral clock signals
    input clk,
    input rst_n,
    // towards SPI slave interface signals
    input byte_sync,
    input [7:0] data_in,
    output [7:0] data_out,
    // register access signals
    output read,
    output write,
    output [5:0] addr,
    input [7:0] data_read,
    output [7:0] data_write
);

    localparam ST_SETUP = 1'b0;
    localparam ST_DATA = 1'b1;

    reg state;

    reg curr_rw;      
    reg [5:0] addr_reg;
    reg [7:0] data_out_reg;
    reg [7:0] data_write_reg;
    reg read_reg;
    reg write_reg;

    assign data_out = data_out_reg;
    assign data_write = data_write_reg;
    assign read = read_reg;
    assign write = write_reg;
    assign addr = addr_reg;

    function is_16b_reg;
        input [5:0] a;
        begin
            is_16b_reg = (a == 6'h00) || (a == 6'h03) || 
                         (a == 6'h05) || (a == 6'h08); 
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_SETUP;
            curr_rw <= 1'b0;
            addr_reg <= 6'h00;
            data_out_reg <= 8'h00;
            data_write_reg <= 8'h00;
            read_reg <= 1'b0;
            write_reg <= 1'b0;
        end else begin
            read_reg <= 1'b0;
            write_reg <= 1'b0;

            if (byte_sync) begin
                case (state)
                    ST_SETUP: begin
                        curr_rw <= data_in[7];

                        if (is_16b_reg(data_in[5:0])) begin
                            addr_reg <= data_in[5:0] + (data_in[6] ? 6'd1 : 6'd0);
                        end else begin
                            addr_reg <= data_in[5:0];
                        end

                        if (data_in[7] == 1'b0) begin
                            read_reg <= 1'b1;
                        end

                        state <= ST_DATA;
                    end

                    ST_DATA: begin
                        if (curr_rw) begin
                            data_write_reg <= data_in;
                            write_reg      <= 1'b1;
                            data_out_reg   <= 8'h00;  
                        end else begin
                            data_out_reg <= data_read;
                        end

                        state <= ST_SETUP;
                    end
                endcase
            end
        end
    end

endmodule
