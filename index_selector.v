module index_selector(address, x_ship, y_ship, x_bullet, y_bullet, x_rock, y_rock, index, index_out);

	input [18:0] address, x_ship, y_ship;
	// BULLET 
	input [18:0] x_bullet, y_bullet;
	// ASTEROIDS
	input [18:0] x_rock, y_rock;

	input [7:0] index;
	output [7:0] index_out;

	wire [18:0] curr_x, curr_y;	
	assign curr_x = address % 19'd640;
	assign curr_y = address / 19'd640;
	
	wire [18:0] h_ship, w_ship;
	assign h_ship = 19'd100;
	assign w_ship = 19'd100;

	wire [18:0] h_bullet, w_bullet;
	assign h_bullet = 19'd20;
	assign w_bullet = 19'd20;
	
	wire [18:0] h_rock, w_rock;
	assign h_rock = 19'd100;
	assign w_rock = 19'd100;

	wire slct_ship, slct_bullet, slct_rock;
	assign slct_ship =   (curr_x - x_ship < w_ship && curr_x - x_ship  >= 19'd0 && curr_y - y_ship < h_ship && curr_y - y_ship >= 19'd0);
	assign slct_bullet = (curr_x - x_bullet < w_bullet && curr_x - x_bullet >= 19'd0 && curr_y - y_bullet < h_bullet && curr_y - y_bullet >= 19'd0);
	assign slct_rock = (curr_x - x_rock < w_rock && curr_x - x_rock >= 19'd0 && curr_y - y_rock < h_rock && curr_y - y_rock >= 19'd0);
	wire [7:0] first, second;
	assign first = slct_bullet ? 8'd3 : index;
	assign second = slct_rock ? 8'd4 : first;
	assign index_out = slct_ship ? 8'd2 : second;

endmodule
