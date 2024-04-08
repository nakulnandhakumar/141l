module ALU(
    input logic [7:0] A,
    input logic [7:0] B,
    input logic [1:0] ALU_op,
    output logic [15:0] P,
);

popcnt pc1(.A(A), .P(P));
case (ALU_op)
    2'b00: P = A + B;
    2'b01: P = -B;
    2'b10: P = A * B;
    default:;
endcase


endmodule