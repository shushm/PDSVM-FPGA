`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:11:07 01/12/2018 
// Design Name: 
// Module Name:    svm_train 
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
module svm_train(

       input             train_clk,          //input clock
		 input             rst_n,              //input reset
       input             svm_train_enable,   //input enable
		 output reg        test_end_sign,       //train_end
		 output reg [207:0] ss_out,            //128
		 output reg [79:0] s_out,
		 output reg [79:0] sv_out,
		 output reg [31:0] svm_b,              //
		 
		 output reg        alpha_read_start,
		 output reg        alpha_pard_start,
		 output reg [29:0] alpha_rd_ddr,
		 output reg [29:0] alpha_rdZ_ddr,
		 output reg [29:0] alpha_rdN_ddr,
		 output reg [29:0] alpha_rdT_ddr,
		 output reg [29:0] alpha_rdH_ddr,//
		 input [31:0]      data_rd_x,    
		 input [31:0]      data_rd_y,             
		 input [31:0]      data_rd_z,             
		 input [31:0]      data_rd_w,            
		 
		 input             ddr_end,
		 input [15:0]      num_sample,
		 input [31:0]      sample_addr,
		 input [31:0]      sample_alpha,
		 input             alpha_read_end,
		 input      [31:0] alpha_data_in,
       output reg        alpha_wr_start,
       output reg [31:0] alpha_wr_data,
       output reg [29:0] alpha_wr_ddr,       
       input             alpha_wr_end,
		 input             off_on_sign
		 
);

      //parameter sample = 80;//SampleNum,16
		//parameter labels = 80;//16
		//parameter par_num = 20;//
		///////////////////////mul_sign
      reg [31:0] A_one;
		//reg [16:0] A_par_one;
		reg [31:0] A_two;
		//reg [16:0] A_par_two;
		reg [31:0] B_one;
		//reg [16:0] B_par_one;
		reg [31:0] B_two;
		//reg [16:0] B_par_two;
		reg [31:0] C_one;
		//reg [16:0] C_par_one;
		reg [31:0] C_two;
		//reg [16:0] C_par_two;
		reg [31:0] D_one;
		//reg [16:0] D_par_one;;
	   reg [31:0] D_two;
		//reg [16:0] D_par_two;
	   //reg [31:0] mpar_one;
	   //reg [31:0] mpar_two;
		//reg [31:0] mpar_three;
		//reg [31:0] mpar_four;
		
		reg start_A;
		//reg start_AP;
		reg start_B;
		//reg start_BP;
		reg start_C;
		//reg start_CP;
		reg start_D;
		//reg start_DP;
	   //reg start_E;
		
		wire [31:0] data_one;
		//wire [31:0] data_apar;
	   wire busy_one;
		//wire busy_apar;
		wire [31:0] data_two;
		//wire [31:0] data_bpar;
	   wire busy_two;
		//wire busy_bpar;
		wire [31:0] data_three;
		//wire [31:0] data_cpar;
	   wire busy_three;
		//wire busy_cpar;
		wire [31:0] data_four;
		//wire [31:0] data_dpar;
	   wire busy_four;
		//wire busy_dpar;
	   ///wire [31:0] data_five;
	   ///wire busy_five;
		
		reg [31:0] data_par_one;
		reg [31:0] data_par_two;
		reg [31:0] data_par_three;
		reg [31:0] data_par_four;
		//////////////////////div_sign
		wire div_busy;
		wire [31:0] div_out;
		reg div_sign;
		
      reg [31:0] eps;
		reg [31:0] tolerance;		
      reg [11:0] iterCounter;
		reg [11:0] numChanged;
		reg [31:0] c;
		reg examineall;//布尔型，boolean
		
		//////////////////////////////////////开始训练，状态机
		reg [5:0] status;
      reg [5:0] s_state_reg;
      reg [5:0] s_state_mul;
      reg [31:0] svc_reg;
		reg [31:0] svz_reg;
		reg [31:0] svn_reg;
		reg [31:0] svt_reg;
		reg [31:0] svh_reg;
		reg [31:0] sum_par_one;
		reg [31:0] sum_par_two;
		reg par_add_sign;
		reg par_mul_end;
		
      reg [31:0] smo_reg;
      reg [11:0] i_or_e;//i_one,i_two,e_cnt	
      reg [29:0] address_reg;
      reg [31:0] alpha_er;		
		parameter s_idle =          6'b000000;//0
		parameter s_while_ori =     6'b000001;//1
		parameter s_s_b =           6'b000010;//2
		parameter s_three =         6'b000011;//3
		parameter s_four =          6'b000100;//4
		//parameter s_mul_one =     6'b000101;//5
		parameter s_rd_ddr =        6'b000101;//5
		parameter s_five =          6'b000110;//6
		parameter s_nine =          6'b000111;//7
		parameter s_ten =           6'b001000;//8
		parameter s_twelve =        6'b001001;//9
		//parameter s_mul_two =     6'b001010;//10
		parameter s_rd_mul =        6'b001010;//10
		parameter s_thirteen =      6'b001011;//11
		//parameter s_mul_three =   6'b001100;//12
		parameter s_rd_kernel =     6'b001100;//12
		parameter s_fourteen =      6'b001101;//13
		parameter s_fifteen =       6'b001110;//14
		parameter s_eta =           6'b001111;//15
		parameter s_eta_end =       6'b010000;//16
		parameter s_sixteen =       6'b010001;//17
		parameter s_update =        6'b010010;//18
		parameter s_bnew =          6'b010011;//19
		parameter s_b_one =         6'b010100;//20//
		parameter s_b_two =         6'b010101;//21
		//parameter s_btwo_end =    6'b010110;//22
		parameter s_rd_ker =        6'b010110;//22
		parameter s_bot =           6'b010111;//23
		parameter s_deltaB =        6'b011000;//24
		parameter s_error =         6'b011001;//25
		parameter s_error_one =     6'b011010;//26//
		parameter s_error_two =     6'b011011;//27
		//parameter s_error_end =   6'b011100;//28
		parameter s_rd_kertwo =     6'b011100;//28
		parameter s_finish =        6'b011101;//29
		parameter s_flag =          6'b011110;//30
		
		parameter s_error_onend =   6'b011111;//31
		parameter s_add_error =     6'b100000;//32
		parameter s_wr_errorcache = 6'b100001;//33
		parameter s_wr_ddr =        6'b100010;//34
		parameter s_wr_alpha =      6'b100011;//35
		parameter s_update_Alpha =  6'b100100;//36
		parameter s_sub_ktrain =    6'b100101;//37
		parameter s_waiting =       6'b100110;//38
		
		parameter s_rd_errorcache = 6'b100111;//39
		parameter s_r_two =         6'b101000;//40
		parameter s_E_two =         6'b101001;//41
		parameter s_rd_kernum =     6'b101010;//42
		parameter s_rd_kerdata =    6'b101011;//43
		parameter s_update_Error =  6'b101100;//44
		parameter s_rd_Errordata =  6'b101101;//45
		parameter s_rd_kerone =     6'b101110;//46
		parameter s_wr_alphatwo =   6'b101111;//47
		parameter s_test =          6'b110000;//48
		parameter s_par_ddr =       6'b110001;//49
		parameter s_par_mul =       6'b110010;//49
		parameter s_four_mul =      6'b110011;//49
		
		reg start_svm;
		reg begin_svm;
		reg flag_svm;
		
		reg [31:0] r_two;
		reg [11:0] i_one;//31
		reg [11:0] i_two;//31
		reg [11:0] qq;//31
		
		reg [31:0] alpha_one;
		reg [31:0] alpha_two;
		reg        y_one;    //[31:0]
		reg        y_two;    //[31:0]
		reg [31:0] E_one;
		reg [31:0] E_two;
		reg [31:0] a_one;
		reg [31:0] a_two;
		
		reg        s;//[31:0]
		reg [31:0] L;
		reg [31:0] H;
		reg [31:0] L_H;
		reg [31:0] a_L;
		reg [31:0] a_H;
		reg [31:0] aa_c;
		reg [31:0] a_a;
		reg [31:0] a_two_alpha;
		
		reg [31:0] eta;
		reg [31:0] bNew;
		reg [31:0] deltaB;
		reg [31:0] b_add_b;
		reg [31:0] b_two;
		reg [31:0] b_one;
		reg [31:0] t_one;
		reg [31:0] t_two;
		reg [31:0] k_one_two;
		reg [31:0] k_one_one;
		reg [31:0] k_two_two;

		reg [31:0] sub_ee;
		reg [31:0] KK_train;
		reg [31:0] sub_e;
		reg [31:0] KK_tri;/////
		
		//==reg [31:0] svm_b;
		//reg        train_start;
		
		reg        busy_YN;
		reg        busy_btwo;
		reg        busy_bone;
		reg        busy_bthree;
		reg        busy_TK_one;
		reg        busy_sumone;
		reg        busy_sumtwo;
		reg        busy_sumthree;
		reg        busy_a_two;
		
		reg [11:0] e_cnt;
		reg [11:0] error_cnt;
		reg [31:0] sum_one;
		reg [31:0] sum_two;
		reg [31:0] sum_three;
		reg        alpha_rd_flag;
		reg        alpha_wr_flag;
		reg        errorcache_wr_flag;
		
		reg        test_ddr;
		
		reg [7:0]  delay_count;
		reg [31:0] RT;///
		reg [15:0] sp_num;//==//
		reg [29:0] sp_addr;//==//
		reg [29:0] sp_alpha;//==//
		reg [29:0] sp_reg_alpha;
		//==reg [79:0] s_out;//-
		//==reg [79:0] sv_out;//=
		
		//==reg [29:0] adds_reg [79:0];////--
		////////////////////////////////////////////////////////////////
		always @(posedge train_clk or negedge rst_n)
	   begin
		    if(!rst_n)
			 begin
			     /////////////////////		
			     start_A <= 1'b0;
				  start_B <= 1'b0;
				  start_C <= 1'b0;
				  start_D <= 1'b0;
				  
				  A_one <= 32'd0;
				  A_two <= 32'd0;
				  B_one <= 32'd0;
				  B_two <= 32'd0;		
				  C_one <= 32'd0;				  
				  C_two <= 32'd0;				  
				  D_one <= 32'd0;
				  D_two <= 32'd0;				  
				  data_par_one <= 32'd0;
				  data_par_two <= 32'd0;
				  data_par_three <= 32'd0;
				  data_par_four <= 32'd0;					
				  start_svm <= 1'b0;
				  begin_svm <= 1'b0;
				  r_two <= 32'd0;
				  i_one <= 12'd0;//32
				  i_two <= 12'd0;//32
				  qq <= 12'd0;//32
				  flag_svm <= 1'b0;				  
				  alpha_one <= 32'd0;
				  alpha_two <= 32'd0;
				  y_one <= 1'b0;//32
				  y_two <= 1'b0;//32
				  E_one <= 32'd0;
				  E_two <= 32'd0;
				  a_one <= 32'd0;
				  a_two <= 32'd0;
				  s <= 1'b0;//32
				  L <= 32'd0;
				  H <= 32'd0;
				  L_H <= 32'd0;
				  a_L <= 32'd0;
				  a_H <= 32'd0;
				  aa_c <= 32'd0;
				  a_a <= 32'd0;
				  a_two_alpha <= 32'd0;				  
				  eta <= 32'd0;
				  bNew <= 32'd0;
				  deltaB <= 32'd0;
				  b_add_b <= 32'd0;
				  b_two <= 32'd0;
				  b_one <= 32'd0;
				  t_one <= 32'd0;
				  t_two <= 32'd0;
				  k_one_one <= 32'd0;
				  k_one_two <= 32'd0;
				  k_two_two <= 32'd0;				  
				  sub_ee <= 32'd0;
				  KK_train <= 32'd0;
				  sub_e <= 32'd0;
				  KK_tri <= 32'd0;
		          div_sign <= 1'b0;			  
				  svm_b <= 32'd0;
				  status <= s_idle;//
				  s_state_reg <= s_idle;//				  
				  busy_a_two <= 1'b0;
				  busy_TK_one <= 1'b0;
				  busy_YN <= 1'b1;
				  busy_btwo <= 1'b0;
				  busy_bone <= 1'b0;
				  busy_bthree <= 1'b0;
				  busy_sumone <= 1'b0;
				  busy_sumtwo <= 1'b0;
				  busy_sumthree <= 1'b0;				  
				  /////////////////////////////////////////////////////
			     c <= 32'h00028000;//C = 1,0.5,0.25,修改C，偏离置信
			     iterCounter <= 0;
			     numChanged <= 0;
			     examineall <= 1'b1;//初始置1
			  
			     eps <= 32'b00000000000000000000000001000010;//0.00100708,0.00098
			     tolerance <= 32'b00000000000000000000000001000010;//0.00100708
				  
				  test_end_sign <= 1'b0;
				  ss_out <= 208'd0;
				  alpha_rd_flag <= 1'b0;
				  alpha_wr_flag <= 1'b0;
				  errorcache_wr_flag <= 1'b0;
				  alpha_read_start <= 1'b0;//
				  alpha_rd_ddr <= 30'd0;//
				  alpha_wr_start <= 1'b0;//
				  alpha_wr_data <= 32'd0;//
				  alpha_wr_ddr <= 30'd0;//
				  svc_reg <= 32'd0;
				  svz_reg <= 32'd0;
				  svn_reg <= 32'd0;
				  svt_reg <= 32'd0;
				  svh_reg <= 32'd0;
				  sum_par_one <= 32'd0;
				  sum_par_two <= 32'd0;
				  e_cnt <= e_cnt + 4;
				  par_add_sign <= 1'b0;
				  par_mul_end <= 1'b0;
				  alpha_pard_start <= 1'b0;
				  
				  smo_reg <= 32'd0;
				  e_cnt <= 12'd0;
				  error_cnt <= 12'd0;
				  sum_one <= 32'd0;
				  sum_two <= 32'd0;
				  sum_three <= 32'd0;
				  
				  test_ddr <= 1'b0;
				  delay_count <= 8'd0;
				  address_reg <= 30'd0;
				  alpha_er <= 32'd0;
				  RT <= 32'd0;///
				  s_out <= 80'd0;//-
				  sv_out <= 80'd0;//=
				  sp_num <= 16'd0;//==//
				  sp_addr <= 30'd0;//==//
              sp_alpha <= 30'd0;//==//
				  sp_reg_alpha <= 30'd0;

			 end
			 else begin
				          //////////////////////////////////////////////////////svm训练过程
							 case (status)
							 s_waiting: 
							       begin
									    status <= s_waiting;
										 test_end_sign <= 1'b1;
										 ss_out <= ss_out;
									 end
							 s_idle:                                            //s_idle:等待,0
									 begin
											if(svm_train_enable == 1'b1)
											begin
												  if((numChanged > 0)||(examineall == 1'b1))//(numChanged > 0)||
												  begin
														 i_two <= 0;
														 numChanged <= 0;
														 status <= s_while_ori;//开始循环
														 
												  end
												  else begin														
														 status <= s_waiting;//														 
														 svm_b <= svm_b;
														 ss_out <= {4'd0,iterCounter[11:0],s_out,svm_b[31:0],sv_out};
												  end
											end
											else begin
												  status <= s_idle;//
												  if(ddr_end == 1'b1)
												  begin
												  sp_num <= num_sample;//==//
												  sp_addr <= sample_addr;//==//
												  sp_alpha <= sample_alpha;//==//
												  sp_reg_alpha <= sample_alpha + 252;//==//
												  end
											end
									 end
							 s_while_ori: //1
									  begin
										if(i_two < (sp_num<<1))//==(sample-1)
											begin
												flag_svm <= 1'b0;/////
												start_svm <= 1'b0;
												begin_svm <= 1'b0;
												if(off_on_sign == 1'b1)
												begin
												    alpha_rd_ddr <= sp_alpha + (i_two<<4);     //alpha2,160,56960
												    alpha_read_start <= 1'b1;
													s_state_reg <= s_s_b;///--s_wr_errorcache;///
													status <= s_rd_ddr;
												end													 
											end
												else if(i_two >= (sp_num<<1))
												begin
													 examineall <= 1'b0;
													 iterCounter <= iterCounter + 1;
													 status <= s_idle;//开始下一轮循环
												end
											 
									  end
							 s_rd_ddr:
							       begin
									     alpha_rd_flag <= alpha_read_end;
										  if(!alpha_rd_flag && alpha_read_end)//上升沿检测
										  begin
												alpha_read_start <= 1'b0;               //read信号
												svc_reg <= alpha_data_in;          //alpha(i2)										
										  end
										  if(alpha_rd_flag && !alpha_read_end)//下降沿检测
										  //-if(alpha_read_end == 1'b0 && alpha_read_start == 1'b0)
										  begin
											   status <= s_state_reg;//--s_waiting;//
										  	   alpha_rd_flag <= 1'b0; 
										  end
									 end
							 s_par_ddr:begin
							       alpha_rd_flag <= alpha_read_end;
									 if(!alpha_rd_flag && alpha_read_end)//上升沿检测
									 begin
									    alpha_pard_start <= 1'b0;               //read信号
										 //==alpha_read_start <= 1'b0;               //read信号
										 svz_reg <= data_rd_x;          //alpha(i2)
                               svn_reg <= data_rd_y;
                               svt_reg <= data_rd_z;
                               svh_reg <= data_rd_w;										 
									 end
									 if(alpha_rd_flag && !alpha_read_end)//下降沿检测
									//-if(alpha_read_end == 1'b0 && alpha_read_start == 1'b0)
									 begin
										status <= s_state_reg;//--s_waiting;//
										alpha_rd_flag <= 1'b0; 
									 end
							 end
							 s_s_b://2
									 begin
											if(examineall == 1'b1)
											begin
												  start_svm <= 1'b1;
												  status <= s_three;
											end
											else begin
												  if((svc_reg != 0)&&(svc_reg != c))
												  begin
														 start_svm <= 1'b0;
														 begin_svm <= 1'b1;
														 status <= s_three;
												  end
												  else begin
														 start_svm <= 1'b0;
														 begin_svm <= 1'b0;
														 status <= s_three;
												  end
											end
									 
									 end
							 s_three: //3
									  begin
											 if((start_svm == 1'b1)||(begin_svm == 1'b1))
											 begin
													y_two <= (i_two < sp_num)? 0 : 1;//6个样本<=2,0正1负
													alpha_two <= svc_reg;
													E_two <= 32'd0;
													e_cnt <= 12'd0;
													sum_one <= 32'd0;
													status <= s_four;
											 end
											 else begin
											      y_two <= (i_two < sp_num)? 0 : 1;//6个样本<=2,0正1负
													alpha_two <= svc_reg;
													E_two <= 32'd0;
													e_cnt <= 12'd0;
											      sum_one <= 32'd0;
													status <= s_flag;/////问题修改
											 end
									  end
							 s_four: //4
									 begin
											if((alpha_two[31] == 0)&&(alpha_two > 0)&&(alpha_two < c))
											begin
											     if(off_on_sign == 1'b1)
												  begin
												  s_state_reg <= s_r_two;
												  status <= s_rd_ddr;
												  alpha_read_start <= 1'b1;
												  alpha_rd_ddr <= sp_alpha + (sp_num<<5) + (i_two<<4);//200,58256
												  end
											end
											else begin
												  if(e_cnt < (sp_num<<1))
												  begin
												     if(off_on_sign == 1'b1)
													  begin
													  s_state_reg <= s_rd_errorcache;//s_four;
                                         alpha_rdZ_ddr <= sp_alpha + (e_cnt<<4);//160
                                         alpha_rdN_ddr <= sp_alpha + ((e_cnt+1)<<4);//160
													  alpha_rdT_ddr <= sp_alpha + ((e_cnt+2)<<4);//160
													  alpha_rdH_ddr <= sp_alpha + ((e_cnt+3)<<4);//160
													  alpha_pard_start <= 1'b1;
													  status <= s_par_ddr;//==s_rd_ddr;
                                         end													  
												  end
												  else begin
													  E_two <= (y_two == 0)?(sum_one + svm_b - 32'h00010000):(sum_one + svm_b + 32'h00010000);
													  status <= s_five;//-
													  e_cnt <= 0;
													  r_two <= (y_two == 0)?(sum_one + svm_b - 32'h00010000):(0 - sum_one - svm_b - 32'h00010000);//(~(sum_one) + 1)
												  end
											end
									 end
                      s_rd_errorcache:begin
									s_state_mul <= s_four;
									A_one <= svz_reg;
									B_one <= svn_reg;
 									C_one <= svt_reg;
								   D_one <= svh_reg;									  
                           if(e_cnt >= i_two)
							  begin
                              if(off_on_sign == 1'b1)
										begin									  
										alpha_rdZ_ddr <= sp_addr + ((e_cnt*(e_cnt+1))<<3) + (i_two<<4);//5120
										alpha_rdN_ddr <= sp_addr + (((e_cnt+1)*(e_cnt+2))<<3) + (i_two<<4);
										alpha_rdT_ddr <= sp_addr + (((e_cnt+2)*(e_cnt+3))<<3) + (i_two<<4);
										alpha_rdH_ddr <= sp_addr + (((e_cnt+3)*(e_cnt+4))<<3) + (i_two<<4);
										alpha_pard_start <= 1'b1;
										status <= s_par_mul;
                              end										 
									end								  
									else if((e_cnt+3) <= i_two)
									begin
									 if(off_on_sign == 1'b1)
									 begin
										alpha_rdZ_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + (e_cnt<<4);
										alpha_rdN_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + ((e_cnt+1)<<4);
										alpha_rdT_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + ((e_cnt+2)<<4);
										alpha_rdH_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + ((e_cnt+3)<<4);
										alpha_pard_start <= 1'b1;
										status <= s_par_mul;
								    end
									end
									else begin
									   if(off_on_sign == 1'b1)
									   begin									  
										alpha_rdZ_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + (e_cnt<<4);
										alpha_rdN_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + ((e_cnt+1)<<4);
										alpha_rdT_ddr <= sp_addr + (((e_cnt+2)*(e_cnt+3))<<3) + (i_two<<4);
										alpha_rdH_ddr <= sp_addr + (((e_cnt+3)*(e_cnt+4))<<3) + (i_two<<4);
										alpha_pard_start <= 1'b1;
										status <= s_par_mul;
                              end
                           end
                      end						 
							 s_r_two:
								begin
									E_two <= svc_reg;
									status <= s_five;//-
									r_two <= (y_two == 0)?(svc_reg):(0 - svc_reg);
								end
						 
                      s_rd_mul:
							       begin
									    alpha_rd_flag <= alpha_read_end;
										 if(!alpha_rd_flag && alpha_read_end)//上升沿检测
										 begin
												alpha_read_start <= 1'b0;               //read信号
												A_one <= A_one;
												A_two <= alpha_data_in;
										 end
										 if(alpha_rd_flag && !alpha_read_end)//下降沿检测
										 begin
											   start_A <= 1'b1;
										 	   alpha_rd_flag <= 1'b0;
												e_cnt <= e_cnt + 1;
										 end
										 busy_sumone <= busy_one;
										 if(busy_sumone && !busy_one)//下降沿检测
										 begin
												start_A <= 0;
												sum_one <= (e_cnt <= sp_num)?(sum_one + data_one):(sum_one - data_one);//2
												status <= s_state_mul;
                                    alpha_rd_flag <= 1'b0;												
										 end 
									 end
                      s_par_mul:begin
                               alpha_rd_flag <= alpha_read_end;
										 if(!alpha_rd_flag && alpha_read_end)//上升沿检测
										 begin
												//alpha_read_start <= 1'b0;               //read信号
												alpha_pard_start <= 1'b0;
												A_one <= A_one;
												A_two <= data_rd_x;
												B_one <= B_one;
												B_two <= data_rd_y;
												C_one <= C_one;
												C_two <= data_rd_z;
												D_one <= D_one;
												D_two <= data_rd_w;
										 end
										 if(alpha_rd_flag && !alpha_read_end)//下降沿检测
										 begin
											   start_A <= 1'b1;
												start_B <= 1'b1;
												start_C <= 1'b1;
												start_D <= 1'b1;
										 	   alpha_rd_flag <= 1'b0;
												e_cnt <= e_cnt + 4;//4
										 end
										 busy_sumone <= busy_one;
										 if(busy_sumone && !busy_one)//下降沿检测
										 begin
												start_A <= 1'b0;
												start_B <= 1'b0;
												start_C <= 1'b0;
												start_D <= 1'b0;
												par_add_sign <= 1'b1;
												data_par_one <= (e_cnt <= sp_num)?data_one:(0 - data_one);
												data_par_two <= (e_cnt <= sp_num)?data_two:(0 - data_two);
												data_par_three <= (e_cnt <= sp_num)?data_three:(0 - data_three);
												data_par_four <= (e_cnt <= sp_num)?data_four:(0 - data_four);

                                    alpha_rd_flag <= 1'b0;												
										 end
										 if(par_add_sign == 1'b1)
										 begin
										    alpha_rd_flag <= 1'b0;
										    par_add_sign <= 1'b0;
										    par_mul_end <= 1'b1;
										    sum_par_one <= data_par_one + data_par_two;
											 sum_par_two <= data_par_three + data_par_four;
										 end
										 if(par_mul_end == 1'b1)
										 begin
										    par_mul_end <= 1'b0;
											 status <= s_state_mul;
											 sum_one <= sum_one + sum_par_one + sum_par_two;//2
										 end 
									end							 
							 s_five://6
									begin 
										if(((r_two[31] == 1)&&((0 - r_two)> tolerance)&&(alpha_two < c)))
										begin
											i_one <= 12'd0;
											qq <= 12'd0;
											status <= s_nine;
											sum_one <= 32'd0;
										end
										else if(((r_two[31] == 0)&&(r_two > tolerance)&&(alpha_two > 0)))
										begin
										   i_one <= 12'd0;
											qq <= 12'd0;
											status <= s_nine;
											sum_one <= 32'd0;
										end
										else begin
										   sum_one <= 32'd0;
											status <= s_flag;//判断numChanged是否加1
										end
									end
							s_nine://7
									begin
										  if(qq < (sp_num<<1)) 
										  begin
											  if(qq == ((sp_num<<1) - 1))
											  begin
												  i_one <= 0;
												  status <= s_ten;
											  end
											  else begin
												  i_one <= qq + 1;
												  status <= s_ten;
											  end
										  end
										  else begin
										       qq <= 0;///
												 status <= s_flag;//判断numChanged是否加1
										  end
										  
									end
							
							s_ten://8
									begin
										  if(i_one == i_two)
										  begin
												 qq <= qq + 1;
												 flag_svm <= 0;
												 status <= s_nine;
										  end
										  else begin
										       if(off_on_sign == 1'b1)
												 begin
										       alpha_read_start <= 1'b1;
												 alpha_rd_ddr <= sp_alpha + (i_one<<4);//alpha_one,160,56960
												 address_reg <= sp_alpha + (i_two<<4);//160,56960
												 s_state_reg <= s_update_Alpha;
												 status <= s_rd_ddr;//s_twelve;
												 end

												 y_one <= (i_one < sp_num)?0:1;//6个样本,2
												 y_two <= (i_two < sp_num)?0:1;//6个样本,2
												 E_one <= 32'd0;
												 E_two <= 32'd0;
												 a_one <= 32'd0;
												 a_two <= 32'd0;
												 L <= 32'd0;
												 H <= 32'd0;
												 L_H <= 32'd0;
												 a_L <= 32'd0;
												 a_H <= 32'd0;
												 aa_c <= 32'd0;
												 a_a <= 32'd0;
												 a_two_alpha <= 32'd0;
												 sum_one <= 32'd0;
												 sum_two <= 32'd0;
												 sum_three <= 32'd0;

										  end
									end
							s_update_Alpha:begin
							      alpha_one <= svc_reg;
							      if(off_on_sign == 1'b1)
									begin
										alpha_rd_ddr <= address_reg;//64
										s_state_reg <= s_update_Error;									
									   alpha_read_start <= 1'b1;	
										status <= s_rd_ddr;
									end
                     end							
							s_update_Error:
							      begin 											 								
										alpha_two <= svc_reg;	
										s <= ((y_one+y_two) == 1)?(1'b1):(1'b0);
										if(off_on_sign == 1'b1)
									   begin
										alpha_rd_ddr <= sp_alpha + (sp_num<<5) + (i_one<<4);//E1,200 ,58256
										alpha_read_start <= 1'b1;
										s_state_reg <= s_twelve;
										status <= s_rd_ddr;
                              end										
									end
							s_twelve://9
									 begin
											if((alpha_one[31] == 0)&&(alpha_one > 0)&&(alpha_one < c))
											begin
												  E_one <= svc_reg;
												  status <= s_E_two;
											end
											else begin
												  if(e_cnt < (sp_num<<1))
												  begin
												     if(off_on_sign == 1'b1)
									              begin
													  s_state_reg <= s_rd_kernum;
													  alpha_rdZ_ddr <= sp_alpha + (e_cnt<<4);//160
                                         alpha_rdN_ddr <= sp_alpha + ((e_cnt+1)<<4);//160
													  alpha_rdT_ddr <= sp_alpha + ((e_cnt+2)<<4);//160
													  alpha_rdH_ddr <= sp_alpha + ((e_cnt+3)<<4);//160
													  alpha_pard_start <= 1'b1;
													  status <= s_par_ddr;//==s_rd_ddr;												 
                                         end													  
												  end
												  else begin
													  E_one <= (y_one == 0)?(sum_one + svm_b - 32'h00010000):(sum_one + svm_b + 32'h00010000);
													  status <= s_E_two;
													  e_cnt <= 0;
												  end
											end
									 end
							s_rd_kernum:begin								
								s_state_mul <= s_twelve;
								A_one <= svz_reg;
                        B_one <= svn_reg;
 								C_one <= svt_reg;
								D_one <= svh_reg;
                        if(e_cnt >= i_one)
									begin
                              if(off_on_sign == 1'b1)
										begin									  
										alpha_rdZ_ddr <= sp_addr + ((e_cnt*(e_cnt+1))<<3) + (i_one<<4);
										alpha_rdN_ddr <= sp_addr + (((e_cnt+1)*(e_cnt+2))<<3) + (i_one<<4);
										alpha_rdT_ddr <= sp_addr + (((e_cnt+2)*(e_cnt+3))<<3) + (i_one<<4);
										alpha_rdH_ddr <= sp_addr + (((e_cnt+3)*(e_cnt+4))<<3) + (i_one<<4);
										alpha_pard_start <= 1'b1;
										status <= s_par_mul;
                              end										 
									end								  
									else if((e_cnt+3) <= i_one)
									begin
									 if(off_on_sign == 1'b1)
									 begin
										alpha_rdZ_ddr <= sp_addr + ((i_one*(i_one+1))<<3) + (e_cnt<<4);
										alpha_rdN_ddr <= sp_addr + ((i_one*(i_one+1))<<3) + ((e_cnt+1)<<4);
										alpha_rdT_ddr <= sp_addr + ((i_one*(i_one+1))<<3) + ((e_cnt+2)<<4);
										alpha_rdH_ddr <= sp_addr + ((i_one*(i_one+1))<<3) + ((e_cnt+3)<<4);
										alpha_pard_start <= 1'b1;
										status <= s_par_mul;
								    end
									end
									else begin
									   if(off_on_sign == 1'b1)
									   begin									  
										alpha_rdZ_ddr <= sp_addr + ((i_one*(i_one+1))<<3) + (e_cnt<<4);
										alpha_rdN_ddr <= sp_addr + ((i_one*(i_one+1))<<3) + ((e_cnt+1)<<4);
										alpha_rdT_ddr <= sp_addr + (((e_cnt+2)*(e_cnt+3))<<3) + (i_one<<4);
										alpha_rdH_ddr <= sp_addr + (((e_cnt+3)*(e_cnt+4))<<3) + (i_one<<4);
										alpha_pard_start <= 1'b1;
										status <= s_par_mul;
                              end
                           end
                        
							end
							s_E_two:begin
									sum_one <= 0;
									if(off_on_sign == 1'b1)
									begin
									alpha_rd_ddr <= sp_alpha + (sp_num<<5) + (i_two<<4);//E2,200,58256								
									alpha_read_start <= 1'b1;
									s_state_reg <= s_thirteen;
									status <= s_rd_ddr;	
                           end									
							end
							
							s_thirteen://11
									 begin
											if((alpha_two[31] == 0)&&(alpha_two > 0)&&(alpha_two < c))
											begin
												  E_two <= svc_reg;//E_two;
												  aa_c <= alpha_one + alpha_two - c;
												  a_a <= alpha_two - alpha_one;
												  status <= s_fourteen;
											end
											else begin
												  if(e_cnt < (sp_num<<1))
												  begin
												      if(off_on_sign == 1'b1)
									               begin
														s_state_reg <= s_rd_kerdata;
														alpha_rdZ_ddr <= sp_alpha + (e_cnt<<4);//160
                                          alpha_rdN_ddr <= sp_alpha + ((e_cnt+1)<<4);//160
													   alpha_rdT_ddr <= sp_alpha + ((e_cnt+2)<<4);//160
													   alpha_rdH_ddr <= sp_alpha + ((e_cnt+3)<<4);//160
													   alpha_pard_start <= 1'b1;
													   status <= s_par_ddr;//==s_rd_ddr;	
                                          end														
												  end
												  else begin
														E_two <= (y_two == 0)?(sum_one + svm_b - 32'h00010000):(sum_one + svm_b + 32'h00010000);
														aa_c <= alpha_one + alpha_two - c;
														a_a <= alpha_two - alpha_one;
														status <= s_fourteen;
														e_cnt <= 0;
												  end
											end
									 end
							s_rd_kerdata:begin
								s_state_mul <= s_thirteen;	
                        A_one <= svz_reg;
                        B_one <= svn_reg;
 							   C_one <= svt_reg;
							   D_one <= svh_reg;
                        if(e_cnt >= i_two)
									begin
                              if(off_on_sign == 1'b1)
										begin									  
										alpha_rdZ_ddr <= sp_addr + ((e_cnt*(e_cnt+1))<<3) + (i_two<<4);
										alpha_rdN_ddr <= sp_addr + (((e_cnt+1)*(e_cnt+2))<<3) + (i_two<<4);
										alpha_rdT_ddr <= sp_addr + (((e_cnt+2)*(e_cnt+3))<<3) + (i_two<<4);
										alpha_rdH_ddr <= sp_addr + (((e_cnt+3)*(e_cnt+4))<<3) + (i_two<<4);
										alpha_pard_start <= 1'b1;
										status <= s_par_mul;
                              end										 
									end								  
									else if((e_cnt+3) <= i_two)
									begin
									 if(off_on_sign == 1'b1)
									 begin
										alpha_rdZ_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + (e_cnt<<4);
										alpha_rdN_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + ((e_cnt+1)<<4);
										alpha_rdT_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + ((e_cnt+2)<<4);
										alpha_rdH_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + ((e_cnt+3)<<4);
										alpha_pard_start <= 1'b1;
										status <= s_par_mul;
								    end
									end
									else begin
									   if(off_on_sign == 1'b1)
									   begin									  
										alpha_rdZ_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + (e_cnt<<4);
										alpha_rdN_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + ((e_cnt+1)<<4);
										alpha_rdT_ddr <= sp_addr + (((e_cnt+2)*(e_cnt+3))<<3) + (i_two<<4);
										alpha_rdH_ddr <= sp_addr + (((e_cnt+3)*(e_cnt+4))<<3) + (i_two<<4);
										alpha_pard_start <= 1'b1;
										status <= s_par_mul;
                              end
                           end									
							end
							
							s_fourteen://13
									 begin
											if(y_one == y_two)
											begin
											     sum_one <= 0;
												  if((aa_c[31] == 0)&&(aa_c > 0))
												  begin
														 L <= aa_c;
														 H <= c;
														 L_H <= aa_c - c;
														 status <= s_fifteen;
												  end
												  else begin
														 L <= 0;
														 H <= aa_c + c;
														 L_H <= 0 - aa_c - c;
														 status <= s_fifteen;
												  end
											end
											else if(y_one != y_two)
											begin
											     sum_one <= 0;
												  if((a_a[31] == 0)&&(a_a > 0))
												  begin
														 L <= a_a;
														 H <= c;
														 L_H <= a_a - c;
														 status <= s_fifteen;
												  end
												  else begin
														 L <= 0;
														 H <= c + a_a;
														 L_H <= 0 - c - a_a;
														 status <= s_fifteen;
												  end
											end
									 end
							s_fifteen://14
									 begin							   
											if(L_H[31] == 0)
											begin
												  qq <= qq + 1;
												  flag_svm <= 0;
												  status <= s_nine;
											end
											else begin     
												s_state_reg <= s_rd_kernel;
												if(i_one >= i_two)
												begin
													if(off_on_sign == 1'b1)
													begin
													alpha_rd_ddr <= sp_addr + ((i_one*(i_one+1))<<3) + (i_two<<4);
													alpha_read_start <= 1'b1;
													status <= s_rd_ddr;
													end
												end
												else begin
													if(off_on_sign == 1'b1)
													begin
													alpha_rd_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + (i_one<<4);
													alpha_read_start <= 1'b1;
													status <= s_rd_ddr;
													end
												end
                                    												
											end
									 end							
							s_rd_kernel: 
							       begin
										  status <= s_eta;
										  k_one_one <= 32'h00010000;          //k11
										  k_two_two <= 32'h00010000;//errorcache_two_in;//k22
										  sub_e <= E_one - E_two;
										  k_one_two <= svc_reg;          //k12
										  KK_tri <= 32'h00020000 - (svc_reg<<1);//i_one*sample + i_two
										  eta <= 32'h00020000 - (svc_reg<<1);//i_one*sample + i_two										  
									 end
							s_eta://15
									begin
										if(KK_tri == 0)
										begin
											  status <= s_eta_end;  
										end
										else if(KK_tri != 0 && sub_e == 0)
										begin
										     status <= s_eta_end;
											  a_two <= alpha_two;
											  a_L <= alpha_two - L;
											  a_H <= alpha_two - H;
										end
										else if(KK_tri != 0 && sub_e != 0)
										begin
										  if((sub_e[31] == 1)&&(KK_tri[31] == 1))
										  begin
												 sub_ee <= 0 - sub_e;
												 KK_train <= 0 - KK_tri;
												 div_sign <= 1'b1;
										  end
										  else if((sub_e[31] == 1)&&(KK_tri[31] == 0))
										  begin
												 sub_ee <= 0 - sub_e;
												 KK_train <= KK_tri;
												 div_sign <= 1'b1;
										  end
										  else if((sub_e[31] == 0)&&(KK_tri[31] == 1))
										  begin
												 sub_ee <= sub_e;
												 KK_train <= 0 - KK_tri;
												 div_sign <= 1'b1;
										  end
										  else if((sub_e[31] == 0)&&(KK_tri[31] == 0))
										  begin
												 sub_ee <= sub_e;
												 KK_train <= KK_tri;
												 div_sign <= 1'b1;
										  end
										  busy_a_two <= div_busy;
										  if(busy_a_two && !div_busy)//下降沿检测
										  begin
												 if(((sub_e[31]) ^ (KK_tri[31])) == 1)
												 begin
														a_two <= (y_two == 0)?(alpha_two - div_out):(alpha_two + div_out);
														a_L <= (y_two == 0)?(alpha_two - div_out - L):(alpha_two + div_out - L);
														a_H <= (y_two == 0)?(alpha_two - div_out - H):(alpha_two + div_out - H);
														div_sign <= 0;
														status <= s_eta_end;
												 end
												 else if(((sub_e[31]) ^ (KK_tri[31])) == 0)
												 begin
														a_two <= (y_two == 0)?(alpha_two + div_out):(alpha_two - div_out);
														a_L <= (y_two == 0)?(alpha_two + div_out - L):(alpha_two - div_out - L);
														a_H <= (y_two == 0)?(alpha_two + div_out - H):(alpha_two - div_out - H);
														div_sign <= 0;
														status <= s_eta_end;
												 end
										  end
										end
									end						
							s_eta_end://16
									begin
										  if((eta[31] == 0)&&(eta > 0))
										  begin
												 if((a_L[31] == 0)&&((a_H == 0)||(a_H[31] == 1)))
												 begin
														a_two <= a_two;
														a_two_alpha <= a_two - alpha_two;
														status <= s_sixteen;
												 end
												 else if(a_L[31] == 1)
												 begin
														a_two <= L;
														a_two_alpha <= L - alpha_two;
														status <= s_sixteen;
												 end
												 else if((a_H[31] == 0)&&(a_H > 0))
												 begin
														a_two <= H;
														a_two_alpha <= H - alpha_two;
														status <= s_sixteen;
												 end
										  end
										  else begin
												 a_two <= alpha_two;
												 a_two_alpha <= alpha_two - alpha_two;////a_two
												 status <= s_sixteen;
										  end
									end									
							s_sixteen: //17
									begin
										  if((a_two_alpha[31] == 0)&&(a_two_alpha < ((a_two+alpha_two+eps)>>9)))//<=
										  begin
												 qq <= qq + 1;
												 flag_svm <= 0;
												 status <= s_nine;
										  end
										  else if((a_two_alpha[31] == 1)&&((0 - a_two_alpha) < ((a_two+alpha_two+eps)>>9))) //<=
										  begin
												 qq <= qq + 1;
												 flag_svm <= 0;
												 status <= s_nine;
										  end
										  else begin
												 a_one <= (s == 0)?(alpha_one - a_two_alpha):(alpha_one + a_two_alpha);
												 status <= s_update;
										  end
									end
							s_update://18
									begin
											if(a_one[31] == 1)
											begin
												  a_two <= (s == 0)?(a_two + a_one):(a_two - a_one);
												  a_one <= 0;
												  status <= s_bnew;
											end
											else if((a_one[31] == 0)&&(a_one > c))
											begin
												  a_two <= (s == 0)?(a_two + a_one - c):(a_two + c - a_one);
												  a_one <= c;
												  status <= s_bnew;
											end
											else begin
												  a_one <= a_one;
												  status <= s_bnew;
											end
									end
							s_bnew://19
									begin
									  if(busy_YN == 1'b1)
									  begin
										  A_one <= (y_two == 0)?(a_two - alpha_two):(alpha_two - a_two);
										  A_two <= k_one_two;
										  start_A <= 1'b1;
										  busy_YN <= 1'b0;
									  end
									  busy_bone <= busy_one;
									  if(busy_bone && !busy_one)//下降沿检测
									  begin
										  b_one <= (y_one == 0)?(alpha_one - a_one - data_one):(a_one - alpha_one - data_one);
										  start_A <= 0;
										  status <= s_b_one;
									  end	
									end
							s_b_one://20
									begin
									     busy_YN <= 1'b1;
										  status <= s_b_two;
										  b_one <= svm_b - E_one + b_one;
									end
							s_b_two://21
									begin
									  if(busy_YN == 1'b1)
									  begin
										  A_one <= (y_one == 0)?(a_one - alpha_one):(alpha_one - a_one);
										  A_two <= k_one_two;
										  start_A <= 1'b1;
										  busy_YN <= 1'b0;
									  end	  
									  bNew <= 32'b0;
									  deltaB <= 32'b0;
									  b_add_b <= 32'b0;
									  busy_bone <= busy_one;
									  if(busy_bone && !busy_one)//下降沿检测
									  begin
										  b_two <= (y_two == 0)?(svm_b - E_two - data_one - a_two + alpha_two):(svm_b - E_two - data_one + a_two - alpha_two);
										  start_A <= 0;
										  status <= s_bot;
									  end
									end
							
							s_bot://23
									begin
									     busy_YN <= 1'b1;
										  b_add_b <= b_one + b_two;
										  status <= s_deltaB;
										  t_one <= (y_one == 0)?(a_one - alpha_one):(alpha_one - a_one);
										  t_two <= (y_two == 0)?(a_two - alpha_two):(alpha_two - a_two);
									end
							s_deltaB://24
									begin
										  if((a_one[31] == 0)&&(a_one > 0) && (a_one < c))
										  begin
												 bNew <= b_one;
												 deltaB <= b_one - svm_b;
												 svm_b <= b_one;
												 status <= s_error;
										  end
										  else if((a_two[31] == 0)&&(a_two > 0)&&(a_two < c))
										  begin
												 bNew <= b_two;
												 deltaB <= b_two - svm_b;
												 svm_b <= b_two;
												 status <= s_error;
										  end
										  else begin
												 bNew <= (b_add_b[31] == 0)?(b_add_b>>1):((b_add_b>>1) + 32'h80000000);
												 deltaB <= (b_add_b[31] == 0)?((b_add_b>>1)-svm_b):((b_add_b>>1) + 32'h80000000 - svm_b);
												 svm_b <= (b_add_b[31] == 0)?(b_add_b>>1):((b_add_b>>1) + 32'h80000000);
												 status <= s_error;
										  end
									end
							s_error://25
									begin
										  if(error_cnt < (sp_num<<1))
										  begin
										       if(off_on_sign == 1'b1)
									          begin
												 alpha_rd_ddr <= sp_alpha + (error_cnt<<4);//alpha(i),160,56960
										       s_state_reg <= s_rd_Errordata;
												 alpha_read_start <= 1'b1;
												 status <= s_rd_ddr;
												 end
										  end
										  else begin
												 error_cnt <= 0;
												 status <= s_wr_alpha; 
										  end
									end
							s_rd_Errordata:begin
										alpha_er <= svc_reg;
										if(off_on_sign == 1'b1)
									   begin
										alpha_rd_ddr <= sp_alpha + (sp_num<<5) + ((error_cnt)<<4);//errorcache(i),200,58256
										s_state_reg <= s_rd_ker;
										alpha_read_start <= 1'b1;
										status <= s_rd_ddr;
										end
							end
							s_rd_ker:
							      begin
									    if((alpha_er[31] == 0)&&(alpha_er > 0)&&(alpha_er < c))
										 begin
										    alpha_wr_data <= svc_reg;
											 status <= s_rd_kerone;//--s_rd_kertwo;
									    end
										 else begin
										    if((error_cnt == i_one) || (error_cnt == i_two))
										    begin
											   status <= s_wr_errorcache;
											   alpha_wr_data <= svc_reg;
											 end
											 else begin
											   status <= s_error;
											 	error_cnt <= error_cnt + 1;
											 end
										 end
									end
							s_rd_kerone:begin
								s_state_reg <= s_error_one;
								   if(i_one >= error_cnt)
									begin
									   if(off_on_sign == 1'b1)
									   begin
										alpha_rd_ddr <= sp_addr + ((i_one*(i_one+1))<<3) + (error_cnt<<4);
										alpha_read_start <= 1'b1;
										status <= s_rd_ddr;
										end
									end
									else begin
									   if(off_on_sign == 1'b1)
									   begin
										alpha_rd_ddr <= sp_addr + ((error_cnt*(error_cnt+1))<<3) + (i_one<<4);
										alpha_read_start <= 1'b1;
										status <= s_rd_ddr;
										end
									end
							end

							s_error_one:
							      begin//26
									   if(busy_YN == 1'b1)
										begin
									     start_A <= 1'b1;
										  A_one <= svc_reg;
										  A_two <= t_one;
										  busy_YN <= 1'b0;
										end
										busy_TK_one <= busy_one;
										if(busy_TK_one && !busy_one)//下降沿检测
										begin
										   start_A <= 0;
										   status <= s_rd_kertwo;
											alpha_wr_data <= alpha_wr_data + data_one;
		 						      end
							      end
							s_rd_kertwo:
							      begin
									  s_state_reg <= s_error_onend;
									 if(i_two >= error_cnt)
									  begin
									   if(off_on_sign == 1'b1)
									    begin
										alpha_rd_ddr <= sp_addr + ((i_two*(i_two+1))<<3) + (error_cnt<<4);
										alpha_read_start <= 1'b1;
										status <= s_rd_ddr;
										end
									  end
									  else begin
									   if(off_on_sign == 1'b1)
									    begin
										alpha_rd_ddr <= sp_addr + ((error_cnt*(error_cnt+1))<<3) + (i_two<<4);
										alpha_read_start <= 1'b1;
										status <= s_rd_ddr;
										end
									  end									  
									end
							
							s_error_onend:
							      begin
									     A_one <= svc_reg;
									     busy_YN <= 1'b1;
									     status <= s_add_error;
										  alpha_wr_data <= alpha_wr_data - deltaB;
									end
							s_add_error:
							      begin
									  if(busy_YN == 1'b1)
									  begin
									    start_A <= 1'b1;
										 A_one <= A_one;
										 A_two <= t_two;
										 busy_YN <= 1'b0;
									  end
										 busy_TK_one <= busy_one;
										 if(busy_TK_one && !busy_one)//下降沿检测
										 begin
												start_A <= 0;
												status <= s_wr_errorcache;
												alpha_wr_data <= alpha_wr_data + data_one;
												busy_YN <= 1'b1;
										 end
									end
							s_wr_errorcache:
							      begin
									   if((error_cnt == i_one) || (error_cnt == i_two))
										begin
										   if(off_on_sign == 1'b1)
									      begin
										   alpha_wr_data <= 32'd0;//32'hAAFFBBDD;//--
											alpha_wr_ddr <= sp_reg_alpha + (sp_num<<5) + ((error_cnt)<<4);//58508
											alpha_wr_start <= 1'b1;
											status <= s_wr_ddr;
											s_state_reg <= s_error;//s_rd_ddr;//--
											end
										end
										else begin
										   if(off_on_sign == 1'b1)
									      begin
										   alpha_wr_data <= alpha_wr_data;//32'hAAFFBBDD;//--
											alpha_wr_ddr <= sp_reg_alpha + (sp_num<<5) + ((error_cnt)<<4);//58508
											alpha_wr_start <= 1'b1;
											status <= s_wr_ddr;
											s_state_reg <= s_error;//s_rd_ddr;//--
											end
										end
									end
							s_wr_ddr:
							      begin
									   alpha_wr_flag <= alpha_wr_end;
										if(!alpha_wr_flag && alpha_wr_end)//上升沿检测
										begin
										   alpha_wr_start <= 1'b0;
											error_cnt <= error_cnt + 1;
										end
										if(alpha_wr_flag && !alpha_wr_end)//下降沿检测
										begin
										   status <= s_state_reg;
											alpha_wr_flag <= 1'b0;

										end

									end
							s_wr_alpha:
                           begin
									   if(off_on_sign == 1'b1)
									   begin
										alpha_wr_ddr <= sp_reg_alpha + (i_one<<4);//160,57212
									    alpha_wr_start <= 1'b1;
										alpha_wr_data <= a_one;
										status <= s_wr_ddr;
									    s_state_reg <= s_wr_alphatwo;
										//
									  end
                           end
                     s_wr_alphatwo:begin
							      if(off_on_sign == 1'b1)
									begin
									   alpha_wr_ddr <= sp_reg_alpha + (i_two<<4);//160
									   alpha_wr_start <= 1'b1;
										alpha_wr_data <= a_two;
										status <= s_wr_ddr;
										s_state_reg <= s_error_two;//-
										//==s_out[i_two] <= a_one[17]^a_one[16];
									end
                     end
                     				
							s_error_two://27
									begin	
										alpha_read_start <= 0;
										alpha_wr_start <= 0;										
									   error_cnt <= 0;
										status <= s_finish;
										if(a_one[17] == 1)
										begin
										   sv_out[i_one] <= 1;
										end
										if(a_one > 0)//a_one <= c && 
										//=if(a_one[17] == 1 || a_one[16] == 1)
										begin
										   s_out[i_one] <= 1;
										end
										if(a_two[17] == 1)
										begin
										   sv_out[i_two] <= 1;
										end
										if(a_two > 0)//a_two <= c &&
										//=if(a_two[17] == 1 || a_two[16] == 1)
										begin
										   s_out[i_two] <= 1;
										end
									end						
							s_finish://29
									begin
										flag_svm <= 1'b1;
										qq <= (sp_num<<1);//sample;
										status <= s_flag;
									end					
							s_flag://30
									 begin
											if(flag_svm == 1'b0)
											begin
												  i_two <= i_two + 1;
												  status <= s_while_ori;
											end
											else begin
												  numChanged <= numChanged + 1;
												  i_two <= i_two + 1;
												  status <= s_while_ori;
											end
									 end
							 
							 default:  
										 begin  
											  status <= s_idle;  
										 end  
							 endcase
			 end
		end
		
		///////////////////////////////////////////
	  div_cal div_test(
		  
		  .clk(train_clk),
		  .rst_n(rst_n),
		  .div_a(sub_ee),
		  .div_b(KK_train),
		  .enable(div_sign),
		  .svm_enable(svm_train_enable),
		  .busy_div(div_busy),
		  .out_b(div_out)
		  
		);	
	  
	  mul_one mul_one_data(
			  
			  .clk(train_clk),
			  .rst_n(rst_n),
			  .mul_a(A_one),
			  .mul_b(A_two),
			  .start(start_A),// start sign
			  .svm_enable(svm_train_enable),
			  .busy_one(busy_one),//output mul_one state
			  .data_one(data_one)//output result one
		 
		);

	  
	   mul_two mul_two_data(
	     
		  .clk(train_clk),
		  .rst_n(rst_n),
	     .mul_a(B_one),
		  .mul_b(B_two),//input mul_one result
		  .start(start_B),//input mul_one state
		  .svm_enable(svm_train_enable),
		  .busy_two(busy_two),//output mul_two state
	     .data_two(data_two)//output SUM one
	 
	   );
		
     mul_three mul_three_data(
	     
		  .clk(train_clk),
		  .rst_n(rst_n),
	     .mul_a(C_one),
		  .mul_b(C_two),
		  .start(start_C),// start sign
		  .svm_enable(svm_train_enable),
		  .busy_three(busy_three),//output mul_three state
	     .data_three(data_three)//output result three
	 
	   );
	  
	  mul_four mul_four_data(
	     
		  .clk(train_clk),
		  .rst_n(rst_n),
	     .mul_a(D_one),
		  .mul_b(D_two),
		  .start(start_D),// start sign
		  .svm_enable(svm_train_enable),
		  .busy_four(busy_four),//output mul_three state
	     .data_four(data_four)//output result three
	 
	   );	 
		

endmodule
