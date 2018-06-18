constant MAX : std_logic_vector := 255; 

row := "00000000"
col := "00000000"

for i in 0 to MAX loop
	report "row " & std_logic_vector'image(row);
	if row >= ROWS then 
		report "rows finished";
		exit;
	else 
		for j in 0 to MAX loop
			report "col " & std_logic_vector'image(col);
			if col >= COLS then
				report "cols finished on this row" 
				exit;
			else 
				read_data();
				update();
			end if;
			col := col + 1;
		end loop;
	end if;
	row := row + 1;
end loop;
compute_result();
write_result();



procedure update 
	(
		data, trig: in std_logic_vector;
		row, col: in std_logic_vector;
		left, right, top, bottom: inout std_logic_vector
	) 
is begin 
	if data >= trig:
		if row < top then
			top := row;
		else if row > bottom then
			bottom := row;
		end if; end if;
		if col < left then
			left := col;
		else if col > right then
			right := col;
		end if; end if;
	end if;
end;

function compute_result 
	(
		left, right, top, bottom: std_logic_vector
	) 
	return std_logic_vector
is begin 
	return (UNSIGNED(right) - UNSIGNED(left)) * (UNSIGNED(bottom) - UNSIGNED(top));
end;

architecture example of subprograms is



begin
process (a)
begin
                     simple(a(0), a(1), a(2), m(0));
                     simple(a(2), a(0), a(1), m(1));
                     simple(a(1), a(2), a(0), m(2));
end process; end example;




