module popcnt (
    input clk,
    input logic start,
    input logic [7:0] A,
    output logic [7:0] P,
    output logic done,
);

logic [7:0] out;
logic [7:0] cnt;

always_ff @ (posedge clk) begin
    if (start) begin
        cnt <= 0;
        out <= 0;
        done <= 0;
    end else begin
        if (cnt == 8) begin
            assign P = out;
            assign done = 1;
        end else begin
            out <= out + A[cnt];
        end
    end
end

endmodule