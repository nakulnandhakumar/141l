module top_level(
  input clk, start,
  output logic done
);

// memory interface
logic wr_en;
logic [7:0] raddr, waddr, data_in;
logic [7:0] data_out;

logic [8:0] instr;

// program counter
logic[15:0] pg_ct = 0;
logic[7:0] karatsuba_out = 0;

// regs
logic [15:0][7:0] regs = 0;
logic [7:0] oper_reg = 0; // Operation register

typedef enum {first, second, third} oper_states;
oper_states state = first;

// instantiate submodules
// data memory -- fill in the connections
dat_mem dm1(
  .clk(clk),
  .write_en(wr_en),
  .raddr(raddr),
  .waddr(waddr),
  .data_in(data_in),
  .data_out(data_out)
);

instr_mem im1(
  .clk(clk),
  .raddr(pg_ct),
  .data_out(instr)
);
popcnt pc1(
  .A(reg[0]),
  .P(reg[2])
);
karatsuba_mult km1(
  .A(reg[0][3:0]),
  .B(reg[1][3:0]),
  .P(karatsuba_out)
);

always_ff @ (posedge clk) begin
  if (start) begin
    pg_ct <= 0;
    state <= first;
    done <= 0;
  end else begin
    case (state)
      first: begin
        if (instr[8] == 0) begin // Store operation in oper_reg
          oper_reg <= instr[7:0];
        end else begin // Execute operation in oper_reg with immediate value
          case (oper_reg)
            8'b0000_0000: //clear regs
              for (int i = 0; i < 16; i++) begin
                regs[i] <= 0;
              end
            8'b0000_0001: // add immediate
              regs[0] <= regs[0] + regs[1] + instr[7:0];
            8'b0000_0010: // sub immediate
              regs[0] <= regs[0] - regs[1] - instr[7:0];
            8'b0000_0011: // mult immediate
              regs[0] <= karatsuba_out;
            8'b0000_0100: // Negate reg[a] and store in reg[b]
              regs[instr[3:0]] <= -regs[instr[7:4]];
            8'b0000_0101: // store reg[a] to memory
              wr_en <= 1;
              waddr <= regs[instr[7:4]] + instr[3:0];
              state <= second;
            8'b0000_0110: // load reg[a] from memory to reg[b]
              wr_en <= 0;
              raddr <= regs[instr[7:4]];
              state <= second;
            8'b0000_0111: // mov reg[a] to reg[b]
              regs[instr[7:4]] <= regs[instr[3:0]];
            8'b0000_1000: // max reg[a] and reg[b] to reg[0]
              regs[0] <= max(regs[instr[7:4]], regs[instr[3:0]]);
            8'b0000_1001: // min reg[a] and reg[b] to reg[0]
              regs[0] <= min(regs[instr[7:4]], regs[instr[3:0]]);
            8'b0000_1010: // popcount reg[a] to reg[b]
              reg[2] <= 0;
              state <= third;
            8'b0000_1011: // conditional jump to reg0 if reg1 is greater than immediate
              if (regs[1] > instr[7:0]) begin
                pg_ct <= regs[0];
              end
            8'b0000_1100: // unconditional jump to reg0
              pg_ct <= regs[0] + instr[7:0];
            8'b0000_1101: // conditional jump to reg0 if reg[a] > reg[b]
              if (regs[instr[7:4]] > regs[instr[3:0]]) begin
                pg_ct <= regs[0];
              end
            8'b0000_1110: // unconditional jump to immediate
              pg_ct <= instr[7:0];
            8'b0000_1111: // halt
              done <= 1;
          endcase
        end
        pg_ct <= pg_ct + 1;
      end
      second: begin
        case (oper_reg)
          8'b0000_0111: begin 
            regs[instr[3:0]] = data_out; // load from memory
            state <= first;
          end
          8'b0000_1010: begin 
            regs[instr[3:0]] = popcnt_out; // popcount
            state <= first;
          end
        endcase
        wr_en <= 0; // Reset write enable
      end
      default: state <= first;
    endcase
  end
end

endmodule