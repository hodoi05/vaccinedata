#!/usr/bin/gnuplot

# based on sources by Torben Menke
# https://entorb.net


load "header.gp"

# Input file contains comma-separated values fields
set datafile separator ","

set title ""

# now lets compare several stats
set timefmt '%Y-%m-%d' # %Y-%m-%d   %d.%m.%Y %H:%M
set format x "%m.%y'
set xdata time

set key top left at graph 0, graph 1 font 'Verdana,12'

set colorsequence default
unset style # reset line styles/types to default


date_last = system("tail -1 '../data/df_all.csv' | cut -d ',' -f1")
delta_t = system("cat '../data/peak_deltat.txt'")

set label 1 label1_text_right."Quellen: https://github.com/entorb, https://github.com/ard-data, https://www.divi.de"

title = "Verlauf Covid Infektionen und Impfkampagne (Stand: ".date_last.")"
set title title
set ylabel ""
set rmargin screen 0.96


#plot \
#  '../data/df_all.csv' using (column("Datum")):(column("CoV-Infektionen pro Woche")) title "CoV-Infektionen pro Woche" with lines lw 2, \
#  '../data/df_all.csv' using (column("Datum")):(column("Intensiv-CoV-Patienten")) title "Intensiv-CoV-Patienten" with lines lw 2, \
#  '../data/df_all.csv' using (column("Datum")):(column("Beatmete CoV-Patienten")) title "Beatmete CoV-Patienten" with lines lw 2, \
#  '../data/df_all.csv' using (column("Datum")):(column("Todesfälle mit CoV pro Woche")) title "Todesfälle mit CoV pro Woche" with lines lw 2, \


set yrange [0:200000]
set terminal svg size 800,500
set output '../plots-gnuplot/correlation_disease_vaccination.svg'
plot \
  '../data/df_all.csv' using (column("Datum")):(column("CoV-Infektionen pro Woche")) title "CoV-Infektionen pro Woche" with lines lw 2 lt rgb "web-green", \
  '../data/df_all.csv' using (column("Datum")):(column("Intensiv-CoV-Patienten")) title "Intensiv-CoV-Patienten" with lines lw 2 lt rgb "goldenrod", \
  '../data/df_all.csv' using (column("Datum")):(column("Beatmete CoV-Patienten")) title "Beatmete CoV-Patienten" with lines lw 2 lt rgb "red", \
  '../data/df_all.csv' using (column("Datum")):(column("Todesfälle mit CoV pro Woche")) title "Todesfälle mit CoV pro Woche" with lines lw 2 lt rgb "black", \
  '../data/df_all.csv' using (column("Datum")):(column("Personen mit Erstimpfung")) title "Personen mit Erstimpfung" with lines lw 1 lt rgb "dark-cyan", \
  '../data/df_all.csv' using (column("Datum")):(column("Personen mit Vollschutz")) title "Personen mit Vollschutz" with lines lw 1 lt rgb "web-blue", \

unset output

set terminal png size 800,500
set output '../plots-gnuplot/correlation_disease_vaccination.png'
plot \
  '../data/df_all.csv' using (column("Datum")):(column("CoV-Infektionen pro Woche")) title "CoV-Infektionen pro Woche" with lines lw 2 lt rgb "web-green", \
  '../data/df_all.csv' using (column("Datum")):(column("Intensiv-CoV-Patienten")) title "Intensiv-CoV-Patienten" with lines lw 2 lt rgb "goldenrod", \
  '../data/df_all.csv' using (column("Datum")):(column("Beatmete CoV-Patienten")) title "Beatmete CoV-Patienten" with lines lw 2 lt rgb "red", \
  '../data/df_all.csv' using (column("Datum")):(column("Todesfälle mit CoV pro Woche")) title "Todesfälle mit CoV pro Woche" with lines lw 2 lt rgb "black", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Personen mit Erstimpfung")) title "Personen mit Erstimpfung" with lines lw 1 lt rgb "dark-cyan", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Personen mit Vollschutz")) title "Personen mit Vollschutz" with lines lw 1 lt rgb "web-blue", \

unset output


title = "Normalisierter Verlauf Covid Infektionen und Impfkampagne (Stand: ".date_last.")"
set title title
set ylabel "min/max normalisiert"
set label 1 label1_text_right.delta_t."\r\nQuellen: https://www.rki.de"

set yrange [0:1.4]
set terminal svg size 800,500

set output '../plots-gnuplot/correlation_disease_vaccination_normalized.svg'

# '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Cases")) title "CoV Fälle" with lines lw 2, \  
plot \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("CoV-Infektionen pro Woche")) title "CoV-Infektionen pro Woche" with lines lw 1 lt rgb "web-green", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Intensiv-CoV-Patienten")) title "Intensiv-CoV-Patienten" with lines lw 1 lt rgb "goldenrod", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Beatmete CoV-Patienten")) title "Beatmete CoV-Patienten" with lines lw 1 lt rgb "red", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Todesfälle mit CoV pro Woche")) title "Todesfälle mit CoV pro Woche" with lines lw 1  lt rgb "black", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Personen mit Erstimpfung")) title "Personen mit Erstimpfung" with lines lw 1 lt rgb "dark-cyan", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Personen mit Vollschutz")) title "Personen mit Vollschutz" with lines lw 1 lt rgb "web-blue", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Verhältnis Intensivpatienten/Infektionen (mit deltaT)")) title "Verhältnis Intensivpatienten/Infektionen (mit deltaT)" with lines lw 2 lt rgb "goldenrod", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Verhältnis beatmete Patienten/Infektionen (mit deltaT)")) title "Verhältnis beatmete Patienten/Infektionen (mit deltaT)" with lines lw 2 lt rgb "red", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Verhältnis Todesfälle/Infektionen (mit deltaT)")) title "Verhältnis Todesfälle/Infektionen (mit deltaT)" with lines lw 2 lt rgb "black", \

unset output

set terminal png size 800,500
set output '../plots-gnuplot/correlation_disease_vaccination_normalized.png'
plot \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("CoV-Infektionen pro Woche")) title "CoV-Infektionen pro Woche" with lines lw 1 lt rgb "web-green", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Intensiv-CoV-Patienten")) title "Intensiv-CoV-Patienten" with lines lw 1 lt rgb "goldenrod", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Beatmete CoV-Patienten")) title "Beatmete CoV-Patienten" with lines lw 1 lt rgb "red", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Todesfälle mit CoV pro Woche")) title "Todesfälle mit CoV pro Woche" with lines lw 1  lt rgb "black", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Personen mit Erstimpfung")) title "Personen mit Erstimpfung" with lines lw 1 lt rgb "dark-cyan", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Personen mit Vollschutz")) title "Personen mit Vollschutz" with lines lw 1 lt rgb "web-blue", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Verhältnis Intensivpatienten/Infektionen (mit deltaT)")) title "Verhältnis Intensivpatienten/Infektionen (mit deltaT)" with lines lw 2 lt rgb "goldenrod", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Verhältnis beatmete Patienten/Infektionen (mit deltaT)")) title "Verhältnis beatmete Patienten/Infektionen (mit deltaT)" with lines lw 2 lt rgb "red", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Verhältnis Todesfälle/Infektionen (mit deltaT)")) title "Verhältnis Todesfälle/Infektionen (mit deltaT)" with lines lw 2 lt rgb "black", \

unset output


set output '../plots-gnuplot/correlation_disease_course.svg'
set terminal svg size 800,500

set multiplot

set tmargin screen 0.85
set lmargin screen 0.2
set rmargin screen 0.95

set xrange ["2020-03-23":date_last]

set label 1 label1_text_right.delta_t."\r\nQuellen: https://github.com/entorb, https://github.com/ard-data, https://www.divi.de"
title = "Korrelation gemeldete Covid Infektionen und Krankheitsverlauf (Stand: ".date_last.")"
set title title


set style line 50 lt 1 lc rgb "blue" lw 2
set border ls 50

set ytics 10000000 offset -8,0
set yrange [0:85000000]

set ylabel "Geimpfte Personen" offset -6,0 textcolor rgb "blue"

plot \
  '../data/df_all.csv' using (column("Datum")):(column("Personen mit Erstimpfung")) title "Personen mit Erstimpfung" at 0.85,0.71 with lines lw 1 lt rgb "dark-cyan", \
  '../data/df_all.csv' using (column("Datum")):(column("Personen mit Vollschutz")) title "Personen mit Vollschutz" at 0.85,0.68 with lines lw 1 lt rgb "web-blue", \


set style line 50 lt 1 lc rgb "black" lw 2
set border ls 50

set ytics 0.05  offset 0,0
set yrange [0:0.25]
set ylabel "Verhältnis zu Infektionszahlen" offset 2,0 textcolor rgb "black"

plot \
  '../data/df_all.csv' using (column("Datum")):(column("Verhältnis Intensivpatienten/Infektionen (mit deltaT)")) title "Verhältnis Intensivpatienten/Infektionen (mit deltaT)"  at 0.85,0.80 with lines lw 2 lt rgb "goldenrod", \
  '../data/df_all.csv' using (column("Datum")):(column("Verhältnis beatmete Patienten/Infektionen (mit deltaT)")) title "Verhältnis beatmete Patienten/Infektionen (mit deltaT)"  at 0.85,0.77 with lines lw 2 lt rgb "red", \
  '../data/df_all.csv' using (column("Datum")):(column("Verhältnis Todesfälle/Infektionen (mit deltaT)")) title "Verhältnis Todesfälle/Infektionen (mit deltaT)"  at 0.85,0.74 with lines lw 2 lt rgb "black"


unset multiplot
unset output


set timefmt '%Y-%m-%d'
set xdata time

title = "Altersverteilung der Infektionen (Stand: ".date_last.")"
set title title
set label 1 label1_text_right.delta_t."\r\nQuellen: https://www.rki.de"
set lmargin screen 0.15
set rmargin screen 0.85

set yrange [0:17000]
set ytics 5000  offset 0,0
set ylabel "Anzahl Fälle"
set xrange ["2020-03-23":"2021-05-04"]
set terminal svg size 800,500

set output '../plots-gnuplot/age_cases.svg'
#Gesamt,90+,85 - 89,80 - 84,75 - 79,70 - 74,65 - 69,60 - 64,55 - 59,50 - 54,45 - 49,40 - 44,35 - 39,30 - 34,25 - 29,20 - 24,15 - 19,10 - 14,5 - 9,0 - 4,Datum

set multiplot

plot \
  '../data/df_age.csv' using (column("Datum")):(column("90+")) title "Alter 90 +" with lines lw 1 lc rgb '#FF0000', \
  '../data/df_age.csv' using (column("Datum")):(column("85 - 89")) title "Alter 85 - 89" with lines lw 1 lc rgb '#F00000', \
  '../data/df_age.csv' using (column("Datum")):(column("80 - 84")) title "Alter 80 - 84" with lines lw 1 lc rgb '#E00000', \
  '../data/df_age.csv' using (column("Datum")):(column("75 - 79")) title "Alter 75 - 79" with lines lw 1 lc rgb '#D01000', \
  '../data/df_age.csv' using (column("Datum")):(column("70 - 74")) title "Alter 70 - 74" with lines lw 1 lc rgb '#C02000', \
  '../data/df_age.csv' using (column("Datum")):(column("65 - 69")) title "Alter 65 - 69" with lines lw 1 lc rgb '#B03000', \
  '../data/df_age.csv' using (column("Datum")):(column("60 - 64")) title "Alter 60 - 64" with lines lw 1 lc rgb '#A04000', \
  '../data/df_age.csv' using (column("Datum")):(column("55 - 59")) title "Alter 55 - 59" with lines lw 1 lc rgb '#905000', \
  '../data/df_age.csv' using (column("Datum")):(column("50 - 54")) title "Alter 50 - 54" with lines lw 1 lc rgb '#806000', \
  '../data/df_age.csv' using (column("Datum")):(column("45 - 49")) title "Alter 45 - 49" with lines lw 1 lc rgb '#707000', \
  '../data/df_age.csv' using (column("Datum")):(column("40 - 44")) title "Alter 40 - 44" with lines lw 1 lc rgb '#608000', \
  '../data/df_age.csv' using (column("Datum")):(column("35 - 39")) title "Alter 35 - 39" with lines lw 1 lc rgb '#509000', \
  '../data/df_age.csv' using (column("Datum")):(column("30 - 34")) title "Alter 30 - 34" with lines lw 1 lc rgb '#40A000', \
  '../data/df_age.csv' using (column("Datum")):(column("25 - 29")) title "Alter 25 - 29" with lines lw 1 lc rgb '#30B000', \
  '../data/df_age.csv' using (column("Datum")):(column("20 - 24")) title "Alter 20 - 24" with lines lw 1 lc rgb '#20C000', \
  '../data/df_age.csv' using (column("Datum")):(column("15 - 19")) title "Alter 15 - 19" with lines lw 1 lc rgb '#10D000', \
  '../data/df_age.csv' using (column("Datum")):(column("10 - 14")) title "Alter 10 - 14" with lines lw 1 lc rgb '#08E000', \
  '../data/df_age.csv' using (column("Datum")):(column("5 - 9")) title "Alter 5 - 9" with lines lw 1 lc rgb '#04F000', \
  '../data/df_age.csv' using (column("Datum")):(column("0 - 4")) title "Alter 0 - 4" with lines lw 1 lc rgb '#00FF00'

set yrange [0:85000000]
set ytics 10000000  offset 72,0
set ylabel "Anzahl Impfungen" offset 80,0 

plot \
  '../data/df_all.csv' using (column("Datum")):(column("Personen mit Erstimpfung")) title "Personen mit Erstimpfung" at 0.75,0.83 with lines lw 1 lt rgb "dark-cyan", \
  '../data/df_all.csv' using (column("Datum")):(column("Personen mit Vollschutz")) title "Personen mit Vollschutz" at 0.75,0.80 with lines lw 1 lt rgb "web-blue"

unset multiplot
unset output
