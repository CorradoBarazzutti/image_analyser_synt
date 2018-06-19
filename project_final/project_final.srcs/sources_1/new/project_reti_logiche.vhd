----------------------------------------------------------------------------------
-- Company: Polimi
-- Engineer: Marcello Vaccarino
-- 
-- Create Date: 06/18/2018 10:44:02 AM
-- Design Name: Final Project
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: xc7a200tfbg4841
--
-- Description: 
-- data un'immagine in scala di
-- grigi in un formato descritto successivamente, calcoli l'area del rettangolo minimo che circoscrive
-- totalmente una figura di interesse presente nell'immagine stessa
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    generic (
        max_w : integer := 100;
        max_h : integer := 200
    );
    port (
        i_clk       : in    std_logic;
        i_start     : in    std_logic;
        i_rst       : in    std_logic;
        i_data      : in    std_logic_vector(7 downto 0);
        o_address   : out   std_logic_vector(15 downto 0);
        o_done      : out   std_logic;
        o_en        : out   std_logic;
        o_we        : out   std_logic;
        o_data      : out   std_logic_vector(7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

procedure update 
	(
		data, trig: in std_logic_vector(7 downto 0);
		row, col: in std_logic_vector(7 downto 0);
		left, right, top, bottom: inout std_logic_vector(7 downto 0)
	) 
is begin 
	-- if the color is darker than the trigger value
	if data >= trig then
		-- row check
		if row < top then
			top := row;
		else if row > bottom then
			bottom := row;
		end if; end if;
		-- column check
		if col < left then
			left := col;
		else if col > right then
			right := col;
		end if; end if;
	end if;
end;

procedure read_header 
	(
		i : in std_logic_vector(1 downto 0);
		N : inout std_logic_vector(7 downto 0);
		signal o_address : out std_logic_vector(7 downto 0);
		signal i_clk : in std_logic;
		signal o_en : out std_logic
	) 
is begin 
	-- update the requested adress
    o_address <= std_logic_vector(UNSIGNED(N) + UNSIGNED(i));
    -- enable the memory
    o_en <= '1';
    -- wait for half a period for the memory to set i_data
    if i_clk'event and i_clk = '1' then
    	-- read i_data in the second half of the period
        if i_clk'event and i_clk = '0' then
        end if;
    end if;
    -- disable memory update
    o_en <= '0';
end;

procedure read_data 
	(
		row, col, N, COLS: in std_logic_vector(7 downto 0);
		signal o_address: out std_logic_vector(7 downto 0);
		signal i_clk: in std_logic;
		signal o_en: out std_logic
	) 
is begin 
	-- update the requested adress
    o_address <= std_logic_vector(UNSIGNED(N) + "00000011" + UNSIGNED(row) * UNSIGNED(COLS) + UNSIGNED(col));
    -- enable the memory
    o_en <= '1';
    -- wait for half a period for the memory to set i_data
    if i_clk'event and i_clk = '1' then
    	-- read i_data in the second half of the period
        if i_clk'event and i_clk = '0' then
        end if;
    end if;
    -- disable memory update
    o_en <= '0';
end;

function compute_area
	(
		left, right, top, bottom: std_logic_vector(7 downto 0)
	) 
	return std_logic_vector
is begin 
	return std_logic_vector(TO_UNSIGNED(TO_INTEGER(UNSIGNED(right) - UNSIGNED(left)) * TO_INTEGER(UNSIGNED(bottom) - UNSIGNED(top)), 16));
end;

procedure write_result 
	(
		N: in std_logic_vector(7 downto 0);
		area : in std_logic_vector(15 downto 0);
		signal o_data: out std_logic_vector(7 downto 0);
		signal o_address: out std_logic_vector(15 downto 0);
		signal i_clk: in std_logic;
		signal o_en, o_we: out std_logic
	) 
is begin 
	-- write first word
	-- update the requested adress
    o_address <= N;
    o_data <= area(15 downto 8);
    -- enable the memory and writing
    o_en <= '1';
    o_we <= '1';
    -- wait for half a period for the memory to set i_data
    if i_clk'event and i_clk = '1' then
    	-- read i_data in the second half of the period
        if i_clk'event and i_clk = '0' then
        end if;
    end if;

    -- write second word
    -- update the requested adress
    o_address <= std_logic_vector(UNSIGNED(N) + 1);
    o_data <= area(7 downto 0);
    -- enable the memory and writing
    o_en <= '1';
    o_we <= '1';
    -- wait for half a period for the memory to set i_data
    if i_clk'event and i_clk = '1' then
    	-- read i_data in the second half of the period
        if i_clk'event and i_clk = '0' then
        end if;
    end if;
    -- disable memory update
    o_en <= '0';
    o_we <= '0';
end;
    
begin
    process(i_clk, i_start, i_rst, i_data)
    	constant MAX : integer := 255;
        variable row, col, N, ROWS, COLS, TRIG: std_logic_vector(7 downto 0);
        variable left, right, top, bottom: std_logic_vector(7 downto 0);
        variable area : std_logic_vector(15 downto 0);
    begin
        if i_rst = '1' then
            o_done <= '0';
            if i_start = '1' then
            	-- read head
            	N := "00000000";
            	read_header("00", N, o_address, i_clk, o_en);
            	ROWS := i_data;
            	read_header("01", N, o_address, i_clk, o_en);
            	COLS := i_data;
            	read_header("10", N, o_address, i_clk, o_en);
            	TRIG := i_data;
            	-- loop over the grid and compute results
                row := "00000000";
				col := "00000000";
                for i in 0 to MAX loop
					if row >= ROWS then 
						report "rows finished";
						exit;
					else 
						for j in 0 to MAX loop
							if col >= COLS then
								report "cols finished on this row"; 
								exit;
							else 
								read_data (row, col, N, COLS, o_address, i_clk, o_en);
								update(i_data, TRIG, row, col, left, right, top, bottom);
							end if;
							col := std_logic_vector(UNSIGNED(col) + 1);
						end loop;
					end if;
					row := std_logic_vector(UNSIGNED(row) + 1);
				end loop;
				area := compute_area(left, right, top, bottom);
				write_result (N, area, o_data, o_address, i_clk, o_en, o_we);
				-- mark process finished
                o_done <= '1';
            end if;
        end if;
    end process;
end Behavioral; 