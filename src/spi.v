module spi(
    input                           clk,  
    input                           rst_n,
    input                           sclk, 
    input                           cs_n, 
    input                           copi, 

    output reg [7:0]                en_reg_out_7_0,   
    output reg [7:0]                en_reg_out_15_8,  
    output reg [7:0]                en_reg_pwm_7_0,   
    output reg [7:0]                en_reg_pwm_15_8,  
    output reg [7:0]                pwm_duty_cycle
);
    reg [15:0]                      shift_reg;
    reg [4:0]                       count;

    reg                             sclk_s1, sclk_s2, sclk_s2_prev;
    reg                             cs_n_s1, cs_n_s2, cs_n_prev;
    reg                             copi_s1, copi_s2;

    wire                            valid = (shift_reg[15] == 1'b1) && (shift_reg[14:8] <= 7'h04) && (count == 5'd16);
    wire                            sclk_posedge = (sclk_s2 == 1) && (sclk_s2_prev == 0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            en_reg_out_7_0  <= 8'h00;
            en_reg_out_15_8 <= 8'h00;
            en_reg_pwm_7_0  <= 8'h00;
            en_reg_pwm_15_8 <= 8'h00;
            pwm_duty_cycle  <= 8'h00;
            shift_reg       <= 16'b0;
            count           <= 5'b0;


            sclk_s1         <= 0; 
            sclk_s2         <= 0;
            sclk_s2_prev    <= 0;
            cs_n_s1         <= 1; 
            cs_n_s2         <= 1;
            cs_n_prev       <= 1;
            copi_s1         <= 0; 
            copi_s2         <= 0;
        end

        else begin
            sclk_s1      <= sclk; 
            sclk_s2      <= sclk_s1;
            sclk_s2_prev <= sclk_s2;
            cs_n_s1      <= cs_n; 
            cs_n_s2      <= cs_n_s1;
            cs_n_prev    <= cs_n_s2;
            copi_s1      <= copi; 
            copi_s2      <= copi_s1;
        
            if (cs_n_s2 == 1'b0 && sclk_posedge) begin
                shift_reg <= {shift_reg[14:0], copi_s2};
                count     <= count + 5'b1;
            end


            else if (cs_n_s2 == 1'b1 && cs_n_prev == 1'b0) begin
                if (valid) begin
                    case (shift_reg[14:8])
                        7'h00: en_reg_out_7_0   <= shift_reg[7:0];
                        7'h01: en_reg_out_15_8  <= shift_reg[7:0];
                        7'h02: en_reg_pwm_7_0   <= shift_reg[7:0];
                        7'h03: en_reg_pwm_15_8  <= shift_reg[7:0];
                        7'h04: pwm_duty_cycle   <= shift_reg[7:0];
                        default: ;
                    endcase
                end
                
                shift_reg <= 16'b0;
                count     <= 5'b0;
            end
        end
    end

endmodule