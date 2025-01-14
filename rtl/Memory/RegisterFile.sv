module RegisterFile #(
    parameter DATABITWIDTH = 16,
    parameter REGISTERCOUNT = 16,
    parameter REGADDRBITWIDTH = 4
)(
    input clk,
    input clk_en,
    input sync_rst,

    input                        Tag_Request,
    input  [REGADDRBITWIDTH-1:0] ReadA_Address,
    input                        ReadA_En,
    output    [DATABITWIDTH-1:0] ReadA_Data,

    input  [REGADDRBITWIDTH-1:0] ReadB_Address,
    input                        ReadB_En,
    output    [DATABITWIDTH-1:0] ReadB_Data,

    input  [REGADDRBITWIDTH-1:0] Mem_Write_Address,
    input                        Mem_Write_En,
    input     [DATABITWIDTH-1:0] Mem_Write_Data,

    input  [REGADDRBITWIDTH-1:0] Write_Address,
    input                        Write_En,
    input     [DATABITWIDTH-1:0] Write_Data,

    output RegistersSync,
    output RegisterStallIn
);

    // Write Decoder
    logic [REGISTERCOUNT-1:0] WriteDecodeVector;
    always_comb begin : WriteDecoder
        WriteDecodeVector = 0;
        WriteDecodeVector[Write_Address] = 1'b1;
    end

    // Mem Write Decoder
    logic [REGISTERCOUNT-1:0] MemWriteDecodeVector;
    always_comb begin : MemWriteDecoder
        MemWriteDecodeVector = 0;
        MemWriteDecodeVector[Mem_Write_Address] = 1'b1;
    end

    // Dirty Bit Decoder
    logic [REGISTERCOUNT-1:0] DirtyBitDecodeVector;
    always_comb begin : DirtyBitDecoder
        DirtyBitDecodeVector = 0;
        DirtyBitDecodeVector[ReadA_Address] = 1'b1;
    end

    // Register Generation
    wire  [DATABITWIDTH-1:0] DataOutVector [REGISTERCOUNT-1:0];
    wire                     DirtyBitOutVector [REGISTERCOUNT-1:0];
    generate
        genvar RegisterIndex;
        for (RegisterIndex = 0; RegisterIndex < REGISTERCOUNT; RegisterIndex = RegisterIndex + 1) begin : RegisterGeneration
            if (RegisterIndex == 0) begin
                assign DataOutVector[RegisterIndex] = 0;
            end
            else begin
                wire LocalDirtyBitSet = DirtyBitDecodeVector[RegisterIndex] && Tag_Request;
                wire LocalMemWriteEn = MemWriteDecodeVector[RegisterIndex] && Mem_Write_En;
                wire LocalWriteEn = WriteDecodeVector[RegisterIndex] && Write_En;
                RegisterFile_Cell RegisterCell (
                    .clk         (clk),
                    .clk_en      (clk_en),
                    .sync_rst    (sync_rst),
                    .Write_En    (LocalWriteEn),
                    .DataIn      (Write_Data),
                    .Dirty_Set   (LocalDirtyBitSet),
                    .Mem_Write_En(LocalMemWriteEn),
                    .Mem_DataIn  (Mem_Write_Data),
                    .DataOut     (DataOutVector[RegisterIndex]),
                    .DirtyBitOut (DirtyBitOutVector[RegisterIndex])
                );
            end
        end
    endgenerate

    // RegisterStallIn and Sync Generation
    wire   StallA = DirtyBitOutVector[ReadA_Address] && ReadA_En;
    wire   StallB = DirtyBitOutVector[ReadB_Address] && ReadB_En;
    assign RegistersSync = ~|DirtyBitOutVector[0];
    assign RegisterStallIn = StallA || StallB;

    // Read A decoder
    assign ReadA_Data = ReadA_En ? DataOutVector[ReadA_Address] : 0;
    
    // Read B decoder
    assign ReadB_Data = ReadB_En ? DataOutVector[ReadB_Address] : 0;

endmodule