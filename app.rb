#!/usr/bin/env ruby

# Copyright 2016 Caleb Larsen
#
# This file is part of GPO.
#
# GPO is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# GPO is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with GPO.  If not, see <http://www.gnu.org/licenses/>.

# ---------------------    --------------------- #
require 'yaml'
require 'getoptlong'
require 'csv'
require 'io/console'

# ---------------------    --------------------- #
SETTINGS = YAML.load_file('settings.yml')
$recipient = SETTINGS["recipient"] === "default" ? "" : "--recipient #{SETTINGS['recipient']}"
$e_file = SETTINGS["encrypted_file"]
$d_file = SETTINGS["decrypted_file"]

# ---------------------    --------------------- #
def extract_csv()
  if File.file?("#{$e_file}")
    csv_text = `gpg --decrypt #{$e_file}`
  elsif File.file?("#{$d_file}")
    csv_text = `cat #{$d_file}`
  else
    csv_text = ""
  end
  csv_text
end

# ---------------------    --------------------- #
def check_record(record, keyword)
  if record[0] && record[0].match(/#{keyword}/i)
    puts "PW: #{record[2]}"
  end
end

# ---------------------    --------------------- #
def add_record()
  print "Enter subject: "
  subject = gets.chomp
  print "Enter username: "
  username = gets.chomp
  print "Enter password: "
  password = STDIN.noecho(&:gets).chomp
  print "\nRe-enter password: "
  password2 = STDIN.noecho(&:gets).chomp
  raise "Passwords don't match." unless password === password2
  print "\nEnter hint: "
  hint = gets.chomp
  print "Enter note: "
  note = gets.chomp

  line = "#{subject},#{username},#{password},#{hint},#{note}"

  csv_text = extract_csv() << "\n#{line}"
  tmp_file = "tmp.txt"
  File.open(tmp_file, 'w') { |file| file.write(csv_text) }
  `gpg --output #{$e_file} --encrypt #{$recipient} #{tmp_file} && rm #{tmp_file}`
end

# ---------------------    --------------------- #
opts = GetoptLong.new(
  [ '--decrypt', '-d', GetoptLong::NO_ARGUMENT ],
  [ '--encrypt', '-e', GetoptLong::NO_ARGUMENT ],
  [ '--add', '-a', GetoptLong::NO_ARGUMENT ],
  [ '--backup', '-b', GetoptLong::NO_ARGUMENT ],
  [ '--find', '-f', GetoptLong::REQUIRED_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--decrypt'
      `gpg --output #{$d_file} --decrypt #{$e_file} && rm #{$e_file}`
    when '--encrypt'
      `gpg --output #{$e_file} --encrypt #{$recipient} #{$d_file} && rm #{$d_file}`
    when '--add'
      add_record()
    when '--find'
      csv_text = extract_csv()
      arr = CSV.parse(csv_text)
      arr.each do |record|
        check_record(record, arg)
      end
    when '--backup'
      if File.file?("#{$e_file}")
        `cp #{$e_file} #{$e_file}.bak`
      else
        puts "Cannot find encrypted file. Please ensure encrypted file exists prior to backup."
      end
  end
end