library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity camera_capture is
    port ( reg_conf_done : in  std_logic;
           camera_pclk : in  std_logic;
           camera_href : in  std_logic;
           camera_vsync : in  std_logic;
           camera_data : in  std_logic_vector (7 downto 0);
           led : out  std_logic_vector (3 downto 0));
end camera_capture;

architecture Behavioral of camera_capture is
signal counter: integer(0);
signal mycnt: integer range 0 to 3;
signal led_buf: std_logic_vector(3 downto 0);
signal black_counter: integer range 0 to 20;
signal white_counter: integer range 0 to 20;
signal pixel_counter: integer range 0 to 20;
signal camera_data_r_buf: std_logic_vector(4 downto 0);
signal camera_data_g_buf: std_logic_vector(5 downto 0);
signal camera_data_b_buf: std_logic_vector(4 downto 0);
signal data: std_logic_vector(7 downto 0);
type state_list is(s_wait, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, 
			               s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, 
			               s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, 
			               s30, s31, s32, s33, s34, s35, s36, s37, s38, s39, 
			               s40, s41, s42, s43, s44, s45, s46, s47, s48, s49, 
	                       s50, s51, s52, s53, s54, s55, s56, s57, s58, s59, 
			               s60, s61, s62, s63, s64, s65, s66, s67, s68, s69, 
			               s70, s71, s72, s73, s74, s75, s76, s77);	  
signal state: state_list;
begin
led <= led_buf;
process (camera_pclk, reg_conf_done) is
begin
	if (camera_pclk'event and camera_pclk = '0') then  --该程序控制四段LED灯，如果依然无法出现结果，检查连线是否正常
		if (reg_conf_done = '0') then		--如果是复位信号，则灯全亮，图像数据复位
			state <= s_wait;
			mycnt <= 0;
			led_buf <= "1111";
			camera_data_b_buf <= "00000";
			camera_data_r_buf <= "00000";
			camera_data_g_buf <= "000000";
			black_counter <= 0;					--白色像素的个数初始化为0
			white_counter <= 0;					--黑色像素的个数初始化为0
		elsif (camera_vsync = '1') then		--如果场同步信号为1，说明读取完一幅图的一帧
			state <= s_wait;
			camera_data_b_buf <= "00000";
			camera_data_r_buf <= "00000";
			camera_data_g_buf <= "000000";
			black_counter <= 0;
			white_counter <= 0;
		elsif (camera_href = '1' and camera_vsync = '0') then		--如果行同步信号为1，场同步信号为0，说明读取完一行
			case (state) is
				when s_wait =>  --如果是等待信号，则执行
					if (pixel_counter = 19) then
						state <= s0;
						pixel_counter <= 0;
					else
						pixel_counter <= pixel_counter + 1;
					end if;
				when s0 => --判定第一个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s1;
				when s1 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s2;
				when s2 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s3;
				when s3 => state <= s4;
				
				when s4 => --判定第二个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s5;
				when s5 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s6;
				when s6 =>
					if ((camera_data_b_buf > "01000") or(camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s7;
				when s7 => state <= s8;
				
				when s8 => --判定第三个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s9;
				when s9 =>
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s10;
				when s10 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s11;
				when s11 => state <= s12;
				
				when s12 => --判定第四个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s13;
				when s13 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s14;
				when s14 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s15;
				when s15 => state <= s16;
				
				when s16 => --判定第五个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s17;
				when s17 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s18;
				when s18 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s19;
				when s19 => state <= s20;
				
				when s20 => --判定第六个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s21;
				when s21 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s22;
				when s22 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s23;
				when s23 => state <= s24;
				
				when s24 => --判定第七个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s25;
				when s25 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s26;
				when s26 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s27;
				when s27 => state <= s28;
				
				when s28 => --判定第八个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s29;
				when s29 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s30;
				when s30 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s31;
				when s31 => state <= s32;
				
				when s32 => --判定第九个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s33;
				when s33 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s34;
				when s34 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s35;
				when s35 => state <= s36;
				
				when s36 => --判定第十个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s37;
				when s37 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s38;
				when s38 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s39;
				when s39 => state <= s40;
				
				when s40 => --判定第十一个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s41;
				when s41 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s42;
				when s42 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s43;
				when s43 => state <= s44;
				
				when s44 => --判定第十二个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s45;
				when s45 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s46;
				when s46 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s47;
				when s47 => state <= s48;
				
				when s48 => --判定第十三个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s49;
				when s49 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s50;
				when s50 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s51;
				when s51 => state <= s52;
				
				when s52 => --判定第十四个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s53;
				when s53 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s54;
				when s54 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s55;
				when s55 => state <= s56;
				
				when s56 => --判定第十五个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s57;
				when s57 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s58;
				when s58 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s59;
				when s59 => state <= s60;
				
				when s60 => --判定第十六个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s61;
				when s61 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s62;
				when s62 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s63;
				when s63 => state <= s64;
				
				when s64 => --判定第十七个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s65;
				when s65 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s66;
				when s66 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s67;
				when s67 => state <= s68;
				
				when s68 => --判定第十八个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s69;
				when s69 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s70;
				when s70 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s71;
				when s71 => state <= s72;
				
				when s72 => --判定第十九个像素点
					data <= camera_data;
					camera_data_r_buf <= data(7 downto 3);
					camera_data_g_buf(5 downto 3) <= data(2 downto 0);
					state <= s73;
				when s73 =>
					data <= camera_data;
					camera_data_b_buf <= data(4 downto 0);
					camera_data_g_buf(2 downto 0) <= data(7 downto 5);
					state <= s74;
				when s74 =>
					if ((camera_data_b_buf > "01000") or (camera_data_r_buf > "01000")) and (camera_data_g_buf > "010000") then
						white_counter <= white_counter + 1;      
					else
						black_counter <= black_counter + 1; 
					end if;
					state <= s75;
				when s75 => state <= s76;
				
				when s76 => 
					if (white_counter > black_counter) then
						
						led_buf(x) <= '0';
					else
						led_buf(x) <= '1';
					end if;
					
				when s77 =>
					led_buf <= led_buf;
					white_counter <= 0;
					black_counter <= 0;
					data <= "00000000";
					camera_data_b_buf <= "00000";
					camera_data_r_buf <= "00000";
					camera_data_g_buf <= "000000";
				when others => state <= s77;
			end case;
		end if;
	end if;
end process;
end Behavioral;