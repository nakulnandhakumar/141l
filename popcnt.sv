module popcnt (
    input logic [7:0] A,
    output logic [7:0] P
);

logic [7:0] popcnt_table [0:255];

initial begin
    for (int i = 0; i < 256; i++) begin
        popcnt_table[i] = i.countones();
    end
end

assign P = popcnt_table[A];

endmodule