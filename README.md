# knmi

This repository handles KNMI weer /weather datasets and views. 

KNMI data per day and per hour is transformed and merged to a dataset per day for easier dayily forecast and planning operations. 
Data (from 1900 and all dutch weather stations) can be accessed uppon a request via Issues. 
The access can be granted to Azure SQL database which is practical for business users with PowerBI or Excel. 
All our data is optimized for ultra fast selects from PowerBI or Excels making it suitable for dayly updates of weather data in your existing Excel datamodels or reports. (an integration example with Excel and lookups to PowerBI dataset in a datahub can be provided) 
We can also provide a PowerBI file with re-created measures (Excel will not be able to read a default PowerBI dataset with only the columns)

Improvements:

1. KNMI data is stored in 0.1 units. The units are transformed to decimals
2. More decriptive fieldnames are provided
3. Selected hourly data is aggregated per daypart (night is from 0 to 7; day from 8 to 15 ; evening from 16 to 23) and merged with daydata
4. Feeling temperature (#gevoelstemperatuur) calculation. It combines :
 - Under 10 degrees Celcius we use Wind chill Methode JAG/TI zoals berekend door Amerikaanse en Canadese weerbureau's vanaf 1 november 2001 (https://www.uitenbuiten.nl/index.php/windchill-calculator2):
 - Above 25 degrees we use Heat index (https://en.wikipedia.org/wiki/Heat_index)
 - A temperature, wind and humidiy during the day hours (averages) are used.
 - (see VIEW_NL_KNMI_DAAGWAARNEMINGEN for the SQL calculations applied)

```SQL
SELECT TOP (1000) [STN]
      ,[Weerstation]
      ,[date]
      ,[DDVEC: Vectorgemiddelde windrichting in graden]
      ,[FHVEC: Vectorgemiddelde windsnelheid m/s]
      ,[FG: Etmaalgemiddelde windsnelheid m/s]
      ,[FHXH: Uurvak waarin FHX is gemeten]
      ,[FHN: Laagste uurgemiddelde windsnelheid m/s]
      ,[FHNH: Uurvak waarin FHN is gemeten]
      ,[FXX: Hoogste windstoot m/s]
      ,[FXXH: Uurvak waarin FXX is gemeten]
      ,[TG: Etmaalgemiddelde temperatuur]
      ,[TN: Minimum temperatuur ]
      ,[TNH: Uurvak waarin TN is gemeten]
      ,[TX: Maximum temperatuur]
      ,[TXH: Uurvak waarin TX is gemeten]
      ,[T10N: Minimum temperatuur op 10 cm hoogte ]
      ,[T10NH: 6-uurs tijdvak waarin T10N is gemeten]
      ,[SQ: Zonneschijnduur uren berekend uit de globale straling]
      ,[SP: % van de langst mogelijke zonneschijnduur]
      ,[Q: Globale straling (in J/cm2)]
      ,[DR: Duur van de neerslag uur]
      ,[RH: Etmaalsom van de neerslag]
      ,[RHX: Hoogste uursom van de neerslag]
      ,[RHXH: Uurvak waarin RHX is gemeten]
      ,[PG: Etmaalgemiddelde luchtdruk herleid tot zeeniveau (in hPa)]
      ,[PX: Hoogste uurwaarde van de luchtdruk herleid tot zeeniveau (in hPa)]
      ,[PXH: Uurvak waarin PX is gemeten]
      ,[PN: Laagste uurwaarde van de luchtdruk herleid tot zeeniveau (in hPa)]
      ,[PNH: Uurvak waarin PN is gemeten]
      ,[VVN: Minimum opgetreden zicht km]
      ,[VVNH: Uurvak waarin VVN is gemeten]
      ,[VVX: Maximum opgetreden zicht km]
      ,[VVXH: Uurvak waarin VVX is gemeten]
      ,[NG: Etmaalgemiddelde bewolking 0-9]
      ,[UG: % Etmaalgemiddelde relatieve vochtigheid]
      ,[UX: % Maximale relatieve vochtigheid]
      ,[UXH: Uurvak waarin UX is gemeten]
      ,[UN: % Minimale relatieve vochtigheid]
      ,[UNH: Uurvak waarin UN is gemeten]
      ,[EV24: Referentiegewasverdamping (Makkink) mm]
      ,[T: Temperatuur nacht]
      ,[T: Temperatuur overdag]
      ,[T: Temperatuur avond]
      ,[RH: Neerslag mm nacht]
      ,[RH: Neerslag mm overdag]
      ,[RH: Neerslag mm avond]
      ,[U: Relatieve vochtigheid % nacht]
      ,[U: Relatieve vochtigheid % overdag]
      ,[U: Relatieve vochtigheid % avond]
      ,[U: Windsnelheid m/s nacht]
      ,[U: Windsnelheid m/s overdag]
      ,[U: Windsnelheid m/s avond]
      ,[M: Misturen]
      ,[R: Regenuren]
      ,[S: Sneeuwuren]
      ,[O: Onweeruren]
      ,[Y: Ijsvorminguren]
      ,[T_GEV: Gevoelstemperatuur overdag]
  FROM [OPENDATA].[VIEW_NL_KNMI_DAAGWAARNEMINGEN]
```

  <img width="1174" alt="image" src="https://github.com/maximnl/knmi/assets/33482502/b828600e-f900-4299-add2-27a42a04fb3d">


<meta name="google-site-verification" content="_GQ4Sf8SjYCRk7XOG5ifZidV_Qm9kZCEnlS0ZfxXykg" />
  
