module RV32I

#(parameter width = 32)
(
	input  logic CLK,
	input  logic reset_,
	input  logic [width-1:0] instruction,
	output logic [width-1:0] PC,

	output logic [width-1:0] address,
	output logic [width-1:0] store,
	input  logic [width-1:0] load

);

initial address = 0;
initial store = 0;

	//32 cpu registers
	//this is a 32x32 block of memory
	logic [width - 1:0][width - 1:0] x;

	/*
		reg		ABI/Alias		Description					saved
		x0 		zero 			hard wired zero
		x1		ra				return address
		x2		sp				stack pointer				yes
		x3		gp				global pointer
		x4		tp				thread pointer
		x5		t0				temp/alt link register
		x6-7	t1-2			temporaries
		x8		s0/fp			saved reg/frame pointer		yes
		x9		s1				saved register				yes
		x10-11	a0-1			function args/return value
		x12-17	a2-7			function args
		x18-27	s2-11			saved registers				yes
		x28-31	t3-6			temporaries
	*/






localparam JAL 			= 7'b1101111;
localparam JALR 		= 7'b1100111;

localparam icode 		= 7'b0010011;
localparam rcode 		= 7'b0110011;
localparam bcode 		= 7'b1100011;
localparam LUIcode 		= 7'b0110111;
localparam AUIPCcode	= 7'b0010111;
localparam LOAD			= 7'b0000011;
localparam STORE		= 7'b0100011;


localparam BEQ  		= 3'b000;
localparam BNE  		= 3'b001;
localparam BLT  		= 3'b100;
localparam BGE  		= 3'b101;
localparam BLTU 		= 3'b110;
localparam BGEU 		= 3'b111;
	
localparam ADDSUB 		= 3'b000;
localparam SLL			= 3'b001;
localparam SLT			= 3'b010;
localparam SLTU			= 3'b011;
localparam XOR			= 3'b100;
localparam SRLSRA		= 3'b101;
localparam OR			= 3'b110;
localparam AND			= 3'b111;
	
localparam ADDI			= 3'b000;
localparam SLLI			= 3'b001;
localparam SLTI			= 3'b010;
localparam SLTIU		= 3'b011;
localparam XORI			= 3'b100;
localparam SRLISRAI		= 3'b101;
localparam ORI			= 3'b110;
localparam ANDI			= 3'b111;
	
localparam LB			= 3'b000;
localparam LH			= 3'b001;
localparam LW			= 3'b010;
localparam LBU			= 3'b100;
localparam LHU			= 3'b101;
	
localparam SB			= 3'b000;
localparam SH			= 3'b001;
localparam SW			= 3'b010;


wire [2:0] func3;
assign func3 = instruction[14:12];

wire [31:0] imm_b;
assign imm_b = { {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; 

wire [31:0] imm_j;
assign imm_j = { {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};

wire [31:0] imm_i;
assign imm_i = { {20{instruction[31]}}, instruction[31:20]};

wire [31:0] imm_u;
assign imm_u = {instruction[31:12], 12'b0};

wire [6:0] opcode;
assign opcode = instruction[6:0];

//wire [6:0] func7;
wire b30;
assign b30 = instruction[30];

wire [4:0] shamt_i;
assign shamt_i = instruction[24:20];

wire [4:0] rd;
assign rd = instruction[11:7];

wire [4:0] rs1;
assign rs1 = instruction[19:15];

wire [4:0] rs2;
assign rs2 = instruction[24:20];


	//writes to x0 should be discarded, meaning it is allowed... so I should simply overwrite x0	
	always_ff @ (negedge CLK) x[0] <= 0;


	always_ff @ (posedge CLK or negedge reset_) begin

		if(!reset_) begin
		
			$display("reset");
			PC <= 0;
			x <= {32{1'b0}};

		end else begin case(opcode)

			default:
				PC <= PC + 4;
			
			LOAD:
			begin
				$display("Store instruction");
				PC <= PC + 4;
				//	case( func3 )
				//	LB:		x[rd]	=	
				//  LH:		x[rd]	=	
				//  LW:		x[rd]	=	
				//  LBU:	x[rd]	=	
				//  LHU:	x[rd]	=	
				//	default:
				//	endcase
			end

            STORE:
			begin
				$display("Store instruction");
				PC <= PC + 4;
				//	case( func3 )
				//	SB:		
				//  SH:		
				//  SW:		
				//	default:
				//	endcase
			end

			LUIcode: //LUI
			begin
				$display("LUI instruction");
				PC 		<= PC + 4;
				x[rd] 	<= imm_u;
			end
			//these could be factored together. but lets not.
			//x[rd] 	<= imm_u + (condition) ? PC : 0;
            AUIPCcode: //AUIPC
			begin
				$display("AUIPC instruction");
				PC 		<= PC + 4;
				x[rd] 	<= PC + imm_u;
			end


			JAL: //JAL
			begin
				$display("JAL instruction");
				x[rd] 	<= PC + 4;
				PC 		<= PC + imm_j;
			end

			JALR: //JALR
			begin
				$display("JALR instruction");
				x[rd] 	<= PC + 4;
				PC 		<= PC + imm_j;
			end

			rcode: //rd, rs1, rs2
			begin
				PC <= PC + 4;

				$display("R-Type instruction");
				case( func3 )
						
					ADDSUB:	x[rd] <= ( 	b30 )  	? 		x[rs1] - x[rs2] : x[rs1] + x[rs2];
					SLL:	x[rd] <= 	x[rs1]  << ( 	x[rs2] % 32 );
					SLT:	x[rd] <= ( 	x[rs1] 	< 		x[rs2] ) ? 1 : 0;
					SLTU:	x[rd] <= ( 	x[rs1] 	< 		x[rs2] ) ? 1 : 0;
					XOR:	x[rd] <= 	x[rs1]  ^ 		x[rs2];
					SRLSRA:	x[rd] <= ( 	b30 )  	? 		x[rs1] >>> ( x[rs2] % 32 ) : x[rs1] >> ( x[rs2] % 32 );
					OR:		x[rd] <= 	x[rs1]  | 		x[rs2];
					AND:	x[rd] <= 	x[rs1]  & 		x[rs2];
	
				endcase

				x[0] <= 0;

			end

			icode: //immediates
			begin
				PC <= PC + 4;

				$display("I-Type instruction");

				case( func3 )
					//what about the carry/borrow bit?!
					ADDI:		x[rd] <=   x[rs1] +  imm_i;
					SLLI:       x[rd] <=   x[rs1] << shamt_i;
					SLTI:       x[rd] <= ( x[rs1] <  imm_i ) ? 1 : 0;
					SLTIU:      x[rd] <= ( x[rs1] <  imm_i ) ? 1 : 0;
					XORI:       x[rd] <=   x[rs1] ^  imm_i;
					SRLISRAI:   x[rd] <= ( b30 )  ?  x[rs1] >>> shamt_i: x[rs1] >> shamt_i;
					ORI:        x[rd] <=   x[rs1] |  imm_i;
					ANDI:       x[rd] <=   x[rs1] &  imm_i;

				endcase

				x[0] <= 0;

			end

			bcode: //branch, only modifies PC
			begin
				$display("B-Type instruction");
				case( func3 )
	
					BEQ:	 PC <= PC + (( rs1 == rs2 ) ? imm_b : 4);
					BNE:	 PC <= PC + (( rs1 != rs2 ) ? imm_b : 4);
					BLT:	 PC <= PC + (( rs1 <  rs2 ) ? imm_b : 4);
					BGE:	 PC <= PC + (( rs1 >= rs2 ) ? imm_b : 4);
					BLTU:	 PC <= PC + (( rs1 <  rs2 ) ? imm_b : 4);		/* supposed to be unsigned */
					BGEU: 	 PC <= PC + (( rs1 >= rs2 ) ? imm_b : 4);		/* supposed to be unsigned */
					default: PC <= PC + 4; //? // this should never run.
	
				endcase

			end

		endcase	//case(opcode)

		end

	end	//always_ff

endmodule




