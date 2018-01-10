// Part 2 skeleton

module plotDots (
  CLOCK_50, resetn, plot_colour, plot_x, plot_y, dot_plot_en, dots_done
  // The ports below are for the VGA output.  Do not change.

 );


 

 input CLOCK_50;

 
 
 wire resetn;
 assign resetn = KEY[0];


 wire clk;
 assign clk = CLOCK_50;

 
 
 // x, y coordinates from plot controller to VGA
 wire plot_en;
 wire [7:0] plot_x;
 wire [6:0] plot_y; 
 wire [7:0] offset_x;
 wire [6:0] offset_y; 
 wire [2:0] plot_colour;
 wire [2:0] rand_colour;
 wire dot_plot_en, dots_done;
 wire [6:0] counterDot;
 reg [7:0] counterAsync;
 

 
 always @ (posedge clk)//Counter
 begin
 counterAsync <= counterAsync + 1'b1; 
 end  // Coutner
 
 
 LFSR8 lfsrX(clk, offset_x, resetn, counterAsync);
 LFSR7 lfsrY(clk, offset_y, resetn, counterAsync[6:0]);
 LFSR3 lsfrCOLOUR (clk, rand_colour, resetn, counterAsync[2:0]);
 
 wire done_xy_ctrl;
 assign LEDR[0] = done_xy_ctrl;
 
 xy_plot_control xy_plot_controller ( 
  .clk(clk),
  .resetn(resetn), 
  .move_next(KEY[1]), 
  .set_x(SW[7:0]), 
  .rand_colour(rand_colour),
  .set_y(SW[6:0]), 
  .offset_x(offset_x),
  .offset_y(offset_y),
  .plot_x(plot_x), 
  .plot_y(plot_y), 
  .plot_en(plot_en),
  .plot_colour(plot_colour),
  .counterDot(counterDot),
  .done(done_xy_ctrl),
  .dot_plot_en (dot_plot_en),
  .dots_done(dots_done)
 );

 
endmodule 




module LFSR8 (clk, shift, resetn, counterAsync);
input clk;
 input [7:0]counterAsync;
 input resetn;
 output reg [7:0] shift = 7'd1;
 always@(posedge clk) begin
 if (!resetn) begin
 shift <= counterAsync;
 end
 else begin
  shift <= shift<<1;
  shift[0] <= (shift[1] ^ shift[2]) ^ (shift[3] ^ shift[7]);
  end
 end
endmodule




module LFSR7 (clk,shift, resetn, counterAsync);
input clk;
 input [6:0]counterAsync;
 input resetn;
 output reg [6:0] shift= 6'd1;
 always@(posedge clk) begin
  if (!resetn) begin
 shift <= counterAsync;
 end
 else begin
  shift <= shift<<1;
  shift[0] <= (shift[1] ^ shift[2]) ^ (shift[3] ^ shift[6]);
  end
 end
endmodule




module LFSR3 (clk,shift, resetn, counterAsync);
input clk;
 input [2:0]counterAsync;
 input resetn;
 output reg [2:0] shift = 2'd1;
 always@(posedge clk) begin
 if (!resetn) begin
 shift <= counterAsync;
 end
 else begin
  shift <= shift<<1;
  shift[0] <= (shift[1] ^ shift[2]);
  end
 end
endmodule




module xy_plot_control (clk, resetn, move_next, set_x,rand_colour,  set_y, offset_x,  offset_y, plot_x, plot_y, plot_colour, plot_en, counterDot, done, dot_plot_en, dots_done);




 input clk, resetn, move_next;
 input [7:0] set_x;
 input [6:0] set_y;
 input [7:0] offset_x;
 input [6:0] offset_y;
 input [2:0] rand_colour;
 
 
 // Output signals to VGA controller
 output reg plot_en;
 output reg [7:0] plot_x;
 output reg [6:0] plot_y;
 output reg [2:0] plot_colour;
 output reg [6:0] counterDot;
 output reg done;
 output reg dot_plot_en, dots_done;
 
 // States
 reg [3:0] state;
 localparam [3:0] INIT = 4'd0;
 localparam[3:0] PLOT = 4'd1;
 localparam [3:0] DONE = 4'd2;
 localparam [3:0] CLEAR_VGA_MEM = 4'd3;
 
 // Internal variables
 reg [7:0] x;
 reg [6:0] y;
 reg [2:0] set_colour;
 
 // State machine
 always@(posedge clk) begin
  if (!resetn) begin //Case reset
   state <= INIT;
   dots_done <= 0;
  end 
  
  else begin  //Moving around states
  
   case(state)  

    INIT: 
     begin
      plot_x <= 0;
      plot_y <= 0;
      plot_en <= 0;  
      state <= CLEAR_VGA_MEM;
		counterDot <= 0;
    end
    

	 CLEAR_VGA_MEM:
	  begin
	      if (plot_x == 8'b11111111 && plot_y == 7'b1111111) begin
				state <= PLOT;
				plot_colour <= 0;
				dot_plot_en<= 1;
			end else begin
				if (plot_x == 8'b11111111) begin
					plot_y <= plot_y + 1;
					plot_x <= 0;
				end else begin
					plot_x <= plot_x + 1;
				end
				state <= CLEAR_VGA_MEM;
				plot_colour <= 0;
				dot_plot_en <= 1;
			end		
	  
	  end
	

    PLOT:
     begin 
      //if (move_next||counterDot==7'b1111111) begin
		if(counterDot==7'b1111111) begin
       //state <= INIT;  //If counter reaches 100 or w.e, the game has to start. Also, store each dot in memory.
       dot_plot_en <= 0;
		 state <= DONE;
		 counterDot <= 0;
      end else begin
       plot_x <= offset_x;
       plot_y <= offset_y;
       dot_plot_en <= 1; 
		 counterDot <= counterDot+1'b1;
       plot_colour <= rand_colour;       
       state <= PLOT;   
       
      end
     end
	  
	  DONE: begin
	    dot_plot_en <= 0;
		dots_done <= 1;
     end
	  
       default: 
      begin
      //state <= INIT; 
		state <= PLOT;
      plot_x <= 0;
      plot_y <= 0;
      dot_plot_en <= 0;      
      end




     
   endcase
  end 
 end 




 
 

endmodule