#!/usr/bin/env ruby

# file: rpi_lcd16x2.rb

# code originally copied from https://github.com/RobvanB/Ruby-RaspberryPi-LCD
# instruction set reference https://en.wikipedia.org/wiki/HD44780_Character_LCD

require 'wiringpi'


class RpiLcd16x2

  def initialize(string='', p_rs: 11, p_en: 10, d4: 6, d5: 5, d6: 4, d7: 1)

    @p_rs, @p_en, @d4, @d5, @d6, @d7 = p_rs, p_en, d4, d5, d6, d7

    Wiringpi.wiringPiSetup

    # Set all pins to output mode
    [p_rs, p_en, d7, d6, d5, d4].each {|pin,val| Wiringpi.pinMode(pin, 1)}

    function_set # sets the display to use 4-bit instructions
    cursor_off
    print string unless string.empty?
  end

  # Clear all data from screen
  #
  def cls() cmd d4: 1                       end

  def cursor(direction=1) cmd d7: 1, d6: direction, d5: nil, d4: nil end
  def cursor_off()  cmd d7: 1, d6: 1, d5: 0 end
  def cursor_on()   cmd d7: 1, d6: 1, d5: 1 end
  def display_off() cmd d7: 1               end
  def display_on()  cmd d7: 1, d6: 1        end

  # Sets cursor move direction (I/D); specifies to shift the display (S).
  # I/D - increment = 1 or decrement = 0
  # S - 0 = no display shift, 1 = display shift
  # e.g. 0  0 0 0 1 D C B
  #
  def entry(direction=1)
    write_command rs: 1, d7: 0, d6: 0,         d5: 0,   d4: 1
    write_command rs: 1, d7: 0, d6: direction, d5: nil, d4: nil
  end

  # Write data to CGRAM/DDRAM
  #
  def lcd_write(a)

    write_command rs: 1, d7: a[0], d6: a[1], d5: a[2], d4: a[3]
    write_command rs: 1, d7: a[4], d6: a[5], d5: a[6], d4: a[7]
  end

  def home()        cmd d5: 1               end


  def print(raw_s)
    cls
    s = raw_s.split(/\n/).map {|x| x.ljust(40)}.join
    print_text s
  end

  alias text print

  def print_text(s)

    s.each_byte.to_a.each do |x|
      lcd_write ("%08b" % x).each_char.to_a.map(&:to_i)
    end
  end

  protected

  def cmd(h) write_command; write_command h;  sleep 0.001  end

  # Sets interface data length (DL), number of display line (N), 
  #                                                and character font (F).
  # DL - 0 = 4-bit interface, 1 = 8-bit interface
  # N - 0 = 1/8 or 1/11 duty (1 line), 1 = 1/16 duty (2 lines)
  # F - 0 = 5×8 dots, 1 = 5×10 dots
  # e.g.  0  0  1 DL  N   F  *   *
  #      d7 d6 d5 d4  d7 d6 d5 d4
  def function_set()
    write_command rs: 1, d7: 0, d6: 0, d5: 1, d4: 0
    write_command rs: 1, d7: 1, d6: 0, d5: nil, d4: nil
  end

  def write_command(rs: 0, d7: 0, d6: 0, d5: 0, d4: 0)

    [@p_rs, @d7, @d6, @d5, @d4,].zip([rs,d7,d6,d5,d4]).each do |pin,val| 
      Wiringpi.digitalWrite(pin, val) if val
    end
    pulse_enable()
  end

  private

  # Indicate to LCD that command should be 'executed'
  #
  def pulse_enable()
    [1,0].each {|x| Wiringpi.digitalWrite(@p_en, x)}
  end

end