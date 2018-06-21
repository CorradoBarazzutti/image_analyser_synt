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

entity file_reader is
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
end file_reader;

architecture Behavioral of file_reader is

procedure read_header 
	(
		i : in std_logic_vector(1 downto 0);
		N : in std_logic_vector(15 downto 0);
		signal o_address : out std_logic_vector(15 downto 0);
		signal i_clk : in std_logic;
		signal o_en : out std_logic
	) 
is begin 
	-- update the requested adress
    o_address <= std_logic_vector(UNSIGNED(N) + "00000010" + UNSIGNED(i));
    -- enable the memory
    o_en <= '1';
    -- wait for half a period for the memory to set i_data
    wait until rising_edge(i_clk);
    -- read i_data in the second half of the period
    wait until falling_edge(i_clk);
    -- disable memory update
    o_en <= '0';
end;

-- 8 bit multiplication
function mult
    (A, B : unsigned)
    return unsigned
is begin
    return TO_UNSIGNED(TO_INTEGER(A) * TO_INTEGER(B), 16);
end;

procedure read_data 
	(
		row, col, COLS: in std_logic_vector(7 downto 0);
		signal N: in std_logic_vector(15 downto 0);
		signal o_address: out std_logic_vector(15 downto 0);
		signal i_clk: in std_logic;
		signal o_en: out std_logic
	) 
is begin 
	-- update the requested adress
    o_address <= std_logic_vector(UNSIGNED(N) + "00000011" + mult(UNSIGNED(row), UNSIGNED(COLS)) + "00000000" & UNSIGNED(col));
    -- enable the memory
    o_en <= '1';
    -- wait for half a period for the memory to set i_data
    -- wait for half a period for the memory to set i_data
    wait until rising_edge(i_clk);
    -- read i_data in the second half of the period
    wait until falling_edge(i_clk);
    -- disable memory update
    o_en <= '0';
end;

procedure write_result 
	(
		N: in std_logic_vector(15 downto 0);
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
    wait until rising_edge(i_clk);
    wait until falling_edge(i_clk);
    -- disable memory update
    o_en <= '0';
    o_we <= '0';
    
    -- write second word
    -- update the requested adress
    o_address <= std_logic_vector(UNSIGNED(N) + 1);
    o_data <= area(7 downto 0);
    -- enable the memory and writing
    o_en <= '1';
    o_we <= '1';
    -- wait for half a period for the memory to set i_data
    wait until rising_edge(i_clk);
    wait until falling_edge(i_clk);
    -- disable memory update
    o_en <= '0';
    o_we <= '0';
end;

begin
    process
    	constant MAX : integer := 255;
        variable row, col, ROWS, COLS, TRIG: std_logic_vector(7 downto 0);
        variable left, right, top, bottom: std_logic_vector(7 downto 0);
        variable area, N : std_logic_vector(15 downto 0);
    begin
        wait until rising_edge(i_rst);
            o_done <= '0';
            wait until rising_edge(i_start);
            	-- read head
            	N := "0000000000000000";
            	read_header("00", N, o_address, i_clk, o_en);
            	ROWS := i_data;
            	report "ROWS";
            	read_header("01", N, o_address, i_clk, o_en);
            	COLS := i_data;
            	report "COLS";
            	read_header("10", N, o_address, i_clk, o_en);
            	TRIG := i_data;
            	report "TRIG";
            	-- write result
            	write_result (N, std_logic_vector(mult(UNSIGNED(ROWS), UNSIGNED(COLS))), o_data, o_address, i_clk, o_en, o_we);
				-- mark process finished
                o_done <= '1';
    end process;
end Behavioral;