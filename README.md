# KNMI

This repository aims to simplify access to KNMI weather data platform (KNMI data)[https://dataplatform.knmi.nl/] from Excel models and Microsoft Power BI datasets. 
KNMI is a central dutch authority for weather measurements and weather forecast. It provides open API for accessing weather data via files. 
Many business users, planners and forecasters which a less familiar with Python , file handling and API find it too challenging / time consuming accessing the data. 
Moreover, KNMI chunky data structure and API data size limitations require local storing and processing of data in many business scenario's.

We provide :
A1. documentation and maintainance on alternative ways to access KNMI data directly,
A2. an access to processed and normalized data via optimized Azure SQL database tables (updated daily) with a direct SQL connect access uppon a request.
A3. CSV access via URL for an even easier integration with Excel (pending work, expected in 2024. Access for beta testers direct per request.)

# Data 
Data is organized in three domains / tables 
D1. DAY historical weather data
D2. INTRADAY (hourly) weather data
D3. Forecast data 14 days for 6 weather stations

## D1
KNMI data per day is transformed into normal decimal units, extended with clear name and extended with some hourly data consolidated to the day level. 
Improvements:

1. KNMI data is stored in 0.1 units to avoid decimals. For application usage the units need to be transformed back to decimals
2. More decriptive fieldnames are provided
3. Selected hourly data is aggregated per daypart (night is from 0 to 7; day from 8 to 15 ; evening from 16 to 23) and merged with daydata
4. Feeling temperature (#gevoelstemperatuur) calculation. It combines :
 - Under 10 degrees Celcius we use Wind chill Methode JAG/TI zoals berekend door Amerikaanse en Canadese weerbureau's vanaf 1 november 2001 (https://www.uitenbuiten.nl/index.php/windchill-calculator2):
 - Above 25 degrees we use Heat index (https://en.wikipedia.org/wiki/Heat_index)
 - A temperature, wind and humidiy during the day hours (averages) are used.

Data per day starts from 1900 and includes 50+ dutch weather stations. 

### Historical day, hourly and precipitation data

We advice to access KNMI daily and hourly data via een script page using POST method. 
Base data : (day/hour data)[https://daggegevens.knmi.nl/klimatologie/daggegevens]
Script page: (script)[https://www.knmi.nl/kennis-en-datacentrum/achtergrond/data-ophalen-vanuit-een-script]

Example: getting day data for selected list of stations (STN parameter) for the last 10 days  
(https://www.daggegevens.knmi.nl/klimatologie/daggegevens&stns=391:340:315:308:286:269:319:251:240:344:215:280:273:279:380:330:313:249:209:277:377:258:312:290:331:356:370:375:310:285:267:260:235:210:270:265:324:348:323:248:350:316:283:278:343:225:242:311:275:257&start=20231020)
Notice that the Script page uses POST method and will show an error if you simply accesing via URL (it uses GET method which will not work from URL or Excel)

Getting hourly weather data work in a similar manner. 
(hourly data)[https://www.daggegevens.knmi.nl/klimatologie/uurgegevens]
METHOD: POST
Filter (Azure Synapse Analytics Copy data (getting last 10 days data): stns=391:340:315:308:286:269:319:251:240:344:215:280:273:279:380:330:313:249:209:277:377:258:312:290:331:356:370:375:310:285:267:260:235:210:270:265:324:348:323:248:350:316:283:278:343:225:242:311:275:257&start=@{formatDateTime(addDays(utcNow(),-10),'yyyyMMdd')}&end=@{formatDateTime(addDays(utcNow(),0),'yyyyMMdd')}
<img width="770" alt="image" src="https://github.com/maximnl/knmi/assets/33482502/f70f5169-b036-4ea5-89bf-f4889a9ef516">

Getting precipitation data idem.

### Weather forecast data

Forecast data can be previewed via a PLUIM page (PLUIM)[https://www.knmi.nl/nederland-nu/weer/waarschuwingen-en-verwachtingen/weer-en-klimaatpluim]
PLUIM page consists of highcharts which obscure getting the time series forecast data. 
With big thanks to #alliander weather api work we got a way to access the underlying table data directly. 
(alliander weather api / pluim model)[https://github.com/alliander-opensource/weather-provider-api/blob/main-2.0/weather_provider_api/routers/weather/sources/knmi/models/pluim.py]
Unfortunately the data is segmentend per station per varaible. The data comes preformated in JSON format ment for highcharts javascript web component and requires extra processing.

Model name "ECMWF pluim"
URL: https://cdn.knmi.nl/knmi/json/page/weer/waarschuwingen_verwachtingen/ensemble/iPluim/{stn}_{factor}.json
Description = Predictions for the coming 15 days, current included, with two predictions made for " "each day."
{stn} -  parameter is one of 6 weather stations. 
<img width="456" alt="image" src="https://github.com/maximnl/knmi/assets/33482502/66111bc1-d7be-440f-be86-ffba6d844bfa">


{factor} is one of the codes: 
```json
            "wind_speed": {
                "name": "wind_speed",
                "convert": self.kmh_to_ms,  # km/h -> m/s
                "code": 11012,
            },
            "wind_direction": {
                "name": "wind_direction",
                "convert": self.no_conversion,  # 360N, 270W, ...
                "code": 11011,
            },
            "short_time_wind_speed": {
                "name": "wind_speed_max",
                "convert": self.kmh_to_ms,  # km/h -> m/s
                "code": 11041,
            },
            "temperature": {
                "name": "temperature",
                "convert": self.celsius_to_kelvin,  # degree C -> Kelvin
                "code": 99999,
            },
            "precipitation": {
                "name": "precipitation",
                "convert": lambda x: x / 1000,  # mm -> m
                "code": 13021,
            },
            "precipitation_sum": {
                "name": "precipitation_sum",
                "convert": lambda x: x / 1000,  # mm -> m
                "code": 13011,
            },
            "cape": {
                "name": "cape",
                "convert": lambda x: x / 1000,
                "code": 13241,
            },  # J/kg
        }
```

Example: getting temperature forecast data for 15 days for De Bilt (station=260):        
https://cdn.knmi.nl/knmi/json/page/weer/waarschuwingen_verwachtingen/ensemble/iPluim/260_99999.json

<img width="1155" alt="image" src="https://github.com/maximnl/knmi/assets/33482502/52ae8fd5-ada1-4334-898e-2b95aacf7b61">


## A2
The access A2 can be granted to Azure SQL database which is practical for business users with PowerBI or Excel. 
A2 features compressed table storage for ultra fast select queries from PowerBI or Excels. 
We will be providing docs for dayly updates of weather data in your existing Excel models or Power BI datasets. 
 

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
      ,[FH: Windsnelheid m/s nacht]
      ,[FH: Windsnelheid m/s overdag]
      ,[FH: Windsnelheid m/s avond]
      ,[M: Misturen]
      ,[R: Regenuren]
      ,[S: Sneeuwuren]
      ,[O: Onweeruren]
      ,[Y: Ijsvorminguren]
      ,[T_GEV: Gevoelstemperatuur overdag]
  FROM [OPENDATA].[VIEW_NL_KNMI_DAAGWAARNEMINGEN]
```

  <img width="1174" alt="image" src="https://github.com/maximnl/knmi/assets/33482502/b828600e-f900-4299-add2-27a42a04fb3d">



Usage with POWERBI

<img width="1170" alt="image" src="https://github.com/maximnl/knmi/assets/33482502/a7d2cf50-1009-459b-b4e5-39844112f752">
<img width="318" alt="image" src="https://github.com/maximnl/knmi/assets/33482502/2b6e22a1-689b-4429-bdf9-aa9676e63090">







<meta name="google-site-verification" content="_GQ4Sf8SjYCRk7XOG5ifZidV_Qm9kZCEnlS0ZfxXykg" />
<meta name="keywords" content="KNMI, weather, historic, Netherlands, powerbi, excel, planning, forecasting,Wind chill, heat index,gevoelstemperatuur"/>
<meta name="description" content="KNMI historical data optimized for Excel and PowerBI applications, added descriptin"/>
<meta name="subject" content="your website's subject">
<meta name="copyright"content="">
<meta name="language" content="EN">
<meta name="robots" content="index,follow" />
<meta name="revised" content="Tuesday, July 11th, 2023, 5:15 pm" />
<meta name="abstract" content="">
<meta name="topic" content="forecasting">
<meta name="summary" content="">
<meta name="Classification" content="Business">
<meta name="author" content="Maxim, maxim@plansis.nl">
<meta name="designer" content="">
<meta name="copyright" content="">
<meta name="reply-to" content="maxim@plansis.nl">
<meta name="owner" content="">
<meta name="url" content="">
<meta name="identifier-URL" content="">
<meta name="directory" content="submission">
<meta name="category" content="">
<meta name="coverage" content="Worldwide">
<meta name="distribution" content="Global">
<meta name="rating" content="General">
<meta name="revisit-after" content="7 days">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">


  
