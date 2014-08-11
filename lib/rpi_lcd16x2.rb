#!/usr/bin/env ruby

# file: rpi_lcd16x2.rb

# code originally copied from https://github.com/RobvanB/Ruby-RaspberryPi-LCD

require 'wiringpi'

T_MS = 1.0000000/1000000
ON   = 1
OFF  = 0

class RpiLcd16x2

  def initialize(string='hello world', p_rs: 11, p_en: 10, d4: 6, d5: 5, d6: 4, d7: 1)

    @p_rs, @p_en, @d4, @d5, @d6, @d7 = p_rs, p_en, d4, d5, d6, d7

    @char_count = 0

    Wiringpi.wiringPiSetup

    # Set all pins to output mode
    [p_rs, p_en, d7, d6, d5, d4].each {|pin,val| Wiringpi.pinMode(pin, 1)}

    init_display()
    sleep T_MS * 10
    lcd_display(ON, ON, OFF)
    set_entry_mode()
    cls
    text string

  end

  # Clear all data from screen
  #
  def cls()
    [0,1].each {|x| write_command d4: x}
  end

  def text(s)
    # If the string is longer than 16 char - split it.
    if (s.length > 16)
      s.split(" ").each do |x|
        print_text(x)
        next_line()
        sleep 1
      end
    else
      print_text(s)
    end
    next_line()
  end

  private

  # Indicate to LCD that command should be 'executed'
  #
  def pulse_enable()
    [0,1,0].each {|x| Wiringpi.digitalWrite(@p_en, x); sleep T_MS * 10}
  end

  # Turn on display and cursor
  #
  # 1 = 0n
  # 1 = Cursor on, 0 = Cursor off
  # 1 = Block, 0 = Underline cursor
  #
  def lcd_display(display, cursor, block)

    write_command
    write_command d7: 1, d6: display, d5: cursor, d4: block
  end

  def write_command(rs: 0, d7: 0, d6: 0, d5: 0, d4: 0)

    [@p_rs, @d7, @d6, @d5, @d4,].zip([rs,d7,d6,d5,d4])\
                          .each {|pin,val| Wiringpi.digitalWrite(pin, val)}
    pulse_enable()
  end

  # Entry mode set: move cursor to right after each DD/CGRAM write
  #
  def set_entry_mode()

    write_command
    write_command d6: 1, d5: 1
    sleep T_MS
  end

  # Write data to CGRAM/DDRAM
  #
  def lcd_write(a)

    write_command rs: 1, d7: a[0], d6: a[1], d5: a[2], d4: a[3]
    write_command rs: 1, d7: a[4], d6: a[5], d5: a[6], d4: a[7]
    @char_count += 1
  end

  # Set function to 4 bit operation
  #
  def init_display()

    3.times { sleep 42 * T_MS; write_command d5: 1, d4: 1 }

    # Function set to 4 bit
    2.times { write_command d5: 1}

    # Set number of display lines

    # D7: N = 0 = 1 line display
    # D6: F = 0 = 5x8 character font

    write_command d7: 1; sleep T_MS

    # Display Off (2 blocks)
    write_command;       sleep T_MS
    write_command d7: 1; sleep T_MS

    # Display clear (2 blocks)
    write_command;       sleep T_MS
    write_command d4: 1; sleep T_MS

    # Entry mode set"
    write_command;       sleep T_MS

    # D5: 1 = Increment by 1
    # D4: 0 = no shift

    write_command d6: 1, d5: 1, d4: 1
  end

  # Loop through each character in the string, convert it to binary, 
  #                                                   and print it to the LCD
  def print_text(s)
    lcd_write s.each_byte.to_a.map(&:to_i)
  end

  # Display automatically goes to next line when we hit 40 chars
  #
  def next_line()
    
    fill_str  = " "
    fill_cntr = 1

    while (@char_count + fill_cntr < 40)
      fill_str += " "
      fill_cntr += 1
    end

    print_text(fill_str)

    @char_count = 0
  end

end
