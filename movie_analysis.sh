#!/bin/bash

# There are some lines belong to 1 movie
awk '/^[0-9]+,/{print ""; printf "%s",$0; next}{printf " %s",$0}' tmdb-movies.csv > movies_cleaned.csv

# Q1. Sort movies by released date
(
head -n 1 movies_cleaned.csv
 
awk '
 match($0, /,[0-9][0-9]*\/[0-9][0-9]*\/[0-9][0-9],/) {
  date = substr($0, RSTART+1, RLENGTH-2)
    split(date, d, "/")
    
    yy = d[3] + 0
    if (yy < 20) 
        yyyy = 2000 + yy
    else
        yyyy = 1900 + yy
        
    printf "%04d %02d %02d\t%s\n", yyyy, d[1], d[2], $0
}
' movies_cleaned.csv |
sort -k1,1nr -k2,2nr -k3,3nr |
cut -f2- 
) > q1.csv


# Q2. Find all movies that have vote average > 7.5
(
 head -n 1 movies_cleaned.csv

 tail -n +2 movies_cleaned.csv | awk -F',' '$(NF-3) > 7.5 { print $(NF-3) "\t" $0 }' | sort -k1,1nr | cut -f2-
) > q2.csv

# Q3. Movies that have the highest and lowest revenue
(
 head -n 1 movies_cleaned.csv

 awk -F',' '{ print $NF "\t" $0}' movies_cleaned.csv | sort -k1,1nr | cut -f2- | head -1| less
 
 awk -F',' '{ print $NF "\t" $0}' movies_cleaned.csv | sort -k1,1n | cut -f2- | head -1| less
) > q3.csv

# Q4. Total revenue of all movies
(
 echo "Total revenue of all movies"
 awk -F',' '{sum += $NF}; END{print sum}' movies_cleaned.csv
) > q4.csv

# Q5. Top 10 Movies have the highest profit
(
 head -n 1 movies_cleaned.csv

 awk -F',' '{ profit = $NF - $(NF-1); print profit "\t" $0}' movies_cleaned.csv | sort -k1,1nr | cut -f2- | head -10 | less
) > q5.csv

# Q6. Director have the most films and actors appeared the most
awk '
{
  q=0; out=""
  for(i=1;i<=length;i++){
    c=substr($0,i,1)
    if(c=="\"") q=!q
    if(c!="," || !q) out=out c
  }
  print out
}
' movies_cleaned.csv > movies_nocomma_in_quote.csv

(
 echo "Director have the most films:"
 awk -F',' '$9 != "" {print $9}' movies_nocomma_in_quote.csv | tr "|" "\n" | sort | uniq -c | sort -r | head -1 | cut -d" " -f4-

 echo "Actor appeared the most:"
 awk -F',' '$7 != "" {print $7}' movies_nocomma_in_quote.csv | tr "|" "\n" | sort | uniq -c | sort -r | head -1 | cut -d" " -f4-
) > q6.csv

# Q7. Number of movies per genre
(
 echo "number of movies per genre" 
 tail -n +2 movies_nocomma_in_quote.csv | awk -F',' '$14 != "" {print $14}'| tr "|" "\n" | sort | uniq -c | sort -r
) > q7.csv

# Q8. Number of movies per year
(
 echo "number of movies per year"
 tail -n +2 movies_nocomma_in_quote.csv | awk -F',' '$19 != "" {print $19}'| tr "|" "\n" | sort -r | uniq -c | sort -k1r
) > q8.csv

# Q9. Revenue per genre
(
 echo "genre,revenue"

 tail -n +2 movies_nocomma_in_quote.csv| 
 awk -F',' '
  {
   n = split($14, g, "|")
   for (i=1; i<=n; i++){
    sum[g[i]] += $21
   }
  } 
  END {
   for (i in sum) print i","sum[i]
  }
 ' 
) > q9.csv

# Q10. Top keywords appear the most
(
 echo "keyword,count"
 tail -n +2 movies_nocomma_in_quote.csv| awk -F',' '$11 != "" {print $11}' | tr "|" "\n" | sort | uniq -c | sort -k1r | awk '{print $2,$1}'
) > q10.csv
