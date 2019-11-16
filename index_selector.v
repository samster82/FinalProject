module index_selector(address, min_x, min_y, min_x_bullet, min_y_bullet, index, index_out);

input [18:0] address, min_x, min_y;
// BULLET 
input [18:0] min_x_bullet, min_y_bullet;


input [7:0] index;
output [7:0] index_out;

wire [18:0] curr_x, curr_y, height, width;

assign height = 19'd100;
assign width = 19'd100;

assign curr_x = address % 19'd640;
assign curr_y = address / 19'd640;

wire [18:0] bullet_height, bullet_width;
assign bullet_height = 19'd20;
assign bullet_width = 19'd20;

wire slct_ship, slct_bullet;
assign slct_ship =   (curr_x - min_x        < width        && curr_x - min_x        >= 19'd0 && curr_y - min_y        < height        && curr_y - min_y        >= 19'd0);
assign slct_bullet = (curr_x - min_x_bullet < bullet_width && curr_x - min_x_bullet >= 19'd0 && curr_y - min_y_bullet < bullet_height && curr_y - min_y_bullet >= 19'd0);
wire [7:0] first;
assign first = slct_bullet ? 8'd3 : index;
assign index_out = slct_ship ? 8'd2 : first;
// always @*​
// begin​
// if (curr_x - min_x < width && curr_x - min_x >= 19'd0 && curr_y - min_y < height && curr_y - min_y >= 19'd0)​
// index_out <= 19'd2;​
// else​
// index_out <= index;​
// end​

endmodule
