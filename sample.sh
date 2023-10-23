#! /bin/bash

# First two queries passes, but third panics
occlum run /bin/chdb "
  SELECT number, hex(MD5(toString(number))) as hash, hex(randomString(200)) as rand_string 
  FROM numbers(20000000) 
  INTO OUTFILE '/tmp/1.txt' 
  FORMAT TSVWithNames;

  SELECT number, hash, hex(randomString(200)) as rand_string2
  FROM file('/tmp/1.txt', 'TSVWithNames') 
  WHERE number % 2 == 0 
  ORDER BY RAND() 
  INTO OUTFILE '/tmp/2.txt'
  FORMAT TSVWithNames;

  SELECT a1.number, a1.rand_string, a2.rand_string2
  FROM file('/tmp/1.txt', 'TSVWithNames') as a1 
  INNER JOIN file('/tmp/2.txt', 'TSVWithNames') as a2 
    ON a1.number = a2.number 
  SETTINGS join_algorithm = 'partial_merge' 
  INTO OUTFILE '/tmp/3.txt' FORMAT TSVWithNames
"