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
    type state_type is (IDLE, LOAD_ADDR, LOAD_WZ, CALC_DIFF, ENCODE, STORE_ADDR, DONE);
    signal curr_state, next_state : state_type;
    signal address, encoded, wz_address : std_logic_vector(7 downto 0);
    signal wz_num : std_logic_vector(2 downto 0);
    signal wz_offset : std_logic_vector(3 downto 0);
    signal ram_address : std_logic_vector(15 downto 0);
begin
    state_register : process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            curr_state <= IDLE;
        elsif (rising_edge(i_clk)) then
            curr_state <= next_state;
        end if;
    end process;

    lambda_delta : process(curr_state, i_start)
        variable diff : unsigned(6 downto 0); -- check signal size
    begin
        case curr_state is
            when IDLE =>
                address <= "00000000";
                encoded <= "00000000";
                o_data <= "00000000";
                o_done <= '0';
                
                ram_address <= "0000000000001000"; --todo: replace with constant
                o_address <= "0000000000001000";

                if (i_start = '1') then
                    o_en <= 1;
                    next_state <= LOAD_ADDR;
                else
                    next_state <= IDLE;
                end if;
            when LOAD_ADDR =>
                address <= i_data;
                -- save address as default output
                encoded <= i_data; -- todo: check if ok

                ram_address <= "0000000000000000"; --todo: replace with constant
                o_address <= "0000000000000000";

                next_state <= LOAD_WZ;
            when LOAD_WZ =>
                wz_address <= i_data;
                wz_num <= ram_address(2 downto 0);

                ram_address <= ram_address + 1; --todo: check ... + "0000000000000001"
                o_address <= ram_address + 1; --todo: check ... + "0000000000000001"

                next_state <= CALC_DIFF;
            when CALC_DIFF =>
                diff := unsigned(address) - unsigned(wz_address);
                -- since diff is unsigned, negative values are not allowed
                if (diff < 4) then --todo: check
                    -- found working zone
                    wz_offset <= std_logic_vector(diff);
                    next_state <= ENCODE;
                --elsif (ram_address = "0000000000000111") then --todo: replace with constant
                elsif (wz_num = "111") then --todo: replace with constant
                    -- all working zone processed
                    --encoded <= address; -- todo: moved to LOAD_ADDR, remove if ok
                    next_state <= STORE_ADDR;
                else
                    -- go to next working zone
                    next_state <= LOAD_WZ;
                end if;
            when ENCODE =>
                encoded <= '1' & wz_num & "0000"; -- check
                encoded(to_integer(unsigned(wz_offset))) <= '1';

                next_state <= STORE_ADDR;
            when STORE_ADDR =>
                ram_address <= "0000000000001001"; --todo: replace with constant
                o_address <= "0000000000001001";

                o_we <= '1';
                o_data <= encoded;
                
                next_state <= DONE;
            when DONE =>
                if (i_start = '0') then
                    o_done = '0';
                    next_state <= IDLE;
                else
                    o_done = '1';
                    o_en <= '0';
                    o_we <= '0';
                    next_state <= DONE;
                end if;
        end case;  
    end process;
end fsm;