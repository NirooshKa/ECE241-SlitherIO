
module FinalProject	(
		CLOCK_50, KEY, LEDR, SW,
		PS2_CLK, PS2_DAT, //PS2_CLK2, PS2_DAT2,
		
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	
	input	CLOCK_50;
	input [3:0] KEY;
	
	input [2:0] SW;
	
	// Bidirectionals
	inout				PS2_CLK;
	inout				PS2_DAT;
//	inout				PS2_CLK2;
//	inout				PS2_DAT2;
//	
	
	output [9:0] LEDR;
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]	
	
	
	/* ******************************************************* */

	wire resetn;
	assign resetn = KEY[0];
	
	wire clk;
	assign clk = CLOCK_50;	
	
	wire boost;
	assign boost = ~KEY[3];
	
	wire boost2;
	assign boost2 = ~KEY[1];
	
	//wire [2:0] direction;
	//assign direction = SW[2:0];
	reg [7:0] plot_x;
	reg [6:0] plot_y;
	
	
	
	/* ******************************************************* */
	//random colour generator
	wire [2:0] rand_colour;
	
	LFSR3 color1 (clk, rand_colour, resetn, 3'b100);
	
	
	/* ******************************************************* */
	
	reg [7:0] plot_VGA_x;
	reg [6:0] plot_VGA_Y;
	reg [2:0] plot_VGA_colour; 
	reg plot_VGA_en;
	
	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(clk),
			.colour(plot_VGA_colour),
			.x(plot_VGA_x),
			.y(plot_VGA_Y),
			.plot(plot_VGA_en),

			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
	
	/* ******************************************************* */
	
	wire [7:0] dot_x;
	wire [6:0] dot_y;
	wire [2:0] dot_colour; 
	wire dot_plot_en, dots_done, doneclear;
	assign LEDR[0] = dots_done;
	assign LEDR[1] = plot_VGA_en;
	
	plotDots	plotDot_i (
			.clk(clk), 
			.resetn(resetn),
			.plot_colour(dot_colour),
			.plot_x(dot_x),
			.plot_y(dot_y),
			.plot_en(dot_plot_en),
			.done_ploting_init_dots(dots_done),
			.doneclear(doneclear)
		);	
		
		
		
	/* ******************************************************* */	
	//MOUSE1
	wire		[7:0]	ps2_key_data1;
	wire				ps2_key_pressed1;
	reg [1:0] counter1;
	
	reg [7:0] mouse1_x;
	reg [6:0] mouse1_y;
	reg [7:0] l3, l2, l1;
	reg get_enable1, reset_counter1;
	
	PS2_Controller PS2_1 (
		// Inputs
		.CLOCK_50				(clk),
		.reset				(~KEY[0]),

		// Bidirectionals
		.PS2_CLK			(PS2_CLK),
		.PS2_DAT			(PS2_DAT),

		// Outputs
		.received_data		(ps2_key_data1),
		.received_data_en	(ps2_key_pressed1)
	);
	
	
	always @(posedge CLOCK_50)
	begin
		if (resetn == 1'b0) begin
			l3 <= 8'h00;
			counter1 <= 2'b00;
			//get_enable1 <= 1'b1;
		end
		
		else begin
			
			//if (ps2_key_pressed1 && get_enable1) begin
			if (ps2_key_pressed1 && get_enable1 && (counter1 != 2'b11) ) begin
				l3 <= ps2_key_data1;
				l2 <= l3;
				l1 <= l2;
				/*
				if (counter1 == 2'b10) begin
					//get_enable1 <= 1'b0;
					counter1 <= 2'b00;
				end
				else counter1 <= counter1 + 1'b1;
				*/
				counter1 <= counter1 + 1'b1;
			end
			
			if (reset_counter1) counter1 <= 2'b00;
			//else get_enable1 <= 1'b1;
		end
	end
	
	/* ******************************************************* */	
	//MOUSE 2
//	
//	wire		[7:0]	ps2_key_data2;
//	wire				ps2_key_pressed2;
//	reg [1:0] counter2;
//	
//	reg [7:0] mouse2_x;
//	reg [6:0] mouse2_y;
//	reg [7:0] u3, u2, u1;
//	reg get_enable2, reset_counter2;
//	
//	PS2_Controller PS2_1 (
//		// Inputs
//		.CLOCK_50				(clk),
//		.reset				(~KEY[0]),
//
//		// Bidirectionals
//		.PS2_CLK			(PS2_CLK2),
//		.PS2_DAT			(PS2_DAT2),
//
//		// Outputs
//		.received_data		(ps2_key_data2),
//		.received_data_en	(ps2_key_pressed2)
//	);
//	
//	
//	always @(posedge CLOCK_50)
//	begin
//		if (resetn == 1'b0) begin
//			u3 <= 8'h00;
//			counter2 <= 2'b00;
//			//get_enable1 <= 1'b1;
//		end
//		
//		else begin
//			
//			//if (ps2_key_pressed1 && get_enable1) begin
//			if (ps2_key_pressed2 && get_enable2 && (counter2 != 2'b11) ) begin
//				u3 <= ps2_key_data2;
//				u2 <= u3;
//				u1 <= u2;
//				/*
//				if (counter1 == 2'b10) begin
//					//get_enable1 <= 1'b0;
//					counter1 <= 2'b00;
//				end
//				else counter1 <= counter1 + 1'b1;
//				*/
//				counter2 <= counter2 + 1'b1;
//			end
//			
//			if (reset_counter2) counter2 <= 2'b00;
//			//else get_enable1 <= 1'b1;
//		end
//	end
//	
	
	
	
	
	/* ******************************************************* */
	
	
	reg dots_to_mem;
	wire [7:0] dot_cur_x;
	wire [7:0] dot_cur_y;
	wire [7:0] dot_cur_colour;
	reg [6:0] counterDot;
	reg [2:0] dot_out_colour;
	
	reg data_wait_counter1;

	dotsram dotx(  
			.address(counterDot),
			.clock(clk),
			.data(dot_x),
			.wren(dots_to_mem),
			.q(dot_cur_x) 
			);

	dotsram doty(  
			.address(counterDot),
			.clock(clk),
			.data({1'b0,dot_y}),
			.wren(dots_to_mem),
			.q(dot_cur_y) 
			);
			
	dotsram dotcolour(  
			.address(counterDot),
			.clock(clk),
			.data({5'b00000,dot_out_colour}),
			.wren(dots_to_mem),
			.q(dot_cur_colour) 
			);
	
	
	/* ******************************************************* */
	reg snake_counter;
	reg [3:0] speed_difference;
	
	reg [3:0] frame_counter; //counts each frame
	reg [19:0] second_counter; //counts 1/60 of a second
	
	reg [1:0] data_wait_counter2;
	
	
	//SNAKE 1
	wire [7:0]  snake1_cur_x,  snake1_cur_y;	
	//wire s_draw, s_erase, s_update_head, s_increase_length, s_update_body, write_to_mem, s_store;
	reg [8:0] snake1_memory_counter1, snake1_total_data;
	reg snake1_to_mem;
	reg snake1_done;
	
	reg [3:0] speed;
	
	reg [7:0] snake1_out_x, snake1_out_y;
	reg [7:0] snake1_prev_x, snake1_prev_y;
	
	reg [2:0] last_direc;
	reg [2:0] direction;
	reg [2:0] snake1_colour;
	
	ram512x8 getx1(  
			.address(snake1_memory_counter1),
			.clock(clk),
			.data(snake1_out_x),
			.wren(snake1_to_mem),
			.q(snake1_cur_x) 
			);
			
	ram512x8 gety1(  
			.address(snake1_memory_counter1),
			.clock(clk),
			.data(snake1_out_y),
			.wren(snake1_to_mem),
			.q(snake1_cur_y) 
			);
	
	/* ******************************************************* */
	//SNAKE 2
	wire [7:0]  snake2_cur_x,  snake2_cur_y;	
	reg [8:0] snake2_memory_counter2, snake2_total_data;
	reg snake2_to_mem;
	reg snake2_done;
	
	reg [3:0] speed2;
	
	reg [7:0] snake2_out_x, snake2_out_y;
	reg [7:0] snake2_prev_x, snake2_prev_y;
	
	reg [2:0] last_direc2;
	wire [2:0] direction2;
	assign direction2 = SW[2:0];
	reg [2:0] snake2_colour;
	
	ram512x8 getx2(  
			.address(snake2_memory_counter2),
			.clock(clk),
			.data(snake2_out_x),
			.wren(snake2_to_mem),
			.q(snake2_cur_x) 
			);
			
	ram512x8 gety2(  
			.address(snake2_memory_counter2),
			.clock(clk),
			.data(snake2_out_y),
			.wren(snake2_to_mem),
			.q(snake2_cur_y) 
			);
			
			
	/* ******************************************************* */
	//states
	reg [7:0] state;
	localparam 	PLOT_DOTS = 8'd16,
					INIT_DOTS = 8'd17,
					DOT_DATA_wait = 8'd18,
					DOTS_SCREEN_WAIT = 8'd19,
					WAIT = 8'd20,
					
					draw = 8'd0,
					d_wait = 8'd1, 
					dprint = 8'd14,
					draw_reset_counter = 8'd11,//resetting the memory counter1 and determines the speed of the snake
					
					enable_mouse = 8'd25,
					erase_mouse = 8'd26,
					update_mouse = 8'd27,
					draw_mouse = 8'd28,
					disable_mouse =8'd29,
					
					enable_mouse2 = 8'd30,
					erase_mouse2 = 8'd31,
					update_mouse2 = 8'd37,
					draw_mouse2 = 8'd33,
					disable_mouse2 =8'd34,
					
					wait_time = 8'd2,
					change_snake = 8'd35,
					
					erase = 8'd3,
					e_wait = 8'd4,
					eprint = 8'd15,
					erase_reset_counter = 8'd12,
					
					get_direction = 8'd5,
					update_head = 8'd6,
					
					food_data_wait = 8'd21,
					check_food = 8'd22,
					next_food = 8'd23,
					increase_length = 8'd7,
					
					othersnake_data_wait =8'd36,
					check_snake = 8'd37,
					next_snake_coord = 8'd38,
					
					update_wait = 8'd13,
					update_body = 8'd8,
					
					store_wait = 8'd24, 
					store_update = 8'd9,
					u_wait = 8'd10,
					game_over = 8'd39;//max
	
	
	/* ******************************************************* */				
	reg temp;				
					
	assign LEDR[9] = temp;
	
	/* ******************************************************* */
	
	always@(posedge clk) 
	begin
	
	if (!resetn) begin //Case reset
		state <= INIT_DOTS; 
		plot_VGA_x <= 0;
		plot_VGA_Y <= 0;
		plot_VGA_colour <= 0; 
		plot_VGA_en <= 0;   
		
		dots_to_mem <= 1'b0;
		counterDot <= 7'b1111111; //make it 0 the first time
		snake_counter <= 1'b0;
		
		data_wait_counter1 <= 1'b1;
		data_wait_counter2 <= 2'b10;
		
		snake1_to_mem <= 1'b0;
		snake1_memory_counter1 <= 9'b000000000;
		snake1_out_x <= 8'b00000010;
		snake1_out_y <= 8'b00000010;
		snake1_total_data <= 9'b000000001;
		snake1_colour <= 3'b011;
		last_direc <= 3'b000;
		direction <= 3'b000;
		snake1_done <= 1'b0;	
		
		snake1_to_mem <= 1'b1;
		snake2_memory_counter2 <= 9'b000000000;
		snake2_out_x <= 8'b01111111;
		snake2_out_y <= 8'b01111100;
		snake2_total_data <= 9'b000000001;
		snake2_colour <= 3'b011;
		last_direc2 <= 3'b111;
		//direction2 <= 3'b000;
		snake2_done <= 1'b0;
		
		mouse1_x <= 8'b01010000;
		mouse1_y <= 7'b0111100;
		get_enable1 <= 1'b0;
		reset_counter1 <= 1'b0;
		
		speed_difference <= 4'b0000;
		
		plot_x <= 8'b00000000;
		plot_y <=0;
		
		temp <= 1'b0;
	end 
	
	
	else begin  //Moving around states
  
		case(state)  
		
			INIT_DOTS:
			begin 
				if (dots_done) begin 
					state <= store_update;
					dots_to_mem <= 1'b0;
					counterDot <= 0;
					plot_VGA_en <= 1'b0;
				end
				
				else
				begin
					if (doneclear) begin
						dots_to_mem <= 1'b1;
						counterDot <= counterDot + 1'b1;
					end
					
					state <= INIT_DOTS;
					plot_VGA_x <= dot_x;
					plot_VGA_Y <= dot_y;
					plot_VGA_colour <= dot_colour; 
					dot_out_colour <= dot_colour;
					plot_VGA_en <= dot_plot_en;  		 
				end
			end
			
			
			
			/* ******************************************************* */
			//draw dots
			
			//wait for data from memory
			DOT_DATA_wait: 
			begin
				temp <= 1'b0;
				
				if (data_wait_counter1 == 1'b0) begin
					state <= PLOT_DOTS;
					data_wait_counter1 <= 1'b1;
				end
				
				else begin
					plot_VGA_en <= 1'b0;
					state <= DOT_DATA_wait;
					data_wait_counter1 <= data_wait_counter1 -1'b1;
				end
			end

			//send to VGA
			PLOT_DOTS:
			begin
				plot_VGA_x <= dot_cur_x;
				plot_VGA_Y <= dot_cur_y[6:0];
				plot_VGA_colour <= dot_cur_colour[2:0];
				plot_VGA_en <= 1'b1;
				state <= DOTS_SCREEN_WAIT;
			end
	
			//VGA has received data, plot to screen
			DOTS_SCREEN_WAIT:
			begin
				plot_VGA_en <= 1'b0;
				
				if(counterDot==7'b1111111) begin
					state <= d_wait;
					counterDot <= 0;
				end
				
				else begin
					state <= DOT_DATA_wait;
					counterDot <= counterDot + 1'b1;			
				end
				
			end
			
			/* ******************************************************* */
			//snake 1 draw
			
			d_wait: 
			begin
				if (data_wait_counter1 == 1'b0) begin
					state <= draw;
					data_wait_counter1 <= 1'b1;
				end
				
				else begin
					plot_VGA_en <= 1'b0;
					state <= d_wait;
					data_wait_counter1 <= data_wait_counter1 -1'b1;
				end
			end
			
			draw:
			begin
				if (snake_counter == 1'b0) begin
					plot_VGA_x <= snake1_cur_x;
					plot_VGA_Y <= snake1_cur_y[6:0];
					plot_VGA_colour <= boost? rand_colour : snake1_colour;
					if (boost) snake1_colour <= (rand_colour == 3'b000) ? 3'b011 :rand_colour;
				end
				
				else begin
					plot_VGA_x <= snake2_cur_x;
					plot_VGA_Y <= snake2_cur_y[6:0];
					plot_VGA_colour <= boost2? rand_colour : snake2_colour;
					if (boost2) snake2_colour <= (rand_colour == 3'b000) ? 3'b101 :rand_colour;
				end
				
				state <= dprint;
				
				plot_VGA_en <= 1'b1;
				
			end
			
			dprint:
			begin
				plot_VGA_en <= 1'b0;
				
				if (snake_counter == 1'b0) begin
					if( snake1_memory_counter1 == (snake1_total_data-1'b1) ) begin
						state <= draw_reset_counter;
						snake1_memory_counter1 <= 0;
					end
					
					else begin
						state <= d_wait;
						snake1_memory_counter1 <= snake1_memory_counter1 + 1'b1;
					end
				end
				
				else begin
					if( snake2_memory_counter2 == (snake2_total_data-1'b1) ) begin
						state <= draw_reset_counter;
						snake2_memory_counter2 <= 0;
					end
					
					else begin
						state <= d_wait;
						snake2_memory_counter2 <= snake2_memory_counter2 + 1'b1;
					end
				end
				
				
				
			end
			
			draw_reset_counter: 
			begin
				plot_VGA_en <= 1'b0;	
				
				if (snake_counter == 1'b0) begin
					snake1_memory_counter1 <= 9'b000000000;
					speed <= (boost) ? 4'b0001 : 4'b1111;
				end
				
				else begin
					snake2_memory_counter2 <= 9'b000000000;
					speed2 <= (boost2) ? 4'b0001 : 4'b1111;
				end
				
				state <= enable_mouse; 
				
				second_counter <= 20'b11001011011100110101; //50 million divide by 60 == 833333
				frame_counter <= 4'b0000;
			end
			
			/* ******************************************************* */
			//Mouse 1
			
			enable_mouse: begin 
				//if ( (counter1 == 2'b11) && ps2_key_pressed1) begin
				if (counter1 == 2'b11) begin
					state <= erase_mouse;
					get_enable1 <= 1'b0;
					reset_counter1 <= 1'b1;
				end
				
				else begin
					state <= wait_time;
					get_enable1 <= 1'b1;
				end
			end
			
			erase_mouse: begin
				state <= update_mouse;
				
				reset_counter1 <= 1'b0;
				plot_VGA_x <= mouse1_x;
				plot_VGA_Y <= mouse1_y;
				plot_VGA_colour <= 3'b000;
				plot_VGA_en <= 1'b1;
			end
			
			update_mouse: begin
				state <= draw_mouse;
				
				if (l2 == 8'b0) mouse1_x <= mouse1_x;
				else begin
					if (l1[4]) mouse1_x <= mouse1_x - 1'b1;// - (~l2 ) - 1'b1;
					else mouse1_x <= mouse1_x + 1'b1;//l2;
				end
				
				if (l3 == 8'b0) mouse1_y <= mouse1_y;
				else begin
					if (!l1[5]) mouse1_y <= mouse1_y - 1'b1;//(~l3[6:0]) - 1'b1;
					else mouse1_y <= mouse1_y + 1'b1;// l3[6:0];
				end
				
				plot_VGA_en <= 1'b0;
			end
					
			draw_mouse: begin
				state <= disable_mouse;
				plot_VGA_x <= mouse1_x;
				plot_VGA_Y <= mouse1_y;
				plot_VGA_colour <= 3'b011;
				plot_VGA_en <= 1'b1;
			end
			
			disable_mouse: begin
				state <= wait_time;
				plot_VGA_en <= 1'b0;
				
				get_enable1 <= 1'b1;
			end
					
			/* ******************************************************* */
			//Mouse 2
//			
//			enable_mouse2: begin 
//				//if ( (counter1 == 2'b11) && ps2_key_pressed1) begin
//				if (counter2 == 2'b11) begin
//					state <= erase_mouse2;
//					get_enable2 <= 1'b0;
//					reset_counter2 <= 1'b1;
//				end
//				
//				else begin
//					state <= wait_time;
//					get_enable2 <= 1'b1;
//				end
//			end
//			
//			erase_mouse2: begin
//				state <= update_mouse2;
//				
//				reset_counter2 <= 1'b0;
//				plot_VGA_x <= mouse2_x;
//				plot_VGA_Y <= mouse2_y;
//				plot_VGA_colour <= 3'b000;
//				plot_VGA_en <= 1'b1;
//			end
//			
//			update_mouse2: begin
//				state <= draw_mouse2;
//				
//				if (u2 == 8'b0) mouse2_x <= mouse2_x;
//				else begin
//					if (u1[4]) mouse2_x <= mouse2_x - 1'b1;//- (~l2 ) - 1'b1;
//					else mouse2_x <= mouse2_x + 1'b1; //l2;
//				end
//				
//				if (u3 == 8'b0) mouse2_y <= mouse2_y;
//				else begin
//					if (!l2[5]) mouse2_y <= mouse2_y - 1'b1;//(~l3[6:0]) - 1'b1;
//					else mouse2_y <= mouse2_y +  1'b1; //l3[6:0];
//				end
//				
//				plot_VGA_en <= 1'b0;
//			end
//					
//			draw_mouse2: begin
//				state <= disable_mouse2;
//				plot_VGA_x <= mouse2_x;
//				plot_VGA_Y <= mouse2_y;
//				plot_VGA_colour <= 3'b011;
//				plot_VGA_en <= 1'b1;
//			end
//			
//			disable_mouse2: begin
//				state <= wait_time;
//				plot_VGA_en <= 1'b0;
//				
//				get_enable2 <= 1'b1;
//			end
//			
					
			/* ******************************************************* */
					
			
			
			wait_time: 
			begin
				if (frame_counter == speed || frame_counter == speed2) begin
					state <=  change_snake;
					frame_counter <= 4'b0000;
					second_counter <= 20'b00001011011100110101;
				end
				
				else begin
					if ( second_counter == 20'b01100101101110011010) //- 2'b11 *(frame_counter/2'b11) == 1'b0)
						state <= (counter1 == 2'b11)? enable_mouse: wait_time; //mouse counter data
					else state <= wait_time;
					
					//1/60 of a second reached
					if (second_counter == {20{1'b0}}) begin
						frame_counter <= frame_counter + 1'b1;
						second_counter <= 20'b00001011011100110101; //changed b11001011011100110101
					end

					else begin
						second_counter <= second_counter - 1'b1;//{ {19{1'b0}}, 1'b1};
					end	
					
				end
				
			end
			
			
			//boost_check:
//				if ( ((speed2 != 4'b1111) ^ (speed != 4'b1111)) && (speed_difference != 4'b1111) ) begin
//					speed_difference <= speed_difference + 1'b1;
//				end
//				
//				
//				else begin
//					speed_difference <= 4'b0000;
//					snake_counter <= snake_counter + 1'b1;
//				end
//				snake_counter <= snake_counter + 1'b1;
			
			change_snake: begin
				if (snake_counter == 1'b0) begin
					if (snake1_done) begin
						state <= DOT_DATA_wait;
						snake_counter <= 1'b1;
						snake1_done <= 1'b0;
					end
					
					else begin
						state <= e_wait;
						snake_counter<= 1'b0;
					end
				end
				
				else begin
					if (snake2_done) begin
						state <= DOT_DATA_wait;
						snake_counter <= 1'b0;
						snake2_done <= 1'b0;
					end
					
					else begin
						state <= e_wait;
						snake_counter<= 1'b1;
					end
				end

			end
			
			
			/* ******************************************************* */
			//snake erase
			
			e_wait: 
			begin
				if (data_wait_counter1 == 1'b0) begin
					state <=  erase;
					data_wait_counter1 <= 1'b1;
				end
				
				else begin
					plot_VGA_en <= 1'b0;
					state <=  e_wait;
					data_wait_counter1 <= data_wait_counter1 -1'b1;
				end
				
			end
			
			erase:
			begin
				if (snake_counter == 1'b0) begin
					plot_VGA_x <= snake1_cur_x;
					plot_VGA_Y <= snake1_cur_y[6:0];
					plot_VGA_colour <= 3'b000;
				end
				
				else begin
					plot_VGA_x <= snake2_cur_x;
					plot_VGA_Y <= snake2_cur_y[6:0];
					plot_VGA_colour <= 3'b000;
				end
				
				state <= eprint;
				
				plot_VGA_en <= 1'b1;
			end
			
			
			eprint:
			begin
				plot_VGA_en <= 1'b0;
				
				if (snake_counter == 1'b0) begin
					if( snake1_memory_counter1 == (snake1_total_data-1'b1) ) begin
						state <= erase_reset_counter;
						snake1_memory_counter1 <= 0;
					end
					
					else begin
						state <= e_wait;
						snake1_memory_counter1 <= snake1_memory_counter1 + 1'b1;
					end
				end
				
				else begin
					if( snake2_memory_counter2 == (snake2_total_data-1'b1) ) begin
						state <= erase_reset_counter;
						snake2_memory_counter2 <= 0;
					end
					
					else begin
						state <= e_wait;
						snake2_memory_counter2 <= snake2_memory_counter2 + 1'b1;
					end
				end
			end
			
			erase_reset_counter: 
			begin 
				if (data_wait_counter2 == 2'b00) begin
					state <= get_direction;
					data_wait_counter2 <= 2'b10;
				end
					
				else begin
					state <= erase_reset_counter;
					plot_VGA_en <= 1'b0;
					data_wait_counter2 <= data_wait_counter2 - 1'b1;
					
					if (snake_counter == 1'b0) snake1_memory_counter1 <= 9'b000000000;
					else snake2_memory_counter2 <= 9'b000000000;
				end
			end
			
			/* ******************************************************* */
			//snake head update
			
			get_direction:
			begin
				state <= update_head;
				
				if ( (mouse1_y == snake1_cur_y) && (mouse1_x > snake1_cur_x) ) direction <= 3'b000;
				if ( (mouse1_y == snake1_cur_y) && (mouse1_x < snake1_cur_x) ) direction <= 3'b001;
				if ( (mouse1_y < snake1_cur_y) && (mouse1_x == snake1_cur_x) ) direction <= 3'b010;
				if ( (mouse1_y > snake1_cur_y) && (mouse1_x == snake1_cur_x) ) direction <= 3'b011;
				if ( (mouse1_y > snake1_cur_y) && (mouse1_x < snake1_cur_x) ) direction <= 3'b100;
				if ( (mouse1_y < snake1_cur_y) && (mouse1_x > snake1_cur_x) ) direction <= 3'b101;
				if ( (mouse1_y > snake1_cur_y) && (mouse1_x > snake1_cur_x) ) direction <= 3'b110;
				if ( (mouse1_y < snake1_cur_y) && (mouse1_x < snake1_cur_x) ) direction <= 3'b111;

			end
			
			
			update_head: 
			begin
				state <= food_data_wait;
				//food? increase_length :store_update;
				
				if (snake_counter == 1'b0) begin
				
					snake1_prev_x <= snake1_cur_x;
					snake1_prev_y <= snake1_cur_y;
				
					//direction is the opposite as the last_direction
					//we will ignore the current direction b/c snake cant go backward
					if ( (direction[1] == last_direc[1]) && (direction[2] == last_direc[2]) ) begin								
						case (last_direc)
							3'b000: begin  //right
								snake1_out_x <= snake1_cur_x + 1'b1; 
								snake1_out_y <= snake1_cur_y;
							end
							3'b001: begin  //left
								snake1_out_x <= snake1_cur_x - 1'b1; 
								snake1_out_y <= snake1_cur_y;
							end
							3'b010: begin //up
								snake1_out_y <= snake1_cur_y - 1'b1; 
								snake1_out_x <= snake1_cur_x;
							end
							3'b011: begin //down
								snake1_out_y <= snake1_cur_y + 1'b1;  
								snake1_out_x <= snake1_cur_x;
							end 
							
							3'b100: begin  
								snake1_out_x <= snake1_cur_x - 1'b1; 
								snake1_out_y <= snake1_cur_y + 1'b1;
							end
							
							3'b101: begin  
								snake1_out_x <= snake1_cur_x + 1'b1; 
								snake1_out_y <= snake1_cur_y - 1'b1;
							end
							3'b110: begin 
								snake1_out_y <= snake1_cur_y + 1'b1; 
								snake1_out_x <= snake1_cur_x + 1'b1;
							end
							3'b111: begin 
								snake1_out_y <= snake1_cur_y - 1'b1;  
								snake1_out_x <= snake1_cur_x - 1'b1;
							end 
							
							default: begin 
								snake1_out_x <= snake1_cur_x + 1'b1;
								snake1_out_y <= snake1_cur_y;
							end
						endcase
						
						//last_direction stays the same
						last_direc <= last_direc;
					end
					
					//next direction is valid
					else begin
						case (direction)
							3'b000: begin  //right
								snake1_out_x <= snake1_cur_x + 1'b1; 
								snake1_out_y <= snake1_cur_y;
							end
							3'b001: begin  //left
								snake1_out_x <= snake1_cur_x - 1'b1; 
								snake1_out_y <= snake1_cur_y;
							end
							3'b010: begin //up
								snake1_out_y <= snake1_cur_y - 1'b1; 
								snake1_out_x <= snake1_cur_x;
							end
							3'b011: begin //down
								snake1_out_y <= snake1_cur_y + 1'b1;  
								snake1_out_x <= snake1_cur_x;
							end 
							
							3'b100: begin  
								snake1_out_x <= snake1_cur_x - 1'b1; 
								snake1_out_y <= snake1_cur_y + 1'b1;
							end
							
							3'b101: begin  
								snake1_out_x <= snake1_cur_x + 1'b1; 
								snake1_out_y <= snake1_cur_y - 1'b1;
							end
							3'b110: begin 
								snake1_out_y <= snake1_cur_y + 1'b1; 
								snake1_out_x <= snake1_cur_x + 1'b1;
							end
							3'b111: begin 
								snake1_out_y <= snake1_cur_y - 1'b1;  
								snake1_out_x <= snake1_cur_x - 1'b1;
							end 
							
							default: begin 
								snake1_out_x <= snake1_cur_x + 1'b1;
								snake1_out_y <= snake1_cur_y;
							end
						endcase
						
						last_direc <= direction;
					end
				end
				
				
				else begin
					snake2_prev_x <= snake2_cur_x;
					snake2_prev_y <= snake2_cur_y;
				
					//direction is the opposite as the last_direction
					//we will ignore the current direction b/c snake cant go backward
					if ( (direction2[1] == last_direc2[1]) && (direction2[2] == last_direc2[2]) ) begin								
						case (last_direc2)
							3'b000: begin  //right
								snake2_out_x <= snake2_cur_x + 1'b1; 
								snake2_out_y <= snake2_cur_y;
							end
							3'b001: begin  //left
								snake2_out_x <= snake2_cur_x - 1'b1; 
								snake2_out_y <= snake2_cur_y;
							end
							3'b010: begin //up
								snake2_out_y <= snake2_cur_y - 1'b1; 
								snake2_out_x <= snake2_cur_x;
							end
							3'b011: begin //down
								snake2_out_y <= snake2_cur_y + 1'b1;  
								snake2_out_x <= snake2_cur_x;
							end 
							
							3'b100: begin  
								snake2_out_x <= snake2_cur_x - 1'b1; 
								snake2_out_y <= snake2_cur_y + 1'b1;
							end
							
							3'b101: begin  
								snake2_out_x <= snake2_cur_x + 1'b1; 
								snake2_out_y <= snake2_cur_y - 1'b1;
							end
							3'b110: begin 
								snake2_out_y <= snake2_cur_y + 1'b1; 
								snake2_out_x <= snake2_cur_x + 1'b1;
							end
							3'b111: begin 
								snake2_out_y <= snake2_cur_y - 1'b1;  
								snake2_out_x <= snake2_cur_x - 1'b1;
							end 
							
							default: begin 
								snake2_out_x <= snake2_cur_x + 1'b1;
								snake2_out_y <= snake2_cur_y;
							end
						endcase
						
						//last_direction stays the same
						last_direc2 <= last_direc2;
					end
					
					//next direction is valid
					else begin
						case (direction2)
							3'b000: begin  //right
								snake2_out_x <= snake2_cur_x + 1'b1; 
								snake2_out_y <= snake2_cur_y;
							end
							3'b001: begin  //left
								snake2_out_x <= snake2_cur_x - 1'b1; 
								snake2_out_y <= snake2_cur_y;
							end
							3'b010: begin //up
								snake2_out_y <= snake2_cur_y - 1'b1; 
								snake2_out_x <= snake2_cur_x;
							end
							3'b011: begin //down
								snake2_out_y <= snake2_cur_y + 1'b1;  
								snake2_out_x <= snake2_cur_x;
							end 
							
							3'b100: begin  
								snake2_out_x <= snake2_cur_x - 1'b1; 
								snake2_out_y <= snake2_cur_y + 1'b1;
							end
							
							3'b101: begin  
								snake2_out_x <= snake2_cur_x + 1'b1; 
								snake2_out_y <= snake2_cur_y - 1'b1;
							end
							3'b110: begin 
								snake2_out_y <= snake2_cur_y + 1'b1; 
								snake2_out_x <= snake2_cur_x + 1'b1;
							end
							3'b111: begin 
								snake2_out_y <= snake2_cur_y - 1'b1;  
								snake2_out_x <= snake2_cur_x - 1'b1;
							end 
							
							default: begin 
								snake2_out_x <= snake2_cur_x + 1'b1;
								snake2_out_y <= snake2_cur_y;
							end
						endcase
						
						last_direc2 <= direction2;
					end
				
				end
				
			end
			
			/* ******************************************************* */
			//CHECK FOOD
			food_data_wait:
			begin
				if (data_wait_counter1 == 1'b0) begin
					state <= check_food;
					data_wait_counter1 <= 1'b1;
				end
				
				else begin
					state <= food_data_wait;
					data_wait_counter1 <= data_wait_counter1 -1'b1;
				end
			end


			check_food:
			begin
				if (snake_counter == 1'b0) begin
					if ( (snake1_out_x == dot_cur_x) &&	(snake1_out_y == dot_cur_y) && (dot_cur_colour[2:0] != 3'b000) ) begin
						state <= increase_length;
						dot_out_colour <= 3'b000;
						dots_to_mem <= 1'b1;
					end
					
					else begin
						state <= next_food;
					end
				end
				
				else begin
					if ( (snake2_out_x == dot_cur_x) &&	(snake2_out_y == dot_cur_y) && (dot_cur_colour[2:0] != 3'b000) ) begin
						state <= increase_length;
						dot_out_colour <= 3'b000;
						dots_to_mem <= 1'b1;
					end
					
					else begin
						state <= next_food;
					end
				end
			end


			next_food:
			begin
				if(counterDot==7'b1111111) begin
					//change here to check other collisions
					state <= othersnake_data_wait;
					counterDot <= 0;
				end
				
				else begin
					state <= food_data_wait;
					counterDot <= counterDot + 1'b1;			
				end
			end
			
			/* ******************************************************* */
			//check snake
			othersnake_data_wait:
			begin
				if (data_wait_counter1 == 1'b0) begin
					state <= check_snake;
					data_wait_counter1 <= 1'b1;
				end
				
				else begin
					state <= othersnake_data_wait;
					data_wait_counter1 <= data_wait_counter1 -1'b1;
				end
			end


			check_snake:
			begin
				if (snake_counter == 1'b0) begin
					if ( (snake1_out_x == snake2_cur_x) &&	(snake1_out_y == snake2_cur_y) )
						state <= game_over;
					
					else
						state <= next_snake_coord;
				end
				
				else begin
					if ( (snake2_out_x == snake1_cur_x) &&	(snake2_out_y == snake1_cur_y) )
						state <= game_over;
					
					else begin
						state <= next_snake_coord;
					end
				end
			end


			next_snake_coord:
			begin
			//flip cuz check other snake
				if (snake_counter == 1'b1) begin
					if( snake1_memory_counter1 == (snake1_total_data-1'b1) ) begin
						state <= store_update;
						snake1_memory_counter1 <= 0;
					end
					
					else begin
						state <= othersnake_data_wait;
						snake1_memory_counter1 <= snake1_memory_counter1 + 1'b1;
					end
				end
				
				else begin
					if( snake2_memory_counter2 == (snake2_total_data-1'b1) ) begin
						state <= store_update;
						snake2_memory_counter2 <= 0;
					end
					
					else begin
						state <= othersnake_data_wait;
						snake2_memory_counter2 <= snake2_memory_counter2 + 1'b1;
					end
				end
			end		
			
			
			
			
			/* ******************************************************* */
			
			
			increase_length:
			begin
				state <= store_update;
				
				dots_to_mem <= 1'b0;
				counterDot <= 0;
				
				if (snake_counter == 1'b0) snake1_total_data <= snake1_total_data + 1'b1;
				else snake2_total_data <= snake2_total_data + 1'b1;
			end
			
			
			/* ******************************************************* */
			//snake body update
			
			update_wait: 
			begin 
				if (data_wait_counter1 == 1'b0) begin
					state <= update_body;
					data_wait_counter1 <= 1'b1;
				end
				
				else begin
					state <= update_wait;
					data_wait_counter1 <= data_wait_counter1 - 1'b1;
				end
				
			end
			
			update_body: begin
				state <= store_update;
				
				if (snake_counter == 1'b0) begin
					snake1_prev_x <= snake1_cur_x;
					snake1_prev_y <= snake1_cur_y;
					snake1_out_x <= snake1_prev_x; //store the next unit's x,y in out_x, out_y
					snake1_out_y <= snake1_prev_y; //so we can assign them next_state
				end
				
				else begin
					snake2_prev_x <= snake2_cur_x;
					snake2_prev_y <= snake2_cur_y;
					snake2_out_x <= snake2_prev_x; 
					snake2_out_y <= snake2_prev_y;
				end
			end
			
			
			/* ******************************************************* */
			//store update
			
			store_update: begin
				state <= store_wait;
				
				if (snake_counter == 1'b0) begin
					snake1_to_mem <= 1'b1;
					snake1_out_x <= snake1_out_x;
					snake1_out_y <= snake1_out_y;
				end
				
				else begin
					snake2_to_mem <= 1'b1;
					snake2_out_x <= snake2_out_x;
					snake2_out_y <= snake2_out_y;
				end	
			end
			
			store_wait: begin
				if (snake_counter == 1'b0) begin
					if (snake1_memory_counter1 == (snake1_total_data-1'b1)) begin
						state <= u_wait;
					end
					
					else begin
						state <= update_wait; 
						snake1_memory_counter1 <= snake1_memory_counter1 + 1'b1; 
					end
					
					snake1_to_mem <= 1'b0;
				end
				
				else begin
					if (snake2_memory_counter2 == (snake2_total_data-1'b1)) begin
						state <= u_wait;
					end
					
					else begin
						state <= update_wait; 
						snake2_memory_counter2 <= snake2_memory_counter2 + 1'b1; 
					end
					
					snake2_to_mem <= 1'b0;
				end
			end
			
			u_wait: begin
				if (data_wait_counter2 == 2'b00) begin
					state <= WAIT;
					data_wait_counter2 <= 2'b10;
				end
			
				else begin
					state <= u_wait;
					data_wait_counter2 <= data_wait_counter2 - 1'b1;
					
					if (snake_counter == 1'b0) snake1_memory_counter1 <= 0;
					else snake2_memory_counter2 <= 0;
				end
			end
			
			/* ******************************************************* */
						
						
			WAIT:
			begin
				state <= DOT_DATA_wait;
				temp <= 1'b1;
				
				if (snake_counter == 1'b0) snake1_done <= 1'b1;
				else snake2_done <= 1'b1;

			end
			
			
			game_over:
			begin
				if (plot_x == 8'b11111111 && plot_y == 7'b1111111) begin
					state <= game_over;
					plot_VGA_en <= 1'b0; 
				end 
				
				else begin
					if (plot_x == 8'b11111111) begin
						plot_y <= plot_y + 1'b1;
						plot_x <= 8'b0;
					end 
					else begin
						plot_x <= plot_x + 1'b1;
					end
					
					state <= game_over;
					
					plot_VGA_x <= plot_x;
					plot_VGA_Y <= plot_y;
					plot_VGA_colour <= 3'b111; 
					plot_VGA_en <= 1'b1; 
				end		
			
			end
			
		 
		 default: state <= INIT_DOTS;
		endcase
	end
	
	
	end
	
	
endmodule


