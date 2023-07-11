SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER view [OPENDATA].[VIEW_NL_KNMI_DAAGWAARNEMINGEN] AS
SELECT K.[STN]
 ,S.NAME 'Weerstation'      
      ,try_convert(date,convert(varchar(10),K.[YYYYMMDD])) date
      ,[DDVEC] as 'DDVEC: Vectorgemiddelde windrichting in graden'
      ,try_convert(real,[FHVEC]) / 10 'FHVEC: Vectorgemiddelde windsnelheid m/s'
      ,try_convert(real,[FG]) / 10 'FG: Etmaalgemiddelde windsnelheid m/s'
      , FHXH 'FHXH: Uurvak waarin FHX is gemeten'
      ,try_convert(real,[FHN]) / 10 'FHN: Laagste uurgemiddelde windsnelheid m/s'
      ,[FHNH] 'FHNH: Uurvak waarin FHN is gemeten'
      ,try_convert(real,[FXX] ) / 10 'FXX: Hoogste windstoot m/s'
      ,[FXXH] 'FXXH: Uurvak waarin FXX is gemeten'
      ,try_convert(real,[TG] ) / 10  'TG: Etmaalgemiddelde temperatuur'
      ,try_convert(real,[TN] ) / 10  'TN: Minimum temperatuur '
      ,[TNH] 'TNH: Uurvak waarin TN is gemeten'
      ,try_convert(real,[TX] ) / 10  'TX: Maximum temperatuur' 
      ,[TXH] 'TXH: Uurvak waarin TX is gemeten'
      ,try_convert(real,[T10N] ) / 10   'T10N: Minimum temperatuur op 10 cm hoogte '
      ,[T10NH] 'T10NH: 6-uurs tijdvak waarin T10N is gemeten'
      ,try_convert(real,[SQ]) / 10   'SQ: Zonneschijnduur uren berekend uit de globale straling'
      ,try_convert(real,[SP] ) / 100 'SP: % van de langst mogelijke zonneschijnduur'
      ,[Q] 'Q: Globale straling (in J/cm2)'
      ,try_convert(real,[DR]) / 10  'DR: Duur van de neerslag uur'
      ,try_convert(real,[RH]) / 10    'RH: Etmaalsom van de neerslag'
      ,try_convert(real,case when [RHX]=-1 then 0.5 else RHX END) / 10 'RHX: Hoogste uursom van de neerslag'
      ,[RHXH] 'RHXH: Uurvak waarin RHX is gemeten'
      ,try_convert(real,[PG] ) / 10  'PG: Etmaalgemiddelde luchtdruk herleid tot zeeniveau (in hPa)'
      ,try_convert(real,[PX] ) / 10  'PX: Hoogste uurwaarde van de luchtdruk herleid tot zeeniveau (in hPa)'
      ,[PXH] 'PXH: Uurvak waarin PX is gemeten'
      ,try_convert(real,[PN]) / 10  'PN: Laagste uurwaarde van de luchtdruk herleid tot zeeniveau (in hPa)'
      ,[PNH] 'PNH: Uurvak waarin PN is gemeten'
      ,try_convert(real,[VVN]) * 100 / 1000 'VVN: Minimum opgetreden zicht km'
      ,[VVNH] 'VVNH: Uurvak waarin VVN is gemeten'
      ,try_convert(real,[VVX]) * 100 / 1000 'VVX: Maximum opgetreden zicht km'
      ,[VVXH] 'VVXH: Uurvak waarin VVX is gemeten'
      ,[NG] 'NG: Etmaalgemiddelde bewolking 0-9'
      ,try_convert(real,[UG])/100 'UG: % Etmaalgemiddelde relatieve vochtigheid'
      ,try_convert(real,[UX])/100 'UX: % Maximale relatieve vochtigheid'
      ,[UXH] 'UXH: Uurvak waarin UX is gemeten'
      ,try_convert(real,[UN])/100 'UN: % Minimale relatieve vochtigheid'
      ,[UNH] 'UNH: Uurvak waarin UN is gemeten'
      ,try_convert(real,[EV24]) / 10   'EV24: Referentiegewasverdamping (Makkink) mm'
      , [T_NACHT] 'T: Temperatuur nacht'
      ,[T_OVERDAG] 'T: Temperatuur overdag'
      ,[T_AVOND] 'T: Temperatuur avond'
      ,[RH_NACHT] 'RH: Neerslag mm nacht'
      ,[RH_OVERDAG] 'RH: Neerslag mm overdag'
      ,[RH_AVOND] 'RH: Neerslag mm avond'
      , U_NACHT 'U: Relatieve vochtigheid % nacht'
      , U_OVERDAG 'U: Relatieve vochtigheid % overdag'
      , U_AVOND 'U: Relatieve vochtigheid % avond'
      , FH_NACHT 'FH: Windsnelheid m/s nacht'
      , FH_OVERDAG 'FH: Windsnelheid m/s overdag'
      , FH_AVOND 'FH: Windsnelheid m/s avond'
      ,[M] 'M: Misturen'
      ,[R] 'R: Regenuren'
      ,[S] 'S: Sneeuwuren'
      ,[O] 'O: Onweeruren'
      ,[Y] 'Y: Ijsvorminguren'

        , case when T_OVERDAG<10 THEN 
        13.12 + 0.6215 * try_convert(real,[T_OVERDAG] ) / 10 + 0.3965 * (try_convert(real,[T_OVERDAG]) /10 - 28.675) *  POWER(3.6 * try_convert(real,FH_OVERDAG) / 10,0.16)
        WHEN T_OVERDAG>25 THEN -8.78469475556 + 1.61139411*T_OVERDAG + 2.33854883889*U_OVERDAG*100 + -0.14611605*T_OVERDAG*U_OVERDAG*100
         + -0.012308094*(T_OVERDAG*T_OVERDAG) + -0.0164248277778*(U_OVERDAG*100*U_OVERDAG*100) 
         + 0.002211732*((T_OVERDAG*T_OVERDAG)*U_OVERDAG*100) + 0.00072546*(T_OVERDAG*(U_OVERDAG*100*U_OVERDAG*100)) 
         + -0.000003582*((T_OVERDAG*T_OVERDAG)*(U_OVERDAG*100*U_OVERDAG*100)) 
        ELSE T_OVERDAG END as [T_GEV: Gevoelstemperatuur overdag]
 


  FROM [OPENDATA].[NL_KNMI] K
  left join OPENDATA.NL_KNMI_STN S on K.STN=S.STN

  


  FROM [OPENDATA].[NL_KNMI] K
  left join OPENDATA.NL_KNMI_STN S on K.STN=S.STN

  
GO
