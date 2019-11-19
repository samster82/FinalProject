module vga_controller(iRST_n,
							iVGA_CLK,
							oBLANK_n,
							oHS,
							oVS,
							b_data,
							g_data,
							r_data,							
							left,
							right,
							up,
							down, shoot	
);


input iRST_n;
input iVGA_CLK;

input left, right, up, down, shoot;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
//output [7:0] g_data; 

output [7:0] g_data;

output [7:0] r_data;
//output [7:0] r_data;                      
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
//wire RTS_n;
////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
										.reset(rst),
										.blank_n(cBLANK_n),
										.HS(cHS),
										.VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
	if (!iRST_n) //was !RST_n	
		ADDR<=19'd0;
	else if (cHS==1'b0 && cVS==1'b0)	
		ADDR<=19'd0;
	else if (cBLANK_n==1'b1)
		ADDR<=ADDR+19'd1;
end
//////////////////////////

// Input: Address, Output: index corresponding to the address

//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data img_data_inst (.address ( ADDR ), .clock ( VGA_CLK_n ), .q ( index ));

reg[18:0] x_ship, y_ship, x_ship_gun, y_ship_gun, x_bullet, y_bullet, x_rock, y_rock;
wire [7:0] index_selected, bullet_index_slct;
wire [18:0] offset;

initial begin 
	x_ship = 19'd270;
	y_ship = 19'd400;
	x_ship_gun = 19'd320;
	y_ship_gun = 19'd400;
	x_bullet = -19'd80;
	y_bullet = -19'd80;
	x_rock = 19'd270;
	y_rock = 19'd0;
end

assign offset = 19'd20;
reg [23:0] countc;
reg [21:0] count;
reg [18:0] countb;


always @(posedge iVGA_CLK) begin
	count <= count + 22'd1;
	if (count == 1) begin
		if (up == 0) begin
			y_ship <= y_ship - offset;
			y_ship_gun <= y_ship_gun - offset;
		end
		else if (down == 0) begin
			y_ship <= y_ship + offset;
			y_ship_gun <= y_ship_gun + offset;
		end
		////x_ship <= x_ship - offset;
			//x_ship_gun <= x_ship_gun - offset;
		//endelse if (left == 0) begin
			
		else if (right == 0) begin
			x_ship <= x_ship + offset;
			x_ship_gun <= x_ship_gun + offset;
		end
	end
end

always @(posedge iVGA_CLK) begin
	countb <= countb + 19'd1;
	if (countb == 1) begin
		x_bullet <= x_ship_gun;
//		if (collision == 1) begin
//			//y_bullet <= y_bullet_out;
//		end
//		else if (collision == 0) begin
//			y_bullet <= y_bullet - offset;
//		end
		if (dead == 1) begin
			y_bullet <= 19'd0;
		end
		else if (dead == 0) begin
			y_bullet <= y_bullet - offset;
		end
		if (shoot == 0) begin
			x_bullet <= x_ship_gun;
			y_bullet <= y_ship_gun;
		end
	end
end

always @(posedge iVGA_CLK) begin
	countc <= countc + 24'd1;
	if (countc == 1) begin
//		if (collision == 1) begin
//			x_rock <= x_rock_out;
//			y_rock <= y_rock_out;
//		end
//		else if (collision == 0) begin
//			x_rock <= 19'd270;
//			y_rock <= y_rock + offset;
//		end
		if (dead == 1) begin
			x_rock <= 19'd600;// bit amount should be how many bits have 640
			y_rock <= 19'd0;
		end
		else if (dead == 0) begin
			x_rock <= 19'd270;
			y_rock <= y_rock + offset;
		end
	end
end

index_selector select_index(.address(ADDR), .x_ship(x_ship), .y_ship(y_ship), .x_bullet(x_bullet), .y_bullet(y_bullet), .x_rock(x_rock), .y_rock(y_rock), .index(index), .index_out(index_selected));
wire [18:0] x_bullet_out, y_bullet_out, x_rock_out, y_rock_out;
wire collision;
collision col0(x_bullet, y_bullet, x_rock, y_rock,
					  h_bullet, w_bullet, h_rock, w_rock,
					  x_bullet_out, y_bullet_out, x_rock_out, y_rock_out,
					  collision);
wire dead;
dflipflop dff0(1'b1, iVGA_CLK, 1'b0, collision, dead);

/////////////////////////
//////Add switch-input logic here

// Gets the data at a specific pixel index in the image.

//////Color table output
img_index img_index_inst (
.address ( index_selected ),
.clock ( iVGA_CLK ),
.q ( bgr_data_raw)
);
//////
//////latch valid data at falling edge;
always@(posedge VGA_CLK_n) bgr_data <= bgr_data_raw;
assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin

	oHS<=cHS;
	oVS<=cVS;	
	oBLANK_n<=cBLANK_n;
end


endmodule
