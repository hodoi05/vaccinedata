#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
fetched German hospital occupancy data from DIVI https://www.intensivregister.de
lk_id sind https://de.wikipedia.org/wiki/Amtlicher_Gemeindeschl%C3%BCssel
"""

__author__ = "Dr. Torben Menke"
__email__ = "https://entorb.net"
__license__ = "GPL"

# Built-in/Generic Imports
import os
import os.path
import re
import csv
import glob
import requests  # for read_url_or_cachefile
import pandas as pd
import numpy as np
import datetime


# my helper modules
import helper

col_date='Datum'
col_infectionsperweek='CoV-Infektionen pro Woche'
col_infections='Cases'
col_intensiv='Intensiv-CoV-Patienten'
col_beatmet='Beatmete CoV-Patienten'
col_tod='Todesfälle mit CoV pro Woche'
col_erstimpfung='Personen mit Erstimpfung'
col_vollschutz='Personen mit Vollschutz'
col_ratio_intensiv='Verhältnis Intensivpatienten/Infektionen (mit deltaT)'
col_ratio_beatmet='Verhältnis beatmete Patienten/Infektionen (mit deltaT)'
col_ratio_tod='Verhältnis Todesfälle/Infektionen (mit deltaT)'

all_deltat={}

def extractLinkList(cont: str) -> list:
    # myPattern = '<a href="(/divi-intensivregister-tagesreport-archiv-csv/divi-intensivregister-[^"]+/download)"'
    myPattern = r'<a href="(/divi-intensivregister-tagesreport-archiv-csv/viewdocument/\d+?/divi-intensivregister-[^"]*)"'
#    /divi-intensivregister-tagesreport-archiv-csv/viewdocument/5330/divi-intensivregister-2020-12-21-12-15
    myRegExp = re.compile(myPattern)
    myMatches = myRegExp.findall(cont)
    assert len(myMatches) > 10, "Error: no csv download links found"
    return myMatches

# '01' -> 'SH' etc, see https://de.wikipedia.org/wiki/Amtlicher_Gemeindeschl%C3%BCssel -> Aktuelle Länderschlüssel


d_bl_id2code = {'01': 'SH', '02': 'HH', '03': 'NI', '04': 'HB', '05': 'NW', '06': 'HE', '07': 'RP',
                '08': 'BW', '09': 'BY', '10': 'SL', '11': 'BE', '12': 'BB', '13': 'MV', '14': 'SN', '15': 'ST', '16': 'TH', 'DE-total': 'DE-total'}


def fetch_latest_csvs():
    """
    fetches the 5 latest files from https://www.divi.de/divi-intensivregister-tagesreport-archiv-csv?layout=table
    only keeps the latest file per day
    """

    url = 'https://www.divi.de/divi-intensivregister-tagesreport-archiv-csv?layout=table'
    cachefile = 'cache/de-divi/list-csv-page-1.html'
    payload = {"filter_order_Dir": "DESC",
               "filter_order": "tbl.ordering",
               "start": 0}
    # "cid[]": "0", "category_id": "54", "task": "", "8ba87835776d29f4e379a261512319f1": "1"

    cont = helper.read_url_or_cachefile(
        url=url, cachefile=cachefile, request_type='post', payload=payload, cache_max_age=3600, verbose=True)

    # extract link of from <a href="/divi-intensivregister-tagesreport-archiv-csv/divi-intensivregister-2020-06-28-12-15/download"

    l_csv_urls = extractLinkList(cont=cont)

    # reduce list to the 5 latest files
    # commented out, since at 07.07.2020 at the source the table sourting was strange, so that the new files where not on top of the list
    # while len(l_csv_urls) > 5:
    #     l_csv_urls.pop()

    d_csvs_to_fetch = {}

    # loop over urls to replace outdated files by latest file per day
    # '/divi-intensivregister-tagesreport-archiv-csv/divi-intensivregister-2020-06-25-12-15/download'
    # '/divi-intensivregister-tagesreport-archiv-csv/divi-intensivregister-2020-06-25-12-15-2/download'
    for url in l_csv_urls:
        url = f"https://www.divi.de{url}"
        '/divi-intensivregister-tagesreport-archiv-csv/viewdocument/5330/divi-intensivregister-2020-12-21-12-15'
        filename = re.search(
            r'/divi-intensivregister-tagesreport-archiv-csv/viewdocument/\d+?/divi-intensivregister-(\d{4}\-\d{2}\-\d{2})[^/]', url).group(1)
        d_csvs_to_fetch[filename] = url
    del l_csv_urls

    assert len(d_csvs_to_fetch) > 0, "Error: no files to fetch"
    for filename, url in d_csvs_to_fetch.items():
        cachefile = f"data/source/de-divi/{filename}.csv"
        cont = helper.read_url_or_cachefile(
            url=url, cachefile=cachefile, request_type='get', payload={}, cache_max_age=3600, verbose=True)


def generate_database() -> dict:
    d_database_states = {'01': {}, '02': {}, '03': {}, '04': {}, '05': {}, '06': {}, '07': {
    }, '08': {}, '09': {}, '10': {}, '11': {}, '12': {}, '13': {}, '14': {}, '15': {}, '16': {}, 'DE-total': {}}
    for csv_file in glob.glob('data/source/de-divi/*.csv'):
        (filepath, fileName) = os.path.split(csv_file)
        (fileBaseName, fileExtension) = os.path.splitext(fileName)
        date = fileBaseName
        del filepath, fileName, fileBaseName, fileExtension

# file 2020-04-24.csv:
# bundesland,kreis,anzahl_standorte,betten_frei,betten_belegt,faelle_covid_aktuell_im_bundesland
# file 2020-04-26.csv:
# gemeindeschluessel,anzahl_meldebereiche,faelle_covid_aktuell,faelle_covid_aktuell_beatmet,anzahl_standorte,betten_frei,betten_belegt,bundesland
# 2020-04-28.csv
# gemeindeschluessel,anzahl_meldebereiche,faelle_covid_aktuell,faelle_covid_aktuell_beatmet,anzahl_standorte,betten_frei,betten_belegt,bundesland,daten_stand
# file 2020-06-28.csv
# bundesland,gemeindeschluessel,anzahl_meldebereiche,faelle_covid_aktuell,faelle_covid_aktuell_beatmet,anzahl_standorte,betten_frei,betten_belegt,daten_stand


# -> skipping file 2020-04-24.csv and 2020-04-25.csv
        if date in ('2020-04-24', '2020-04-25'):
            continue

        with open(csv_file, mode='r', encoding='utf-8') as f:
            csv_reader = csv.DictReader(f, delimiter=",")
            for row in csv_reader:
                assert len(row) >= 8, "Error: too few rows found"
                bl_id = row["bundesland"]
                divi_col_beatmet="faelle_covid_aktuell_invasiv_beatmet"
                datetime_date = datetime.datetime.strptime(date, "%Y-%m-%d")
                if datetime_date < datetime.datetime(2021,3,31):           
                    divi_col_beatmet = "faelle_covid_aktuell_beatmet"
                d = {
                    # "bl_id": row["bundesland"],
                    # "lk_id": row["gemeindeschluessel"],
                    "Date": date,
                    "anzahl_meldebereiche": int(row["anzahl_meldebereiche"]),
                    "faelle_covid_aktuell": int(row["faelle_covid_aktuell"]),
                    "faelle_covid_aktuell_beatmet": int(row[divi_col_beatmet]),
                    "anzahl_standorte": int(row["anzahl_standorte"]),
                    "betten_frei": int(float(row["betten_frei"])),
                    "betten_belegt": int(float(row["betten_belegt"]))
                }
                d["betten_ges"] = d["betten_frei"] + d["betten_belegt"]


                # if "daten_stand" in row:
                #     d["daten_stand"] = row["daten_stand"]
                # else:
                #     d["daten_stand"] = date

                # calc de_states_sum
                d2 = dict(d)
                del d2['Date']
                if date not in d_database_states[bl_id]:
                    d_database_states[bl_id][date] = d2
                else:
                    for k in d2.keys():
                        d_database_states[bl_id][date][k] += d2[k]
                # 'DE-total'
                if date not in d_database_states['DE-total']:
                    d_database_states['DE-total'][date] = d2
                else:
                    for k in d2.keys():
                        d_database_states['DE-total'][date][k] += d2[k]
                d2['Date']=date                
                # print(d_database_states[bl_id][date])

    return d_database_states


def export_csv(d_database):
    for bl_id, l_time_series in d_database.items():
        fileOut = f"data/source/de-divi-bl/{bl_id}"
        with open(fileOut+'.csv', mode='w', encoding='utf-8', newline='\n') as fh:
            csvwriter = csv.DictWriter(fh, delimiter=',', extrasaction='ignore', fieldnames=[
                'Date',
                'betten_ges',
                'betten_belegt',
                'faelle_covid_aktuell',
                'faelle_covid_aktuell_beatmet'])
            csvwriter.writeheader()
            for d in l_time_series:
                csvwriter.writerow(l_time_series[d])
    pass

def df_addcol_peakrefrelatedratio(df,col_a, col_b, col_deltaratio):
  peakdate_a = df[df[col_a]==df[col_a].max()][col_date].min()
  peakdate_b = df[df[col_b]==df[col_b].max()][col_date].min()
  deltat = peakdate_b - peakdate_a
 
  col_refval = f'{col_b} -{deltat}d (peak matched)'
  df_deltat = df[[col_date, col_b]].copy()
  df_deltat[col_date] = df_deltat[col_date]-deltat
  df_deltat = df_deltat.rename(columns={col_b:col_refval})
  df = pd.merge(df, df_deltat, on=col_date, how='left')

  df[col_deltaratio] = df[col_refval] / df[col_a]

  all_deltat[col_b] = deltat.days

  return df

def calc_efficiency(df):
   df = df_addcol_peakrefrelatedratio(df, col_infectionsperweek, col_intensiv, col_ratio_intensiv)
   df = df_addcol_peakrefrelatedratio(df, col_infectionsperweek, col_beatmet, col_ratio_beatmet)
   df = df_addcol_peakrefrelatedratio(df, col_infectionsperweek, col_tod, col_ratio_tod)
   # Pre 2020-04-15 not ennough data has been gathered => set to nan
   df[col_ratio_tod][df[col_date] < pd.to_datetime('2020-04-15')] = np.nan

   fileOut = "data/peak_deltat.txt"
   with open(fileOut, mode='w', encoding='utf-8', newline='\n') as fh:
      fh.write(
         f"deltaT: Infektion-Intensiv:{all_deltat[col_intensiv]}d, "
         f"Infektion-Beatmung: {all_deltat[col_beatmet]}d, "
         f"Infektion-Tod: {all_deltat[col_tod]}d"
      )
     
   return df

def retrieve_ageincidents():

    helper.download_as_browser("https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Altersverteilung.xls?__blob=publicationFile", "data/source/Altersverteilung.xls")
    helper.download_as_browser("https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/COVID-19_Todesfaelle.xlsx?__blob=publicationFile", "data/source/COVID-19_Todesfaelle.xlsx")
    helper.download_as_browser("https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquotenmonitoring.xlsx?__blob=publicationFile", "data/source/Impfquotenmonitoring.xlsx")
    df_age_original = pd.read_excel("data/source/Altersverteilung.xls", sheet_name="Fälle", engine='xlrd')
    df_age = df_age_original.transpose()
    df_age = df_age.set_axis(
        [
        "Gesamt",
        "90+",
        "85 - 89",
        "80 - 84",
        "75 - 79",
        "70 - 74",
        "65 - 69",
        "60 - 64",
        "55 - 59",
        "50 - 54",
        "45 - 49",
        "40 - 44",
        "35 - 39",
        "30 - 34",
        "25 - 29",
        "20 - 24",
        "15 - 19",
        "10 - 14",
        "5 - 9",
        "0 - 4"
        ], axis="columns")
    df_age.reset_index(inplace=True)   
    df_age = df_age.drop(labels=0, axis=0)
    df_age = df_age.rename(columns = {'index':'Date'})
    df_age["Datum"] = pd.to_datetime(df_age["Date"] + "-1", format="%Y_%W-%w")
    df_age.pop("Date")
    df_age_pyramid = pd.read_excel('data/source/Age_structure_germany.xlsx', engine='openpyxl')
    return df_age

 
df_age = retrieve_ageincidents()
df_age.to_csv('data/df_age.csv', index=False)


fetch_latest_csvs()
d_database = generate_database()
export_csv(d_database)

df_divi = pd.read_csv('data/source/de-divi-bl/DE-total.csv')
df_vaccine = pd.read_csv('data/source/all-vaccine.csv')
df_vaccine = df_vaccine.rename(columns={"date":'Date'})
df_vaccine_DE = df_vaccine[df_vaccine["region"] == "DE"]
df_vaccine_personen_erst = df_vaccine_DE[df_vaccine_DE["metric"] == 'personen_erst_kumulativ'].copy().reset_index(drop=True)
df_vaccine_personen_voll = df_vaccine_DE[df_vaccine_DE["metric"] == "personen_voll_kumulativ"].copy().reset_index(drop=True)
df_infections = pd.read_csv('data/source/de-state-DE-total-infections.tsv', sep='\t')

df_all = pd.merge(df_infections, df_divi, on='Date', how='left')
df_vaccine_personen_erst = df_vaccine_personen_erst.rename(columns={"value":col_erstimpfung})
df_all = pd.merge(df_all, df_vaccine_personen_erst, on='Date', how='left')
df_vaccine_personen_voll = df_vaccine_personen_voll.rename(columns={"value":col_vollschutz})
df_all = pd.merge(df_all, df_vaccine_personen_voll, on='Date', how='left')

df_all = df_all.rename(columns={"Date":col_date})
df_all = df_all.rename(columns={"Cases_Last_Week":col_infectionsperweek})
df_all = df_all.rename(columns={"Deaths_Last_Week":col_tod})
df_all = df_all.rename(columns={"faelle_covid_aktuell":col_intensiv})
df_all = df_all.rename(columns={"faelle_covid_aktuell_beatmet":col_beatmet})

df_all[col_date] = pd.to_datetime(df_all[col_date])

df_all = calc_efficiency(df_all)

df_all = df_all[[col_date,
  col_infectionsperweek,
  col_infections,
  col_intensiv,
  col_beatmet,
  col_tod,
  col_erstimpfung,
  col_vollschutz,
  col_ratio_intensiv,
  col_ratio_beatmet,
  col_ratio_tod]]

df_all = df_all.sort_values(by = col_date)

df_all.to_csv('data/df_all.csv', index=False)

df_min_max_scaled = df_all.copy()
# apply normalization techniques by Column 1 
for column in [col_infectionsperweek,
  col_infections,
  col_intensiv,
  col_beatmet,
  col_tod,
  col_erstimpfung,
  col_vollschutz]:
    df_min_max_scaled[column] = (df_min_max_scaled[column] - df_min_max_scaled[column].min()) / (df_min_max_scaled[column].max() - df_min_max_scaled[column].min())     

df_min_max_scaled = calc_efficiency(df_min_max_scaled)

for column in [col_ratio_intensiv,
  col_ratio_beatmet,
  col_ratio_tod]:
    df_min_max_scaled[column] = (df_min_max_scaled[column] - df_min_max_scaled[column].min()) / (df_min_max_scaled[column].max() - df_min_max_scaled[column].min())     

df_min_max_scaled.to_csv('data/df_all_min_max_scaled.csv', index=False)

pass
