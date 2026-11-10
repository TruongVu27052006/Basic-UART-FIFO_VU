module uart_rx #(
    parameter DATA_WIDTH = 8
) (
    input    logic clk,
    input    logic rst_n,
    input    logic uartrx_i,
    input    logic s_tick_i,
    output   logic [DATA_WIDTH-1 : 0] uartrx_o,
    output   logic rxdone_o
);

    localparam IDLE    = 2'b00;
    localparam START   = 2'b01;
    localparam DATA    = 2'b10;
    localparam STOP    = 2'b11;
    localparam SB_TICK = 16;    // 16 tick cho 1 stop bit 

    logic [3:0] scount, next_scount;                    // Bo dem 16 ticks lay mau 
    logic [$clog2(DATA_WIDTH) : 0] bcount, next_bcount; // Dem so bit da nhan 
    logic [DATA_WIDTH-1 : 0] b, next_b;                 // Thanh ghi dich du lieu 
    logic meta, rx;                                     // Dong bo 2 tang chong metastability
    logic [1:0] current_state, next_state;
    logic next_rxdone;

    assign uartrx_o = b;    // Xuat du lieu thang tu thanh ghi b --> uartrx_o

    //1. Logic chuyen trang thai (FSM)
    always_comb begin : proc_state 
        next_state  = current_state;
        next_scount = scount;
        next_bcount = bcount;
        next_rxdone = 1'b0;
        next_b      = b;

        case(current_state)
            IDLE : begin 
                if(rx == 1'b0) begin 
                    next_state    = START;
                    next_scount   = 4'd0;
                end 
            end

            START : begin 
                if(s_tick_i) begin 
                    if(scount == 4'd7) begin 
                        next_state   = DATA;
                        next_scount  = 4'd0;
                        next_bcount  = '0;
                    end
                    else begin 
                        next_scount  = scount + 4'd1;
                    end  
                end 
            end

            DATA : begin 
                if(s_tick_i) begin 
                    if(scount == 4'd15) begin 
                        next_scount = 4'd0;
                        next_b      = {rx, b[DATA_WIDTH-1 : 1]}; // Dich bit moi vao MSB
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
                if(s_tick_i) begin 
                    if(scount == SB_TICK - 1) begin 
                        next_rxdone  = 1'b1;
                        next_state   = IDLE;
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

    //2. Dong bo hoa hai tang chong metastability
    always_ff @(negedge rst_n or posedge clk) begin : proc_meta 
        if(!rst_n) begin 
            meta <= 1'b1;
            rx   <= 1'b1;
        end
        else begin 
            meta <= uartrx_i;
            rx   <= meta;
        end  
    end

    //3. Cap nhat thanh ghi trang thai 
    always_ff @(negedge rst_n or posedge clk) begin : proc_output 
        if(!rst_n) begin 
            current_state    <= IDLE;
            scount           <= 4'd0;
            bcount           <= '0;
            b                <= '0;
            rxdone_o         <= 1'b0;
        end
        else begin 
            current_state <= next_state;
            scount        <= next_scount;
            bcount        <= next_bcount;
            b             <= next_b;
            rxdone_o      <= next_rxdone;
        end  
    end 


endmodule

