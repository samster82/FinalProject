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
img_data img_data_inst (
.address ( ADDR ),
.clock ( VGA_CLK_n ),
.q ( index )
);

reg[18:0] x_cor_min, y_cor_min, x_bullet_min, y_bullet_min;
wire [7:0] index_selected, bullet_index_slct;
wire [18:0] cor_iterator;

initial begin 
	x_cor_min = 19'd270;
end
initial begin 
	y_cor_min = 19'd190;
end
initial begin 
	x_bullet_min = 19'd80;
end
initial begin 
	y_bullet_min = 19'd80;
end

assign cor_iterator = 19'd20;

reg [23:0] count, countb;

always @(posedge iVGA_CLK) begin
	count <= count + 24'd1;
	if (count == 1) begin
		if (up == 0) begin
			y_cor_min <= y_cor_min - cor_iterator;
		end
		else if (down == 0) begin
			y_cor_min <= y_cor_min + cor_iterator;
		end
		else if (left == 0) begin
			x_cor_min <= x_cor_min - cor_iterator;
		end
		else if (right == 0) begin
			x_cor_min <= x_cor_min + cor_iterator;
		end
		//x_bullet_min <= x_bullet_min + 19'b0;
		//y_bullet_min <= y_bullet_min + 19'b0;
	end
end

always @(posedge iVGA_CLK) begin
	countb <= countb + 24'd1;
	if (countb == 1) begin
	y_bullet_min <= y_bullet_min + cor_iterator;
		if (up == 0) begin
			y_bullet_min <= y_bullet_min - cor_iterator;
		end
		else if (down == 0) begin
			y_bullet_min <= y_bullet_min + cor_iterator;
		end
		else if (left == 0) begin
			x_bullet_min <= x_bullet_min - cor_iterator;
		end
		else if (right == 0) begin
			x_bullet_min <= x_bullet_min + cor_iterator;
		end
		//x_bullet_min <= x_bullet_min + 19'b0;
		//y_bullet_min <= y_bullet_min + 19'b0;
	end
end

index_selector select_index(.address(ADDR), .min_x(x_cor_min), .min_y(y_cor_min), .min_x_bullet(x_bullet_min), .min_y_bullet(y_bullet_min), .index(index), .index_out(index_selected));

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





