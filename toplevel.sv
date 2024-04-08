module top_level(
  input          clk, start, 
  output logic   done);

// memory interface
  logic          wr_en;
  logic    [7:0] raddr, 
                 waddr,
                 data_in;
  logic    [7:0] data_out;
  logic         on_pre;
  logic[5:0] pre_length = 0;
  logic    [10:0] instr;   

// program counter
  logic[15:0] pg_ct = 0;
  
// regs
logic       [7:0] reg0 = 0, reg1 = 0;
typedef enum {first, second, third} oper_states;
oper_states state = first;

// instantiate submodules
// data memory -- fill in the connections
  dat_mem dm1(.clk(clk),
              .write_en(wr_en),
              .raddr(raddr),
              .waddr(waddr),
              .data_in(data_in),
              .data_out(data_out));

  instr_mem im1(.clk(clk),
                .raddr(pg_ct),
                .data_out(instr));

    always_ff @ (posedge clk) begin:
        if (start) begin
            pg_ct <= 0;
            state <= first;
            done <= 0;
        end
        else
          if (state == first)
            pg_ct <= pg_ct + 1;
        
        case(instr&10'b1110000000)
          10'b1000000000: begin
            if(oper_states == first) begin:
              raddr <= instr&10'b0001111111;
              oper_states <= second;
            end
            else begin:
              reg1 <= data_out;
              reg0 <= reg0 + reg1;
              oper_states <= first;
            end
          end
          10'b1010000000: begin
            if(oper_states == first) begin:
              raddr <= instr&10'b0001111111;
              oper_states <= second;
            end
            else begin:
              reg1 <= data_out;
              reg0 <= reg0 & reg1;
              oper_states <= first;
            end
          end
          10'b1100000000: begin
            reg0 <= -reg0;
          end
          10'b1110000000: begin
            if(oper_states == first) begin:
              raddr <= instr&10'b0001111111;
              oper_states <= second;
            end
            else begin:
              reg1 <= data_out;
              reg0 <= reg0 ^ reg1;
              oper_states <= first;
            end
          end
          10'b0000000000: begin
            if(oper_states == first) begin:
              raddr <= instr&10'b0001111111;
              oper_states <= second;
            end
            else begin:
              reg1 <= data_out;
              reg0 <= popcnt(reg1);
              oper_states <= first;
            end
          end
          10'b0010000000: begin
            if(oper_states == first) begin:
              raddr <= instr&10'b0001111111;
              oper_states <= second;
            end
            else begin:
              reg0 <= data_out;
              oper_states <= first;
            end
          end
          10'b0100000000: begin
            waddr <= reg0;
            oper_states <= second;
          end
          10'b0110000000: begin
            if(oper_states == first) begin:
              raddr <= instr&10'b0001111111;
              oper_states <= second;
            end
            else if (oper_states == second) begin:
              reg1 <= data_out;
              raddr <= instr&10'b0001111111 + 1;
              oper_states <= third;
            end
            else begin:
              pg_ct <= {reg1, data_out};
              oper_states <= first;
            end
          end
    end
              
              
endmodule