module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4    // Chieu sau FIFO = 2^4 = 16 bytes
) (
    input logic clk,
    input logic rst_n,

    // Giao tiep Ghi (Write)
    input logic wr_en,
    input logic [DATA_WIDTH-1 : 0] wr_data_i,
    output logic full_o,

    // Giao tiep Doc (Read)
    input logic rd_en,
    output logic [DATA_WIDTH-1 : 0] rd_data_o,
    output logic empty_o
);

    //1. Khai bao mang nho 2 chieu 
    logic [DATA_WIDTH-1 : 0] mem [0 : (1 << ADDR_WIDTH) - 1];

    //2. Khai bao con tro va Counter 
    logic [ADDR_WIDTH-1 : 0] wr_ptr, next_wr_ptr;   // Con tro Ghi 
    logic [ADDR_WIDTH-1 : 0] rd_ptr, next_rd_ptr;   // Con tro Doc 
    logic [ADDR_WIDTH : 0] count, next_count;       // 16 bytes --> co 17 trang thai dem tu 0-16

    //3. Tinh toan trang thai Rong/Day
    assign empty_o = (count == '0);
    assign full_o  = (count == (1 << ADDR_WIDTH));

    // Co che FWFT
    assign rd_data_o = mem[rd_ptr];

    //4. Logic dieu khien Ghi/Doc 
    logic write_valid, read_valid;
    assign write_valid = wr_en & ~full_o;
    assign read_valid  = rd_en & ~empty_o;

    //5. Tinh toan gia tri ke tiep cho con tro va bo dem 
    always_comb begin : proc_pointers 
        next_wr_ptr = wr_ptr;
        next_rd_ptr = rd_ptr;
        next_count  = count;

        // Xu ly con tro Ghi 
        if(write_valid) begin 
            next_wr_ptr = wr_ptr + 1'b1;
        end

        // Xu ly con tro Doc 
        if(read_valid) begin 
            next_rd_ptr = rd_ptr + 1'b1;
        end  

        // Xu ly bo dem so luong phan tu 
        case({write_valid, read_valid})
            2'b10 : begin   // Chi Ghi  
                next_count = count + 1'b1;
            end

            2'b01 : begin   // Chi Doc 
                next_count = count - 1'b1;
            end

            // Khong lam gi ca 
            default : begin 
                next_count = count;
            end  
        endcase
    end

    //6. Cap nhat mang nho 
    always_ff @(posedge clk) begin : proc_memory
        if(write_valid) begin 
            mem[wr_ptr] <= wr_data_i;
        end 
    end

    //7. Cap nhat cac con tro va bo dem vao Filp-Flop 
    always_ff @(negedge rst_n or posedge clk) begin : proc_register
        if(!rst_n) begin 
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
        end
        else begin 
            wr_ptr <= next_wr_ptr;
            rd_ptr <= next_rd_ptr;
            count  <= next_count;
        end  
    end 

endmodule

