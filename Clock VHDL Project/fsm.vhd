library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    Port ( clk : in STD_LOGIC; --semnal de 100MHz trebuie divizat
           rst : in STD_LOGIC; --reset global
           btnL : in STD_LOGIC;
           btnR : in STD_LOGIC;
           btnC : in STD_LOGIC;
           sw_alarm : in STD_LOGIC; --switch pentru activare alarma
           sw_timer : in STD_LOGIC; -- switch pentru activare cronometru
           seg : out STD_LOGIC_VECTOR (0 to 6);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           dp : out STD_LOGIC);
end fsm;

architecture Behavioral of fsm is -- se definesc componentele, semnalele interne, starile, si logica de funcsionare.
    
    component driver7seg is --declaratie de componente externe
    Port ( clk : in STD_LOGIC; 
           Din : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0); 
           seg : out STD_LOGIC_VECTOR (0 to 6); 
           dp_in : in STD_LOGIC_VECTOR (3 downto 0); 
           dp_out : out STD_LOGIC; 
           rst : in STD_LOGIC); 
    end component driver7seg;
       
    component deBounce is --declaratie componenta externa
    port(   clk : in std_logic;
            rst : in std_logic;
            button_in : in std_logic;
            pulse_out : out std_logic
        );
    end component;
    
    signal btnLd, btnRd, btnCd : std_logic; --butoane pentru retinerea butotnului de duba debounce
    
    type states is (display_time, set_hours, set_minutes, set_alarm_hours, set_alarm_minutes, timer_mode); --type cuvant cheie  ce anunta ca definim un nout tip de date, in cazul nostru (states, doar un nume), in paranteza valorile posibile pe care le poate lua states 
    signal current_state, next_state : states; --defineste doua semnale de tip states " : " are tipul
    
    --constant n : integer := 100;
    constant n : integer := 10**8;--numar folosit pentru divizarea ceasului de la 100MHz la un HZ->o secunda
    signal inc_hours, inc_min, inc_sec : std_logic;--semnale de incrementare
    
    type sec is record -- record=defineste un tip de date care contine mai multe valori, fiecare cu propriul nume si tip.
        u : integer range 0 to 9; --pentru unitati
        t : integer range 0 to 5; --pentru zeci
    end record;
    
    type min is record
        u : integer range 0 to 9;
        t : integer range 0 to 5;
    end record;
    
    type hours is record
        u : integer range 0 to 9;
        t : integer range 0 to 2;
    end record;
    
    type time is record--combina toate trei de mai sus 
        hours : hours;
        min : min;
        sec : sec;
    end record;
    
    signal t : time := ((0,0),(0,0),(0,0)) ;--t=ora completa
    signal alarm_t : time := ((0,0),(0,0),(0,0)); -- semnal pentru alarma
    signal timer_t : time := ((0,0),(0,0),(0,0)); --semnal pentru cronometru
    signal alarm_active : std_logic := '0';       -- semnal pentru activare alarma
    signal alarm_counter : integer range 0 to 10 := 0;
    signal alarm_triggered : std_logic := '0';

    
    --semnale de afisare
    signal hours_min : STD_LOGIC_VECTOR (15 downto 0);
    signal sec_sec : STD_LOGIC_VECTOR (15 downto 0);
    signal timer_disp : STD_LOGIC_VECTOR (15 downto 0); --afisare cronometru
    signal alarm_disp: std_logic_vector(15 downto 0);
    signal d : STD_LOGIC_VECTOR (15 downto 0);
    
    signal clk1hz : std_logic;
    signal blink_hours, blink_min : std_logic;
    signal prev_sw_timer : std_logic := '0'; --retine valoarea anterioara a comutatorului
    signal an_int : std_logic_vector (3 downto 0);

begin

--Debounce pentru butoane
deb1 : deBounce port map (clk => clk, rst => '0', button_in => btnL, pulse_out => btnLd);
deb2 : deBounce port map (clk => clk, rst => '0', button_in => btnC, pulse_out => btnCd);
deb3 : deBounce port map (clk => clk, rst => '0', button_in => btnR, pulse_out => btnRd);

--masina de stari finit
state_register : process(rst, clk)
begin
  if rst = '1' then
    current_state <= display_time;
  elsif rising_edge(clk) then
    case current_state is

      when display_time =>
        if sw_alarm = '1' and btnLd = '1' then current_state <= set_alarm_hours;
        elsif sw_timer = '1' then current_state <= timer_mode;
        elsif btnLd = '1' then current_state <= set_hours;
        end if;

      when set_hours =>
        if btnLd = '1' then current_state <= set_minutes; end if;

      when set_minutes =>
        if btnLd = '1' then current_state <= display_time; end if;

      when set_alarm_hours =>
        if btnLd = '1' then current_state <= set_alarm_minutes; end if;

      when set_alarm_minutes =>
        if btnLd = '1' then current_state <= display_time; end if;

      when timer_mode =>
        if sw_timer = '0' then current_state <= display_time; end if;

      when others =>
        current_state <= display_time;

    end case;
  end if;
end process;

  
generate_incsec: process (rst, clk) --genereaza un impuls la fiecare n cicluri de ceas, functioneaza ca divizor de frecventa pe baza lui n care ne duce la un HZ
    variable counter : integer :=0;
begin--counter numara fronturi de ceas, daca ajune la 1000000 atunci a numar fix frecventa ceasului si ii ia o secunda atunci se incrmemteaza secundele
    if rst = '1' then
      counter := 0;
      inc_sec <= '1';
    elsif  rising_edge(clk) then
       if counter = n - 1 then
           counter := 0;
           inc_sec <= '1';
       else 
           counter := counter + 1;
           inc_sec <= '0';
       end if;
    end if;
end process;

--logica de incrementare timp
inc_min <= '1' when (current_state = set_minutes or current_state = set_alarm_minutes)  and btnRd = '1' else '0';
inc_hours <= '1' when (current_state = set_hours   or current_state = set_alarm_hours)  and btnRd = '1' else '0';

-- retinere stare sw_timer previous
process(rst, clk)
begin
  if rst = '1' then prev_sw_timer <= '0';
  elsif rising_edge(clk) then prev_sw_timer <= sw_timer;
  end if;
end process;

-- proces principal timp, alarma, cronometru
process (rst, clk)
begin
    if rst = '1' then
      t <= ((0,0),(0,0),(0,0));
      alarm_t <= ((0,0),(0,0),(0,0));
      timer_t <= ((0,0),(0,0),(0,0));
    elsif rising_edge(clk) then
            -- reset timer la intrarea in modul
        if sw_timer = '1' and prev_sw_timer = '0' then
            timer_t <= ((0,0),(0,0),(0,0));
        end if;
        
        -- ceas normal
        
        if inc_sec = '1' and sw_timer = '0' then
            -- increment timp normal (identic ca in codul initial)
            if t.sec.u = 9 then
               t.sec.u <= 0;
               if t.sec.t = 5 then
                  t.sec.t <= 0;
                  if t.min.u = 9 then
                     t.min.u <= 0;
                     if t.min.t = 5 then
                        t.min.t <= 0;
                        if t.hours.u = 3 and t.hours.t = 2 then
                            t.hours.u <= 0;
                            t.hours.t <= 0;
                        elsif t.hours.u = 9 then
                            t.hours.u <= 0;
                            t.hours.t <= t.hours.t + 1;
                        else 
                            t.hours.u <= t.hours.u + 1;
                        end if;
                     else
                        t.min.t <= t.min.t + 1;
                     end if;
                  else
                     t.min.u <= t.min.u + 1;   
                  end if;
              else
                  t.sec.t <= t.sec.t + 1; 
              end if;
            else 
                t.sec.u <= t.sec.u + 1;
            end if;
        end if;

        -- incrementare valoare in setari minute / alarm minutes
        if inc_min = '1' then
            if current_state = set_minutes then
                if t.min.u = 9 then t.min.u <= 0; if t.min.t = 5 then t.min.t <= 0; else t.min.t <= t.min.t + 1; end if;
                else t.min.u <= t.min.u + 1; end if;
            elsif current_state = set_alarm_minutes then
                if alarm_t.min.u = 9 then alarm_t.min.u <= 0; if alarm_t.min.t = 5 then alarm_t.min.t <= 0; else alarm_t.min.t <= alarm_t.min.t + 1; end if;
                else alarm_t.min.u <= alarm_t.min.u + 1; end if;
            end if;
        end if;
        
        -- incrementare valoare in setari ore / alarm hours
        if inc_hours = '1' then
            if current_state = set_hours then
                if t.hours.u = 3 and t.hours.t = 2 then t.hours.u <= 0; t.hours.t <= 0;
                elsif t.hours.u = 9 then t.hours.u <= 0; t.hours.t <= t.hours.t + 1;
                else t.hours.u <= t.hours.u + 1; end if;
            elsif current_state = set_alarm_hours then
                if alarm_t.hours.u = 3 and alarm_t.hours.t = 2 then alarm_t.hours.u <= 0; alarm_t.hours.t <= 0;
                elsif alarm_t.hours.u = 9 then alarm_t.hours.u <= 0; alarm_t.hours.t <= alarm_t.hours.t + 1;
                else alarm_t.hours.u <= alarm_t.hours.u + 1; end if;
            end if;
        end if;

        -- cronometru: incrementare in modul timer
        if sw_timer = '1' and inc_sec = '1' then
            if timer_t.sec.u = 9 then timer_t.sec.u <= 0;
                if timer_t.sec.t = 5 then timer_t.sec.t <= 0;
                    if timer_t.min.u = 9 then timer_t.min.u <= 0;
                        if timer_t.min.t = 5 then timer_t.min.t <= 0;
                            if timer_t.hours.u = 9 then timer_t.hours.u <= 0; timer_t.hours.t <= timer_t.hours.t + 1;
                            else timer_t.hours.u <= timer_t.hours.u + 1; end if;
                        else timer_t.min.t <= timer_t.min.t + 1; end if;
                    else timer_t.min.u <= timer_t.min.u + 1; end if;
                else timer_t.sec.t <= timer_t.sec.t + 1; end if;
            else timer_t.sec.u <= timer_t.sec.u + 1; end if;
        end if;

        -- alarma: declan?are ?i men?inere 10 secunde
        if sw_alarm = '1' and t.hours = alarm_t.hours and t.min = alarm_t.min and t.sec.u = 0 and t.sec.t = 0 then
            alarm_triggered <= '1';
            alarm_counter <= 10; -- porne?te contorul de 10 secunde
        elsif inc_sec = '1' and alarm_counter > 0 then
            alarm_counter <= alarm_counter - 1;
            if alarm_counter = 1 then
                alarm_triggered <= '0'; -- se opre?te dup? 10 secunde
            end if;
        end if;
        alarm_active <= alarm_triggered;


   end if;
end process;

--convertire cifre pentru afisare
hours_min <= std_logic_vector(to_unsigned(t.hours.t,4)) &
             std_logic_vector(to_unsigned(t.hours.u,4)) &
             std_logic_vector(to_unsigned(t.min.t,4)) &
             std_logic_vector(to_unsigned(t.min.u,4));
sec_sec  <=  std_logic_vector(to_unsigned(0,4)) &
             std_logic_vector(to_unsigned(0,4)) &
             std_logic_vector(to_unsigned(t.sec.t,4)) &
             std_logic_vector(to_unsigned(t.sec.u,4));
             
timer_disp <= std_logic_vector(to_unsigned(timer_t.min.t,4)) &
              std_logic_vector(to_unsigned(timer_t.min.u,4)) &
              std_logic_vector(to_unsigned(timer_t.sec.t,4)) &
              std_logic_vector(to_unsigned(timer_t.sec.u,4));
              
alarm_disp <= std_logic_vector(to_unsigned(alarm_t.hours.t,4)) &
              std_logic_vector(to_unsigned(alarm_t.hours.u,4)) &
              std_logic_vector(to_unsigned(alarm_t.min.t,4)) &
              std_logic_vector(to_unsigned(alarm_t.min.u,4));          

d <= timer_disp when sw_timer = '1' else
    alarm_disp when (current_state= set_alarm_hours or current_state= set_alarm_minutes) else
     sec_sec when btnC = '1' else
     hours_min;

--afisarea propriu zisa
display :  driver7seg port map (
    clk => clk,
    Din => d,
    an => an_int,
    seg => seg,
    dp_in => (others => '0'),
    dp_out => dp, 
    rst => rst);

--blink pe cifre la setare
blink_hours <= '1' when current_state = set_hours or current_state = set_alarm_hours else '0';
blink_min <= '1' when current_state = set_minutes or current_state = set_alarm_minutes else '0';

--divizor 1Hz pentru blink
div1Hz : process(rst, clk)
  variable counter : integer := 0;
begin
  if rst = '1' then
    counter := 0;
    clk1hz <= '0'; 
  elsif rising_edge(clk) then
    if counter = n/2 - 1 then
      counter := 0;
      clk1hz <= not clk1hz;
    else
      counter := counter + 1;
      clk1hz <= clk1hz;
    end if;  
  end if;    
end process;

--control anode cu blink
an(0) <= (an_int(0) or clk1hz) when (blink_min = '1' or alarm_active = '1') else an_int(0);
an(1) <= (an_int(1) or clk1hz) when (blink_min = '1' or alarm_active = '1') else an_int(1);
an(2) <= (an_int(2) or clk1hz) when (blink_hours = '1' or alarm_active = '1') else an_int(2);
an(3) <= (an_int(3) or clk1hz) when (blink_hours = '1' or alarm_active = '1') else an_int(3);


end Behavioral;
