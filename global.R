
### GLOBAL: Zentrale Initialisierung Shiny-App

# 1 - Paket- & Umgebungs-Setup (renv)
# 2 - Laden R-Bibliotheken
# 3 - (Optional) Datenimport & Datenvorverarbeitung (GIS)
# 4 - Aufbau Leaflet-Basiskarte

#---#

## 1 - Paket- & Umgebungs-Setup (renv)

## renv – Reproduzierbare Paketverwaltung (renv: https://rstudio.github.io/renv/articles/renv.html) für Kontrolle & Pflege 

# renv::init()          ## Initialisiert renv-Projekt
# renv::snapshot()      ## Schreibt aktuellen Paketstand in renv.lock
# renv::status()        ## Abweichungen zwischen Code & Lockfile
# renv::upgrade()       ## Aktualisiert renv 
# renv::clean()         ## Entfernt ungenutzte Pakete
# renv::repair()        ## Repariert beschädigte Bibliotheken
# renv::update()        ## Aktualisiert Projektpakete
# renv::dependencies()  ## Analysiert Paketabhängigkeiten im Projekt

## Feste Paketversionen (notwendig für DOCKER | reproduzierbare Deployments)

# renv::record('Matrix@1.6-3')          
# renv::record('MASS@7.3-60')          
# renv::record('sp@2.1-2')              
# renv::record('lattice@0.22-5')        
# renv::record('mgcv@1.9-0')            
# renv::record('jsonlite@1.8.7')        
# renv::record('shiny@1.9.0')           
# renv::record('leaflet.extras@2.0.0')  

## Umgebungsvariable für renv-Cache in DOCKER | Serverumgebungen

Sys.setenv(RENV_PATHS_CACHE = '/tmp/shared/renv/cache')

#---#

# 2 - Laden R-Bibliotheken

### Laden Pakete für Shiny-Webanwendung, GIS-Prozessierung (Vektor & Raster), Visualisierung & Netzwerkanalyse

library(renv)
library(dplyr)
library(DT)
library(fontawesome)
library(gdistance)
library(geojsonsf)
library(geosphere)
library(htmlwidgets)
library(igraph)
library(leafem)
library(leaflet)
library(leaflet.extras)
library(leafpm)
library(leafpop)
library(leastcostpath)
library(plotly)
library(raster)
require(readxl)
library(sf)
library(sfnetworks)
library(smoothr)
library(sp)
library(shiny)
options(shiny.autoreload = TRUE)
library(shinyBS)
library(shinycssloaders)
library(shinyjs)
library(shinythemes)
library(shinyWidgets)
library(terra)
library(tidygraph)
library(tidyr)
library(tippy)
library(bslib)
library(viridisLite)

## Globale Optionen >> keine wissenschaftliche Notation + automatisches Neuladen der App bei Dateiänderungen

options(scipen=999, shiny.autoreload = TRUE) 

#---#

# 3 - Datenimport & Datenvorverarbeitung GIS (auskommentiert - einmalige Ausführung zur Initialerstellung der Datenbasis)

## Maßnahmenkatalog (Excel-Datei)

# meaTAB = read_excel(path  = "/home/lucas/RProjects/PLANeD/R_PRO/Texts/Maßnahmenkatalog.xlsx")

## Layer | Vektordaten für Untersuchungsgebiet (Shapefiles)

# BIOTO = sf::st_read('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/Biotope_HoKi.shp', layer = 'Biotope_HoKi') # Biotopflächen
# EH100_S = sf::st_read('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/EhdaPotenzial_gr100_SIMP.shp', layer = 'EhdaPotenzial_gr100_SIMP') # Eh da-Flächen > 100m
# GA100_S = sf::st_read('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/Gaerten_ALKIS_gr100_SIMP.shp', layer = 'Gaerten_ALKIS_gr100_SIMP') # ALKIS Garten
# GEMAR = sf::st_read('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/Gemarkungen_HoKi.shp', layer = 'Gemarkungen_HoKi') # Gemarkungsfläche Hohmberg | Kirtorf
# GEMEI = sf::st_read('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/Gemeindegrenze_HoKi.shp', layer = 'Gemeindegrenze_HoKi') # Gemeindefläche in Hohmberg | Kirtorf
# KOMPE = sf::st_read('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/Kompensationsflaechen_HoKi.shp', layer = 'Kompensationsflaechen_HoKi') # Kompensationsflächen
# SCHUT = sf::st_read('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/Schutzgebiete_HoKi.shp', layer = 'Schutzgebiete_HoKi') # Schutzgebiete
# BFS = sf::st_read('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/BFS.shp', layer = 'BFS') # Potentialflächen

## Transformation Vektordaten WGS84 (EPSG:4326, notwqendig für Leaflet)

# BIOTO = st_transform(BIOTO, CRS('epsg:4326'))     
# EH100_S = st_transform(EH100_S, CRS('epsg:4326'))
# GA100_S = st_transform(GA100_S, CRS('epsg:4326'))
# GEMAR = st_transform(GEMAR, CRS('epsg:4326'))
# GEMEI = st_transform(GEMEI, CRS('epsg:4326'))
# KOMPE = st_transform(KOMPE, CRS('epsg:4326'))
# SCHUT = st_transform(SCHUT, CRS('epsg:4326'))
# BFS = st_transform(BFS, CRS('epsg:4326')) # Potentialflächen

## Eindeutige IDs für BFS

# BFS = BFS %>%
#   mutate(ID = row_number()) 

## Zentroide für Layer-Labels (LabelOnlyMarkers)

# BFSc=BFS
# BFSc$geometry=st_centroid(BFSc$geometry)

# GEMEIc = GEMEI
# GEMEIc$geometry = st_centroid(GEMEIc$geometry)

# GEMARc = GEMAR
# GEMARc$geometry = st_centroid(GEMARc$geometry)

## Eh-da-Flächen >> Umbenennen Spaltennamen & Rundung Flächenwerte

# colnames(EH100_S) = c('Nr.', 'Kategorie',  'Eh da-Typ', 'Gemeinde', 'Umfang [m]', 'Flaeche [m²]', 'geometry')
# EH100_S$'Flaeche [m²]' = round(EH100_S$'Flaeche [m²]',1)

## Hilfsobjekte Leaflet (Buffer & Bounding Box)

# BUF = st_buffer(st_union(GEMEI), 1000000)
# BUF = st_difference(BUF, st_union(GEMEI))
# BUF = st_transform(BUF, CRS('epsg:4326'))

# BNDs = GEMEI %>% st_bbox()
# BNDs = as.character(round(BNDs,5))
# BNDs = as.numeric(BNDs)

## WMS-Dienste >> Luftbild & ALKIS (Hessen)

# urlGDS_RGB = 'https://gds-srv.hessen.de/cgi-bin/lika-services/ogc-free-images.ows'
# urlGDS_ALK = 'https://www.gds-srv.hessen.de/cgi-bin/lika-services/ogc-free-maps.ows'

### Farbpaletten für Leaflet

# PAL_LCRA100 = colorFactor(c('darkgrey', 'lightgreen', 'darkgreen', 'blue', 'brown'), values(LCRA100), na.color = 'transparent')

# palT_BIO = c('red', 'blue', 'green')
# P_BIO = colorFactor(palT_BIO, as.factor(unique(BIOTO$Typ)))

# palT_SCH = c('deepskyblue', 'khaki', 'lightcoral', 'purple')
# P_SCH = colorFactor(palT_SCH, as.factor(unique(SCHUT$Typ)))

## Kostenraster

# CRA100 = raster('/home/lucas/RProjects/PLANeD/R_PRO/GeoData/LS_COSTs/LC_100_Co.tif') # Auflösung 10m 
# CRA1000 = raster('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/LS_COSTs/LC_1000_Co.tif') # Auflösung 100m 
# CRA = projectRaster(CRA1000, crs = '+proj=longlat +datum=WGS84 +units=m +no_defs') # Reprojektion WGS84

## Landcover-Raster 

# LCRA10 = raster('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/LS_COSTs/LC_10.tif') # Auflösung 1m 
# LCRA100 = raster('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/LS_COSTs/LC_100.tif') # Auflösung 10m 

# LCRA10[LCRA10 < 0] = NA  # Negative Werte zu NA 
# LCRA100[LCRA100 < 0] = NA # Negative Werte zu NA 

## Raster-Aggregation >> 10m zu 100m Pixel | Attribut - 10m-Pixel pro 100m-Pixel in Prozent Landcover-Klassen

# vals = c(0,1,2,3,4)

# for (val in vals){
#  
#   LCRA100_V = aggregate(LCRA10, fact=10, 10, fun = function(x, na.rm) length(x[x == val])) #  Aggregation 10m zu 100m | Attribut - 10m-Pixel pro 100m-Pixel
# 
#   LCRA100_V = mask(crop(LCRA100_V,extent(CRA100)), CRA100) # Zuschneiden Raster 
# 
#   LCRA100_V = projectRaster(LCRA100_V, crs = '+proj=longlat +datum=WGS84 +units=m +no_defs') # Reprojektion WGS84
# 
#   writeRaster(LCRA100_V, paste0('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/LS_COSTs/LC_100_', abs(val),'.tif'), overwrite=TRUE) # Raster speichern
#  
#   assign(paste0('LCRA100_', abs(val)), LCRA100_V) # Dynamische Objektbenennung
# 
# }

## Prozessierte Raster laden & stacken

# LCRA100_0 = raster('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/LS_COSTs/LC_100_0.tif')
# LCRA100_1 = raster('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/LS_COSTs/LC_100_1.tif')
# LCRA100_2 = raster('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/LS_COSTs/LC_100_2.tif')
# LCRA100_3 = raster('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/LS_COSTs/LC_100_3.tif')
# LCRA100_4 = raster('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/LS_COSTs/LC_100_4.tif')

## LCRA-Raster in Raster-Stack

# LCRA100_STACK = stack(list('LC0'=LCRA100_0, 'LC1'=LCRA100_1, 'LC2'=LCRA100_2, 'LC3'=LCRA100_3, 'LC4'=LCRA100_4))

## Stack in DataFrame

# LCRA100_STACK_ST = as.data.frame(LCRA100_STACK, xy=TRUE)
# LCRA100_STACK_ST = na.omit(LCRA100_STACK_ST)
# LCRA100_STACK_ST = LCRA100_STACK_ST[rowSums(LCRA100_STACK_ST[,c(3:7)]) <= 101 ,]
# LCRA100_STACK_ST_P = LCRA100_STACK_ST

## Prozentuale Anteile Landcover-Klasse pro Zelle

# LCRA100_STACK_ST_P[,3] = LCRA100_STACK_ST[,3] / rowSums(LCRA100_STACK_ST[,c(3:7)])
# LCRA100_STACK_ST_P[,4] = LCRA100_STACK_ST[,4] / rowSums(LCRA100_STACK_ST[,c(3:7)])
# LCRA100_STACK_ST_P[,5] = LCRA100_STACK_ST[,5] / rowSums(LCRA100_STACK_ST[,c(3:7)])
# LCRA100_STACK_ST_P[,6] = LCRA100_STACK_ST[,6] / rowSums(LCRA100_STACK_ST[,c(3:7)])
# LCRA100_STACK_ST_P[,7] = LCRA100_STACK_ST[,7] / rowSums(LCRA100_STACK_ST[,c(3:7)])

## Kosten pro Landcover-Klasse

# C0 = 75
# C1 = 50
# C2 = 100
# C3 = 25
# C4 = 125

## Kalkulation (gewichtete) Kosten pro Zelle | Basis Anteile Landcover-Klasse pro Zelle 

# CoSt_100 = LCRA100_STACK_ST_P[,c(1,2)]
# CoSt_100[,3] = as.integer(LCRA100_STACK_ST_P[,3]  * C0 + LCRA100_STACK_ST_P[,4] * C1 + LCRA100_STACK_ST_P[,5] * C2 + LCRA100_STACK_ST_P[,6] * C3 + LCRA100_STACK_ST_P[,7] * C4)

# rm(LCRA100_STACK_ST_P)

## DataFrame zu Raster & speichern

# CoRa = rasterFromXYZ(CoSt_100, crs = 'EPSG:4326')
# writeRaster(CoRa, paste0('/home/lucas/RProjects/PLANeD_forGITHUB/R_PRO/GeoData/LS_COSTs/CoRa100.tif'), overwrite=TRUE)

### Vorbereitung Netzwerkprozessierung >> Linien zw. Potential-Flächen (Standortmittelpunkte)

# BFS_C = sf::st_point_on_surface(BFS)
# BFS_SP = st_sf(sf::st_nearest_points(BFS_C, BFS_C))
# st_geometry(BFS_SP) = 'geometry'

# PAIRs = expand.grid(BFS$Standort, BFS$Standort) # Standortkombinationen

# BFS_SP$Start = PAIRs[,2]
# BFS_SP$End = PAIRs[,1]

# BFS_SP = BFS_SP[!duplicated(t(apply(as.data.frame(BFS_SP[,2:3])[,1:2], 1, sort))),] #  Doppelte Kombinationen entfernen

# BFS_SP = BFS_SP[!st_is_empty(BFS_SP),drop=FALSE] # Entfernen leerer Geometrien
# BFS_SP$geometry[BFS_SP$Start == BFS_SP$End] = st_linestring()
# BFS_SP$geometry[as.numeric(st_length(BFS_SP$geometry)) < .01] = st_linestring()  # Entfernen Geometrien < 0.01 km

# 4 - Aufbau Leaflet-Basiskarte

# Laden .RData: Vektor- & Rasterdaten für Shiny-App  

load('.RData')

# Initiale Leaflet-Karte >> Kartenoptionen & Kartenansicht (Zentrum Bounding Box) & Kartenbereich & Weißer Hintergrund & Leerer Hintergrund

MAP = leaflet(options = leafletOptions(minZoom = 10.5,maxZoom = 18.5, zoomControl = T, preferCanvas = T, doubleClickZoom = FALSE, zoomSnap = 0.25, zoomDelta = 0.25,   wheelPxPerZoomLevel = 250)) %>%
  setView((BNDs[1]/BNDs[3])/2, (BNDs[2]/BNDs[4])/2, zoom = 11.5) %>%
  setMaxBounds(BNDs[1], BNDs[2], BNDs[3], BNDs[4]) %>%
  setMapWidgetStyle(list(background = 'white'))


# Basiskarten >> OpenStreetMap & ESRI-Satellitenbilder 

MAP = addTiles(map = MAP, group = 'OpenStreetMap', layerId = 'OpenStreetMap', options = providerTileOptions(opacity = 0.875)) %>%
  addProviderTiles(provider = 'Esri.WorldImagery', group = 'ESRI-WorldImagery', layerId = 'ESRI-WorldImagery', options = providerTileOptions(opacity = 0.875)) 

# WMS-Dienste >> Luftbild & ALKIS (Hessen) 

MAP = addWMSTiles(map = MAP, urlGDS_RGB, layers = 'he_dop_rgb', options = WMSTileOptions(format = 'image/png', transparent = TRUE, opacity = 0.875), group = 'Luftbild HVBG', layerId = 'Luftbild HVBG') %>% 
  addWMSTiles(urlGDS_ALK, layers = 'he_alk', options = WMSTileOptions(format = 'image/png', transparent = TRUE, opacity = 0.875), group = 'ALKIS HVBG', layerId = 'ALKIS HVBG')

# Kartenwerkzeuge >> Maßstab & Reset-Button & Messwerkzeug (Länge | Fläche)

MAP = MAP %>%
  addScaleBar(position = 'bottomright', options = scaleBarOptions(imperial = FALSE))%>%
  leaflet.extras::addResetMapButton() %>%
  addMeasure(position = 'topleft', primaryLengthUnit='meters', primaryAreaUnit='sqmeters', localization='de') 

# Vektordaten >> Gemeindegrenzen + Beschriftungen & Gemarkungsgrenzen + Beschriftungen

MAP = MAP %>%
  addLabelOnlyMarkers(data = GEMEIc, lat = st_coordinates(GEMEIc$geometry)[,2],lng = st_coordinates(GEMEIc$geometry)[,1], label = ~GMDE_BZ, labelOptions = labelOptions(noHide = TRUE, interactive = FALSE, direction = 'top', offset = c(10,10), textOnly = TRUE, style = list('color' = 'darkgrey', 'font-size' = '16px', 'font-style' = 'italic', 'font-weight' = 'bold', 'text-shadow' = '-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white')), group = 'Gemeindegrenze') %>% 
  addPolygons(data = GEMEI, fillColor = 'transparent', color = 'darkgrey', weight = 2.5, group = 'Gemeindegrenze') %>%
  addLabelOnlyMarkers(data = GEMARc, lat = st_coordinates(GEMARc$geometry)[,2],lng = st_coordinates(GEMARc$geometry)[,1], label = ~GMK_BZ, labelOptions(noHide = TRUE, interactive = FALSE, direction = 'top', offset = c(10,10), textOnly = TRUE, style = list('color' = 'darkgrey', 'font-size' = '12px', 'font-style' = 'italic', 'font-weight' = 'bold', 'text-shadow' = '-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white')), group = 'OrtsGemeindegrenze') %>%   
  addPolygons(data = GEMAR, layerId = GEMAR$GMK_BZ, fillColor = 'transparent', color = 'darkgrey', weight = 1.25, group = 'OrtsGemeindegrenze') 

MAP_0 = MAP

# Speicher aufräumen

rm(MAP); gc()

