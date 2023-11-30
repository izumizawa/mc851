module l1_cache #(
    parameter INDEX_WIDTH = 6
) (
    input  wire         clk,
    input  wire         reset_n,
    input  wire         write_enable,
    input  wire         read_enable,
    input  wire [31:0]  address,
    input  wire [31:0]  data_in,
    output wire [31:0]  data_out,
    output reg          cache_ready,

    // Memory Interface
    input  wire         mem_ready,
    output reg          mem_fetch,
    output reg          mem_write
);
    localparam OFFSET_WIDTH     = 2;
    localparam TAG_WIDTH        = 32 - (INDEX_WIDTH + OFFSET_WIDTH);
    localparam NUM_OF_BLOCKS    = 2**INDEX_WIDTH;

    // TODO: Implementar memória de cache com duas B-SRAMs Single-Port (flags+tag e dados)
    reg block_valid [0:NUM_OF_BLOCKS-1];
    reg block_dirty [0:NUM_OF_BLOCKS-1];
    reg [TAG_WIDTH-1:0] tag_array [0:NUM_OF_BLOCKS-1];
    reg [31:0] block_data [0:NUM_OF_BLOCKS-1];

    initial begin: label0
        integer i;
        for (i = 0; i < NUM_OF_BLOCKS; i = i + 1) begin
            block_valid[i] = 0;
            block_dirty[i] = 0;
            tag_array[i] = 0;
            block_data[i] = 0;
        end
    end

    wire [TAG_WIDTH-1:0]    tag;
    wire [INDEX_WIDTH-1:0]  index;
    wire [OFFSET_WIDTH-1:0] offset;
    wire cache_hit;

    assign tag       = address[31:INDEX_WIDTH+OFFSET_WIDTH];
    assign index     = address[INDEX_WIDTH+OFFSET_WIDTH-1 : OFFSET_WIDTH];
    assign offset    = address[OFFSET_WIDTH-1:0];

    // Cache Controller State Machine
    localparam ACCEPT_REQUEST   = 2'd0;
    localparam WRITE_BACK       = 2'd1;
    localparam MEM_ALLOCATE     = 2'd2;

    reg [1:0] ctrl_state = ACCEPT_REQUEST;

    assign cache_hit = block_valid[index] && tag_array[index] == tag;
    assign data_out = read_enable ? block_data[index] : 0;

    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            ctrl_state <= ACCEPT_REQUEST;
        end else begin
            case (ctrl_state)
                ACCEPT_REQUEST: begin
                    if (!cache_hit && block_dirty[index]) begin
                        ctrl_state <= WRITE_BACK;
                    end else if (!cache_hit && !block_dirty[index]) begin
                        ctrl_state <= MEM_ALLOCATE;
                    end else begin
                        block_valid[index] <= 1;
                        tag_array[index] <= tag;

                        if (write_enable) begin
                            block_dirty[index] <= 1;
                            block_data[index] <= data_in;
                        end
                    end
                end

                WRITE_BACK: begin
                    if (mem_ready) begin
                        ctrl_state <= MEM_ALLOCATE;
                    end
                end

                MEM_ALLOCATE: begin
                    if (mem_ready) begin
                        block_valid[index] <= 1;
                        block_dirty[index] <= 0;
                        tag_array[index] <= tag;
                        block_data[index] <= data_in;

                        ctrl_state <= ACCEPT_REQUEST;
                    end
                end

                default: begin
                    ctrl_state <= ACCEPT_REQUEST;
                end
            endcase
        end
    end

    always @(*) begin
        cache_ready = 0;
        mem_fetch = 0;
        mem_write = 0;

        case (ctrl_state)
            ACCEPT_REQUEST: begin
                cache_ready = 1;
            end

            WRITE_BACK: begin
                mem_write = 1;
            end

            MEM_ALLOCATE: begin
                mem_fetch = 1;
            end

            default: ;
        endcase
    end
endmodule
