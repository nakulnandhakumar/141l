module karatsuba_mult (
    input  logic [7:0] A,
    input  logic [7:0] B,
    output logic [15:0] P
);

// Lookup table for 4-bit multiplications
logic [7:0] mult_table [0:255];

// Initialize the lookup table
initial begin
    for (int i = 0; i < 16; i++) begin
        for (int j = 0; j < 16; j++) begin
            mult_table[{i[3:0], j[3:0]}] = i[3:0] * j[3:0];
        end
    end
end

// Split the multiplicands into high and low parts
logic [3:0] A_high, A_low, B_high, B_low;
assign A_high = A[7:4];
assign A_low  = A[3:0];
assign B_high = B[7:4];
assign B_low  = B[3:0];

// Perform the multiplications using the lookup table
logic [7:0] P_high, P_mid, P_low;
assign P_high = mult_table[{A_high, B_high}];
assign P_mid  = mult_table[{A_high, B_low}] + mult_table[{A_low, B_high}];
assign P_low  = mult_table[{A_low, B_low}];

// Combine the partial products
assign P = {P_high, 8'b0} + {P_mid, 4'b0} + P_low;

endmodule