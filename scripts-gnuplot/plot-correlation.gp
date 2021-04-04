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
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Personen mit Erstimpfung")) title "Personen mit Erstimpfung" with lines lw 1 lt rgb "dark-cyan", \
  '../data/df_all_min_max_scaled.csv' using (column("Datum")):(column("Personen mit Vollschutz")) title "Personen mit Vollschutz" with lines lw 1 lt rgb "web-blue", \

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
set label 1 label1_text_right.delta_t."\r\nQuellen: https://github.com/entorb, https://github.com/ard-data, https://www.divi.de"

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


set label 1 label1_text_right."Quellen: https://github.com/entorb, https://github.com/ard-data, https://www.divi.de"
title = "Korrelation Covid Infektionen und Kranheitsverlauf (Stand: ".date_last.")"
set title title
set ylabel ""
#plot \
#  '../data/df_all.csv' using (column("Datum")):(column("CoV-Infektionen pro Woche")) title "CoV-Infektionen pro Woche" with lines lw 2, \
#  '../data/df_all.csv' using (column("Datum")):(column("Intensiv-CoV-Patienten")) title "Intensiv-CoV-Patienten" with lines lw 2, \
#  '../data/df_all.csv' using (column("Datum")):(column("Beatmete CoV-Patienten")) title "Beatmete CoV-Patienten" with lines lw 2, \
#  '../data/df_all.csv' using (column("Datum")):(column("Todesfälle mit CoV pro Woche")) title "Todesfälle mit CoV pro Woche" with lines lw 2, \
set yrange [0:0.4]
set terminal svg size 800,500
set output '../plots-gnuplot/correlation_disease_pct.svg'
plot \
  '../data/df_all.csv' using (column("Datum")):(column("Verhältnis Intensivpatienten/Infektionen (mit deltaT)")) title "Verhältnis Intensivpatienten/Infektionen (mit deltaT)" with lines lw 2 lt rgb "goldenrod", \
  '../data/df_all.csv' using (column("Datum")):(column("Verhältnis beatmete Patienten/Infektionen (mit deltaT)")) title "Verhältnis beatmete Patienten/Infektionen (mit deltaT)" with lines lw 2 lt rgb "red", \
  '../data/df_all.csv' using (column("Datum")):(column("Verhältnis Todesfälle/Infektionen (mit deltaT)") title "Verhältnis Todesfälle/Infektionen (mit deltaT)" with lines lw 2 lt rgb "black", \
unset output
