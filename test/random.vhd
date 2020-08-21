library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity project_tb is
end project_tb;

architecture projecttb of project_tb is
constant c_CLOCK_PERIOD		: time := 100 ns;
signal   tb_done		: std_logic;
signal   mem_address		: std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst	                : std_logic := '0';
signal   tb_start		: std_logic := '0';
signal   tb_clk		        : std_logic := '0';
signal   mem_o_data,mem_i_data	: std_logic_vector (7 downto 0);
signal   enable_wire  		: std_logic;
signal   mem_we		        : std_logic;

type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);

-- come da esempio su specifica
signal RAM: ram_type;
signal load_data : boolean := false;
signal load_end : boolean := false;

component project_reti_logiche is
port (
      i_clk         : in  std_logic;
      i_start       : in  std_logic;
      i_rst         : in  std_logic;
      i_data        : in  std_logic_vector(7 downto 0);
      o_address     : out std_logic_vector(15 downto 0);
      o_done        : out std_logic;
      o_en          : out std_logic;
      o_we          : out std_logic;
      o_data        : out std_logic_vector (7 downto 0)
      );
end component project_reti_logiche;


begin
UUT: project_reti_logiche
port map (
          i_clk      	=> tb_clk,
          i_start       => tb_start,
          i_rst      	=> tb_rst,
          i_data    	=> mem_o_data,
          o_address  	=> mem_address,
          o_done      	=> tb_done,
          o_en   	=> enable_wire,
          o_we 		=> mem_we,
          o_data    	=> mem_i_data
          );

p_CLK_GEN : process is
begin
    wait for c_CLOCK_PERIOD/2;
    tb_clk <= not tb_clk;
end process p_CLK_GEN;


MEM : process(tb_clk)
    variable line_in : line;
    variable data : std_logic_vector(7 downto 0);
    variable value : integer;
    file ram_values : text open read_mode is "/home/luca/Scrivania/tb/ram_values.txt";
begin
    if tb_clk'event and tb_clk = '1' then
        if load_data then
            for i in 0 to 10 loop
                readline(ram_values, line_in);
                read(line_in, value);
                RAM(i) <= std_logic_vector(to_unsigned(value, 8));
            end loop;
            if endfile(ram_values) then
                load_end <= true;
            end if;
        elsif enable_wire = '1' then
            if mem_we = '1' then
                RAM(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM(conv_integer(mem_address)) after 1 ns;
            end if;
        end if;
    end if;
end process;


test : process is
    variable count : integer := 0;
begin
    wait for 100 ns;
    loop
    -- check if loading of test values is end
    if (load_end) then
        exit;
    end if;
    -- update ram values
    load_data <= true;
    wait for c_CLOCK_PERIOD;
    load_data <= false;
    wait for c_CLOCK_PERIOD;

    -- reset working zones every 10 encoding
    if (count = 10) then
        count := 0;
        tb_rst <= '1';
        wait for c_CLOCK_PERIOD;
        tb_rst <= '0';
        wait for c_CLOCK_PERIOD;
    end if;

    -- start encoding
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';

    -- check encoding result
    assert (RAM(9) = RAM(10)) report "TEST FALLITO. Expected  " & integer'image(to_integer(unsigned(RAM(10)))) & "  found " & integer'image(to_integer(unsigned(RAM(9)))) severity failure;

    wait for c_CLOCK_PERIOD;

    count := count + 1;
    end loop;

    assert false report "Simulation Ended!, TEST PASSATO" severity failure;
end process test;

end projecttb; 
