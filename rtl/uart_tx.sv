module uart_tx #(
    parameter DATA_WIDTH = 8
) (
    input logic clk,
    input logic rst_n,
    input logic [DATA_WIDTH-1 : 0] uarttx_i,    // Data nhan
    input logic s_tick_i,
    input logic txstart_i,  // Tin hieu bao co data truyen toi  
    output logic uarttx_o,  // Data xuat 
    output logic txdone_o   // Tin hieu bao da truyen xong 
);

    localparam IDLE    = 2'b00;
    localparam START   = 2'b01;
    localparam DATA    = 2'b10;
    localparam STOP    = 2'b11;
    localparam SB_TICK = 16;

    logic [3:0] scount, next_scount;
    logic [$clog2(DATA_WIDTH) : 0] bcount, next_bcount;
    logic [DATA_WIDTH-1 : 0] b, next_b;
    logic [1:0] current_state, next_state;
    logic next_txdone;
    logic tx_reg, next_tx;

    assign uarttx_o = tx_reg;

    //1. Logic chuyen trang thai (FSM)
    always_comb begin : proc_state
        next_state    = current_state;
        next_scount   = scount;
        next_bcount   = bcount;
        next_txdone   = 1'b0;
        next_b        = b;
        next_tx       = tx_reg;

        case(current_state)
            IDLE : begin 
                next_tx = 1'b1;
                if(txstart_i && !txdone_o) begin 
                    next_state   = START;
                    next_b       = uarttx_i;
                    next_scount  = 4'd0;
                end 
            end

            START : begin 
                next_tx = 1'b0;
                if(s_tick_i) begin 
                    if(scount == 4'd15) begin 
                        next_state   = DATA;
                        next_scount  = 4'd0;
                        next_bcount  = '0;
                    end
                    else begin 
                        next_scount = scount + 4'd1;
                    end  
                end
            end

            DATA : begin 
                next_tx = b[0];
                if(s_tick_i) begin 
                    if(scount == 4'd15) begin 
                        next_scount = 4'd0;
                        next_b      = {1'b0, b[DATA_WIDTH-1 : 1]};  // Dich phai, chen MSB = 0
                        if(bcount == DATA_WIDTH - 1) begin 
                            next_state = STOP;
                        end
                        else begin 
                            next_bcount = bcount + 1'b1;
                        end  
                    end
                    else begin 
                        next_scount = scount + 4'd1;
                    end  
                end 
            end

            STOP : begin 
                next_tx = 1'b1;
                if(s_tick_i) begin 
                    if(scount == SB_TICK - 1) begin 
                        next_state  = IDLE;
                        next_txdone = 1'b1;
                    end
                    else begin 
                        next_scount = scount + 4'd1;
                    end  
                end 
            end

            default : begin 
                next_state = IDLE;
            end      
        endcase 
    end

    //2. Cap nhat thanh ghi trang thai 
    always_ff @(negedge rst_n or posedge clk) begin 
        if(!rst_n) begin 
            current_state  <= IDLE;
            scount         <= 4'd0;
            bcount         <= '0;
            b              <= '0;
            txdone_o       <= 1'b0;
            tx_reg         <= 1'b1;
        end
        else begin 
            current_state <= next_state;
            scount         <= next_scount;
            bcount         <= next_bcount;
            b              <= next_b;
            txdone_o       <= next_txdone;
            tx_reg         <= next_tx;
        end  
    end  

endmodule
