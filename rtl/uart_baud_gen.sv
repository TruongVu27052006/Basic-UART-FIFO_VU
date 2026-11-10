module uart_baud_gen #(
    parameter BAUDTICK = 78
) (
    input logic clk,
    input logic rst_n,
    output logic s_tick_o
); 

    localparam BIT_WIDTH = $clog2(BAUDTICK);
    logic [BIT_WIDTH-1 : 0] count; // Khoi tao bo dem tick 
    assign s_tick_o = (count == BAUDTICK - 1);

    always_ff @(negedge rst_n or posedge clk) begin 
        if(!rst_n) begin 
            count <= '0;
        end 
        else begin 
            if(count == BAUDTICK - 1) begin 
                count <= '0;
            end
            else begin 
                count <= count + 1'b1;
            end  
        end 
    end 

endmodule
