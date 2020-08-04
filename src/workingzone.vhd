----------------------------------------------------------------------------------
-- Company: Politecnico di Milano
-- Engineer: Luca Morandini (10622606)
-- 
-- Design Name: Working Zone
-- Module Name: project_reti_logiche
-- Project Name: 10622606
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity project_reti_logiche is
    port (
        i_clk       : in  std_logic;
        i_start     : in  std_logic;
        i_rst       : in  std_logic;
        i_data      : in  std_logic_vector(7 downto 0);
        o_address   : out std_logic_vector(15 downto 0);
        o_done      : out std_logic;
        o_en        : out std_logic;
        o_we        : out std_logic;
        o_data      : out std_logic_vector(7 downto 0)
    );
end project_reti_logiche;

architecture fsm of project_reti_logiche is
    type state_type is (IDLE, WAIT_ADDR, LOAD_ADDR, LOAD_WZ, CALC_DIFF, ENCODE, STORE_ADDR, DONE);
    signal curr_state : state_type;
    signal address, wz_address : std_logic_vector(7 downto 0) := (others => '0');
    signal wz_num : std_logic_vector(2 downto 0) := (others => '0');
    signal wz_offset : unsigned(2 downto 0) := (others => '0');
    signal ram_address : std_logic_vector(15 downto 0) := (others => '0');
begin
    global : process(i_clk, i_rst, i_start)
        variable diff : unsigned(7 downto 0); -- check signal size
    begin
        if (i_rst = '1') then
            curr_state <= IDLE;
        elsif (rising_edge(i_clk)) then
            case curr_state is
                when IDLE =>
                    address <= "00000000";
                    o_en <= '0';
                    o_we <= '0';
                    o_data <= "00000000";
                    o_done <= '0';
                    curr_state <= IDLE;
                    
                    ram_address <= "0000000000001000"; --todo: replace with constant
                    o_address <= "0000000000001000";

                    if (i_start = '1') then
                        o_en <= '1';
                        --curr_state <= LOAD_ADDR;
                        curr_state <= WAIT_ADDR;
                    end if;
                when WAIT_ADDR =>
                    -- while waiting for address to be loaded from RAM
                    -- preload first wz RAM address
                    ram_address <= "0000000000000000"; --todo: replace with constant
                    o_address <= "0000000000000000";

                    curr_state <= LOAD_ADDR;
                when LOAD_ADDR =>
                    address <= i_data;

                    curr_state <= LOAD_WZ;
                when LOAD_WZ =>
                    wz_address <= i_data;
                    wz_num <= ram_address(2 downto 0);

                    ram_address <= ram_address + "0000000000000001";
                    o_address <= ram_address + "0000000000000001";

                    curr_state <= CALC_DIFF;
                when CALC_DIFF =>
                    diff := unsigned(address) - unsigned(wz_address);
                    wz_offset <= diff(2 downto 0);

                    -- since diff is unsigned, negative values are not allowed
                    if (diff < 4) then --todo: check
                        -- found working zone
                        curr_state <= ENCODE;
                    elsif (wz_num = "111") then --todo: replace with constant
                        -- all working zone processed
                        curr_state <= STORE_ADDR;
                    else
                        -- go to next working zone
                        curr_state <= LOAD_WZ;
                    end if;
                when ENCODE =>
                    address <= '1' & wz_num & "0000"; -- check
                    address(to_integer(wz_offset)) <= '1';

                    curr_state <= STORE_ADDR;
                when STORE_ADDR =>
                    ram_address <= "0000000000001001"; --todo: replace with constant
                    o_address <= "0000000000001001";

                    o_we <= '1';
                    o_data <= address;
                    
                    curr_state <= DONE;
                when DONE =>
                    o_en <= '0';
                    o_we <= '0';
                    o_done <= '1';
                    curr_state <= DONE;

                    if (i_start = '0') then
                        o_done <= '0';
                        curr_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
end fsm;