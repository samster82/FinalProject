module collision(x_bullet_in, y_bullet_in, x_rock_in, y_rock_in,
					  h_bullet, w_bullet, h_rock, w_rock,
					  x_bullet_out, y_bullet_out, x_rock_out, y_rock_out,
					  collision

);
	input [18:0] x_bullet_in, y_bullet_in, x_rock_in, y_rock_in, 
	h_bullet, w_bullet, h_rock, w_rock;
	output [18:0] x_bullet_out, y_bullet_out, x_rock_out, y_rock_out;
	output collision;
	
	reg x_col, y_col;
	initial begin 
		x_col = 1'b0;
		y_col = 1'b0;
	end
	
	always begin
		if (((x_bullet_in >= x_rock_in) && (x_bullet_in + w_bullet)) <= (x_rock_in + w_rock)) begin
			x_col <= 1'b1;
		end
		else begin
				x_col <= 1'b0;
		end
		if (((y_bullet_in >= y_rock_in) && (y_bullet_in + h_bullet)) <= (y_rock_in + h_rock)) begin
			y_col <= 1'b1;
		end
		else begin
			y_col <= 1'b0;
		end
	end

	assign collision = x_col && y_col;
	
	assign x_bullet_out = collision ? 19'd0 : x_bullet_in;
	assign y_bullet_out = collision ? 19'd0 : y_bullet_in;
	assign x_rock_out = collision ? 19'd610 : x_rock_in;
	assign y_rock_out = collision ? 19'd0 : y_rock_in; 

endmodule
