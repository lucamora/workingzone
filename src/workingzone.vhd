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
    type state_type is (IDLE, WAIT_ADDR, LOAD_ADDR, LOAD_WZ, CALC_DIFF, STORE_ADDR, WAIT_STORE, DONE);
    signal curr_state : state_type;
    signal address : std_logic_vector(7 downto 0) := (others => '0');
    signal wz_num : std_logic_vector(2 downto 0) := (others => '0');
    signal ram_index : std_logic_vector(3 downto 0) := (others => '0');
    signal diff : unsigned(7 downto 0);
begin
    global : process(i_clk, i_rst, i_start)
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
                    diff <= "00000000";
                    curr_state <= IDLE;
                    
                    ram_index <= "1000"; --todo: replace with constant
                    o_address <= "0000000000001000";
                    wz_num <= "000";

                    if (i_start = '1') then
                        o_en <= '1';
                        curr_state <= WAIT_ADDR;
                    end if;
                when WAIT_ADDR =>
                    -- while waiting for address to be loaded from RAM
                    -- preload first wz RAM address
                    ram_index <= "0000"; --todo: replace with constant
                    o_address <= "0000000000000000";

                    curr_state <= LOAD_ADDR;
                when LOAD_ADDR =>
                    address <= i_data;
                    
                    -- while loading address from RAM
                    -- preload second wz RAM address
                    ram_index <= ram_index + "0001";
                    o_address <= "000000000000" & (ram_index + "0001");

                    curr_state <= LOAD_WZ;
                when LOAD_WZ =>
                    -- compute diff for the first wz that will be checked in the next clock cycle
                    diff <= unsigned(address) - unsigned(i_data);
                    
                    -- initialize zw_num for the first wz
                    wz_num <= "000";

                    -- load next wz
                    ram_index <= ram_index + "0001";
                    o_address <= "000000000000" & (ram_index + "0001");

                    curr_state <= CALC_DIFF;
                when CALC_DIFF =>
                    -- as default go to next working zone
                    curr_state <= CALC_DIFF;

                    -- since diff is unsigned, negative values are not allowed
                    if (diff < 4) then --todo: check
                        -- found working zone
                        address <= '1' & wz_num & "0000"; -- check
                        address(to_integer(diff(1 downto 0))) <= '1';

                        curr_state <= STORE_ADDR;
                    end if;

                    if (wz_num = "111") then --todo: replace with constant
                        -- all working zone processed
                        curr_state <= STORE_ADDR;
                    end if;

                    -- compute diff for the next wz
                    diff <= unsigned(address) - unsigned(i_data);

                    -- calculate zw_num of the next wz
                    wz_num <= wz_num + "001";

                    -- load next wz
                    ram_index <= ram_index + "0001";
                    o_address <= "000000000000" & (ram_index + "0001");
                when STORE_ADDR =>
                    ram_index <= "1001"; --todo: replace with constant
                    o_address <= "0000000000001001";

                    o_we <= '1';
                    o_data <= address;
                    
                    curr_state <= WAIT_STORE;
                when WAIT_STORE =>
                    o_done <= '1';
                    o_en <= '0';
                    o_we <= '0';

                    curr_state <= DONE;
                when DONE =>
                    curr_state <= DONE;

                    if (i_start = '0') then
                        o_done <= '0';
                        curr_state <= IDLE;
                    end if;
                when others =>
                    curr_state <= IDLE;
            end case;
        end if;
    end process;
end fsm;