module ALU_Simple0 #(
    parameter BITWIDTH = 16
)(
    input  [BITWIDTH-1:0] Data_InA,
    input  [BITWIDTH-1:0] Data_InB,

    input                 ALU_Enable,
    input           [3:0] Opcode,

    output [BITWIDTH-1:0] ResultOut
);

    wire [BITWIDTH-1:0] ANDResult = Data_InA & Data_InB;
    wire [BITWIDTH-1:0] XORResult = Data_InA ^ Data_InB;
    wire [BITWIDTH-1:0] ORResult = Data_InA | Data_InB;

    logic [BITWIDTH-1:0] TempOutput;
    always_comb begin : ALU_Simple0_OperationSelectionMux
        case (Opcode)
            4'h1   : TempOutput = Data_InB + 1;        // Inc
            4'h2   : TempOutput = Data_InA - Data_InB; // Sub
            4'h3   : TempOutput = Data_InB - 1;        // Dec
            4'h4   : TempOutput = ANDResult;           // AND
            4'h5   : TempOutput = XORResult;           // XOR
            4'h6   : TempOutput = ORResult;            // OR
            4'h7   : TempOutput = Data_InB;            // Move
            4'h8   : TempOutput = 16'h0;               // // Reserved
            4'h9   : TempOutput = 16'h0;               // // Reserved
            4'hA   : TempOutput = 16'h0;               // // Reserved
            4'hB   : TempOutput = 16'h0;               // // Reserved
            4'hC   : TempOutput = ~ANDResult;          // NAND
            4'hD   : TempOutput = ~XORResult;          // XNOR
            4'hE   : TempOutput = ~ORResult;           // NOR
            4'hF   : TempOutput = ~Data_InB;           // NOT B
            default: TempOutput = Data_InA + Data_InB; // Add (Default is 4'h0)
        endcase
    end

    // Assign Output
    //assign ResultOut = ALU_Enable ? TempOutput : 0;
    assign ResultOut = TempOutput;

endmodule