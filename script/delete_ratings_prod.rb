#!/usr/bin/env ruby.exe
require 'pg'
conn = PGconn.open(:dbname => 'production')
conn.exec('delete from ratings')

conn.close()

