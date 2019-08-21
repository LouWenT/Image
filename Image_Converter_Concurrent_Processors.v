`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:00:32 07/05/2019 
// Design Name: 
// Module Name:    Image_Converter_Concurrent_Processors 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Image_Converter_Concurrent_Processors #(parameter pixel_size = 8,N_col = 8 ,M_row = 6)
				( output [1:N_col*M_row]            HTPV_bits,   //转换后的图像数据
				  output                            Done,       //转换完成的标志
				  input  [1:N_col*M_row*pixel_size] pixel_bits, //输入的图像数据流
				  input                             Go,clk_i,rst_n
					);
					
		wire [23:0] index;
		wire        Ld_image,Ld_values;
		
		wire [pixel_size-1:0]        PP_1_Err_1, PP_1_Err_2, PP_1_Err_3, PP_1_Err_4, PP_1_PV,//每个处理器所需的数据
									 PP_2_Err_1, PP_2_Err_2, PP_2_Err_3, PP_2_Err_4, PP_2_PV,
									 PP_3_Err_1, PP_3_Err_2, PP_3_Err_3, PP_3_Err_4, PP_3_PV,
									 PP_4_Err_1, PP_4_Err_2, PP_4_Err_3, PP_4_Err_4, PP_4_PV;
									 
		wire [pixel_size-1:0]        PP_1_Err_0,PP_2_Err_0,PP_3_Err_0,PP_4_Err_0; //每个处理器处理后的数据误差
		
		wire 						 PP_1_HTPV,PP_2_HTPV,PP_3_HTPV,PP_4_HTPV; //每个处理器经过处理后的图像数据
		
		
		//4个像素处理器单元的例化
		PP_Datapath_Unit M1_Datapath ( .Err_0(PP_1_Err_0),
									   .HTPV( PP_1_HTPV),
									   .Err_1(PP_1_Err_1),
									   .Err_2(PP_1_Err_2),
									   .Err_3(PP_1_Err_3),
									   .Err_4(PP_1_Err_4),
									   .PV(PP_1_PV)
									   );
									   
		PP_Datapath_Unit M2_Datapath ( .Err_0(PP_2_Err_0),
									   .HTPV( PP_2_HTPV),
									   .Err_1(PP_2_Err_1),
									   .Err_2(PP_2_Err_2),
									   .Err_3(PP_2_Err_3),
									   .Err_4(PP_2_Err_4),
									   .PV(PP_2_PV)
									   );
									   
		PP_Datapath_Unit M3_Datapath ( .Err_0(PP_3_Err_0),
									   .HTPV( PP_3_HTPV),
									   .Err_1(PP_3_Err_1),
									   .Err_2(PP_3_Err_2),
									   .Err_3(PP_3_Err_3),
									   .Err_4(PP_3_Err_4),
									   .PV(PP_3_PV)
									   );
									   
		PP_Datapath_Unit M4_Datapath ( .Err_0(PP_4_Err_0),
									   .HTPV( PP_4_HTPV),
									   .Err_1(PP_4_Err_1),
									   .Err_2(PP_4_Err_2),
									   .Err_3(PP_4_Err_3),
									   .Err_4(PP_4_Err_4),
									   .PV(PP_4_PV)
									   );
									   
		//控制单元的例化
		
		PP_Control_Unit M0_Controller ( .index(index),
									    .Ld_image(Ld_image),
										.Ld_values(Ld_values),
										.Done(Done),
										.Go(Go),
										.clk_i(clk_i),
										.rst_n(rst_n)
										);
									   
		//存储器单元的例化
		
		PP_Memory_Unit M5_Memory ( .HTPV_bits(HTPV_bits),
								   .PP_1_Err_1(PP_1_Err_1),.PP_1_Err_2(PP_1_Err_2),.PP_1_Err_3(PP_1_Err_3),.PP_1_Err_4(PP_1_Err_4),.PP_1_PV(PP_1_PV),
								   .PP_2_Err_1(PP_2_Err_1),.PP_2_Err_2(PP_2_Err_2),.PP_2_Err_3(PP_2_Err_3),.PP_2_Err_4(PP_2_Err_4),.PP_2_PV(PP_2_PV),
								   .PP_3_Err_1(PP_3_Err_1),.PP_3_Err_2(PP_3_Err_2),.PP_3_Err_3(PP_3_Err_3),.PP_3_Err_4(PP_3_Err_4),.PP_3_PV(PP_3_PV),
								   .PP_4_Err_1(PP_4_Err_1),.PP_4_Err_2(PP_4_Err_2),.PP_4_Err_3(PP_4_Err_3),.PP_4_Err_4(PP_4_Err_4),.PP_4_PV(PP_4_PV),
								   .PP_1_Err_0(PP_1_Err_0),.PP_2_Err_0(PP_2_Err_0),.PP_3_Err_0(PP_3_Err_0),.PP_4_Err_0(PP_4_Err_0),
								   .PP_1_HTPV(PP_1_HTPV),.PP_2_HTPV(PP_2_HTPV),.PP_3_HTPV(PP_3_HTPV),.PP_4_HTPV(PP_4_HTPV),
								   .pixel_bits(pixel_bits),
								   .index(index),
								   .Go(Go),
								   .Ld_image(Ld_image),
								   .Ld_values(Ld_values),
								   .clk_i(clk_i),
								   .rst_n(rst_n)
								   );
								   

		
		

endmodule



//控制单元的设计，决定每个时刻处理像素的数据地址，并将整个像素数据存入存储器

module PP_Control_Unit ( output reg [23:0] index,
						 output reg        Ld_image,Ld_values,Done,
						 input             Go,clk_i,rst_n
						);
						
		reg [4:0] state,next_state;
		
		parameter S_idle = 5'd0,S_1 = 5'd1,S_2 = 5'd2,S_3 = 5'd3,S_4 = 5'd4,S_5 = 5'd5,S_6 = 5'd6,
								S_7 = 5'd7,S_8 = 5'd8,S_9 = 5'd9,S_10 = 5'd10,S_11 = 5'd11,S_12 = 5'd12,
								S_13 = 5'd13,S_14 = 5'd14,S_15 = 5'd15,S_16 = 5'd16,S_17 = 5'd17,S_18 = 5'd18; //每个时刻的状态编码
								
		//状态机的设计，包括状态的输出、转换条件及控制信号的加载
		//状态的转移条件
		always @(posedge clk_i) begin
			if(!rst_n)
				state <= S_idle;
			else
				state <= next_state;
		end
			
		//状态的转换
		always @(state,Go) begin
			Ld_values  = 0;
			next_state = S_idle; //赋初值防止生成锁存器
			case(state)
				S_idle : if(Go) next_state = S_1;
				S_18   : begin
							next_state = S_idle;
							Ld_values  = 1;
						end
				default : begin
							next_state = state + 1;
							Ld_values  = 1;
						end
			endcase
		end
		
		//决定是否加载数据到存储器的控制信号
		always @ (state,Go) begin
			Done = 0;
			Ld_image = 0;
			if(state == S_idle) begin
				Done = 1;
				if(Go)
					Ld_image = 1;
			end
		end
		
		//不同状态的输出
		always @(state) begin
			index = 0;
			case(state)
				S_idle  : index = {{6'd0},{6'd0},{6'd0},{6'd0}};
				S_1     : index = {{6'd1},{6'd0},{6'd0},{6'd0}};
				S_2     : index = {{6'd2},{6'd0},{6'd0},{6'd0}};
				S_3     : index = {{6'd3},{6'd9},{6'd0},{6'd0}};
				S_4     : index = {{6'd4},{6'd10},{6'd0},{6'd0}};
				S_5     : index = {{6'd5},{6'd11},{6'd17},{6'd0}};
				S_6     : index = {{6'd6},{6'd12},{6'd18},{6'd0}};
				S_7     : index = {{6'd7},{6'd13},{6'd19},{6'd25}};
				S_8     : index = {{6'd8},{6'd14},{6'd20},{6'd26}};
				S_9     : index = {{6'd15},{6'd21},{6'd27},{6'd33}};
				S_10    : index = {{6'd16},{6'd22},{6'd28},{6'd34}};
				S_11    : index = {{6'd23},{6'd29},{6'd35},{6'd41}};
				S_12    : index = {{6'd24},{6'd30},{6'd36},{6'd42}};
				S_13    : index = {{6'd0},{6'd31},{6'd37},{6'd43}};
				S_14    : index = {{6'd0},{6'd32},{6'd38},{6'd44}};
				S_15    : index = {{6'd0},{6'd0},{6'd39},{6'd45}};
				S_16    : index = {{6'd0},{6'd0},{6'd40},{6'd46}};
				S_17    : index = {{6'd0},{6'd0},{6'd0},{6'd47}};
				S_18    : index = {{6'd0},{6'd0},{6'd0},{6'd48}};
				default : index = 0;
			endcase
		end
		
endmodule //: PP_Control_Unit
				
				
//像素处理单元的设计，进行图像数据的转换
module PP_Datapath_Unit #(parameter pixel_size = 8)
						( output [pixel_size-1:0] Err_0,
						  output                  HTPV,
						  input  [pixel_size-1:0] Err_1,Err_2,Err_3,Err_4,PV
							);
							
		wire [pixel_size+1:0] CPV,CPV_round,E_av;
		
		parameter w1 = 2, w2 = 8, w3 = 4, w4 = 2; //权值
		parameter Threshold = 128;//阈值
		
		assign E_av      = (w1 * Err_1 + w2 * Err_2 + w3 * Err_3 + w4 * Err_4) >> 4;
		assign CPV       = PV + E_av;
		assign CPV_round = (CPV < Threshold) ? 0 : 255;
		assign HTPV      = (CPV_round == 0) ? 0 : 1;
		assign Err_0     = CPV - CPV_round;
		
endmodule

//存储器单元的设计
module PP_Memory_Unit #(parameter pixel_size = 8,N_col = 8 ,M_row = 6)
					( output      [1:N_col*M_row]  HTPV_bits,
					  output  reg [pixel_size-1:0] PP_1_Err_1,PP_1_Err_2,PP_1_Err_3,PP_1_Err_4,PP_1_PV,
												   PP_2_Err_1,PP_2_Err_2,PP_2_Err_3,PP_2_Err_4,PP_2_PV,
												   PP_3_Err_1,PP_3_Err_2,PP_3_Err_3,PP_3_Err_4,PP_3_PV,
												   PP_4_Err_1,PP_4_Err_2,PP_4_Err_3,PP_4_Err_4,PP_4_PV,
					  input       [pixel_size-1:0] PP_1_Err_0,PP_2_Err_0,PP_3_Err_0,PP_4_Err_0,
					  input                        PP_1_HTPV,PP_2_HTPV,PP_3_HTPV,PP_4_HTPV,
					  input       [1:N_col*M_row*pixel_size] pixel_bits,
					  input       [23:0] 					 index,
					  input                                  Go,clk_i,rst_n,Ld_image,Ld_values
						);
						
	reg [pixel_size-1:0] PV [1:N_col][1:M_row];//图像点像素值数组
	
	reg HTPV [1:N_col][1:M_row];//处理后的图像点数据数组
	
	reg [pixel_size-1:0] Err [0:N_col + 1][0:M_row];//与图像处理点相邻的四个像素点值数组
	
	genvar nn,mm;
	generate
		for (mm = 1; mm <= M_row; mm = mm + 1) begin:HTPV_row_loop
			for(nn = 1; nn <= N_col; nn = nn + 1) begin : HTPV_col_loop
				assign HTPV_bits[(mm - 1) * N_col + nn] = HTPV[nn][mm];
			end
		end
	endgenerate
	
	wire [5:0] index_1 = index[23:18],
			   index_2 = index[17:12],
			   index_3 = index[11:6],
			   index_4 = index[5:0]; //分别对应四个图像处理单元处理图像点的地址
			   
	
	always @(index_1) begin  //图像处理单元1的处理像素点
		case(index_1)
		
			1,2,3,4,5,6,7,8 : begin
								PP_1_Err_1 = Err[index_1 - 1][1];  //N列 * M行
								PP_1_Err_2 = Err[index_1 - 1][0];
								PP_1_Err_3 = Err[index_1][0];
								PP_1_Err_4 = Err[index_1 + 1][0];
								PP_1_PV    = PV [index_1][1];
							end
							
			15,16           :  begin
								PP_1_Err_1 = Err[index_1 - 1 - 8][2];
								PP_1_Err_2 = Err[index_1 - 1 - 8][1];
								PP_1_Err_3 = Err[index_1 - 1 - 7][1];
								PP_1_Err_4 = Err[index_1 - 1 - 6][1];
								PP_1_PV    = PV[index - 1 - 7][2];
							end
							
			23,24           : begin
								PP_1_Err_1 = Err[index_1 - 1 - 16][3];
								PP_1_Err_2 = Err[index_1 - 1 - 16][2];
								PP_1_Err_3 = Err[index_1 - 16][2];
								PP_1_Err_4 = Err[index_1 - 1 - 15][2];
								PP_1_PV    = PV[index - 16][3];
							end
							
			default         : begin 
								PP_1_Err_1 = 8'bx;
								PP_1_Err_2 = 8'bx;
								PP_1_Err_3 = 8'bx;
								PP_1_Err_4 = 8'bx;
								PP_1_PV    = 8'bx;
							end
		endcase
	end
								
	
	always 	@(index_2) begin //图像处理单元2的处理像素点
		case (index_2)
			
			9,10,11,12,13,14 : begin
								PP_2_Err_1 = Err[index_2 - 1 - 8][2];  //N列 * M行
								PP_2_Err_2 = Err[index_2 - 1 - 8][1];
								PP_2_Err_3 = Err[index_2 - 8][1];
								PP_2_Err_4 = Err[index_2 - 7][1];
								PP_2_PV    = PV [index_2 - 8][2];
							end
							
			21,22            : begin
								PP_2_Err_1 = Err[index_2 - 1 - 16][3];  //N列 * M行
								PP_2_Err_2 = Err[index_2 - 1 - 16][2];
								PP_2_Err_3 = Err[index_2 - 1 - 15][2];
								PP_2_Err_4 = Err[index_2 - 1 - 14][2];
								PP_2_PV    = PV [index_2 - 16][3];
							end
			
							
			29,30,31,32      : begin
								PP_2_Err_1 = Err[index_2 - 1 - 24][4];  //N列 * M行
								PP_2_Err_2 = Err[index_2 - 1 - 24][3];
								PP_2_Err_3 = Err[index_2 - 1 - 23][3];
								PP_2_Err_4 = Err[index_2 - 1 - 22][3];
								PP_2_PV    = PV [index_2 - 24][4];
							end
							
			default          : begin
								PP_2_Err_1 = 8'bx;
								PP_2_Err_2 = 8'bx;
								PP_2_Err_3 = 8'bx;
								PP_2_Err_4 = 8'bx;
								PP_2_PV    = 8'bx;
							end
		endcase
	end
								
	always 	@(index_3) begin //图像处理单元3的处理像素点
		case (index_3)
			
			17,18,19,20     : begin
								PP_3_Err_1 = Err[index_3 - 1 - 16][3];  //N列 * M行
								PP_3_Err_2 = Err[index_3 - 1 - 16][2];
								PP_3_Err_3 = Err[index_3 - 1 - 15][2];
								PP_3_Err_4 = Err[index_3 - 1 - 14][2];
								PP_3_PV    = PV [index_3 - 16][3];
							end
							
			27,28           : begin
								PP_3_Err_1 = Err[index_3 - 1 - 24][4];  //N列 * M行
								PP_3_Err_2 = Err[index_3 - 1 - 24][3];
								PP_3_Err_3 = Err[index_3 - 1 - 23][3];
								PP_3_Err_4 = Err[index_3 - 1 - 22][3];
								PP_3_PV    = PV [index_3 - 24][4];
							end
							
			35,36,37,38,39,40 : begin
								PP_3_Err_1 = Err[index_3 - 1 - 32][5];  //N列 * M行
								PP_3_Err_2 = Err[index_3 - 1 - 32][4];
								PP_3_Err_3 = Err[index_3 - 1 - 31][4];
								PP_3_Err_4 = Err[index_3 - 1 - 30][4];
								PP_3_PV    = PV [index_3 - 32][5];
							end
			
			default          : begin
								PP_3_Err_1 = 8'bx;
								PP_3_Err_2 = 8'bx;
								PP_3_Err_3 = 8'bx;
								PP_3_Err_4 = 8'bx;
								PP_3_PV    = 8'bx;
							end
		endcase
	end
		
	
	always 	@(index_4) begin //图像处理单元4的处理像素点
		case (index_4)
			
			25,26          : begin
								PP_4_Err_1 = Err[index_4 - 1 - 24][4];  //N列 * M行
								PP_4_Err_2 = Err[index_4 - 1 - 24][3];
								PP_4_Err_3 = Err[index_4 - 1 - 23][3];
								PP_4_Err_4 = Err[index_4 - 1 - 22][3];
								PP_4_PV    = PV [index_4 - 24][4];
							end
							
			33,34          : begin
								PP_4_Err_1 = Err[index_4 - 1 - 32][5];  //N列 * M行
								PP_4_Err_2 = Err[index_4 - 1 - 32][4];
								PP_4_Err_3 = Err[index_4 - 1 - 31][4];
								PP_4_Err_4 = Err[index_4 - 1 - 30][4];
								PP_4_PV    = PV [index_4 - 32][5];
							end
							
			41,42,43,44,45,46,47,48 : begin
										PP_4_Err_1 = Err[index_4 - 1 - 40][6];  //N列 * M行
										PP_4_Err_2 = Err[index_4 - 1 - 40][5];
										PP_4_Err_3 = Err[index_4 - 1 - 39][5];
										PP_4_Err_4 = Err[index_4 - 1 - 38][5];
										PP_4_PV    = PV [index_4 - 40][6];
									end
			
			default :         begin
								PP_4_Err_1 = 8'bx;
								PP_4_Err_2 = 8'bx;
								PP_4_Err_3 = 8'bx;
								PP_4_Err_4 = 8'bx;
								PP_4_PV    = 8'bx;
							end
		endcase
	end
	
	
	integer n,m;
	
	always @ (posedge clk_i) begin
		
		if(!rst_n) begin
			for(m = 0; m <= M_row ; m = m + 1)
				for(n = 0 ;n <= N_col + 1; n = n + 1)
					Err[n][m] <= 0;
			
			for(m = 1; m <= M_row ; m = m + 1)
				for(n = 1 ;n <= N_col ; n = n + 1)
					PV[n][m] <= 0;
		end
	
	
		else if(Ld_image) begin : Array_Initialization	
			for(m = 1; m <= M_row ; m = m + 1) begin : row_loop
				for(n = 1; n <= N_col ; n = n + 1) begin : col_loop
					Err[n][m] <= 0;
					PV[n][m]  <= pixel_bits[(m-1) * N_col * pixel_size + (n-1) * pixel_size + 1 +: pixel_size];
				end
			end
		end
		
	    else if(Ld_values) begin : Image_Conversion
			
			case(index_1)
				
				1,2,3,4,5,6,7,8 : begin
									Err [index_1][1]  <= PP_1_Err_0;
									HTPV[index_1][1]  <= PP_1_HTPV;
								 end
								 
				15,16           : begin
									Err [index_1 - 8][2] <= PP_1_Err_0;
									HTPV[index_1 - 8][2] <= PP_1_Err_0;
								end
								
				23,24           : begin	
									Err [index_1 - 16][3] <= PP_1_Err_0;
									HTPV[index_1 - 16][3] <= PP_1_Err_0;
								end
				
			endcase
			
			case(index_2)
				
				9,10,11,12,13,14 : begin
									Err [index_2 - 8][2]  <= PP_2_Err_0;
									HTPV[index_2 - 8][2]  <= PP_2_HTPV;
								 end
								 
				21,22           : begin
									Err [index_2 - 16][3] <= PP_2_Err_0;
									HTPV[index_2 - 16][3] <= PP_2_Err_0;
								end
								
				29,30,31,32     : begin	
									Err [index_2 - 24][4] <= PP_2_Err_0;
									HTPV[index_2 - 24][4] <= PP_2_Err_0;
								end
				
			endcase
					
			case(index_3)
				
				17,18,19,20 : begin
									Err [index_3 - 16][3]  <= PP_3_Err_0;
									HTPV[index_3 - 16][3]  <= PP_3_HTPV;
								 end
								 
				27,28           : begin
									Err [index_3 - 24][4] <= PP_3_Err_0;
									HTPV[index_3 - 24][4] <= PP_3_Err_0;
								end
								
				35,36,37,38,39,40     : begin	
											Err [index_3 - 32][5] <= PP_3_Err_0;
											HTPV[index_3 - 32][5] <= PP_3_Err_0;
										end
				
			endcase
			
			case(index_4)
				
				25,26          : begin
									Err [index_4 - 24][3]  <= PP_4_Err_0;
									HTPV[index_4 - 24][3]  <= PP_4_HTPV;
								 end
								 
				33,34           : begin
									Err [index_4 - 32][5] <= PP_4_Err_0;
									HTPV[index_4 - 32][3] <= PP_4_Err_0;
								end
								
				41,42,43,44,45,46,47,48     : begin	
												Err [index_2 - 40][6] <= PP_4_Err_0;
												HTPV[index_2 - 40][6] <= PP_4_Err_0;
											end
				
			endcase
			
		end
		
	end
	
endmodule
			
				
									
										
								
								