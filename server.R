
# SERVER – REAKTIVITÄTS- UND LOGIKSTEUERUNG DER SHINY-APP

server = function(input, output, session) {
  
  # 1. NAVIGATION DER BENUTZEROBERFLÄCHE
  
  # Umschalten zwischen den Tabs der GUI über actionLink-Elemente
  
  observeEvent(input$L1, {
    newvalue = '1. Start'
    updateTabsetPanel(session, 'panels', newvalue)
  })
  
  observeEvent(input$L2, {
    newvalue = '2. Aktuelles'
    updateTabsetPanel(session, 'panels', newvalue)
  })
  
  observeEvent(input$L3, {
    newvalue = '3. Karten & Werkzeuge'
    updateTabsetPanel(session, 'panels', newvalue)
  })
  
  observeEvent(input$L4, {
    newvalue = '4. Maßnahmenkatalog'
    updateTabsetPanel(session, 'panels', newvalue)
  })
  
  observeEvent(input$L5, {
    newvalue = '5. Hintergrund'
    updateTabsetPanel(session, 'panels', newvalue)
  })
  
  observeEvent(input$L6, {
    newvalue = '6. Bedienungsanleitung'
    updateTabsetPanel(session, 'panels', newvalue)
  })
  
  observeEvent(input$L7, {
    newvalue = '7. Modellierte Ergebnisse/Simulationen/Was-wäre-wenn-Analysen'
    updateTabsetPanel(session, 'panels', newvalue)
  })
  
  observeEvent(input$L8, {
    newvalue = '8. Maßnahmenkatalog'
    updateTabsetPanel(session, 'panels', newvalue)
  })
  
  observeEvent(input$L9, {
    newvalue = 'Impressum & Datenschutzinformation'
    updateTabsetPanel(session, 'panels', newvalue)
  })
  
  # 2. MAßNAHMENKATALOG
  
  # Interaktive Tabelle mit Maßnahmen zur ökologischen Aufwertung. Die Tabelle kann sortiert, durchsucht und exportiert werden
  
  meaDT = DT::datatable(
    meaTAB,
    selection = "single",
    rownames = FALSE,
    options = list(
      autoWidth = TRUE,
      paging = FALSE,
      searching = FALSE,
      dom = "t",
      scrollX = F
    )
  )
  
  # Darstellung der Tabelle im UI
  
  output$meaTAB = renderDT(meaDT %>%
                             formatStyle(c(1:dim(meaTAB)[2]), border = '.125px solid #FFFAFA', fontSize = '87.5%'))
  
  # Downloadfunktion 
  
  output$download_MEA = downloadHandler(
    filename = function() {
      paste0("Maßnahmenkatalog.csv")
    },
    content = function(file) {
      write.csv(meaTAB,
                file,
                row.names = FALSE,
                fileEncoding = "UTF-8")
    },
  )
  
  # 3. REAKTIVE DATENSTRUKTUREN
  
  # Datencontainer zur Speicherung der zentralen Geodaten > Änderungen an diesen Objekten lösen automatisch Aktualisierungen in Karten, Auswahlfeldern und Netzwerkanalysen aus.
  
  # Potentialflächen
  
  BFS_r = reactiveVal() 
  BFS_r(BFS)
  
  # Zentroide der Potentialflächen > werden für Labels in Leaflet sowie als Knoten (Nodes) in Netzwerkanalysen genutzt
  
  BFSc_r = reactiveVal() 
  BFSc_r(BFSc)
  
  # Verbindungen zwischen Potentialflächen > dienen als Kanten (Edges) für Netzwerkanalysen
  
  BFS_SP_r = reactiveVal() 
  BFS_SP_r(BFS_SP)
  
  # 4. VISUALISIERUNG DER GEODATEN - MAP_1 
  
  # Darstellung des Projektgebiets und der verfügbaren Geodaten. Zusätzlich können Potentialflächen digitalisiert, bearbeitet oder gelöscht werden.
  
  # Reaktive Variable zum erneuten Rendern der Leaflet-Karte 
  
  MAP_TRIGGER = reactiveVal(0)
  
  output$MAP_1 = renderLeaflet({
    
    # Prüfen, ob externer Rendering-Trigger aktiv is
    
    req(MAP_TRIGGER())
    
    # Basis-Karte laden (MAP_1), vorhandene Controls entfernen, Labels der Potentialflächen anzeigen, Kartenebenen (MapPanes) definieren, & Zeichenwerkzeug für Digitalisierung hinzufügen
    
    MAP_0 %>%
      clearControls() %>% 
      {DF = BFSc_r()
      
      # Prüfung: existieren Zentroidpunkte der Potentialflächen?
      
      if (!is.null(DF) && is.data.frame(DF) && nrow(DF) > 0) {
        
        addLabelOnlyMarkers( 
          .,
          data = DF,
          lat = st_coordinates(BFSc_r()$geometry)[, 2],
          lng = st_coordinates(BFSc_r()$geometry)[, 1],
          label = ~ Standort,
          labelOptions = labelOptions(
            noHide = T,
            direction = 'centered',
            offset = c(0, 0),
            textOnly = TRUE,
            style = list(
              'color' = 'grey66',
              'font-size' = '14px',
              'text-shadow' = '-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white'
            )
          ),
          group = 'BFS_L'
        ) %>%
          groupOptions('BFS_L', zoomLevels = 14:22) 
      } else {
        .
      }
      } %>% 
      
      # Definition der Kartenebenen (Z-Index) > https://www.rdocumentation.org/packages/leaflet/versions/2.2.2/topics/addMapPane
      
      addMapPane('Potentialflächen', zIndex = 500) %>% 
      addMapPane('Eh da-Fläche (>100m²)', zIndex = 450) %>%
      
      # Darstellung der Potentialflächen
      
      addPolygons(
        data = BFS_r(),
        layerId = BFS_r()$Standort,
        fillColor = '#00ff00',
        color = 'darkgrey',
        weight = 1.25,
        opacity = 1,
        fillOpacity = .625,
        dashArray = '1',
        highlightOptions = highlightOptions(
          color = 'darkgrey',
          weight = 5,
          opacity = .125,
          sendToBack = FALSE
        ),
        group = 'Potentialflächen',
        options = pathOptions(pane = 'Potentialflächen')
      ) %>%
      
      # Zeichenwerkzeug für Potentialflächen (Leaflet DrawToolbar) > https://www.rdocumentation.org/packages/leaflet.extras/versions/2.0.1/topics/addDrawToolbar
      
      addDrawToolbar( 
        targetGroup = "Potentialflächen",
        toolbar = toolbarOptions(
          actions = list(text = "Abbrechen"),
          finish = list(text = "Speichern"),
          undo = list(text = "Rückgängig"),
          buttons = list(
            polygon = "Polygon zeichnen",
            rectangle = "Viereck zeichnen")
        ),
        handlers = handlersOptions(
          polygon = list(
            tooltipStart = "Klicken, um mit dem Zeichnen zu beginnen",
            tooltipCont  = "Weiter klicken, um das Polygon fortzusetzen",
            tooltipEnd   = "Klicken auf den ersten Punkt zum Schließen"
          ),
          rectangle = list(tooltipStart = "Klicken und ziehen, um ein Rechteck zu zeichnen"),
          simpleshape = list(tooltipEnd = "Maustaste loslassen, um das Zeichnen zu beenden")
        ),
        polylineOptions = FALSE,
        polygonOptions = drawPolygonOptions(
          shapeOptions = drawShapeOptions(
            fillColor   = "grey",
            color       = "red",
            weight      = 2.5,
            fillOpacity = 0.125,
            dashArray   = "1"
          )
        ),
        circleOptions = FALSE,
        rectangleOptions = drawRectangleOptions(
          shapeOptions = drawShapeOptions(
            fillColor   = "grey",
            color       = "red",
            weight      = 2.5,
            fillOpacity = 0.125,
            dashArray   = "1"
          )
        ),
        markerOptions = FALSE,
        circleMarkerOptions = FALSE,
        editOptions = editToolbarOptions(edit = TRUE, remove = TRUE),
        edittoolbar = edittoolbarOptions(
          actions = list(
            save = list(title = "Änderungen speichern", text  = "Speichern"),
            cancel = list(title = "Bearbeitung abbrechen", text  = "Abbrechen"),
            clearAll = list(title = "Alle Objekte löschen", text  = "Alles löschen")
          ),
          buttons = list(
            edit           = "Objekte bearbeiten",
            editDisabled   = "Keine Objekte zum Bearbeiten",
            remove         = "Objekte löschen",
            removeDisabled = "Keine Objekte zum Löschen"
          )
        ),
        
        # Editier- und Löschfunktionen
        
        edithandlers = edithandlersOptions(
          edit = list(tooltipText = "Objekt editieren: Fläche oder einzelne Punkte verschieben", tooltipSubtext = ""),
          remove = list(tooltipText = "Klicken, um ein Objekt zu löschen")
        )
      ) %>%
      
      # Layer-Control
      
      addLayersControl(
        baseGroups = c(
          'Leer',
          'OpenStreetMap',
          'ESRI-WorldImagery',
          'Luftbild HVBG',
          'ALKIS HVBG'
        ),
        overlayGroups = c(
          'Potentialflächen',
          'Landschaftsklassifikation',
          'Eh da-Fläche (>100m²)',
          'Garten ALKIS',
          'Kompensationsfläche',
          'Biotope',
          'Schutzgebiete',
          # 'Gemeindegrenze',
          'OrtsGemeindegrenze'
        ),
        options = layersControlOptions(
          collapsed = TRUE,
          unchecked = FALSE ,
          autoZIndex = FALSE
        )
      ) %>%
      
      # Definition weiterer Kartenebenen
      
      addMapPane('Potentialflächen', zIndex = 500) %>%
      addMapPane('Landschaftsklassifikation', zIndex = 400) %>%
      addMapPane('Eh da-Fläche (>100m²)', zIndex = 450) %>%
      addMapPane('Garten ALKIS', zIndex = 450) %>%
      addMapPane('Kompensationsfläche', zIndex = 450) %>%
      addMapPane('Biotope', zIndex = 450) %>%
      addMapPane('Schutzgebiete', zIndex = 450) %>%
      addMapPane('OrtsGemeindegrenze', zIndex = 450) %>%
      
      # Standardmäßig deaktivierte Layer
      
      hideGroup('Landschaftsklassifikation') %>%
      hideGroup('Eh da-Fläche (>100m²)') %>%
      hideGroup('Garten ALKIS') %>%
      hideGroup('Kompensationsfläche') %>%
      hideGroup('Biotope') %>%
      hideGroup('Schutzgebiete') %>%
      hideGroup('OrtsGemeindegrenze')
    
  })
  
  # 5. IMPORT EXTERNER POTENTIALFLÄCHEN (.GPKG)
  
  # Upload und Integration externer Potentialflächen inklusive:
  #   * Validierung des Dateiformats
  #   * Ableitung abhängiger Geometrien (Zentroide, Verbindungen)
  #   * Aktualisierung aller reaktiven Komponenten (Karte, Picker, Netzwerkanalyse)
  
  observeEvent(c(input$upload_R), {
    
    # Bestimmung des Dateinamens und der Dateiendung
    
    name_O = input$upload_R$name
    EXT = tolower(tools::file_ext(name_O))
    
    # Validierung des Dateiformats
    
    if (EXT != "gpkg") {
      
      showModal(
        modalDialog(
          size = "s",
          tags$h5('Falsches Datenformat - Format ".gpkg" notwendig!', align = "center"),
          easyClose = TRUE
        )
      )
      
      return(NULL)
      
    }
    
    # Einlesen der GeoPackage-Datei als sf-Objekt
    
    BFS = sf::st_read(input$upload_R[4]) %>%
      rename(geometry = geom)
    
    BFS$ID = seq_len(nrow(BFS))
    
    
    # Ableitung der Zentroidpunkte der Potentialflächen
    
    BFSc = BFS
    BFSc$geometry = st_centroid(BFSc$geometry)
    
    # Ableitung der Verbindungen zwischen Potentialflächen
    # Punktrepräsentation der Flächen (robuster als Zentroid)
    
    BFS_C = sf::st_point_on_surface(BFS)
    
    # Berechnung aller Linien zwischen Punktkombinationen
    
    BFS_SP = st_sf(sf::st_nearest_points(BFS_C, BFS_C))
    st_geometry(BFS_SP) = 'geometry'
    
    # Definition der Start- und Endpunkte der Verbindungen
    
    PAIRs = expand.grid(BFS$Standort, BFS$Standort)
    
    BFS_SP$Start = PAIRs[, 2]
    BFS_SP$End = PAIRs[, 1]
    
    # Entfernen doppelter Verbindungen (A–B == B–A)
    
    BFS_SP = BFS_SP[!duplicated(t(apply(as.data.frame(BFS_SP[, 2:3])[, 1:2], 1, sort))), ]
    
    # Entfernen leerer Verbindungen
    
    BFS_SP = BFS_SP[!st_is_empty(BFS_SP), drop = FALSE]
    
    # Entfernen Selbstverbindungen
    
    BFS_SP$geometry[BFS_SP$Start == BFS_SP$End] = st_linestring()
    
    # Entfernen sehr kurzer Verbindungen 
    
    BFS_SP$geometry[as.numeric(st_length(BFS_SP$geometry)) < .01] = st_linestring()
    
    # Entfernen leerer Verbindungen
    
    BFS_SP = BFS_SP[!st_is_empty(BFS_SP), , drop = FALSE]
    
    # Aktualisierung der reaktiven Datencontainer
    
    BFS_r(BFS)
    BFSc_r(BFSc)
    BFS_SP_r(BFS_SP)
    
    # Aktualisierung der Auswahlfelder (Picker)
    
    updatePickerInput(
      session = session,
      inputId = 'I1',
      choices = unique(sort(BFS_r()$Standort)),
      selected = NULL
    )
    
    # Aktualisierung der Kartenansicht
    
    rDT()
    
  })
  
  # 6. EXPOPRT POTENTIALFLÄCHEN (.GPKG)
  # Export der aktuell verwendeten Potentialflächen 
  
  output$download_R = downloadHandler(
    
    filename = function()
    {
      paste0("BFS.gpkg")
    },
    content = function(file)
    {
      st_write(BFS_r(), file, delete_layer = TRUE)
    }
    
  )
  
  # 7. PERFORMANCE-OPTIMIERUNG MAP_1 – DYNAMISCHES LADEN VON KARTENLAYERN
  
  # Verhindern des initialen Ladens großer Layer. Layer werden erst geladen, wenn sie durch den Nutzer aktiviert werden.
  
  # Speicherung bereits geladener Layer
  
  loadLAYERS_1 = reactiveVal()
  
  # Reaktiver Trigger für Änderungen der Layer-Auswahl > da 'input$MAP_1_groups' nicht zuverlässig als Trigger funktioniert, wird ein expliziter Event-Zähler verwendet.
  
  MAP_1_TRIGGER = reactiveVal(0)
  
  # Aktualisierung des Triggers bei Änderung der Layer-Auswahl
  
  observeEvent(input$MAP_1_groups, {
    
    MAP_1_TRIGGER(MAP_1_TRIGGER() + 1)
    
  })
  
  # Listener für dynamisches Laden der Kartenlayer
  
  observeEvent(c(MAP_1_TRIGGER()), {
    
    # Ein Layer wird geladen, wenn vom Nutzer aktiviert wurde & noch nicht geladen wurde
    
    # Ablauf:
    #   1. Layer als "geladen" markieren
    #   2. Layer dynamisch zur Leaflet-Karte hinzufügen
    
    if ('Landschaftsklassifikation' %in% input$MAP_1_groups & !('Landschaftsklassifikation' %in% loadLAYERS_1())){
      
      loadLAYERS_1(unique(c(loadLAYERS_1(), 'Landschaftsklassifikation')))
      
      leafletProxy(map = 'MAP_1', session = session) %>%
        addRasterImage(
          LCRA100,
          colors = PAL_LCRA100,
          opacity = .75,
          group = 'Landschaftsklassifikation',
          project  =  FALSE,
          options = pathOptions(pane = 'Landschaftsklassifikation')
        ) %>%
        addLegend(
          position = 'bottomright',
          opacity = .75,
          pal = PAL_LCRA100,
          values = values(LCRA100),
          layerId="legend_kosten",
          labFormat = function(type, cuts, p)
          {
            label_map = c(
              '0' = 'Verkehr',
              '1' = 'Offenland',
              '2' = 'Gehölz',
              '3' = 'Wasser',
              '4' = 'Gebäude'
            )
            sapply(cuts, function(x)
              label_map[as.character(x)])
          },
          group = 'Landschaftsklassifikation'
        )
    }
    
    if ('Eh da-Fläche (>100m²)' %in% input$MAP_1_groups & !('Eh da-Fläche (>100m²)' %in% loadLAYERS_1())){
      
      loadLAYERS_1(unique(c(loadLAYERS_1(), 'Eh da-Fläche (>100m²)')))
      
      leafletProxy(map = 'MAP_1', session = session) %>%
        addPolygons(
          data = EH100_S,
          fillColor = '#7FFFD4',
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Eh da-Fläche (>100m²)',
          popup = popupTable(
            EH100_S,
            zcol = c(1:4, 6),
            feature.id = F,
            row.numbers = F,
            className = 'popupTAB'
          ),
          popupOptions = popupOptions(maxWidth = 1000, minWidth = 10),
          highlightOptions = highlightOptions(color = 'darkgrey', weight = 3),
          options = pathOptions(pane = "Eh da-Fläche (>100m²)")
        ) %>%
        addLegend(
          'bottomright',
          colors = '#7FFFD4',
          labels = 'Eh da-Fläche (>100m²)',
          opacity = .75,
          group = 'Eh da-Fläche (>100m²)',
          layerId = "Eh da_legend"
        )
      
    }
    
    if ('Garten ALKIS' %in% input$MAP_1_groups & !('Garten ALKIS' %in% loadLAYERS_1())){
      
      loadLAYERS_1(unique(c(loadLAYERS_1(), 'Garten ALKIS')))
      
      leafletProxy(map = 'MAP_1', session = session) %>%
        addPolygons(
          data = GA100_S,
          layerId = GA100_S$OBJECTID,
          fillColor = 'orange',
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Garten ALKIS',
          options = pathOptions(pane = 'Garten ALKIS')
        ) %>%
        addLegend(
          'bottomright',
          colors = 'orange',
          labels = 'Garten ALKIS',
          opacity = .75,
          group = 'Garten ALKIS'
        )
      
    }
    
    if ('Kompensationsfläche' %in% input$MAP_1_groups & !('Kompensationsfläche' %in% loadLAYERS_1())){
      
      loadLAYERS_1(unique(c(loadLAYERS_1(), 'Kompensationsfläche')))
      
      leafletProxy(map = 'MAP_1', session = session) %>%
        addPolygons(
          data = KOMPE,
          layerId = KOMPE$OBJECTID,
          fillColor = 'orchid',
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Kompensationsfläche',
          options = pathOptions(pane = 'Kompensationsfläche')
        ) %>%
        addLegend(
          'bottomright',
          colors = 'orchid',
          labels = 'Kompensationsfläche',
          opacity = .75,
          group = 'Kompensationsfläche'
        )
      
    }
    
    if ('Biotope' %in% input$MAP_1_groups & !('Biotope' %in% loadLAYERS_1())){
      
      loadLAYERS_1(unique(c(loadLAYERS_1(), 'Biotope')))
      
      leafletProxy(map = 'MAP_1', session = session) %>%
        addPolygons(
          data = BIOTO,
          layerId = BIOTO$OBJECTID,
          fillColor = ~ P_BIO(Typ),
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Biotope',
          options = pathOptions(pane = 'Biotope')
        ) %>%
        addLegend(
          'bottomright',
          colors = palT_BIO,
          labels = LABs,
          values =  ~ BIOTO$Typ,
          opacity = .75,
          group = 'Biotope'
        )
      
    }
    
    if ('Schutzgebiete' %in% input$MAP_1_groups & !('Schutzgebiete' %in% loadLAYERS_1())){
      
      loadLAYERS_1(unique(c(loadLAYERS_1(), 'Schutzgebiete')))
      
      leafletProxy(map = 'MAP_1', session = session) %>%
        addPolygons(
          data = SCHUT,
          layerId = SCHUT$OBJECTID,
          fillColor = ~ P_SCH(Typ),
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Schutzgebiete',
          options = pathOptions(pane = 'Schutzgebiete')
        ) %>%
        addLegend(
          'bottomright',
          colors = palT_SCH,
          labels = unique(SCHUT$Typ),
          opacity = .75,
          group = 'Schutzgebiete'
        )
      
    }
    
  })
  
  # 8. FUNKTION rDT() – REINITIALISIERUNG UND SYNCHRONISATION MAP_1
  
  # Die Funktion rDT() wird aufgerufen, z. B. durch:
  #   * Digitalisierung neuer Flächen
  #   * Editieren oder Löschen bestehender Flächen
  #   * Import externer Geodaten (.gpkg)
  
  # Ziel der Funktion:
  #   * Aktualisierung der Auswahlfelder (Picker) für Netzwerkanalysen
  #   * Reinitialisierung der Leaflet-Karte MAP_1
  #   * Synchronisation aller reaktiven Komponenten
  #   * Beibehaltung der aktuellen Kartenposition (Center & Zoom)
  
  rDT = function(){
    
    # Aktualisierung der Auswahl der Potentialflächen für die Netzwerkanalyse in MAP_2
    
    updatePickerInput(
      session = session,
      inputId = 'I1',
      choices = unique(sort(BFS_r()$Standort)),
      selected = NULL
    )
    
    # Aktualisierung der Auswahl der Potentialflächen für die Netzwerkanalyse in MAP_3
    
    updatePickerInput(
      session = session,
      inputId = 'I1_3',
      choices = unique(sort(BFS_r()$Standort)),
      selected = NULL
    )
    
    # Aktive Overlay-Layer werden zwischengespeichert, um sie nach der Karten-Reinitialisierung wiederherzustellen
    
    LA = input$MAP_1_groups
    
    # Liste bereits geladener Layer wird geleert, damit das Performance-Loading erneut greifen kann
    
    loadLAYERS_1(character(0))
    
    # Kartenparameter (Center & Zoom) werden gespeichert, damit sich die Kartenposition nach der Aktualisierung nicht verändert
    
    PARAs = list(center = input$MAP_1_center, zoom = input$MAP_1_zoom)
    
    # REINITIALISIERUNG DER LEAFLET-KARTE MAP_1
    
    leafletProxy(map = 'MAP_1', session = session) %>%
      
      # Entfernen vorhandener Controls
      
      clearControls() %>%
      
      # Wiederherstellung der aktuellen Kartenposition
      
      invokeMethod(
        'map',
        'setView',
        c(PARAs$center$lat, PARAs$center$lng),
        PARAs$zoom,
        list(animate = FALSE)
      ) %>%
      
      # Darstellung der Labels der Potentialflächen
      
      {
        DF = BFSc_r()
        
        # Prüfung, ob Zentroidpunkte existieren & 
        
        if (!is.null(DF) && is.data.frame(DF) && nrow(DF) > 0) {
          
          addLabelOnlyMarkers(
            .,
            data = DF,
            lat = st_coordinates(BFSc_r()$geometry)[, 2],
            lng = st_coordinates(BFSc_r()$geometry)[, 1],
            label = ~ Standort,
            labelOptions = labelOptions(
              noHide = T,
              direction = 'centered',
              offset = c(0, 0),
              textOnly = TRUE,
              style = list(
                'color' = 'grey66',
                'font-size' = '14px',
                'text-shadow' = '-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white'
              )
            ),
            group = 'BFS_L'
          ) %>%
            
            # Labels erst ab höherem Zoomlevel anzeigen
            
            groupOptions('BFS_L', zoomLevels = 14:22) 
        } else {
          .
        }
      } %>%
      
      # Darstellung der Potentialflächen
      
      groupOptions('BFS_L', zoomLevels = 14:22) %>%
      addMapPane('Potentialflächen', zIndex = 500) %>%
      addMapPane('Eh da-Fläche (>100m²)', zIndex = 450) %>%
      addPolygons(
        data = BFS_r(),
        layerId = BFS_r()$Standort,
        fillColor = '#00ff00',
        color = 'darkgrey',
        weight = 1.25,
        opacity = 1,
        fillOpacity = .625,
        dashArray = '1',
        highlightOptions = highlightOptions(
          color = 'darkgrey',
          weight = 5,
          opacity = .125,
          sendToBack = FALSE
        ),
        group = 'Potentialflächen',
        options = pathOptions(pane = 'Potentialflächen')
      ) %>%
      
      # Zeichenwerkzeug der Potentialflächen
      
      addDrawToolbar(
        targetGroup = "Potentialflächen",
        toolbar = toolbarOptions(
          actions = list(text = "Abbrechen"),
          finish = list(text = "Speichern"),
          undo = list(text = "Rückgängig"),
          buttons = list(
            polygon = "Polygon zeichnen",
            rectangle = "Viereck zeichnen")
        ),
        handlers = handlersOptions(
          polygon = list(
            tooltipStart = "Klicken, um mit dem Zeichnen zu beginnen",
            tooltipCont  = "Weiter klicken, um das Polygon fortzusetzen",
            tooltipEnd   = "Klicken auf den ersten Punkt zum Schließen"
          ),
          rectangle = list(tooltipStart = "Klicken und ziehen, um ein Rechteck zu zeichnen"),
          simpleshape = list(tooltipEnd = "Maustaste loslassen, um das Zeichnen zu beenden")
        ),
        polylineOptions = FALSE,
        polygonOptions = drawPolygonOptions(
          shapeOptions = drawShapeOptions(
            fillColor   = "grey",
            color       = "red",
            weight      = 2.5,
            fillOpacity = 0.125,
            dashArray   = "1"
          )
        ),
        circleOptions = FALSE,
        rectangleOptions = drawRectangleOptions(
          shapeOptions = drawShapeOptions(
            fillColor   = "grey",
            color       = "red",
            weight      = 2.5,
            fillOpacity = 0.125,
            dashArray   = "1"
          )
        ),
        markerOptions = FALSE,
        circleMarkerOptions = FALSE,
        editOptions = editToolbarOptions(edit = TRUE, remove = TRUE),
        edittoolbar = edittoolbarOptions(
          actions = list(
            save = list(title = "Änderungen speichern", text  = "Speichern"),
            cancel = list(title = "Bearbeitung abbrechen", text  = "Abbrechen"),
            clearAll = list(title = "Alle Objekte löschen", text  = "Alles löschen")
          ),
          buttons = list(
            edit           = "Objekte bearbeiten",
            editDisabled   = "Keine Objekte zum Bearbeiten",
            remove         = "Objekte löschen",
            removeDisabled = "Keine Objekte zum Löschen"
          )
        ),
        edithandlers = edithandlersOptions(
          edit = list(tooltipText    = "Objekt editieren: Fläche oder einzelne Punkte verschieben", tooltipSubtext = ""),
          remove = list(tooltipText = "Klicken, um ein Objekt zu löschen")
        )
      ) %>%
      addLayersControl(
        baseGroups = c(
          'Leer',
          'OpenStreetMap',
          'ESRI-WorldImagery',
          'Luftbild HVBG',
          'ALKIS HVBG'
        ),
        overlayGroups = c(
          'Potentialflächen',
          'Landschaftsklassifikation',
          'Eh da-Fläche (>100m²)',
          'Garten ALKIS',
          'Kompensationsfläche',
          'Biotope',
          'Schutzgebiete',
          # 'Gemeindegrenze',
          'OrtsGemeindegrenze'
        ),
        options = layersControlOptions(
          collapsed = TRUE,
          unchecked = FALSE ,
          autoZIndex = FALSE
        )
      ) %>%
      addMapPane('Potentialflächen', zIndex = 500) %>%
      addMapPane('Landschaftsklassifikation', zIndex = 400) %>%
      addMapPane('Eh da-Fläche (>100m²)', zIndex = 450) %>%
      addMapPane('Garten ALKIS', zIndex = 450) %>%
      addMapPane('Kompensationsfläche', zIndex = 450) %>%
      addMapPane('Biotope', zIndex = 450) %>%
      addMapPane('Schutzgebiete', zIndex = 450) %>%
      addMapPane('OrtsGemeindegrenze', zIndex = 450) %>%
      hideGroup('Landschaftsklassifikation') %>%
      hideGroup('Eh da-Fläche (>100m²)') %>%
      hideGroup('Garten ALKIS') %>%
      hideGroup('Kompensationsfläche') %>%
      hideGroup('Biotope') %>%
      hideGroup('Schutzgebiete') %>%
      hideGroup('OrtsGemeindegrenze')
    
    # Wiederherstellung der aktiven Overlay-Layer 
    
    for (L in LA) {
      
      leafletProxy(map = 'MAP_1', session = session) %>%
        showGroup(L) %>%
        htmlwidgets::onRender("function(el, x, data) { this.invalidateSize(); }")
      
    }
    
    # Auslösen des Performance-Loading MAP_1 (durch Erhöhen des Triggers)
    
    MAP_1_TRIGGER(MAP_1_TRIGGER() + 1)
    
  }
  
  # 9. EDITIERMODUS DER POTENTIALFLÄCHEN MAP_1
  
  # Statusvariable für den Editiermodus > Verhindert Mehrfachtrigger während der Bearbeitung von Polygonen.
  
  EDIT_ACTIVE_1 = reactiveVal(FALSE)
  
  observeEvent(input$MAP_1_draw_editstart, {
    EDIT_ACTIVE_1(TRUE)
  })
  observeEvent(input$MAP_1_draw_editstop, {
    EDIT_ACTIVE_1(FALSE)
  })
  
  # LISTENER FÜR DIGITALISIERUNGS-, EDITIER- UND LÖSCHPROZESSE MAP_1
  
  # Listener reagiert auf Start von:
  #   * Digitalisierung neuer Potentialflächen
  #   * Editieren bestehender Flächen
  #   * Löschen vorhandener Flächen
  
  # Ziel:
  #   * Entfernen vorhandener Buffer-Geometrien
  #   * Aktivierung des Statusflags für Digitalisierungsprozesse
  
  observeEvent(c(input$MAP_1_draw_start,input$MAP_1_draw_editstart,input$MAP_1_draw_deletestart),{
    
    # Entfernen vorhandener Buffer-Geometrien aus der Karte
    
    leafletProxy(map = 'MAP_1', session = session) %>%
      clearGroup('Buffer') 
    
    # Aktivieren Statusflag für Zeichen-/Editierprozess
    
    S_ED(TRUE)
    
  },ignoreNULL = FALSE)
  
  # Status-Flag 'Modal' > Speichert den Zustand eines geöffneten Modal-Fensters (Offen / Geschlossen) und verhindert Mehrfachtrigger
  
  openMODAL = reactiveVal(FALSE)
  
  # Listener 'Editierte Features' > Wird ausgelöst, wenn vorhandene Potentialflächen bearbeitet wurden
  
  observeEvent(c(input$MAP_1_draw_edited_features), {
    
    # Prüfen, ob Editiermodus aktiv ist
    
    req(EDIT_ACTIVE_1())
    
    # Editiermodus deaktivieren
    
    EDIT_ACTIVE_1(FALSE)
    
    # Prüfen, ob editierte Features aus Leaflet vorhanden sind
    
    if (!is.null(input$MAP_1_draw_edited_features)) {
      
      # Konvertierung editierter GeoJSON-Features in sf-Objekte
      
      nFEA_E = input$MAP_1_draw_edited_features
      nFEA_E = geojsonsf::geojson_sf(jsonify::to_json(nFEA_E, unbox = T))
      
      BFS = BFS_r()
      
      # Variable zur Speicherung fehlerhafter Geometrien
      
      nV_IDs = NULL
      
      # Schleife über alle editierten Features
      
      for (x in 1:nrow(nFEA_E)) {
        
        # Prüfen, ob Geometrie gültig ist
        
        if (nFEA_E$geometry[[x]] %>% st_is_valid() == TRUE) {
          
          # Ersetzen der Geometrie im Datensatz der Potentialflächen
          
          BFS[BFS$Standort == nFEA_E$layerId[[x]], ]$geometry = nFEA_E$geometry[[x]]
          
        }
        
        # Speicherung ungültiger Geometrien
        
        else {
          
          nV_IDs = append(nV_IDs, nFEA_E$layerId[[x]])
          
        }
      }
      
      # Warnmeldung bei ungültigen Geometrien
      
      if (length(nV_IDs) > 0) {
        
        showModal(modalDialog(
          size = c('s'),
          tags$h5(paste0(
            'Editieren von Polygon(en) mit ID(s)'
          ), align = "center"),
          div(tags$h4(
            paste(nV_IDs, collapse = ", "), style = "color: orange;"
          ), align = "center"),
          tags$h5(paste0('fehlerhaft'), align = "center"),
          footer = tagList(),
          easyClose = T
        ))
        
        Sys.sleep(2)
        
        # Modal schließen 
        
        removeModal()
        openMODAL(FALSE)
        
      }
      
      # NEUBERECHNUNG DER VERBINDNGEN 
      
      # Ableitung der Zentroidpunkte der Potentialflächen > dienen als Labels in Leaflet & Knoten in Netzwerkanalyse)
      
      BFSc = BFS
      BFSc$geometry = st_centroid(BFSc$geometry)
      
      # Punktrepräsentation innerhalb der Flächen (robuster als Zentroid)
      
      BFS_C = sf::st_point_on_surface(BFS)
      
      # Linien zwischen allen Punktkombinationen
      
      BFS_SP = st_sf(sf::st_nearest_points(BFS_C, BFS_C))
      st_geometry(BFS_SP) = 'geometry'
      
      # Definition der Start- und Endpunkte
      
      PAIRs = expand.grid(BFS$Standort, BFS$Standort)
      
      BFS_SP$Start = PAIRs[, 2]
      BFS_SP$End = PAIRs[, 1]
      
      # Entfernen doppelter Verbindungen (A–B == B–A)
      
      BFS_SP = BFS_SP[!duplicated(t(apply(as.data.frame(BFS_SP[, 2:3])[, 1:2], 1, sort))), ]
      
      # Entfernen leerer Verbindungen
      
      BFS_SP = BFS_SP[!st_is_empty(BFS_SP), drop = FALSE]
      
      # Entfernen von Selbstverbindungen
      
      BFS_SP$geometry[BFS_SP$Start == BFS_SP$End] = st_linestring()
      
      # Entfernen sehr kurzer Verbindungen 
      
      BFS_SP$geometry[as.numeric(st_length(BFS_SP$geometry)) < .01] = st_linestring()
      
      # Entfernen leerer Verbindungen
      
      BFS_SP = BFS_SP[!st_is_empty(BFS_SP), , drop = FALSE]
      
      # Aktualisierung der reaktiven Datencontainer
      
      BFS_r(BFS)
      BFSc_r(BFSc)
      BFS_SP_r(BFS_SP)
      
      # Aktualisierung der Kartenansicht
      
      rDT()
      
    }
    
  })
  
  # 10. LÖSCHEN VON POTENTIALFLÄCHEN MAP_1
  
  # Statusflag für den Löschmodus verhindert Mehrfachtrigger während des Löschvorgangs
  
  DELE_ACTIVE_1 = reactiveVal(FALSE)
  
  observeEvent(input$MAP_1_draw_deletestart, {
    DELE_ACTIVE_1(TRUE)
  })
  observeEvent(input$MAP_1_draw_deletestop, {
    DELE_ACTIVE_1(FALSE)
  })
  
  # LISTENER – GELÖSCHTE FEATURES
  
  observeEvent(c(input$MAP_1_draw_deleted_features), {
    
    # Prüfen, ob Löschmodus aktiv ist
    
    req(DELE_ACTIVE_1())
    
    # Löschmodus deaktivieren
    
    DELE_ACTIVE_1(FALSE)
    
    # Gelöschte Features aus Leaflet
    
    nFEA_D = input$MAP_1_draw_deleted_features
    
    # Prüfen, ob tatsächlich Features gelöscht wurden
    
    if (is.null(nFEA_D$features) || length(nFEA_D$features) == 0) {
      
      return(NULL)
      
    }
    
    # Konvertierung der gelöschten GeoJSON-Features in ein sf-Objekt
    
    nFEA_D = geojsonsf::geojson_sf(jsonify::to_json(nFEA_D, unbox = T))
    
    BFS = BFS_r()
    
    # Entfernen der gelöschten Potentialflächen aus dem Datensatz
    
    for (x in 1:length(nFEA_D$geometry)) {
      
      BFS = BFS[BFS$Standort != nFEA_D$layerId[x], ]
      
    }
    
    # NEUBERECHNUNG DER VERBINDNGEN 
    
    # Ableitung der Zentroidpunkte der Potentialflächen > dienen als Labels in Leaflet & Knoten in Netzwerkanalyse)
    
    BFSc = BFS
    BFSc$geometry = st_centroid(BFSc$geometry)
    
    # Punktrepräsentation innerhalb der Flächen (robuster als Zentroid)
    
    BFS_C = sf::st_point_on_surface(BFS)
    
    # Linien zwischen allen Punktkombinationen
    
    BFS_SP = st_sf(sf::st_nearest_points(BFS_C, BFS_C))
    st_geometry(BFS_SP) = 'geometry'
    
    # Definition der Start- und Endpunkte
    
    PAIRs = expand.grid(BFS$Standort, BFS$Standort)
    
    BFS_SP$Start = PAIRs[, 2]
    BFS_SP$End = PAIRs[, 1]
    
    # Entfernen doppelter Verbindungen (A–B == B–A)
    
    BFS_SP = BFS_SP[!duplicated(t(apply(as.data.frame(BFS_SP[, 2:3])[, 1:2], 1, sort))), ]
    
    # Entfernen leerer Verbindungen
    
    BFS_SP = BFS_SP[!st_is_empty(BFS_SP), drop = FALSE]
    
    # Entfernen von Selbstverbindungen
    
    BFS_SP$geometry[BFS_SP$Start == BFS_SP$End] = st_linestring()
    
    # Entfernen sehr kurzer Verbindungen 
    
    BFS_SP$geometry[as.numeric(st_length(BFS_SP$geometry)) < .01] = st_linestring()
    
    # Entfernen leerer Verbindungen
    
    BFS_SP = BFS_SP[!st_is_empty(BFS_SP), , drop = FALSE]
    
    # Aktualisierung der reaktiven Datencontainer
    
    BFS_r(BFS)
    BFSc_r(BFSc)
    BFS_SP_r(BFS_SP)
    
    # Aktualisierung der Kartenansicht
    
    rDT()
    
  })
  
  # 11. DIGITALISIERUNG VON POTENTIALFLÄCHEN (MAP_1)
  
  # Statusvariable für laufende Digitalisierungsprozesse > verhindert Mehrfachtrigger während der Digitalisierung
  
  S_ED = reactiveVal(NULL)
  
  observeEvent(c(input$MAP_1_draw_stop), {
    
    # Prüfen, ob neue Features digitalisiert wurden und ob der Digitalisierungsmodus aktiv ist
    
    if (!is.null(input$MAP_1_draw_new_feature) & isTRUE(S_ED())) { 
      
      # Konvertierung des digitalisierten GeoJSON-Features in ein sf-Objekt
      
      nFEA = input$MAP_1_draw_new_feature
      nFEA = geojsonsf::geojson_sf(jsonify::to_json(nFEA, unbox = T))
      
      # Prüfen der geometrischen Validität
      
      if (nFEA$geometry %>% st_is_valid() == TRUE) { # Geometrie korrekt
        
        # Eingabedialog für Attribute der neuen Potentialfläche 
        
        showModal(
          modalDialog(
            size = c('s'),
            textInput('ID', 'Flächen ID'),
            textInput('ST', 'Status'),
            footer = tagList(
              actionButton('submit', 'Bestätigen'), # input$submit
              actionButton('cancel', 'Abbrechen'), # input$cancel
              
            ),
            easyClose = F
          )
        )
      }
      
      
      else { 
        
        # Fehlermeldung anzeigen
        
        showModal(modalDialog(
          size = c('s'),
          tags$h5(paste0('Polygon ist fehlerhaft!'), align = "center"),
          footer = tagList(),
          easyClose = T
        ))
        
        # Modal schließt nach 2s
        
        Sys.sleep(2)
        
        removeModal()
        openMODAL(FALSE)
        
        # Temporäre leere Geometrie erzeugen > notwendig, um ein Re-Rendering der Karte auszulösen
        
        nFEA_DF = st_sf(
          Status   = NA,
          Standort = NA,
          ID       = max(BFS_r()$ID) + 1,
          geometry = st_sfc(st_polygon(), crs = st_crs(4326))
        )
        
        BFS = bind_rows(BFS_r() %>% as.data.frame(), nFEA_DF) %>%
          st_sf(sf_column_name = 'geometry')
        
        BFS_r(BFS)
        
        # Kartenaktualisierung
        
        rDT()
        
        # Entfernen der temporären Geometrie
        
        BFS_r(BFS[-nrow(BFS), ])
        
      }
      
    }
    
    # Deaktivieren des Digitalisierungsstatus
    
    S_ED(FALSE)
    
  })
  
  # Abbruch der Digitalisierung 
  
  observeEvent(input$cancel, {
    
    # Schließen des Eingabedialogs
    
    removeModal()
    openMODAL(FALSE)
    
    # Temporäre Geometrie erzeugen > notwendig für erneutes Rendering der Karte
    
    nFEA_DF = st_sf(
      Status   = NA,
      Standort = NA,
      ID       = max(BFS_r()$ID) + 1,
      geometry = st_sfc(st_polygon(), crs = st_crs(4326))
    )
    
    BFS = bind_rows(BFS_r() %>% as.data.frame(), nFEA_DF) %>%
      st_sf(sf_column_name = 'geometry')
    
    BFS_r(BFS)
    
    # Kartenaktualisierung
    
    rDT()
    
    # Entfernen der temporären Geometrie
    
    BFS_r(BFS[-nrow(BFS), ])
    
  })
  
  # Speichern neuer Potentialflächen 
  
  observeEvent(input$submit, {
    
    # Validierung der Eingabefelder
    
    req(
      nzchar(input$ID),
      nzchar(input$ST)
    )
    
    # Prüfen, ob die ID bereits existiert
    
    if ((input$ID %in% BFS_r()$Standort)) {
      
      # Modal schließen 
      
      removeModal()
      openMODAL(FALSE)
      
      # Fehlermeldung anzeigen
      
      showModal(
        modalDialog(
          size = c('s'),
          textInput('ID', 'Flächen ID'),
          div(
            tags$h6('IDs müssen eindeutig sein', style = "color: orange;"),
            align = "center"
          ),
          textInput('ST', 'Status'),
          footer = tagList(
            actionButton('submit', 'Bestätigen'),
            actionButton('cancel', 'Abbrechen'),
            
          ),
          easyClose = F
        )
      )
      
    }
    
    # Speichern der neuen Potentialflächen
    
    if (!(input$ID %in% BFS_r()$Standort)) {
      
      # Modal schließen
      
      removeModal()
      openMODAL(FALSE)
      
      # Konvertierung des GeoJSON-Features
      
      nFEA = input$MAP_1_draw_new_feature
      nFEA = geojsonsf::geojson_sf(jsonify::to_json(nFEA, unbox = T))
      
      nFEA_DF = nFEA$geometry %>% as.data.frame()
      
      # Attribute ergänzen
      
      nFEA_DF$Status = input$ST
      nFEA_DF$Standort = input$ID
      
      # ID-Vergabe
      
      if (nrow(BFS_r()) != 0) {
        
        nFEA_DF$ID = max(BFS_r()$ID) + 1
        
      }
      else{
        
        nFEA_DF$ID = 1
        
      }
      
      # Integration der neuen Fläche
      
      BFS = bind_rows(BFS_r() %>% as.data.frame(), nFEA_DF) %>%
        st_sf(sf_column_name = 'geometry')
      
      BFSc = BFS
      BFSc$geometry = st_centroid(BFSc$geometry)
      
      # NEUBERECHNUNG DER VERBINDNGEN 
      
      # Ableitung der Zentroidpunkte der Potentialflächen > dienen als Labels in Leaflet & Knoten in Netzwerkanalyse)
      
      BFSc = BFS
      BFSc$geometry = st_centroid(BFSc$geometry)
      
      # Punktrepräsentation innerhalb der Flächen (robuster als Zentroid)
      
      BFS_C = sf::st_point_on_surface(BFS)
      
      # Linien zwischen allen Punktkombinationen
      
      BFS_SP = st_sf(sf::st_nearest_points(BFS_C, BFS_C))
      st_geometry(BFS_SP) = 'geometry'
      
      # Definition der Start- und Endpunkte
      
      PAIRs = expand.grid(BFS$Standort, BFS$Standort)
      
      BFS_SP$Start = PAIRs[, 2]
      BFS_SP$End = PAIRs[, 1]
      
      # Entfernen doppelter Verbindungen (A–B == B–A)
      
      BFS_SP = BFS_SP[!duplicated(t(apply(as.data.frame(BFS_SP[, 2:3])[, 1:2], 1, sort))), ]
      
      # Entfernen leerer Verbindungen
      
      BFS_SP = BFS_SP[!st_is_empty(BFS_SP), drop = FALSE]
      
      # Entfernen von Selbstverbindungen
      
      BFS_SP$geometry[BFS_SP$Start == BFS_SP$End] = st_linestring()
      
      # Entfernen sehr kurzer Verbindungen 
      
      BFS_SP$geometry[as.numeric(st_length(BFS_SP$geometry)) < .01] = st_linestring()
      
      # Entfernen leerer Verbindungen
      
      BFS_SP = BFS_SP[!st_is_empty(BFS_SP), , drop = FALSE]
      
      # Aktualisierung der reaktiven Datencontainer
      
      BFS_r(BFS)
      BFSc_r(BFSc)
      BFS_SP_r(BFS_SP)
      
      # Aktualisierung der Kartenansicht
      
      rDT()
      
    }
  })
  
  # 12. BUFFER-ANALYSE DER POTENTIALFLÄCHEN MAP_1
  
  
  
  observeEvent(c(input$I1BUF), {
    
    if (input$I1BUF != "")  {
      
      # RUN-Button während Berechnung deaktivieren (UI-Sperre)
      
      shinyjs::enable("RUN_BUF_1")
      
    }
    
    if (input$I1BUF == "")  {
      
      # RUN-Button während Berechnung deaktivieren (UI-Sperre)
      
      shinyjs::disable("RUN_BUF_1")
      
    }
    
  })
  
  observeEvent(c(input$RUN_BUF_1), {
    
    # Trigger für Karten-Rendering
    
    MAP_TRIGGER(MAP_TRIGGER() + 1)
    
    # Prüfen, ob eine Buffer-Distanz definiert wurde
    
    if (input$I1BUF != '') {
      
      # RUN-Button während Berechnung deaktivieren (UI-Sperre)
      
      shinyjs::disable("RUN_BUF_1")
      
      # Extraktion der numerischen Buffer-Distanz aus UI-Eingabe
      
      BuM = as.numeric(gsub("[^0-9\\.]", "", input$I1BUF))
      
      # Transformation der Potentialflächen in metrisches CRS > für korrekte Distanzberechnung
      
      BFS_proj = st_transform(BFS_r(), crs = 25832)
      
      # Berechnung der Buffer-Geometrien
      
      BFS_Bu = st_buffer(BFS_proj, dist = BuM)
      
      rm(BuM)
      gc()
      
      # Ring-Buffer (Buffer ohne ursprüngliche Fläche)
      
      BFS_BuDi = lapply(1:nrow(BFS_proj), function(x){
        BFS_BuDi = st_difference(BFS_Bu[x,],BFS_proj[x,3])
      })
      
      rm(BFS_proj, BFS_Bu)
      gc()
      
      # Zusammenführen der Buffer-Geometrien und Transformation nach WGS84
      
      BFS_BuDi = do.call(rbind.data.frame, BFS_BuDi)
      BFS_BuDi = st_transform(BFS_BuDi, CRS('epsg:4326'))
      
      BFS_BuDi = st_transform(BFS_BuDi, crs = 4326)
      
      # Extraktion der Rasterzellen innerhalb der Buffer-Geometrien
      
      EXT_DF_Bu =  terra::extract(terra::project(rast(LCRA100), '+proj=longlat +datum=WGS84 +units=m +no_defs', method="near"), BFS_BuDi, cellnumbers = TRUE, df = TRUE, na.rm=TRUE, method='simple', exact = FALSE, threads = 4)
      
      # Anzahl Rasterzellen pro Landschaftsklasse und Buffer
      
      CNTs_Bu = EXT_DF_Bu %>%
        group_by(ID, LC_100) %>%
        summarise(count = n(), .groups='drop')
  
      rm(EXT_DF_Bu)
      gc()
      
      # Berechnung prozentualer Landschaftsanteile
      
      PERs_Bu = CNTs_Bu %>%
        complete(ID, LC_100, fill = list(count = 0)) %>%
        group_by(ID) %>%
        mutate(percentage = count / sum(count) * 100) %>%
        ungroup()
      
      rm(CNTs_Bu)
      gc()
      
      # Aggregation und Umformung in Wide-Format
      
      PERs_Bu = PERs_Bu %>%
        group_by(ID, LC_100) %>%
        summarise(
          percentage = round(sum(percentage), 1),
          .groups = "drop"
        ) %>%
        complete(
          ID,
          LC_100 = c(0, 1, 2, 3, 4, NA),
          fill = list(percentage = 0)
        ) %>%
        mutate(percentage = paste0(percentage, " %")) %>%
        pivot_wider(
          names_from   = LC_100,
          values_from  = percentage,
          names_prefix = "PERC_"
        )
      
      # Aktualisierung der Attribute der Potentialflächen
      
      BFS_r(BFS_r() %>%
              select(-any_of(c(
                'Verkehr',
                'Offenland',
                'Gehölz',
                'Wasser',
                'Gebäude'
              ))))
      
      BFS_r(left_join(BFS_r(), PERs_Bu, by = "ID"))
      
      BFS_r(BFS_r() %>%
              rename(
                'Verkehr' = 'PERC_0',
                'Offenland' = 'PERC_1',
                'Gehölz' = 'PERC_2',
                'Wasser' = 'PERC_3',
                'Gebäude' = 'PERC_4'
              )
      )
      
      rm(PERs_Bu)
      gc()
      
      # Aktive Overlay-Layer speichern
      
      LA = input$MAP_1_groups
      
      # Liste bereits geladener Layer zurücksetzen
      
      loadLAYERS_1(character(0))
      
      # aktuelle Kartenposition sichern
      
      PARAs = list(center = input$MAP_1_center, zoom = input$MAP_1_zoom)
      
      # Rerendering der Leaflet-Karte & hinzufügen Buffer-Geometrien der Potentialflächen mit Popups der Attribute
      
      leafletProxy(map = 'MAP_1', session = session) %>%
        invokeMethod('map', 'setView',
                     c(PARAs$center$lat, PARAs$center$lng),
                     PARAs$zoom,
                     list(animate = FALSE)) %>%
        clearGroup('Potentialflächen') %>%
        addMapPane('Buffer', zIndex = 500) %>%
        addPolygons(
          data = BFS_r(),
          layerId = BFS_r()$Standort,
          fillColor = '#00ff00',
          color = 'darkgrey',
          weight = 1.25,
          opacity = 1, 
          fillOpacity = .625,
          dashArray = '1',
          highlightOptions = highlightOptions(
            color = 'darkgrey',
            weight = 5,
            opacity = .125,
            sendToBack = FALSE
          ),
          popup = popupTable(BFS_r(), # Potentialflächen Popups %-LK Werte 
                             feature.id = FALSE,
                             row.numbers = FALSE,
                             zcol = c('Verkehr', 'Offenland', 'Gehölz', 'Wasser', 'Gebäude'),
                             className = 'leafpop-table'
          ),
          popupOptions = popupOptions(maxWidth = 250, minWidth = 25),
          group = 'Potentialflächen',
          options = pathOptions(pane = 'Potentialflächen')
        ) %>%
        clearGroup('Buffer') %>%
        addMapPane('Buffer', zIndex = 490) %>%
        addPolygons( # Buffer-Geometrien
          data = BFS_BuDi,
          fillColor = 'magenta',
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          fillOpacity = .25,
          dashArray = '1',
          group = 'Buffer',
          options = pathOptions(pane = 'Buffer'),
          highlightOptions = highlightOptions(
            color = 'darkgrey',
            weight = 5,
            opacity = .125,
            sendToBack = FALSE
          )
        ) %>%
        addLayersControl(
          baseGroups = c('Leer',
                         'OpenStreetMap',
                         'ESRI-WorldImagery',
                         'Luftbild HVBG',
                         'ALKIS HVBG'),
          overlayGroups = c('Potentialflächen',
                            'Buffer',
                            'Landschaftsklassifikation',
                            'Eh da-Fläche (>100m²)',
                            'Garten ALKIS',
                            'Kompensationsfläche',
                            'Biotope',
                            'Schutzgebiete',
                            # 'Gemeindegrenze',
                            'OrtsGemeindegrenze'),
          options = layersControlOptions(collapsed = TRUE, unchecked = FALSE, autoZIndex = FALSE)
        )
      
      rm(BFS_BuDi)
      gc()
      
      # Wiederherstellung der zuvor aktiven Overlay-Layer
      
      for (L in LA){
        leafletProxy(map = 'MAP_1', session = session) %>%
          showGroup(L) %>%
          htmlwidgets::onRender("function(el, x, data) { this.invalidateSize(); }")
      }
      
      # Auslösen des Performance-Loading MAP_1 (durch Erhöhen des Triggers)
      
      MAP_1_TRIGGER(MAP_1_TRIGGER() + 1)
      
    }
    
    # Reaktivierung des RUN-Buttons
    
    # shinyjs::enable("RUN_BUF_1")
    
  }, ignoreNULL = FALSE)
  
  
  
  # 13. VISUALISIERUNG DER GEODATEN + NETZWERKANALYSE (EUKLIDISCHE DISTANZ) - MAP_2  (siehe 4.)
  
  MAP_TRIGGER_2 = reactiveVal(0)
  
  output$MAP_2 = renderLeaflet({
    
    req(MAP_TRIGGER_2())
    
    MAP_0 %>%
      clearControls() %>%
      { 
        DF = BFSc_r()
        
        if (!is.null(DF) && is.data.frame(DF) && nrow(DF) > 0) {
          
          addLabelOnlyMarkers(
            .,
            data = DF,
            lat = st_coordinates(BFSc_r()$geometry)[, 2],
            lng = st_coordinates(BFSc_r()$geometry)[, 1],
            label = ~ Standort,
            labelOptions = labelOptions(
              noHide = T,
              direction = 'centered',
              offset = c(0, 0),
              textOnly = TRUE,
              style = list(
                'color' = 'grey66',
                'font-size' = '14px',
                'text-shadow' = '-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white'
              )
            ),
            group = 'BFS_L'
          ) %>%
            groupOptions('BFS_L', zoomLevels = 14:22) 
        } else {
          .
        }
      } %>%
      addMapPane('Potentialflächen', zIndex = 500) %>%
      addMapPane('Eh da-Fläche (>100m²)', zIndex = 450) %>%
      addPolygons(
        data = BFS_r(),
        layerId = BFS_r()$Standort,
        fillColor = '#00ff00',
        color = 'darkgrey',
        weight = 1.25,
        opacity = 1,
        fillOpacity = .625,
        dashArray = '1',
        highlightOptions = highlightOptions(
          color = 'darkgrey',
          weight = 5,
          opacity = .125,
          sendToBack = FALSE
        ),
        group = 'Potentialflächen',
        options = pathOptions(pane = 'Potentialflächen')
      ) %>%
      addLayersControl(
        baseGroups = c(
          'Leer',
          'OpenStreetMap',
          'ESRI-WorldImagery',
          'Luftbild HVBG',
          'ALKIS HVBG'
        ),
        overlayGroups = c(
          'Potentialflächen',
          'Landschaftsklassifikation',
          'Eh da-Fläche (>100m²)',
          'Garten ALKIS',
          'Kompensationsfläche',
          'Biotope',
          'Schutzgebiete',
          # 'Gemeindegrenze',
          'OrtsGemeindegrenze'
        ),
        options = layersControlOptions(
          collapsed = TRUE,
          unchecked = FALSE ,
          autoZIndex = FALSE
        )
      ) %>%
      addMapPane('Potentialflächen', zIndex = 500) %>%
      addMapPane('Landschaftsklassifikation', zIndex = 350) %>%
      addMapPane('Eh da-Fläche (>100m²)', zIndex = 450) %>%
      addMapPane('Garten ALKIS', zIndex = 450) %>%
      addMapPane('Kompensationsfläche', zIndex = 450) %>%
      addMapPane('Biotope', zIndex = 450) %>%
      addMapPane('Schutzgebiete', zIndex = 450) %>%
      addMapPane('OrtsGemeindegrenze', zIndex = 450) %>%
      hideGroup('Landschaftsklassifikation') %>%
      hideGroup('Eh da-Fläche (>100m²)') %>%
      hideGroup('Garten ALKIS') %>%
      hideGroup('Kompensationsfläche') %>%
      hideGroup('Biotope') %>%
      hideGroup('Schutzgebiete') %>%
      hideGroup('OrtsGemeindegrenze')
    
  })
  
  # 14. PERFORMANCE-OPTIMIERUNG – DYNAMISCHES LADEN VON KARTENLAYERN MAP_2 (siehe 7.)
  
  loadLAYERS_2 = reactiveVal()
  
  MAP_2_TRIGGER = reactiveVal(0)
  
  observeEvent(input$MAP_2_groups, {
    
    MAP_2_TRIGGER(MAP_2_TRIGGER() + 1)
    
  })
  
  
  observeEvent(c(MAP_2_TRIGGER()), {
    
    if ('Landschaftsklassifikation' %in% input$MAP_2_groups & !('Landschaftsklassifikation' %in% loadLAYERS_2())){
      
      loadLAYERS_2(unique(c(loadLAYERS_2(), 'Landschaftsklassifikation')))
      
      leafletProxy(map = 'MAP_2', session = session) %>%
        addRasterImage(LCRA100,
                       colors = PAL_LCRA100,
                       opacity = .75,
                       group = 'Landschaftsklassifikation',
                       project=FALSE,
                       options = pathOptions(pane = 'Landschaftsklassifikation')) %>%
        addLegend(
          position = 'bottomright',
          opacity = .75,
          pal = PAL_LCRA100,
          values = values(LCRA100),
          labFormat = function(type, cuts, p) {
            label_map = c('0' = 'Verkehr', '1' = 'Offenland', '2' = 'Gehölz', '3' = 'Wasser', '4' = 'Gebäude')
            sapply(cuts, function(x) label_map[as.character(x)])
          },
          group = 'Landschaftsklassifikation'
        )
      
    }
    
    if ('Eh da-Fläche (>100m²)' %in% input$MAP_2_groups & !('Eh da-Fläche (>100m²)' %in% loadLAYERS_2())){
      
      loadLAYERS_2(unique(c(loadLAYERS_2(), 'Eh da-Fläche (>100m²)')))
      
      leafletProxy(map = 'MAP_2', session = session) %>%
        addPolygons(
          data = EH100_S,
          fillColor = '#7FFFD4',
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Eh da-Fläche (>100m²)',
          popup = popupTable(
            EH100_S,
            zcol = c(1:4, 6),
            feature.id = F,
            row.numbers = F,
            className = 'popupTAB'
          ),
          popupOptions = popupOptions(maxWidth = 1000, minWidth = 10),
          highlightOptions = highlightOptions(color = 'darkgrey', weight = 3),
          options = pathOptions(pane = 'Landschaftsklassifikation')
        ) %>%
        addLegend(
          'bottomright',
          colors = '#7FFFD4',
          labels = 'Eh da-Fläche (>100m²)',
          opacity = .75,
          group = 'Eh da-Fläche (>100m²)',
          layerId = "Eh da_legend"
        )
      
    }
    
    if ('Garten ALKIS' %in% input$MAP_2_groups & !('Garten ALKIS' %in% loadLAYERS_2())){
      
      loadLAYERS_2(unique(c(loadLAYERS_2(), 'Garten ALKIS')))
      
      leafletProxy(map = 'MAP_2', session = session) %>%
        addPolygons(
          data = GA100_S,
          layerId = GA100_S$OBJECTID,
          fillColor = 'orange',
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Garten ALKIS',
          options = pathOptions(pane = 'Garten ALKIS')
        ) %>%
        addLegend(
          'bottomright',
          colors = 'orange',
          labels = 'Garten ALKIS',
          opacity = .75,
          group = 'Garten ALKIS'
        )
      
    }
    
    if ('Kompensationsfläche' %in% input$MAP_2_groups & !('Kompensationsfläche' %in% loadLAYERS_2())){
      
      loadLAYERS_2(unique(c(loadLAYERS_2(), 'Kompensationsfläche')))
      
      leafletProxy(map = 'MAP_2', session = session) %>%
        addPolygons(
          data = KOMPE,
          layerId = KOMPE$OBJECTID,
          fillColor = 'orchid',
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Kompensationsfläche',
          options = pathOptions(pane = 'Kompensationsfläche')
        ) %>%
        addLegend(
          'bottomright',
          colors = 'orchid',
          labels = 'Kompensationsfläche',
          opacity = .75,
          group = 'Kompensationsfläche'
        )
      
    }
    
    if ('Biotope' %in% input$MAP_2_groups & !('Biotope' %in% loadLAYERS_2())){
      
      loadLAYERS_2(unique(c(loadLAYERS_2(), 'Biotope')))
      
      leafletProxy(map = 'MAP_2', session = session) %>%
        addPolygons(
          data = BIOTO,
          layerId = BIOTO$OBJECTID,
          fillColor = ~ P_BIO(Typ),
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Biotope',
          options = pathOptions(pane = 'Biotope')
        ) %>%
        addLegend(
          'bottomright',
          colors = palT_BIO,
          labels = LABs,
          values =  ~ BIOTO$Typ,
          opacity = .75,
          group = 'Biotope'
        )
      
    }
    
    if ('Schutzgebiete' %in% input$MAP_2_groups & !('Schutzgebiete' %in% loadLAYERS_2())){
      
      loadLAYERS_2(unique(c(loadLAYERS_2(), 'Schutzgebiete')))
      
      leafletProxy(map = 'MAP_2', session = session) %>%
        addPolygons(
          data = SCHUT,
          layerId = SCHUT$OBJECTID,
          fillColor = ~ P_SCH(Typ),
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Schutzgebiete',
          options = pathOptions(pane = 'Schutzgebiete')
        ) %>%
        addLegend(
          'bottomright',
          colors = palT_SCH,
          labels = unique(SCHUT$Typ),
          opacity = .75,
          group = 'Schutzgebiete'
        )
      
    }
    
  })
  
  # 15. SYNCHRONISIERUNG (KARTENKLICK & PICKERINPUT) FLÄCHENSELEKTION MAP_2 
  
  ID_2 = NULL
  
  observeEvent(c(input$MAP_2_shape_click), {
    
    # ID des geklickten Features
    
    ID_2 = input$MAP_2_shape_click$id
    
    # Aktuell selektierte IDs im PickerInput
    
    S1 = input$I1
    
    # FALL 1 – Picker-Auswahl vorhanden & Feature wurde geklickt
    
    if (!is.null(S1) & !is.null(ID_2)) {
      
      # Feature bereits selektiert → Entfernen aus Auswahl
      
      if (ID_2 %in% S1) {
        
        S1 = S1[S1 != ID_2]
        
      }
      
      # Feature noch nicht selektiert >>> Hinzufügen
      
      else{
        
        S1 = c(S1, ID_2)
        
      }
      
      # Aktualisierung PickerInput-Auswahl
      
      updatePickerInput(
        session = session,
        inputId = 'I1',
        choices = unique(sort(BFS_r()$Standort)),
        selected = unique(BFS_r()[BFS_r()$Standort %in% S1, ]$Standort)
      )
      
    }
    
    # FALL 2 – Picker-Auswahl vorhanden & kein Feature geklickt
    
    if (!is.null(S1) & is.null(ID_2)) {
      
      # Aktuell selektierte IDs im PickerInput
      
      S1 = input$I1
      
      # Aktualisierung PickerInput-Auswahl
      
      updatePickerInput(
        session = session,
        inputId = 'I1',
        choices = unique(sort(BFS_r()$Standort)),
        selected = unique(BFS_r()[BFS_r()$Standort %in% S1, ]$Standort)
      )
      
    }
    
    # FALL 3 – Keine Picker-Auswahl & Feature wurde geklickt
    
    if (is.null(S1) & !is.null(ID_2)) {
      
      # Picker mit Feature aktualisieren
      
      S1 = c(ID_2)
      
      # Aktualisierung PickerInput-Auswahl
      
      updatePickerInput(
        session = session,
        inputId = 'I1',
        choices = unique(sort(BFS_r()$Standort)),
        selected = unique(BFS_r()[BFS_r()$Standort %in% S1, ]$Standort)
      )
      
    }
    
    # FALL 4 – Keine Picker-Auswahl vorhanden
    
    if (is.null(S1)) {
      
      updatePickerInput(
        session = session,
        inputId = 'I1',
        choices = unique(sort(BFS_r()$Standort)),
        selected = NULL
      )
      
    }
    
  }, ignoreNULL = FALSE)
  
  # Reaktion Änderungen der Featureauswahl I1 > Visualisierung selektierter Potentialflächen in MAP_2
  
  observeEvent(c(input$I1), {
    
    # Subset der selektierten Potentialflächen
    
    BFS_sel = BFS_r()[BFS_r()$Standort %in% input$I1, ]
    
    # Aktualisierung Kartenvisualisierung
    
    leafletProxy(map = 'MAP_2', session = session) %>%
      clearGroup('BFS_L') %>%
      {
        DF = BFSc_r()
        
        if (!is.null(DF) && is.data.frame(DF) && nrow(DF) > 0) {
          
          addLabelOnlyMarkers(
            .,
            data = DF,
            lat = st_coordinates(BFSc_r()$geometry)[, 2],
            lng = st_coordinates(BFSc_r()$geometry)[, 1],
            label = ~ Standort,
            labelOptions = labelOptions(
              noHide = T,
              direction = 'centered',
              offset = c(0, 0),
              textOnly = TRUE,
              style = list(
                'color' = 'grey66',
                'font-size' = '14px',
                'text-shadow' = '-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white'
              )
            ),
            group = 'BFS_L'
          ) %>%
            groupOptions('BFS_L', zoomLevels = 14:22) 
        } else {
          .
        }
      } %>%
      
      # Entfernen vorhandener Analyse-Layer
      
      clearGroup('NET_AREA') %>%
      clearGroup('BFS_sel') %>%
      clearGroup('net_e') %>%
      clearGroup('net_n') %>%
      
      # Visualisierung selektierter Potentialflächen
      
      addPolygons( 
        data = BFS_sel,
        fillColor = '#FFFF00',
        color = '#FFFF00',
        weight = 10,
        opacity = .5, 
        fillOpacity = 0,
        dashArray = '1',
        group = 'BFS_sel'
      ) %>%
      
      # Darstellung aller Potentialflächen
      
      addPolygons(
        data = BFS_r(),
        layerId = BFS_r()$Standort,
        fillColor = '#00ff00',
        color = 'darkgrey',
        weight = 1.25,
        opacity = 1,
        fillOpacity = .625,
        dashArray = '1',
        highlightOptions = highlightOptions(
          color = 'darkgrey',
          weight = 5,
          opacity = .125,
          sendToBack = FALSE
        ),
        group = 'Potentialflächen'
      )
    
  }, ignoreNULL = FALSE)
  
  # 16. NETZWERKANALYSE EUKLIDISCHE-DISTANZ MAP_2
  
  # Aktivierung des Analyse-Button RUN_NET_1
  
  observe({
    
    # Abbruch, wenn Distanzwert nicht gesetzt
    
    if(is.na(input$I2)){
      
      return(NULL)
      
    }
    
    # Prüfen der Aktivierungsbedingungen
    
    if (is.na(input$I2) || input$I2 < 100 || input$I2 > 10000 || (is.null(input$I1) || length(input$I1) == 1)) {
      
      # Analyse-Button deaktivieren
      
      shinyjs::disable("RUN_NET_1")
      
    }
    
    else{
      
      
      # Analyse-Button aktivieren
      
      shinyjs::enable("RUN_NET_1")
      
    }
    
  })
  
  # Ergebnisobjekt Netzwerkanalyse > Speicherung dynamischer Netzwerkkennzahlen und Analyseergebnisse
  
  TXT = reactiveValues(dynamic_table = data.frame(NA), mD = NA, Ef = NA)
  
  # Zurücksetzen der dynamischen Netzwerkkennzahlen bei Änderungen von I1
  
  observeEvent(c(input$I1), {
    
    TXT$text_2_1 = ''
    TXT$text_2_2 = ''
    TXT$text_2_3 = ''
    
  })
  
  # Berechnung von Netzwerkkennzahlen und Visualisierung für selektierten Potentialflächen MAP_2
  
  observeEvent(c(input$RUN_NET_1), {
    
    # Trigger Kartenaktualisierung
    
    MAP_TRIGGER(MAP_TRIGGER() + 1)
    
    # Aktive Overlay-Layer der Karte MAP_2
    
    aG_2 = req(input$MAP_2_groups)
    
    # FALL 1 – Layer „Potentialflächen“ ist NICHT aktiv
    
    if (!("Potentialflächen" %in% aG_2)) {  
      
      # Karten-Reset: Entfernen analyseabhängiger Layer
      
      leafletProxy(map = 'MAP_2', session = session) %>%
        clearGroup('BFS_L') %>%
        clearGroup('BFS_sel') %>%
        clearGroup('NET_AREA') %>%
        clearGroup('net_e') %>%
        clearGroup('net_n')
      
      # Zurücksetzen der Netzwerkkennzahlen
      
      TXT$text_2_1 = ''
      TXT$text_2_2 = ''
      TXT$text_2_3 = ''
      
    }
    
    # FALL 2 – Layer „Potentialflächen“ ist aktiv
    
    else{
      
      # Analyse-Button während Berechnung deaktivieren
      
      shinyjs::disable("RUN_NET_1")
      
      # Subset selektierter Potentialflächen
      
      BFS_sel = BFS_r()[BFS_r()$Standort %in% input$I1, ]
      
      # Ableitung möglicher Start-Ziel-Paare
      
      PA = expand.grid(input$I1, input$I1)
      PA = PA[PA[, 1] != PA[, 2], ]
      
      # Filterung der Netzwerk-Kanten nach maximaler Distanz I2
      
      BFS_SP_sel = BFS_SP_r()[as.numeric(st_length(BFS_SP_r()$geometry)) < input$I2, ]
      BFS_SP_sel = BFS_SP_sel[paste0(BFS_SP_sel$Start, BFS_SP_sel$End) %in% paste0(PA[, 1], PA[, 2]), ]
      
      # Konstruktion eines undirektionalen Netzwerks
      
      net = as_sfnetwork(BFS_SP_sel[!st_is_empty(BFS_SP_sel), , drop = FALSE], directed = FALSE)
      
      # Prüfen, ob Netzwerk überhaupt Kanten enthält
      
      if (net %>% activate("edges") %>% as_tibble() %>% nrow() == 0) { # Netzwerk ohne Kanten 
        
        # Zurücksetzen Netzwerkkennzahlen
        
        TXT$text_2_1 = ''
        TXT$text_2_2 = ''
        TXT$text_2_3 = ''
        
        # Abbruch
        
        return(NULL)
        
      }
      
      # 16.1 BERECHNUNG ZENTRALER NETZWERKKENNZAHLEN
      
      # Bewertung (quantitativ & visuell) ökologischer Konnektivität über Graphmetriken (Zentralitäten | Communities)
      
      
      #  Konstruktion eines undirektionalen Netzwerks; notwendig für viele Netzwerkmetriken (z.B. Betweenness, Community Detection)
      
      net = net %>%
        morph(to_undirected) %>% 
        
        # Vereinfachung der Netzwerkstruktur: entfernt Mehrfachkanten und Selbstschleifen zur Vermeidung künstlich erhöhter Zentralitäten
        
        morph(to_simple) %>% 
        
        # Aktivieren der Kantenebene des Netzwerks zur Berechnung kantenbasierter Netzwerkmetriken
        
        sfnetworks::activate(edges) %>% 
        
        # Edge Betweenness Centrality: identifiziert kritische Verbindungen bzw. Engpässe im Netzwerk (Darstellung über Linienstärke)
        
        mutate(beedgecen = centrality_edge_betweenness()) %>% 
        
        # Aktivieren der Knotenebene des Netzwerks zur Berechnung knotenbasierter Netzwerkmetriken
        
        sfnetworks::activate(nodes) %>% 
        
        mutate(
          
          # Knoten-Betweenness: identifiziert zentrale Standorte ("Stepping Stones") für Netzwerkverbindungen
          
          becen  = centrality_betweenness(), 
          
          # Community Detection (Fast Greedy): identifiziert funktionale Gruppen bzw. Teilnetzwerke über Maximierung der Modularität
          
          group  = group_fast_greedy(), 
          
          # Mittlere Pfadlänge des Netzwerks: durchschnittliche Distanz zwischen allen Knoten als Indikator für Erreichbarkeit/Fragmentierung
          
          meand  = graph_mean_dist(),     
          
          # Netzwerkeffizienz: Maß der globalen Konnektivität; hohe Werte zeigen kurze Wege und ein gut verbundenes Netzwerk
          
          effic  = graph_efficiency()   
          
        ) %>%
        
        # Rückkehr zur ursprünglichen sfnetwork-Struktur nach Abschluss der morph()-Transformationen
        
        unmorph()  
      
      # Identifikation der größten Netzwerk-Komponente | Hauptkomponente
      
      NPs = as.vector(net %>% pull(geometry))[components(net)$membership == which.max(table(components(net)$membership))]
      
      # FALL 2A – zusammenhängende Netzwerk-Komponente vorhanden
      
      if (length(NPs) > 1) {
        
        # Berechnung der Netzwerkfläche (Buffer um Hauptkomponente = halbe Ausbreitungsdistanz)
        
        NET_AREA = st_union(st_buffer(st_transform(NPs, CRS('epsg:4326')), input$I2 / 2))
        NET_AREA = st_make_valid(NET_AREA)
        
        # Ausgabe Netzwerkkennzahlen
        
        TXT$text_2_1 = components(net)$no
        TXT$text_2_2 = round(max(components(net)$csize) / length(input$I1) * 100,1)
        TXT$text_2_3 = round(as.numeric(st_area(st_make_valid(NET_AREA))) / 1000^2, 1) #km²
        
        # Aktive Overlay-Layer MAP_2 speichern
        
        LA = input$MAP_2_groups
        
        # Reaktive Variable aktive Overlay-Layer leeren
        
        loadLAYERS_2(character(0))
        
        PARAs = list(center = input$MAP_2_center, zoom = input$MAP_2_zoom)
        
        leafletProxy(map = 'MAP_2', session = session) %>%
          clearControls() %>%
          invokeMethod(
            'map',
            'setView',
            c(PARAs$center$lat, PARAs$center$lng),
            PARAs$zoom,
            list(animate = FALSE)
          ) %>%
          addMapPane('net_e', zIndex = 475) %>%              #
          addMapPane('net_n', zIndex = 475) %>% 
          clearGroup('NET_AREA') %>%
          clearGroup('BFS_sel') %>%
          clearGroup('net_e') %>%
          clearGroup('net_n') %>%
          clearGroup('BFS_L') %>%
          {
            DF = BFSc_r()
            
            if (!is.null(DF) && is.data.frame(DF) && nrow(DF) > 0) {
              
              addLabelOnlyMarkers(
                .,
                data = DF,
                lat = st_coordinates(BFSc_r()$geometry)[, 2],
                lng = st_coordinates(BFSc_r()$geometry)[, 1],
                label = ~ Standort,
                labelOptions = labelOptions(
                  noHide = T,
                  direction = 'centered',
                  offset = c(0, 0),
                  textOnly = TRUE,
                  style = list(
                    'color' = 'grey66',
                    'font-size' = '14px',
                    'text-shadow' = '-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white'
                  )
                ),
                group = 'BFS_L'
              ) %>%
                groupOptions('BFS_L', zoomLevels = 14:22) 
            } else {
              .
            }
          } %>%
          groupOptions('BFS_L', zoomLevels = 14:22) %>%
          addPolygons( # Netzwerkfläche
            data = NET_AREA,
            fillColor = 'orangered',
            color = 'white',
            weight = 1.25,
            opacity = 1,
            smoothFactor = 5,
            stroke = T,
            dashArray = '1',
            group = 'NET_AREA'
          ) %>%
          addPolygons(
            data = BFS_sel,
            fillColor = '#FFFF00',
            color = '#FFFF00',
            weight = 10,
            opacity = .5, 
            fillOpacity = 0,
            dashArray = '1',
            group = 'BFS_sel'
          ) %>%
          addPolygons(
            data = BFS_r(),
            layerId = BFS_r()$Standort,
            fillColor = '#00ff00',
            color = 'darkgrey',
            weight = 1.25,
            opacity = 1, 
            fillOpacity = .625,
            dashArray = '1',
            highlightOptions = highlightOptions(
              color = 'darkgrey',
              weight = 5,
              opacity = .125,
              sendToBack = FALSE
            ),
            group = 'Potentialflächen',
            options = pathOptions(pane = "Potentialflächen")
          ) %>%
          addPolylines( # Darstellung Netzwerk-Kanten >> Gewichtung nach Zentralität 
            data = st_as_sf(net, 'edges'),
            weight = ~ (beedgecen / max(beedgecen) * 9) + 1,
            dashArray = "1",
            color = 'black',
            opacity = 1,
            group = 'net_e',
            label = ~ paste(round(st_length(geometry), 0), '[m]'),
            labelOptions = labelOptions(noHide = F, direction = "top"),
            highlightOptions = highlightOptions(color = "red", weight = 10, opacity = 1, bringToFront = TRUE),
            options = pathOptions(pane = "net_e")
          ) %>%
          addCircleMarkers( # Darstellung Netzwerk-Knoten >> Gewichtung nach Zentralität | Farbgebung nach Funktionalle Gruppen 
            data = st_as_sf(net, 'nodes'),
            group = 'net_n',
            fillColor =  ~ pal(group),
            fillOpacity = .75,
            color =  'white',
            stroke = T,
            radius =  ~ (becen / max(becen) * 20) + 2.5,
            options = pathOptions(pane = "net_n")
          )
        
        # Overlay-Layer MAP_2 hinzufügen >> showGroup(L) 
        
        for (L in LA){
          leafletProxy(map = 'MAP_2', session = session) %>%
            showGroup(L) %>%
            htmlwidgets::onRender("function(el, x, data) { this.invalidateSize(); }")
        }
        
        # Löst Performance-Loading MAP_2 aus - aktiviert 'showGroup(L)'
        
        MAP_2_TRIGGER(MAP_2_TRIGGER() + 1)
        
      }
      
      # 2: Keine (zusammenhängende) Netwerk-Komponente existiert
      
      else{
        
        # Zurücksetzen (dynamische) Netzwerkindizes  
        
        TXT$text_2_1 = ''
        TXT$text_2_2 = ''
        TXT$text_2_3 = ''
        
        # Aktive Overlay-Layer MAP_2 speichern
        
        LA = input$MAP_2_groups
        
        # Reaktive Variable aktive Overlay-Layer leeren
        
        loadLAYERS_2(character(0))    
        
        PARAs = list(center = input$MAP_2_center, zoom = input$MAP_2_zoom)
        
        leafletProxy(map = 'MAP_2', session = session) %>%
          clearControls() %>%
          invokeMethod(
            'map',
            'setView',
            c(PARAs$center$lat, PARAs$center$lng),
            PARAs$zoom,
            list(animate = FALSE)
          ) %>%
          clearGroup('BFS_L') %>%
          groupOptions('BFS_L', zoomLevels = 14:22) %>%
          clearGroup('NET_AREA') %>%
          clearGroup('BFS_sel') %>%
          clearGroup('net_e') %>%
          clearGroup('net_n') %>%
          addPolygons(
            data = BFS_sel,
            fillColor = '#FFFF00',
            color = '#FFFF00',
            weight = 10,
            opacity = .5, 
            fillOpacity = 0,
            dashArray = '1',
            group = 'BFS_sel',
          ) %>%
          addPolygons(
            data = BFS_r(),
            layerId = BFS_r()$Standort,
            fillColor = '#00ff00',
            color = 'darkgrey',
            weight = 1.25,
            opacity = 1, 
            fillOpacity = .625,
            dashArray = '1',
            highlightOptions = highlightOptions(
              color = 'darkgrey',
              weight = 5,
              opacity = .125,
              sendToBack = FALSE
            ),
            group = 'Potentialflächen',
            options = pathOptions(pane = 'Potentialflächen')
          ) 
        
        # Overlay-Layer MAP_2 hinzufügen >> showGroup(L) 
        
        for (L in LA){
          leafletProxy(map = 'MAP_2', session = session) %>%
            showGroup(L) %>%
            htmlwidgets::onRender("function(el, x, data) { this.invalidateSize(); }")
        }
        
        # Löst Performance-Loading MAP_2 aus - aktiviert 'showGroup(L)'
        
        MAP_2_TRIGGER(MAP_2_TRIGGER() + 1)
        
      }
      
    }
    
    # RUN-Button 'Netzwerkanalyse' aktivieren (MAP_2)
    
    shinyjs::enable("RUN_NET_1")
    
  },
  ignoreNULL = FALSE)
  
  # Textausgabe (UI) >> Ergebnisse der Netzwerkanalyse (MAP_2)
  
  output$text_2_1 = renderText(TXT$text_2_1)
  output$text_2_2 = renderText(TXT$text_2_2)
  output$text_2_3 = renderText(TXT$text_2_3)
  
  #####
  
  MAP_TRIGGER_3 = reactiveVal(0)
  
  ## MAP_3: Visualisierung Geodaten + Netzwerkanalyse Kosten-Distanz (dynamisches Kostenraster) + interaktiver Digitalisierung / Bearbeitung / Löschen Polygone mit definierbaren Kostenwerten 
  
  output$MAP_3 = renderLeaflet({
    
    # Prüfen, ob externer Rendering-Trigger aktiv is
    
    req(MAP_TRIGGER_3())
    
    # Laden Basis-Karte (MAP_0) + Controls entfernen + Beschriftungen (LabelOnlyMarker) + Definition  Kartenebenen (MapPanes) mit Z-Index + Digitalisierungs-, Editier- & Löschwerkzeug 'Kostenwert-Polygonen' (DrawToolbar) + Layer & Basiskarten (LayersControl)
    
    MAP_0 %>%
      clearControls() %>%
      {
        DF = BFSc_r()
        
        if (!is.null(DF) && is.data.frame(DF) && nrow(DF) > 0) {
          
          addLabelOnlyMarkers(
            .,
            data = DF,
            lat = st_coordinates(BFSc_r()$geometry)[, 2],
            lng = st_coordinates(BFSc_r()$geometry)[, 1],
            label = ~ Standort,
            labelOptions = labelOptions(
              noHide = T,
              direction = 'centered',
              offset = c(0, 0),
              textOnly = TRUE,
              style = list(
                'color' = 'grey66',
                'font-size' = '14px',
                'text-shadow' = '-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white'
              )
            ),
            group = 'BFS_L'
          ) %>%
            groupOptions('BFS_L', zoomLevels = 14:22) 
        } else {
          .
        }
      } %>%
      addDrawToolbar(
        targetGroup = "newFEA_DF",
        toolbar = toolbarOptions(
          actions = list(
            text = "Abbrechen"
          ),
          finish = list(
            text = "Speichern"
          ),
          undo = list(
            text = "Rückgängig"
          ),
          buttons = list(
            polygon   = "Polygon zeichnen",
            rectangle = "Viereck zeichnen"
          )
        ),
        handlers = handlersOptions(
          polygon = list(
            tooltipStart = "Klicken, um mit dem Zeichnen zu beginnen",
            tooltipCont  = "Weiter klicken, um das Polygon fortzusetzen",
            tooltipEnd   = "Klicken auf den ersten Punkt zum Schließen"
          ),
          rectangle = list(
            tooltipStart = "Klicken und ziehen, um ein Rechteck zu zeichnen"
          ),
          simpleshape = list(
            tooltipEnd = "Maustaste loslassen, um das Zeichnen zu beenden"
          )
        ),
        polylineOptions = FALSE,
        polygonOptions = drawPolygonOptions(
          shapeOptions = drawShapeOptions(
            fillColor   = "grey",
            color       = "red",
            weight      = 2.5,
            fillOpacity = 0.125,
            dashArray   = "1"
          )
        ),
        circleOptions = FALSE,
        rectangleOptions = drawRectangleOptions(
          shapeOptions = drawShapeOptions(
            fillColor   = "grey",
            color       = "red",
            weight      = 2.5,
            fillOpacity = 0.125,
            dashArray   = "1"
          )
        ),
        markerOptions = FALSE,
        circleMarkerOptions = FALSE,
        editOptions = editToolbarOptions(
          edit   = TRUE,
          remove = TRUE
        ),
        edittoolbar = edittoolbarOptions(
          actions = list(
            save = list(
              title = "Änderungen speichern",
              text  = "Speichern"
            ),
            cancel = list(
              title = "Bearbeitung abbrechen",
              text  = "Abbrechen"
            ),
            clearAll = list(
              title = "Alle Objekte löschen",
              text  = "Alles löschen"
            )
          ),
          buttons = list(
            edit           = "Objekte bearbeiten",
            editDisabled   = "Keine Objekte zum Bearbeiten",
            remove         = "Objekte löschen",
            removeDisabled = "Keine Objekte zum Löschen"
          )
        ),
        edithandlers = edithandlersOptions(
          edit = list(
            tooltipText    = "Objekt editieren: Fläche oder einzelne Punkte verschieben",
            tooltipSubtext = ""
          ),
          remove = list(
            tooltipText = "Klicken, um ein Objekt zu löschen"
          )
        )
      )  %>%
      groupOptions('BFS_L', zoomLevels = 14:22) %>%
      addMapPane('Potentialflächen', zIndex = 500) %>%
      addMapPane('Eh da-Fläche (>100m²)', zIndex = 450) %>%
      addPolygons(
        data = BFS_r(),
        layerId = BFS_r()$Standort,
        fillColor = '#00ff00',
        color = 'darkgrey',
        weight = 1.25,
        opacity = 1,
        fillOpacity = .625,
        dashArray = '1',
        highlightOptions = highlightOptions(
          color = 'darkgrey',
          weight = 5,
          opacity = .125,
          sendToBack = FALSE
        ),
        group = 'Potentialflächen',
        options = pathOptions(pane = "Potentialflächen")
      ) %>%
      addMapPane("Kosten-Raster", zIndex = 350) %>%
      clearGroup("Kosten-Raster") %>% 
      addRasterImage(CoRa(),
                     colors = PAL_CoRa(),
                     opacity = .75,
                     group = 'Kosten-Raster',
                     options = leafletOptions(pane = "Kosten-Raster")) %>%
      addLegend(
        position = 'bottomright',
        opacity = .75,
        pal = PAL_CoRa(),
        values = c(0, maxValue(CoRa())),
        group = 'Kosten-Raster',
        bins = pretty(c(0, ceiling(maxValue(CoRa()) / 10) * 10), n = 4),
        labFormat = labelFormat(digits = 0), 
        layerId="legend_kosten"
      ) %>%
      addLayersControl(
        baseGroups = c(
          'Leer',
          'OpenStreetMap',
          'ESRI-WorldImagery',
          'Luftbild HVBG',
          'ALKIS HVBG'
        ),
        overlayGroups = c(
          'Potentialflächen',
          'Kosten-Raster',
          'Eh da-Fläche (>100m²)',
          'Garten ALKIS',
          'Kompensationsfläche',
          'Biotope',
          'Schutzgebiete',
          # 'Gemeindegrenze',
          'OrtsGemeindegrenze'
        ),
        options = layersControlOptions(
          collapsed = TRUE,
          unchecked = FALSE ,
          autoZIndex = FALSE
        )
      ) %>%
      addMapPane('Potentialflächen', zIndex = 500) %>%
      addMapPane('Kosten-Raster', zIndex = 350) %>%
      addMapPane('Eh da-Fläche (>100m²)', zIndex = 450) %>%
      addMapPane('Garten ALKIS', zIndex = 450) %>%
      addMapPane('Kompensationsfläche', zIndex = 450) %>%
      addMapPane('Biotope', zIndex = 450) %>%
      addMapPane('Schutzgebiete', zIndex = 450) %>%
      addMapPane('OrtsGemeindegrenze', zIndex = 450) %>%
      hideGroup('Eh da-Fläche (>100m²)') %>%
      hideGroup('Garten ALKIS') %>%
      hideGroup('Kompensationsfläche') %>%
      hideGroup('Biotope') %>%
      hideGroup('Schutzgebiete') %>%
      hideGroup('OrtsGemeindegrenze')
    
    # https://coderapp.vercel.app/answer/76640042
    
  })
  
  ## Performance-Loading MAP_3: Dynamisches Laden zur Performanceoptimierung von Overlay-Layern (erst beim Aktivieren in Karte) 
  
  loadLAYERS_3 = reactiveVal()
  
  MAP_3_TRIGGER = reactiveVal(0)
  
  observeEvent(input$MAP_3_groups, {
    
    MAP_3_TRIGGER(MAP_3_TRIGGER() + 1)
    
  })
  
  # Reaktiver Listener (Trigger) für geladene Layer in MAP_3: Reagiert auf Änderungen aktivierten Overlay-Gruppen (i.e., Layer)
  
  observeEvent(c(MAP_3_TRIGGER()), {
    
    if ('Eh da-Fläche (>100m²)' %in% input$MAP_3_groups & !('Eh da-Fläche (>100m²)' %in% loadLAYERS_3())){
      
      loadLAYERS_3(unique(c(loadLAYERS_3(), 'Eh da-Fläche (>100m²)')))
      
      leafletProxy(map = 'MAP_3', session = session) %>%
        addPolygons(
          data = EH100_S,
          fillColor = '#7FFFD4',
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Eh da-Fläche (>100m²)',
          popup = popupTable(
            EH100_S,
            zcol = c(1:4, 6),
            feature.id = F,
            row.numbers = F,
            className = 'popupTAB'
          ),
          popupOptions = popupOptions(maxWidth = 1000, minWidth = 10),
          highlightOptions = highlightOptions(color = 'darkgrey', weight = 3)
        ) %>%
        addLegend(
          'bottomright',
          colors = '#7FFFD4',
          labels = 'Eh da-Fläche (>100m²)',
          opacity = .75,
          group = 'Eh da-Fläche (>100m²)',
          layerId = "Eh da_legend"
        )
      
    }
    
    if ('Garten ALKIS' %in% input$MAP_3_groups & !('Garten ALKIS' %in% loadLAYERS_3())){
      
      loadLAYERS_3(unique(c(loadLAYERS_3(), 'Garten ALKIS')))
      
      leafletProxy(map = 'MAP_3', session = session) %>%
        addPolygons(
          data = GA100_S,
          layerId = GA100_S$OBJECTID,
          fillColor = 'orange',
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Garten ALKIS'
        ) %>%
        addLegend(
          'bottomright',
          colors = 'orange',
          labels = 'Garten ALKIS',
          opacity = .75,
          group = 'Garten ALKIS'
        )
      
    }
    
    if ('Kompensationsfläche' %in% input$MAP_3_groups & !('Kompensationsfläche' %in% loadLAYERS_3())){
      
      loadLAYERS_3(unique(c(loadLAYERS_3(), 'Kompensationsfläche')))
      
      leafletProxy(map = 'MAP_3', session = session) %>%
        addPolygons(
          data = KOMPE,
          layerId = KOMPE$OBJECTID,
          fillColor = 'orchid',
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Kompensationsfläche'
        ) %>%
        addLegend(
          'bottomright',
          colors = 'orchid',
          labels = 'Kompensationsfläche',
          opacity = .75,
          group = 'Kompensationsfläche'
        )
      
    }
    
    if ('Biotope' %in% input$MAP_3_groups & !('Biotope' %in% loadLAYERS_3())){
      
      loadLAYERS_3(unique(c(loadLAYERS_3(), 'Biotope')))
      
      leafletProxy(map = 'MAP_3', session = session) %>%
        addPolygons(
          data = BIOTO,
          layerId = BIOTO$OBJECTID,
          fillColor = ~ P_BIO(Typ),
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Biotope'
        ) %>%
        addLegend(
          'bottomright',
          colors = palT_BIO,
          labels = LABs,
          values =  ~ BIOTO$Typ,
          opacity = .75,
          group = 'Biotope'
        )
      
    }
    
    if ('Schutzgebiete' %in% input$MAP_3_groups & !('Schutzgebiete' %in% loadLAYERS_3())){
      
      loadLAYERS_3(unique(c(loadLAYERS_3(), 'Schutzgebiete')))
      
      leafletProxy(map = 'MAP_3', session = session) %>%
        addPolygons(
          data = SCHUT,
          layerId = SCHUT$OBJECTID,
          fillColor = ~ P_SCH(Typ),
          color = 'darkgrey',
          smoothFactor = 0.25,
          weight = 1.25,
          opacity = 1,
          fillOpacity = .5,
          dashArray = '1',
          group = 'Schutzgebiete'
        ) %>%
        addLegend(
          'bottomright',
          colors = palT_SCH,
          labels = unique(SCHUT$Typ),
          opacity = .75,
          group = 'Schutzgebiete'
        )
      
    }
    
  })
  
  rDT_3 = function() {
    
    # Aktive Overlay-Layer MAP_3 speichern
    
    LA = input$MAP_3_groups
    
    # Reaktive Variable aktive Overlay-Layer leeren
    
    loadLAYERS_3(character(0))
    
    PARAs = list(center = input$MAP_3_center, zoom = input$MAP_3_zoom)
    
    BFS_sel = BFS_r()[BFS_r()$Standort %in% input$I1_3, ]
    
    leafletProxy(map = 'MAP_3', session = session) %>%
      clearControls() %>%
      invokeMethod('map', 'setView',
                   c(PARAs$center$lat, PARAs$center$lng),
                   PARAs$zoom,
                   list(animate = FALSE)) %>%
      {
        DF = BFSc_r()
        
        if (!is.null(DF) && is.data.frame(DF) && nrow(DF) > 0) {
          
          addLabelOnlyMarkers(
            .,
            data = DF,
            lat = st_coordinates(BFSc_r()$geometry)[, 2],
            lng = st_coordinates(BFSc_r()$geometry)[, 1],
            label = ~ Standort,
            labelOptions = labelOptions(
              noHide = T,
              direction = 'centered',
              offset = c(0, 0),
              textOnly = TRUE,
              style = list(
                'color' = 'grey66',
                'font-size' = '14px',
                'text-shadow' = '-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white'
              )
            ),
            group = 'BFS_L'
          ) %>%
            groupOptions('BFS_L', zoomLevels = 14:22) 
        } else {
          .
        }
      } %>%
      groupOptions('BFS_L', zoomLevels = 14:22) %>%
      addPolygons(
        data = BFS_sel,
        fillColor = '#FFFF00',
        color = '#FFFF00',
        weight = 10,
        opacity = .5, 
        fillOpacity = 0,
        dashArray = '1',
        group = 'BFS_sel'
      ) %>%
      addPolygons(
        data = BFS_r(),
        layerId = BFS_r()$Standort,
        fillColor = '#00ff00',
        color = 'darkgrey',
        weight = 1.25,
        opacity = 1,
        fillOpacity = .625,
        dashArray = '1',
        highlightOptions = highlightOptions(
          color = 'darkgrey',
          weight = 5,
          opacity = .125,
          sendToBack = FALSE
        ),
        group = 'Potentialflächen',
        options = pathOptions(pane = "Potentialflächen")
      ) %>%
      {
        DF = newFEA_DF()
        
        if (!is.null(DF) && is.data.frame(DF) && nrow(DF) > 0) {
          
          addPolygons(
            .,
            data = DF,
            layerId = ~ID,
            color = "darkgrey",
            weight = 0.5,
            fillOpacity = 0,
            dashArray = "1",
            highlightOptions = highlightOptions(
              color = "darkgrey",
              weight = 5,
              opacity = 0.125,
              sendToBack = FALSE
            ),
            group = "newFEA_DF"
          )
        } else {
          .
        }
      } %>%
      addDrawToolbar(
        targetGroup = "newFEA_DF",
        toolbar = toolbarOptions(
          actions = list(
            text = "Abbrechen"
          ),
          finish = list(
            text = "Speichern"
          ),
          undo = list(
            text = "Rückgängig"
          ),
          buttons = list(
            polygon   = "Polygon zeichnen",
            rectangle = "Viereck zeichnen"
          )
        ),
        handlers = handlersOptions(
          polygon = list(
            tooltipStart = "Klicken, um mit dem Zeichnen zu beginnen",
            tooltipCont  = "Weiter klicken, um das Polygon fortzusetzen",
            tooltipEnd   = "Klicken auf den ersten Punkt zum Schließen"
          ),
          rectangle = list(
            tooltipStart = "Klicken und ziehen, um ein Rechteck zu zeichnen"
          ),
          simpleshape = list(
            tooltipEnd = "Maustaste loslassen, um das Zeichnen zu beenden"
          )
        ),
        polylineOptions = FALSE,
        polygonOptions = drawPolygonOptions(
          shapeOptions = drawShapeOptions(
            fillColor   = "grey",
            color       = "red",
            weight      = 2.5,
            fillOpacity = 0.125,
            dashArray   = "1"
          )
        ),
        circleOptions = FALSE,
        rectangleOptions = drawRectangleOptions(
          shapeOptions = drawShapeOptions(
            fillColor   = "grey",
            color       = "red",
            weight      = 2.5,
            fillOpacity = 0.125,
            dashArray   = "1"
          )
        ),
        markerOptions = FALSE,
        circleMarkerOptions = FALSE,
        editOptions = editToolbarOptions(
          edit   = TRUE,
          remove = TRUE
        ),
        edittoolbar = edittoolbarOptions(
          actions = list(
            save = list(
              title = "Änderungen speichern",
              text  = "Speichern"
            ),
            cancel = list(
              title = "Bearbeitung abbrechen",
              text  = "Abbrechen"
            ),
            clearAll = list(
              title = "Alle Objekte löschen",
              text  = "Alles löschen"
            )
          ),
          buttons = list(
            edit           = "Objekte bearbeiten",
            editDisabled   = "Keine Objekte zum Bearbeiten",
            remove         = "Objekte löschen",
            removeDisabled = "Keine Objekte zum Löschen"
          )
        ),
        edithandlers = edithandlersOptions(
          edit = list(
            tooltipText = "Objekt editieren: Fläche oder einzelne Punkte verschieben",
            tooltipSubtext = ""
          ),
          remove = list(
            tooltipText = "Klicken, um ein Objekt zu löschen"
          )
        )
      ) %>%
      addRasterImage(CoRa(),
                     colors = PAL_CoRa(),
                     opacity = .75,
                     group = 'Kosten-Raster',
                     options = leafletOptions(pane = "Kosten-Raster")) %>%
      addLegend(
        position = 'bottomright',
        opacity = .75,
        pal = PAL_CoRa(),
        values = c(0, maxValue(CoRa())),
        group = 'Kosten-Raster',
        bins = pretty(c(0, ceiling(maxValue(CoRa()) / 10) * 10), n = 4),
        labFormat = labelFormat(digits = 0), 
        layerId="legend_kosten"
      ) %>%
      addLayersControl(
        baseGroups = c(
          'Leer',
          'OpenStreetMap',
          'ESRI-WorldImagery',
          'Luftbild HVBG',
          'ALKIS HVBG'
        ),
        overlayGroups = c(
          'Potentialflächen',
          'Kosten-Raster',
          'Eh da-Fläche (>100m²)',
          'Garten ALKIS',
          'Kompensationsfläche',
          'Biotope',
          'Schutzgebiete',
          # 'Gemeindegrenze',
          'OrtsGemeindegrenze'
        ),
        options = layersControlOptions(
          collapsed = TRUE,
          unchecked = FALSE ,
          autoZIndex = FALSE
        )
      ) %>%
      addMapPane('Potentialflächen', zIndex = 500) %>%
      addMapPane('Kosten-Raster', zIndex = 350) %>%
      addMapPane('Eh da-Fläche (>100m²)', zIndex = 450) %>%
      addMapPane('Garten ALKIS', zIndex = 450) %>%
      addMapPane('Kompensationsfläche', zIndex = 450) %>%
      addMapPane('Biotope', zIndex = 450) %>%
      addMapPane('Schutzgebiete', zIndex = 450) %>%
      addMapPane('OrtsGemeindegrenze', zIndex = 450) %>%
      hideGroup('Eh da-Fläche (>100m²)') %>%
      hideGroup('Garten ALKIS') %>%
      hideGroup('Kompensationsfläche') %>%
      hideGroup('Biotope') %>%
      hideGroup('Schutzgebiete') %>%
      hideGroup('OrtsGemeindegrenze') 
    
    for (L in LA){
      leafletProxy(map = 'MAP_3', session = session) %>%
        showGroup(L) %>%
        htmlwidgets::onRender("function(el, x, data) { this.invalidateSize(); }")
    }
    
    MAP_3_TRIGGER(MAP_3_TRIGGER() + 1)
    
  }
  
  # Reaktives Kostenraster >> Basis kostenbasierte Netzwerkanalyse; dynamisch aus Landschaftsksoten
  
  CoRa = reactiveVal()
  CoRa(CoRa)
  
  # Reaktive Farbskala Kostenraster >> dynamische Neuberechnung ohne UI-Neustart
  
  PAL_CoRa = reactiveVal()
  PAL_CoRa(PAL_CoRa)
  
  # Reaktive Maske >> Integration manuell digitalisierte Kostenflächen mit individuellen (landschaftsunabhängigen) Kosten in Kostenraster
  
  CoRa_masked = reactiveVal()
  
  # Start dynamische Neu-Berechnung Kostenraster (RUN_CTS) >> Neue Kosten pro Klasse | manuell digitalisierte Flächen + spezifische Kosten
  
  observeEvent(c(input$RUN_CTS), {
    
    # Zurücksetzen (dynamische) Netzwerkindizes (MAP_3)
    
    TXT$text_3_1 = ''
    TXT$text_3_2 = ''
    TXT$text_3_3 = ''
    
    leafletProxy(map = 'MAP_3', session = session)
    
    loadLAYERS_3(character(0))
    
    # updatePickerInput(session = session, inputId = 'I1_3', choices = unique(sort(BFS_r()$Standort)), selected = NULL)
    
    # Kosten Landschaftsklasse aus Eingabe (UI)
    
    C0 = input$C1 # Verkehr
    C1 = input$C2 # Offenland
    C2 = input$C3 # Gehölz
    C3 = input$C4 # Wasser
    C4 = input$C5 # Gebäude
    
    # Berechnung Kostenmatrix >> Summe aus %-Landschaftsklasse per 100x100m Pixel (Flächenanteil) x klassenspezifische Kosten (Eingabe)  
    
    CoSt = LCRA100_STACK_ST_P[, c(1, 2)]
    CoSt[, 3] = as.integer(LCRA100_STACK_ST_P[, 3]  * C0 + LCRA100_STACK_ST_P[, 4] * C1 + LCRA100_STACK_ST_P[, 5] * C2 + LCRA100_STACK_ST_P[, 6] * C3 + LCRA100_STACK_ST_P[, 7] * C4)
    
    rm(C0, C1, C2, C3, C4)
    gc()
    
    # Kostenmatrix in Raster
    
    CoRa = rasterFromXYZ(CoSt, crs = 'EPSG:4326')
    CoRa(CoRa)
    
    # Prüfen ob KOSTEN-Features vorhanden
    
    if (!is.null(newFEA_DF()) && nrow(newFEA_DF()) > 0){
      
      for (x in 1:nrow(newFEA_DF())){
        
        # Raster maskieren auf aktuelle Fläche| Zellen >> spezifische Kosten
        
        CoRa_masked(mask(CoRa(), newFEA_DF()[x,])) 
        CoRa_masked = CoRa_masked()
        CoRa_masked[!is.na(CoRa_masked[])] = as.numeric(newFEA_DF()[x,]$KOSTEN) 
        
        # Kostenraster mit maskiertes Raster aktualisieren
        
        CoRa_up = cover(CoRa_masked, CoRa()) 
        CoRa(CoRa_up) 
        
        rm(CoRa_masked)
        gc()
        
      }
      
    }
    
    rm(CoSt)
    gc()
    
    # Farbpalette Kostenraster aktualisieren (Basis >> Max Kostenwert)
    
    x = colorNumeric(
      turbo(n = 15, direction = 1),
      domain = c(0, maxValue(CoRa()) + 25),
      na.color = "transparent"
    )
    
    PAL_CoRa(x)
    
    # Re-Render MAP_3 
    
    rDT_3()
    
  })
  
  # Reaktive Variable >> neu digitalisiertes Feature  
  
  newFEA = reactiveVal()
  
  # Reaktive Variable >> neu digitalisiertes Polygon 
  
  POLYdrawn = reactiveVal()
  
  # Reaktive Variable >> DataFrame aller digitalisierten Features (sf)
  
  newFEA_DF = reactiveVal()
  
  # Reaktive Variable >> Zuletzt geklickte Feature-ID in MAP_3 (input$MAP_3_shape_click$id)
  
  ID_3 = NULL
  
  # Reaktive Variable >> Speicherung Feature-Koordinaten zur Duplikatserkennung 
  
  coords_OLD = reactiveVal()
  
  # Variable | Status-Flag 'Editiermodus' >> Aktiv | InAktiv; notwendig um Mehrfachtrigger zu verhindern
  
  EDIT_ACTIVE_3 = reactiveVal(FALSE)
  
  observeEvent(input$MAP_3_draw_editstart, {
    EDIT_ACTIVE_3(TRUE)
  })
  
  observeEvent(input$MAP_3_draw_editstop, {
    EDIT_ACTIVE_3(FALSE)
  })
  
  # Listener 'Editierte Features'
  
  observeEvent(c(input$MAP_3_draw_edited_features), {
    
    # Validierung: 'Editiermodus' aktiv
    
    req(EDIT_ACTIVE_3())
    EDIT_ACTIVE_3(FALSE)
    
    # Zurücksetzen (dynamische) Netzwerkindizes 
    
    TXT$text_3_1 = ''
    TXT$text_3_2 = ''
    TXT$text_3_3 = ''
    
    # Editierte GeoJSON-Features (LeafLet) in sf-Objekte 
    
    nFEA_E = input$MAP_3_draw_edited_features
    nFEA_E = geojsonsf::geojson_sf(jsonify::to_json(nFEA_E, unbox = T))
    
    # Aktuelle | existierende Kosten-Features in DF
    
    newFEA_DF = newFEA_DF()
    
    # Aktualisierung editierte Feature-Geometrien; Basis layerId
    
    for (x in 1:nrow(nFEA_E)) {
      
      newFEA_DF[newFEA_DF$ID == nFEA_E$layerId[[x]], ]$geometry = nFEA_E$geometry[[x]]
      
    }
    
    # Raektiver DataFrame aktualisieren
    
    newFEA_DF(newFEA_DF)
    
    C0 = input$C1 # Verkehr
    C1 = input$C2 # Offenland
    C2 = input$C3 # Gehölz
    C3 = input$C4 # Wasser
    C4 = input$C5 # Gebäude
    
    # Berechnung Kostenmatrix >> Summe aus %-Landschaftsklasse per 100x100m Pixel (Flächenanteil) x klassenspezifische Kosten (Eingabe)  
    
    CoSt = LCRA100_STACK_ST_P[, c(1, 2)]
    CoSt[, 3] = as.integer(
      LCRA100_STACK_ST_P[, 3]  * C0 + LCRA100_STACK_ST_P[, 4] * C1 + LCRA100_STACK_ST_P[, 5] * C2 + LCRA100_STACK_ST_P[, 6] * C3 + LCRA100_STACK_ST_P[, 7] * C4
    )
    
    rm(C0, C1, C2, C3, C4)
    gc()
    
    # Kostenmatrix in Raster
    
    CoRa = rasterFromXYZ(CoSt, crs = 'EPSG:4326')
    CoRa(CoRa)
    
    # Prüfen ob KOSTEN-Features vorhanden
    
    if (!is.null(newFEA_DF()) && nrow(newFEA_DF()) > 0){
      
      for (x in 1:nrow(newFEA_DF())){
        
        # Raster maskieren auf aktuelle Fläche| Zellen >> spezifische Kosten
        
        CoRa_masked(mask(CoRa(), newFEA_DF()[x,])) 
        CoRa_masked = CoRa_masked()
        CoRa_masked[!is.na(CoRa_masked[])] = as.numeric(newFEA_DF()[x,]$KOSTEN) 
        
        # Kostenraster mit maskiertes Raster aktualisieren
        
        CoRa_up = cover(CoRa_masked, CoRa()) 
        CoRa(CoRa_up) 
        
        rm(CoRa_masked)
        gc()
        
      }
      
    }
    
    rm(CoSt)
    gc()
    
    # Farbpalette Kostenraster aktualisieren (Basis >> Max Kostenwert)
    
    x = colorNumeric(
      turbo(n = 15, direction = 1),
      domain = c(0, maxValue(CoRa()) + 25),
      na.color = "transparent"
    )
    
    PAL_CoRa(x)
    
    # Re-Render MAP_3 
    
    rDT_3()
    
  }, ignoreNULL = TRUE)
  
  # Variable | Status-Flag 'Löschmodus' >> Aktiv | InAktiv; notwendig um Mehrfachtrigger zu verhindern
  
  DELE_ACTIVE_3 = reactiveVal(FALSE)
  
  observeEvent(input$MAP_3_draw_deletestart, {
    DELE_ACTIVE_3(TRUE)
  })
  
  observeEvent(input$MAP_3_draw_deletestop, {
    DELE_ACTIVE_3(FALSE)
  })
  
  # Listener 'Gelöschte Features' 
  
  observeEvent(c(input$MAP_3_draw_deleted_features), {
    
    # Validierung: 'Editiermodus' aktiv
    
    req(DELE_ACTIVE_3())
    DELE_ACTIVE_3(FALSE)
    
    # Zurücksetzen (dynamische) Netzwerkindizes 
    
    TXT$text_3_1 = ''
    TXT$text_3_2 = ''
    TXT$text_3_3 = ''
    
    if (!is.null(input$MAP_3_draw_deleted_features)) { # 'Gelöschte Features' existieren
      
      # Gelöschte GeoJSON-Features (LeafLet) in sf-Objekt
      
      nFEA_D = input$MAP_3_draw_deleted_features
      nFEA_D = geojsonsf::geojson_sf(jsonify::to_json(nFEA_D, unbox = T))
      
      # Aktuelles | existierendes Kosten-Feature in DF
      
      newFEA_DF = newFEA_DF()
      
      # Geometrien über layerId aus DF löschen
      
      for (x in 1:length(nFEA_D$geometry)) {
        
        newFEA_DF = newFEA_DF[newFEA_DF$ID != nFEA_D$layerId[x], ]
        
      }
      
      # Reaktiver DataFrame aktualisieren
      
      newFEA_DF(newFEA_DF)
      
      C0 = input$C1 # Verkehr
      C1 = input$C2 # Offenland
      C2 = input$C3 # Gehölz
      C3 = input$C4 # Wasser
      C4 = input$C5 # Gebäude
      
      # Berechnung Kostenmatrix >> Summe aus %-Landschaftsklasse per 100x100m Pixel (Flächenanteil) x klassenspezifische Kosten (Eingabe)  
      
      CoSt = LCRA100_STACK_ST_P[, c(1, 2)]
      CoSt[, 3] = as.integer(
        LCRA100_STACK_ST_P[, 3]  * C0 + LCRA100_STACK_ST_P[, 4] * C1 + LCRA100_STACK_ST_P[, 5] * C2 + LCRA100_STACK_ST_P[, 6] * C3 + LCRA100_STACK_ST_P[, 7] * C4
      )
      
      rm(C0, C1, C2, C3, C4)
      gc()
      
      # Kostenmatrix in Raster
      
      CoRa = rasterFromXYZ(CoSt, crs = 'EPSG:4326')
      CoRa(CoRa)
      
      # Prüfen ob KOSTEN-Features vorhanden
      
      if (!is.null(newFEA_DF()) && nrow(newFEA_DF()) > 0){
        
        for (x in 1:nrow(newFEA_DF())){
          
          # Raster maskieren auf aktuelle Fläche| Zellen >> spezifische Kosten
          
          CoRa_masked(mask(CoRa(), newFEA_DF()[x,])) 
          CoRa_masked = CoRa_masked()
          CoRa_masked[!is.na(CoRa_masked[])] = as.numeric(newFEA_DF()[x,]$KOSTEN) 
          
          # Kostenraster mit maskiertes Raster aktualisieren
          
          CoRa_up = cover(CoRa_masked, CoRa()) 
          CoRa(CoRa_up) 
          
          rm(CoRa_masked)
          gc()
          
        }
        
      }
      
      rm(CoSt)
      gc()
      
      # Farbpalette Kostenraster aktualisieren (Basis >> Max Kostenwert)
      
      x = colorNumeric(
        turbo(n = 15, direction = 1),
        domain = c(0, maxValue(CoRa()) + 25),
        na.color = "transparent"
      )
      
      PAL_CoRa(x)
      
      # Re-Render MAP_3 
      
      rDT_3()
      
    }
    
  }, ignoreNULL = TRUE)
  
  
  # Listener 'STOP Digitalisierung'
  
  observeEvent(input$MAP_3_draw_stop, {
    
    # Zurücksetzen (dynamische) Netzwerkindizes 
    
    TXT$text_3_1 = ''
    TXT$text_3_2 = ''
    TXT$text_3_3 = ''
    
    # Digitalisiertes GeoJSON-Feature (LeafLet) in Variable 
    
    newFEA(input$MAP_3_draw_new_feature)
    
    # Prüfen ob neu digitalisiertes Feature exisitiern & Typ Polygon 
    
    if (!is.null(newFEA()$geometry$type) && newFEA()$geometry$type == "Polygon") {
      
      # Duplikatserkennung über Vergleich Feature-Koordinaten mit letzten gespeicherten Feature-Koordinaten   
      
      coords = newFEA()$geometry$coordinates[[1]]
      
      lng = sapply(coords, `[[`, 1)
      lat = sapply(coords, `[[`, 2)
      
      lng_O = sapply(coords_OLD(), `[[`, 1)
      lat_O = sapply(coords_OLD(), `[[`, 2)
      
      # Prüfen ob Feature kein Duplikat | nicht idetisch zuvor digitalisiertem
      
      if (length(lng_O) == 0 || length(lat_O) == 0 || any(lng != unlist(lng_O)) || any(lat != unlist(lat_O))) {
        
        # Speichern Feature-Koordinaten Duplikatserkennung
        
        coords_OLD(coords)
        
        # Polygon erzeugen + in Variable speichern
        
        POLYdrawn = st_polygon(list(cbind(lng, lat))) %>%
          st_sfc(crs = 4326)
        POLYdrawn(POLYdrawn)
        POLYdrawn = as(POLYdrawn, "Spatial")
        
        updateTextInput(session, "COSTs", value = "")
        
        if (!openMODAL()) {
          
          openMODAL(TRUE)
          
          # Modal 'Kosten-Eingabe' 
          
          showModal(
            modalDialog(
              size = 's',
              numericInput('COSTs', 'KOSTEN', value = NULL),  # numericInput
              footer = tagList(
                actionButton('cancel2', 'Abbrechen'),
                actionButton('submit2', 'Bestätigen')
              ),
              easyClose = FALSE
            )
          )
        }
        
      }
      
      newFEA(NULL)
      
    }
    
  }, ignoreNULL = TRUE)
  
  observeEvent(input$cancel2, {
    
    # Modal 'Kosten-Eingabe' schließen 
    
    removeModal()
    openMODAL(FALSE)
    
    # Farbpalette Kostenraster aktualisieren (Basis >> Max Kostenwert) >> HIER: notwendig um Re-Render auszulösen
    
    x = colorNumeric(
      turbo(n = 15, direction = 1),
      domain = c(0, maxValue(CoRa()) + 25),
      na.color = "transparent"
    )
    
    PAL_CoRa(x)
    
    # Re-Render MAP_3 
    
    rDT_3()
    
  })
  
  # Reaktive Variable >> Fortlaufende ID für neu digitalisierte Features | initial 1; wird inkrementiert
  
  ID_n = reactiveVal(1)
  
  # Speichern neu digitalisierte Kostenfläche 
  
  observeEvent(input$submit2, {
    
    # Validierung: Kostenwert vorhanden | numerisch 
    
    req(!is.null(input$COSTs))
    req(!is.na(input$COSTs))
    
    # Modal 'Kosten-Eingabe' schließen 
    
    removeModal()
    openMODAL(FALSE) 
    
    # Digitalisiertes Feature in Variable 
    
    POLYdrawn = POLYdrawn()
    
    # Aufbau sf-Objekts >> ID: fortlaufend eindeutig | KOSTEN: nutzerdefinierter Wert
    
    POLYdrawn = st_sf(
      ID = ID_n(),
      KOSTEN = as.numeric(input$COSTs),
      geometry = POLYdrawn
    )
    
    # ID inkrementieren
    
    ID_n(ID_n()+1)
    
    
    # Prüfen ob reaktiver DataFrame leer
    
    if (is.null(newFEA_DF())){
      
      # Feature hinzufügen
      
      newFEA_DF(POLYdrawn)
      
    }
    
    else{
      
      # Aktuelles | existierendes Kosten-Feature in DF
      
      newFEA_DF = newFEA_DF()
      
      # Feature DF hinzufügen & reaktiven DF aller digitalisierten Features hinzufügen
      
      newFEA_DF(bind_rows(newFEA_DF,POLYdrawn))
      
    }
    
    # Raster maskieren auf aktuelles Feature 
    
    CoRa_masked(mask(CoRa(), POLYdrawn))
    CoRa_masked = mask(CoRa(), POLYdrawn)
    
    # Maskierte Rasterzellen >> spezifische Kosten
    
    CoRa_masked[!is.na(CoRa_masked[])] = as.numeric(input$COSTs)
    
    updateTextInput(session, "COSTs", value = "")
    
    # Kostenraster mit maskiertem Rasterzellen aktualisieren
    
    CoRa_up = cover(CoRa_masked, CoRa())
    
    rm(CoRa_masked)
    gc()
    
    CoRa(CoRa_up)
    
    rm(CoRa_up)
    gc()
    
    # Farbpalette Kostenraster aktualisieren (Basis >> Max Kostenwert)
    
    x = colorNumeric(
      turbo(n = 15, direction = 1),
      domain = c(0, maxValue(CoRa()) + 25),
      na.color = "transparent"
    )
    
    PAL_CoRa(x)
    
    # Re-Render MAP_3 
    
    rDT_3()
    
  })
  
  # Download-Button aktiv >> Kosten-Feature existieren
  
  observe({
    shinyjs::toggleState("download_R22", condition = !is.null(newFEA_DF()) && nrow(newFEA_DF()) > 0)
  })
  
  # Download Kosten-Feature (GPKG)
  
  output$download_R22 = downloadHandler(
    
    filename = function() {
      paste0("KOSTEN_POLY.gpkg")
    },
    
    content = function(file) {
      
      st_write(newFEA_DF(), file, delete_layer = TRUE)
    }, 
    
  )
  
  # Upload externer KOSTEN-Feature (GPKG)
  
  observeEvent(c(input$upload_R22), {
    
    # Zurücksetzen (dynamische) Netzwerkindizes 
    
    TXT$text_3_1 = ''
    TXT$text_3_2 = ''
    TXT$text_3_3 = ''
    
    # Dateiformat prüfen
    
    name_O = input$upload_R22$name
    EXT = tolower(tools::file_ext(name_O))
    
    if (EXT != "gpkg") {
      showModal(modalDialog(
        size = "s",
        tags$h5('Wrong file format - has to be gpkg', align = "center"),
        easyClose = TRUE
      ))
      
      return(NULL)
      
    }
    
    # KOSTEN-Features in DF 
    
    newFEA_DF = sf::st_read(input$upload_R22[4]) %>%
      rename(geometry = geom)
    
    newFEA_DF(newFEA_DF)
    
    # Prüfen keine KOSTEN-Spalte >> Nutzerabfrage
    
    if (!"KOSTEN" %in% names(newFEA_DF)) {
      
      # Modal 'KOSTEN-Eingabe' 
      
      showModal(modalDialog(
        size = "s",
        tags$h5("KOSTEN-Wert fehlt:", align = "center"),
        div(
          numericInput(
            "kosten_value",
            label = NULL,
            value = NA,
            min = 0
          ),
          align = "center"
        ),
        footer = tagList(
          modalButton("Abbrechen"),
          actionButton("setKosten", "Speichern")
        ),
        easyClose = FALSE
      ))
      
      return(NULL)
      
    }
    
    # Prüfen ob KOSTEN-Features vorhanden
    
    if (!is.null(newFEA_DF()) && nrow(newFEA_DF()) > 0){
      
      for (x in 1:nrow(newFEA_DF())){
        
        # Raster maskieren auf aktuelle Fläche| Zellen >> spezifische Kosten
        
        CoRa_masked(mask(CoRa(), newFEA_DF()[x,])) 
        CoRa_masked = CoRa_masked()
        CoRa_masked[!is.na(CoRa_masked[])] = as.numeric(newFEA_DF()[x,]$KOSTEN) 
        
        # Kostenraster mit maskiertes Raster aktualisieren
        
        CoRa_up = cover(CoRa_masked, CoRa()) 
        CoRa(CoRa_up) 
        
        rm(CoRa_masked)
        gc()
        
      }
      
    }
    
    gc()
    
    # Farbpalette Kostenraster aktualisieren (Basis >> max Kostenwert)
    
    x = colorNumeric(
      turbo(n = 15, direction = 1),
      domain = c(0, maxValue(CoRa()) + 25),
      na.color = "transparent"
    )
    
    PAL_CoRa(x)
    
    # Re-Render MAP_3 
    
    rDT_3()
    
  } )
  
  # Setzen (globalen) KOSTEN-Wert >> alle Feature
  
  observeEvent(input$setKosten, {
    
    # Aktuelle | existierende Kosten-Features in DF >> notwendig um Kosten zu DF hinzuzufügen
    
    newFEA_DF = newFEA_DF()
    
    # Globaler KOSTEN-WERT; Eingabe gilt für alle Featue
    
    newFEA_DF$KOSTEN = input$kosten_value
    
    # Raektiver DataFrame aktualisieren
    
    newFEA_DF(newFEA_DF)
    
    # Modal 'KOSTEN-Eingabe' schließen 
    
    removeModal()
    openMODAL(FALSE)
    
    # Prüfen ob KOSTEN-Features vorhanden
    
    if (!is.null(newFEA_DF()) && nrow(newFEA_DF()) > 0){
      
      for (x in 1:nrow(newFEA_DF())){
        
        # Raster maskieren auf aktuelle Fläche| Zellen >> spezifische Kosten
        
        CoRa_masked(mask(CoRa(), newFEA_DF()[x,])) 
        CoRa_masked = CoRa_masked()
        CoRa_masked[!is.na(CoRa_masked[])] = as.numeric(newFEA_DF()[x,]$KOSTEN) 
        
        # Kostenraster mit maskiertes Raster aktualisieren
        
        CoRa_up = cover(CoRa_masked, CoRa()) 
        CoRa(CoRa_up) 
        
        rm(CoRa_masked)
        gc()
        
      }
      
    }
    
    gc()
    
    # Farbpalette Kostenraster aktualisieren (Basis >> Max Kostenwert)
    
    x = colorNumeric(
      turbo(n = 15, direction = 1),
      domain = c(0, maxValue(CoRa()) + 25),
      na.color = "transparent"
    )
    
    PAL_CoRa(x)
    
    # Re-Render MAP_3 
    
    rDT_3()
    
  })
  
  # Synchronisierung FLächenselektion Kartenklick MAP_3 <> PickerInput I1_3
  
  observeEvent(c(input$MAP_3_shape_click), {
    
    # ID geklicktes Feature 
    
    ID_3 = input$MAP_3_shape_click$id
    
    # Picker-IDs (aktiv)
    
    S1 = input$I1_3
    
    # 1: Picker-IDs vorhanden | ID_3 vorhanden
    
    if (!is.null(S1) & !is.null(ID_3)) {
      
      # Prüfen: ID_3 in S1
      
      if (ID_3 %in% S1) {
        
        # ID_3 aus S1 löschen
        
        S1 = S1[S1 != ID_3]
        
      }
      
      else{
        
        # ID_3 zu S1 hinzufügen
        
        S1 = c(S1, ID_3)
        
      }
      
      # Update PickerInput mit aktualisierter Auswahl (S1)
      
      updatePickerInput(
        session = session,
        inputId = 'I1_3',
        choices = unique(sort(BFS_r()$Standort)),
        selected = unique(BFS_r()[BFS_r()$Standort %in% S1, ]$Standort)
      )
      
    }
    
    # 2: PickerIDs vorhanden | ID_3 leer (kein gültiger Klick)
    
    if (!is.null(S1) & is.null(ID_3)) {
      
      # Update PickerInput mit aktualisierter Auswahl (S1)
      
      updatePickerInput(
        session = session,
        inputId = 'I1_3',
        choices = unique(sort(BFS_r()$Standort)),
        selected = unique(BFS[BFS$Standort %in% S1, ]$Standort)
      )
      
    }
    
    # 3: PickerIDs leer | ID_2 vorhanden
    
    if (is.null(S1) & !is.null(ID_3)) {
      
      # Update PickerInput mit initialer Auswahl (S1)
      
      S1 = c(ID_3)
      
      updatePickerInput(
        session = session,
        inputId = 'I1_3',
        choices = unique(sort(BFS_r()$Standort)),
        selected = unique(BFS[BFS$Standort %in% S1, ]$Standort)
      )
      
    }
    
    # 4: Picker-IDs leer 
    
    if (is.null(S1)) {
      
      # Leeren PickerInput
      
      updatePickerInput(
        session = session,
        inputId = 'I1_3',
        choices = unique(sort(BFS_r()$Standort)),
        selected = NULL
      )
      
    }
    
  }, ignoreNULL = FALSE)
  
  # Reaktion Änderungen Picker 'Featureauswahl' (I1_3) >> Selektion von Potentialflächen + Visuelle Hervorhebung in MAP_3
  
  observeEvent(c(input$I1_3), {
    
    # Variable: Subset Potentialflächen in Picker (I1_3)
    
    BFS_sel = BFS_r()[BFS_r()$Standort %in% input$I1_3, ]
    
    leafletProxy(map = 'MAP_3', session = session) %>%
      clearGroup('BFS_L') %>%
      {
        DF = BFSc_r()
        
        if (!is.null(DF) && is.data.frame(DF) && nrow(DF) > 0) {
          
          addLabelOnlyMarkers(
            .,
            data = DF,
            lat = st_coordinates(BFSc_r()$geometry)[, 2],
            lng = st_coordinates(BFSc_r()$geometry)[, 1],
            label = ~ Standort,
            labelOptions = labelOptions(
              noHide = T,
              direction = 'centered',
              offset = c(0, 0),
              textOnly = TRUE,
              style = list(
                'color' = 'grey66',
                'font-size' = '14px',
                'text-shadow' = '-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white'
              )
            ),
            group = 'BFS_L'
          ) %>%
            groupOptions('BFS_L', zoomLevels = 14:22) 
        } else {
          .
        }
      } %>%
      clearGroup('NET_AREA') %>%
      clearGroup('BFS_sel') %>%
      clearGroup('net_e') %>%
      clearGroup('net_n') %>%
      addPolygons(
        data = BFS_sel,
        fillColor = '#FFFF00',
        color = '#FFFF00',
        weight = 10,
        opacity = .5, 
        fillOpacity = 0,
        dashArray = '1',
        group = 'BFS_sel'
      ) %>%
      addPolygons(
        data = BFS_r(),
        layerId = BFS_r()$Standort,
        fillColor = '#00ff00',
        color = 'darkgrey',
        weight = 1.25,
        opacity = 1,
        fillOpacity = .625,
        dashArray = '1',
        highlightOptions = highlightOptions(
          color = 'darkgrey',
          weight = 5,
          opacity = .125,
          sendToBack = FALSE
        ),
        group = 'Potentialflächen',
        options = pathOptions(pane = "Potentialflächen")
      )
    
  }, ignoreNULL = FALSE)
  
  
  observe({
    
    if(is.na(input$I2_3)){
      
      # Abruch wenn keine Selektion
      
      return(NULL)
      
    }
    
    if (is.na(input$I2_3) || input$I2_3 < 50 || input$I2_3 > 5000 || (is.null(input$I1_3) || length(input$I1_3) == 1)) {
      
      # RUN-Button 'Netzwerkanalyse' deaktivieren (MAP_3)
      
      shinyjs::disable("RUN_NET_2")
      
    }
    
    else{
      
      # RUN-Button 'Netzwerkanalyse' aktivieren (MAP_3)
      
      shinyjs::enable("RUN_NET_2")
      
    }
    
  })
  
  observeEvent(c(input$I1_3), {
    
    # Zurücksetzen (dynamische) Netzwerkindizes 
    
    TXT$text_3_1 = ''
    TXT$text_3_2 = ''
    TXT$text_3_3 = ''
    
  })
  
  #  Tooltip 'Kosten-Budegt': Umrechnung in [m] := (max. Distanz / min. Kosten) × Pixelgröße
  
  observe( {
    
    removeTooltip(session, id = "I2_3")
    
    DIST_M = (input$I2_3 / min(input$C1, input$C2, input$C3, input$C4, input$C5) * 100) 
    
    DT = paste0("≙ ", DIST_M, " [m]")
    
    print(DT)
    
    delay(250, {
      addTooltip(session, 
                 id = "I2_3", 
                 title = DT, 
                 placement = "right", 
                 trigger = "hover")
    })
    
  })
  
  
  #  'Kosten-Distanz' (MAP_3):  Least-Cost-Paths | kostenminimale Verbindungen >> Berechnung Netzkennzahlen + Leaflet-Visualisierung (Basis sfnetwork-Objekt für selektierte 'PotentialFlächen' & KostenRaster)  
  
  observeEvent(c(input$RUN_NET_2), {
    
    # Karten-Refresh
    
    MAP_TRIGGER_3(MAP_TRIGGER_3() + 1)
    
    # Aktive Overlay-Gruppen MAP_3
    
    aG_3 = req(input$MAP_3_groups)
    
    # Layer 'Potentialflächen' nicht aktiv
    
    if (!("Potentialflächen" %in% aG_3)) {
      
      # Karten-Reset >> Entfernen Layer 'Netzwerkanalyse'
      
      leafletProxy(map = 'MAP_3', session = session) %>%
        clearGroup('BFS_L') %>%
        clearGroup('BFS_sel') %>%
        clearGroup('net_e') %>%
        clearGroup('net_n')
      
      # Zurücksetzen (dynamische) Netzwerkindizes 
      
      TXT$text_3_1 = ''
      TXT$text_3_2 = ''
      TXT$text_3_3 = ''
      
    }
    
    else{
      
      # RUN-Button 'Netzwerkanalyse' während Berechnung deaktivieren (verhindert Mehrfachausführung)
      
      shinyjs::disable("RUN_NET_2")
      
      # Initalisierung Fortschrittsbalkens in GUI (https://shiny.posit.co/r/reference/shiny/0.11/withprogress.html)
      
      withProgress(message = '', value = 0, max = 1, style = getShinyOption("progress.style", default = "notification"), {
        
        # Selektion PotentialFlächen 
        
        BFS_sel = BFS_r()[BFS_r()$Standort %in% input$I1_3, ]
        
        # Fortschritt-Balken 5 %
        
        setProgress(0.05, detail = paste("5 %"))
        
        # Selektion Start|Ziel-Paare (ohne Selbstverbindungen) (I1_3 )
        
        PA = expand.grid(input$I1_3, input$I1_3)
        PA = PA[PA[, 1] != PA[, 2], ]
        
        # Selektion Zentroide (I1_3) + Transformation in metrisches CRS (EPSG:25832) für Distanzberechnungen
        
        BFS_SP_G = BFSc_r()[BFSc_r()$Standort %in% input$I1_3,]
        BFS_SP_G = st_transform(BFS_SP_G, CRS('epsg:25832'))
        
        # Zentroide in XY-Matrix
        
        P_XY = matrix(unlist(BFS_SP_G$geometry), nrow = length(BFS_SP_G$geometry), byrow = TRUE)
        
        # Vorbereitung Kostenrasters für Least-Cost-Berechnung + Transformation in metrisches CRS (EPSG:25832)
        
        CoRa_INT = CoRa()
        CoRa_INT = projectRaster(CoRa_INT, crs = '+init=epsg:25832', method = "ngb")
        
        # TransitionFunktion Kostenraster >> hohe Kosten := geringe Durchlässigkeit (https://www.rdocumentation.org/packages/gdistance/versions/1.6.5/topics/transition)
        
        TF = function(x) { 1 / x[2] }
        
        # TransitionMatrix (4 Nachbarschaften) für Least-Cost-Berechnung
        
        CRA_TM = transition(CoRa_INT, transitionFunction = TF, directions = 4)
        
        # Anzahl Zentroide
        
        nrows = length(P_XY[,1])
        
        # DF-Datenstruktur für Speicherung Least-Cost-Pfade
        
        BFS_SP_LC = as.data.frame(st_sf(geometry = st_sfc(lapply(1:nrows^2, function(x) st_linestring()))))
        BFS_SP_LC$Start = NA
        BFS_SP_LC$End = NA
        BFS_SP_LC$Cost = NA
        
        # Fortschritt-Balken 25 %
        
        setProgress(0.25, detail = paste("25 %"))
        
        z = 1
        zz = nrows
        
        # Max. Ausbreitungsdistanz [m] unter optimalen Bedingungen >> (Kosten-Budget / min. Kosten) × Pixelgröße
        
        DIST_M = (input$I2_3 / min(input$C1, input$C2, input$C3, input$C4, input$C5) * 100) 
        
        # Iteration über Potentialflächen >> Berechnung Least-Cost-Pfade 
        
        for (x in c(1:nrows)){
          
          # Potentialflächen mit Entfernung | euklidische Distanz <= max. Ausbreitungsdistanz
          
          i_sm = (sqrt((P_XY[,1] - P_XY[x,1])^2 + (P_XY[,2] - P_XY[x,2])^2)) <= DIST_M
          
          # Berechnung Least-Cost-Pfade + Umwandlung in Linien-Polygon + CRS
          
          BFS_SP_z = st_as_sf(shortestPath(CRA_TM, P_XY[x,],  P_XY[i_sm,], output = "SpatialLines"))
          BFS_SP_z = st_set_crs(BFS_SP_z, crs(CoRa_INT))
          
          # Speicherung Least-Cost-Pfade in DF
          
          BFS_SP_LC[c(z + which(i_sm)),]$geometry = BFS_SP_z$geometry
          BFS_SP_LC[c(z + which(i_sm)),]$Start = BFS_SP_G[x,]$Standort
          BFS_SP_LC[c(z + which(i_sm)),]$End = BFS_SP_G[c(which(i_sm)),]$Standort
          BFS_SP_LC[c(z + which(i_sm)),]$Cost = as.numeric(costDistance(CRA_TM, P_XY[x,],  P_XY[i_sm,]))
          
          # Index
          
          z = zz + 1
          zz = zz + nrows
          
          # Speicherbereinigung 
          
          if (x %% ceiling(length(P_XY[,1])/10) == 0) {
            gc()
          }
          
          # Fortschritt-Balken aktualisieren ( 25 - 75 %)
          
          if (x %% 5 == 0) {
            
            perc = round((25 + (75 - 25) * (x - 1) / (nrows - 1)) / 5) * 5
            
            setProgress(perc/100, detail = paste0(perc, ' %'))
            
          }
          
        }
        
        rm(i_sm, BFS_SP_z, CoRa_INT)
        gc()
        
        BFS_SP_LC = st_as_sf(BFS_SP_LC, sf_column_name = "geometry", crs = 25832)
        
        # Fortschritt-Balken 75 %
        
        setProgress(.75, detail = paste('75 %'))
        
        # Entfernen Duplikate
        
        BFS_SP_LC = BFS_SP_LC[!duplicated(t(apply(as.data.frame(BFS_SP_LC[,2:1])[,1:2], 1, sort))),]
        
        # Entfernen leerer Linien 
        
        BFS_SP_LC = BFS_SP_LC[!st_is_empty(BFS_SP_LC),drop=FALSE]
        
        # Entfernen Selbstverbindungen (Start == End) >> Geometrie leer
        
        BFS_SP_LC$geometry[BFS_SP_LC$Start == BFS_SP_LC$End] = st_linestring()
        
        # Entfernen kurze Linien
        
        BFS_SP_LC$geometry[as.numeric(st_length(BFS_SP_LC$geometry)) < .01] = st_linestring()
        
        # Entfernen leerer Linien 
        
        BFS_SP_LC = BFS_SP_LC[!st_is_empty(BFS_SP_LC),,drop=FALSE]
        
        # Doppelte Verbindungen (AB | BA)
        
        BFS_SP_LC = BFS_SP_LC %>%
          mutate(
            a2 = pmin(Start, End),
            b2 = pmax(Start, End)
          ) %>%
          distinct(a2, b2, .keep_all = TRUE) %>%
          select(-a2, -b2)
        
        # Entfernen Geometrien > Kosten-Budegt
        
        BFS_SP_LC_sel = BFS_SP_LC[as.numeric(BFS_SP_LC$Cost) < input$I2_3, ]
        
        # Filterung berechnete Verbindungen auf gültigen Kombinationen in PA
        
        BFS_SP_LC_sel = BFS_SP_LC_sel[paste0(BFS_SP_LC_sel$Start, BFS_SP_LC_sel$End) %in% paste0(PA[, 1], PA[, 2]), ]
        
        # Transformation der Geometrien in WGS84 (EPSG:4326) für Darstellung in Leaflet
        
        BFS_SP_LC_sel = st_transform(BFS_SP_LC_sel, 4326)
        
        # Fortschritt-Balken 80 %
        
        setProgress(0.8, detail = paste("80 %"))
        
        # Linien-Endpunkte auf BFS-Zentroide (über ID) >> notwendig, da Least-Cost-Pfade rasterbasiert und Endpunkte somit nicht BFS-Zentroide entsprechen

        NO_SF = st_transform(BFS_SP_G,4326)

        ED_SF = BFS_SP_LC_sel[!st_is_empty(BFS_SP_LC_sel), , drop =  FALSE] %>%
          mutate(
            from = match(Start, NO_SF$Standort),
            to   = match(End,   NO_SF$Standort)
          )
        
        adj_ED_SF = mapply(function(i, geom) {
          
          coords = st_coordinates(geom)
          
          coords[1,1:2] = st_coordinates(NO_SF$geometry[
            match(ED_SF$Start[i], NO_SF$Standort)
          ])
          
          coords[nrow(coords),1:2] = st_coordinates(NO_SF$geometry[
            match(ED_SF$End[i], NO_SF$Standort)
          ])
          
          st_linestring(coords)
          
        }, seq_len(nrow(ED_SF)), ED_SF$geometry, SIMPLIFY = FALSE)
        
        ED_SF$geometry = st_sfc(adj_ED_SF, crs = st_crs(NO_SF))
        ED_SF = st_as_sf(ED_SF)
        
        # Umwandlung Punkte & Verbindungen | Linien in Netzwerkobjekt
        
        net_LC_o = sfnetwork(NO_SF, ED_SF, directed = FALSE)
        
        # Fortschritt-Balken 90 %
        
        setProgress(0.9, detail = paste("90 %"))
        
        if (net_LC_o %>% activate("edges") %>% as_tibble() %>% nrow() == 0) {
          
          # Zurücksetzen (dynamische) Netzwerkindizes 
          
          TXT$text_3_1 = ''
          TXT$text_3_2 = ''
          TXT$text_3_3 = ''
          
          return(NULL)
          
        }
        
        # Netzwerkanalyse: Berechnung zentraler Netzwerkkennzahlen (Zentralitäten (Knoten & Kanten) | Netzwerk-Gruppen (Communities)) (https://www.rdocumentation.org/packages/sfnetworks/versions/0.6.5) >> Bewertung ökologische Konnektivität quantitativ & visuell
        
        net_LC = net_LC_o %>%
          
          morph(to_undirected) %>% 
          
          # Vereinfachung der Netzwerkstruktur: entfernt Mehrfachkanten und Selbstschleifen zur Vermeidung künstlich erhöhter Zentralitäten
          
          morph(to_simple) %>% 
          
          # Aktivieren der Kantenebene des Netzwerks zur Berechnung kantenbasierter Netzwerkmetriken
          
          sfnetworks::activate(edges) %>% 
          
          # Edge Betweenness Centrality: identifiziert kritische Verbindungen bzw. Engpässe im Netzwerk (Darstellung über Linienstärke)
          
          mutate(beedgecen = centrality_edge_betweenness()) %>% 
          
          # Aktivieren der Knotenebene des Netzwerks zur Berechnung knotenbasierter Netzwerkmetriken
          
          sfnetworks::activate(nodes) %>% 
          
          mutate(
            
            # Knoten-Betweenness: identifiziert zentrale Standorte ("Stepping Stones") für Netzwerkverbindungen
            
            becen  = centrality_betweenness(), 
            
            # Community Detection (Fast Greedy): identifiziert funktionale Gruppen bzw. Teilnetzwerke über Maximierung der Modularität
            
            group  = group_fast_greedy(), 
            
            # Mittlere Pfadlänge des Netzwerks: durchschnittliche Distanz zwischen allen Knoten als Indikator für Erreichbarkeit/Fragmentierung
            
            meand  = graph_mean_dist(),     
            
            # Netzwerkeffizienz: Maß der globalen Konnektivität; hohe Werte zeigen kurze Wege und ein gut verbundenes Netzwerk
            
            effic  = graph_efficiency()   
            
          ) %>%
          
          # Rückkehr zur ursprünglichen sfnetwork-Struktur nach Abschluss der morph()-Transformationen
          
          unmorph() 
        
        # Extraktion Knoten aus Netzwerkobjekt 
        
        NO = st_as_sf(net_LC, 'nodes')
        
        # Extraktion Kanten aus Netzwerkobjekt 
        
        ED = st_as_sf(net_LC, 'edges')
        
        # Prüfung ungültige Geometrien
        
        has_na = vapply(
          st_geometry(ED),
          function(g) {
            coords = st_coordinates(g)
            nrow(coords) == 0 || any(is.na(coords))
          },
          logical(1)
        )
        
        # Entfernen ungültige Geometrien
        
        ED = ED[!has_na & !st_is_empty(ED), , drop = FALSE]
        
        # Kanten-Endpunkte auf Knoten
        
        ends = 
          nearest_id_ends = st_nearest_feature(st_cast(st_boundary(ED), "POINT"), st_geometry(NO))
        
        # Kanten-Linien korrigieren (auf Endpunkte)
        
        new_ED = mapply(
          
          FUN = function(i, geom) {
            
            coords = st_coordinates(geom)
            
            coords[1, 1:2] = st_coordinates(st_geometry(NO)[nearest_id_ends][2*i - 1])[1:2]
            coords[nrow(coords), 1:2] = st_coordinates(st_geometry(NO)[nearest_id_ends][2*i])[1:2]
            
            st_linestring(coords)
            
          },
          
          i = seq_len(nrow(ED)),
          geom = st_geometry(ED),
          SIMPLIFY = FALSE
          
        )
        
        # Aktualisierte Geometrien speichern
        
        ED$geometry = st_zm(st_sfc(new_ED, crs = st_crs(ED)), drop = TRUE)
        
        # Linien glätten (für Visualisierung)
        
        ED = smooth(ED, method = "ksmooth", smoothness = 2.5)
        
        ###
        
        gc()
        
        # Größte (zusammenhängende) Netzwerk-Komponente | Hauptkomponente
        
        NPs = as.vector(net_LC %>% pull(geometry))[components(net_LC)$membership == which.max(table(components(net_LC)$membership))]
        
        # Flächen-Polygon größte Netzwerk-Komponente >> Buffer mit ⌀-Länge Kanten (kein fester Wert möglich, da 1/2 Ausbreitungs-Distanz abhängig von Kostenraster)
        
        NET_AREA = st_union(st_buffer(st_transform(NPs, CRS('epsg:4326')), mean(st_length(st_as_sf(net_LC, 'edges')$geometry))))
        NET_AREA = st_make_valid(NET_AREA)
        
        # Fortschritt-Balken 100 %
        
        setProgress(1, detail = paste("100 %"))
        
        # Textausgabe (UI) >> Ergebnisse Netzwerkanalyse (MAP_3)
        
        TXT$text_3_1 = components(net_LC)$no
        TXT$text_3_2 = round(max(components(net_LC)$csize) / length(input$I1_3) * 100,1)
        TXT$text_3_3 = round(as.numeric(st_area(st_make_valid(NET_AREA))) / 1000^2, 1) #km²
        
        # Aktive Overlay-Layer MAP_3 speichern
        
        LA = input$MAP_3_groups
        
        # Reaktive Variable aktive Overlay-Layer leeren
        
        loadLAYERS_3(character(0))
        
        PARAs = list(center = input$MAP_3_center, zoom = input$MAP_3_zoom)
        
        # Aktualisierung Leaflet-Karte (MAP_3) >> Netzwerk-Verbindungen, Netzwerk-Knoten, Fläche Hauptnetzwerk
        
        leafletProxy(map = 'MAP_3', session = session) %>%
          clearControls() %>%
          invokeMethod(
            'map',
            'setView',
            c(PARAs$center$lat, PARAs$center$lng),
            PARAs$zoom,
            list(animate = FALSE)
          ) %>%
          addMapPane('net_e', zIndex = 475) %>%              
          addMapPane('net_n', zIndex = 475) %>% 
          clearGroup('NET_AREA') %>%
          clearGroup('BFS_sel') %>%
          clearGroup('net_e') %>%
          clearGroup('net_n') %>%
          {
            DF = newFEA_DF()
            
            if (!is.null(DF) && is.data.frame(DF) && nrow(DF) > 0) {
              
              addPolygons(
                .,
                data = DF,
                layerId = ~ID,
                color = "darkgrey",
                weight = 0.5,
                fillOpacity = 0,
                dashArray = "1",
                highlightOptions = highlightOptions(
                  color = "darkgrey",
                  weight = 5,
                  opacity = 0.125,
                  sendToBack = FALSE
                ),
                group = "newFEA_DF"
              )
            } else {
              .
            }
          } %>%
          addDrawToolbar(
            targetGroup = "newFEA_DF",
            toolbar = toolbarOptions(
              actions = list(
                text = "Abbrechen"
              ),
              finish = list(
                text = "Speichern"
              ),
              undo = list(
                text = "Rückgängig"
              ),
              buttons = list(
                polygon   = "Polygon zeichnen",
                rectangle = "Viereck zeichnen"
              )
            ),
            handlers = handlersOptions(
              polygon = list(
                tooltipStart = "Klicken, um mit dem Zeichnen zu beginnen",
                tooltipCont  = "Weiter klicken, um das Polygon fortzusetzen",
                tooltipEnd   = "Klicken auf den ersten Punkt zum Schließen"
              ),
              rectangle = list(
                tooltipStart = "Klicken und ziehen, um ein Rechteck zu zeichnen"
              ),
              simpleshape = list(
                tooltipEnd = "Maustaste loslassen, um das Zeichnen zu beenden"
              )
            ),
            polylineOptions = FALSE,
            polygonOptions = drawPolygonOptions(
              shapeOptions = drawShapeOptions(
                fillColor   = "grey",
                color       = "red",
                weight      = 2.5,
                fillOpacity = 0.125,
                dashArray   = "1"
              )
            ),
            circleOptions = FALSE,
            rectangleOptions = drawRectangleOptions(
              shapeOptions = drawShapeOptions(
                fillColor   = "grey",
                color       = "red",
                weight      = 2.5,
                fillOpacity = 0.125,
                dashArray   = "1"
              )
            ),
            markerOptions = FALSE,
            circleMarkerOptions = FALSE,
            editOptions = editToolbarOptions(
              edit   = TRUE,
              remove = TRUE
            ),
            edittoolbar = edittoolbarOptions(
              actions = list(
                save = list(
                  title = "Änderungen speichern",
                  text  = "Speichern"
                ),
                cancel = list(
                  title = "Bearbeitung abbrechen",
                  text  = "Abbrechen"
                ),
                clearAll = list(
                  title = "Alle Objekte löschen",
                  text  = "Alles löschen"
                )
              ),
              buttons = list(
                edit           = "Objekte bearbeiten",
                editDisabled   = "Keine Objekte zum Bearbeiten",
                remove         = "Objekte löschen",
                removeDisabled = "Keine Objekte zum Löschen"
              )
            ),
            edithandlers = edithandlersOptions(
              edit = list(
                tooltipText    = "Objekt editieren: Fläche oder einzelne Punkte verschieben",
                tooltipSubtext = ""
              ),
              remove = list(
                tooltipText = "Klicken, um ein Objekt zu löschen"
              )
            )
          )  %>%
          addPolygons(
            data = NET_AREA,
            fillColor = 'orangered',
            color = 'white',
            weight = 1.25,
            opacity = 1,
            smoothFactor = 5,
            stroke = T,
            dashArray = '1',
            group = 'NET_AREA'
          ) %>%
          addPolygons(
            data = BFS_sel,
            fillColor = '#FFFF00',
            color = '#FFFF00',
            weight = 10,
            opacity = .5, 
            fillOpacity = 0,
            dashArray = '1',
            group = 'BFS_sel'
          ) %>%
          addPolygons(
            data = BFS_r(),
            layerId = BFS_r()$Standort,
            fillColor = '#00ff00',
            color = 'darkgrey',
            weight = 1.25,
            opacity = 1, 
            fillOpacity = .625,
            dashArray = '1',
            highlightOptions = highlightOptions(
              color = 'darkgrey',
              weight = 5,
              opacity = .125,
              sendToBack = FALSE
            ),
            group = 'Potentialflächen',
            options = pathOptions(pane = "Potentialflächen")
          )  %>%
          addPolylines(
            data = ED,
            weight = ~ (beedgecen / max(beedgecen) * 4) + 1,
            dashArray = "1",
            color = 'black',
            group = 'net_e',
            label = ~ paste(round(st_length(geometry), 0), '[m]'),
            labelOptions = labelOptions(noHide = F, direction = "top"),
            highlightOptions = highlightOptions(color = "red", weight = 10, opacity = 1, bringToFront = TRUE),
            options = pathOptions(pane = "net_e")
          ) %>%
          addCircleMarkers(
            data = NO,
            group = 'net_n',
            fillColor =  ~ pal(group),
            fillOpacity = .75,
            color =  'white',
            stroke = T,
            radius =  ~ (becen / max(becen) * 20) + 2.5,
            options = pathOptions(pane = "net_e")
          ) %>%
          addLegend(
            position = 'bottomright',
            opacity = .75,
            pal = PAL_CoRa(),
            values = c(0, maxValue(CoRa())),
            group = 'Kosten-Raster',
            bins = pretty(c(0, ceiling(maxValue(CoRa()) / 10) * 10), n = 4),
            labFormat = labelFormat(digits = 0), 
            layerId="legend_kosten"
          )  
        
        # Entfernen Objekte aus Arbeitsspeicher
        
        rm(BFS_sel, PA, BFS_SP_G, P_XY, CRA_TM, BFS_SP_LC, BFS_SP_LC_sel, net_LC_o, net_LC, NPs, NET_AREA, NO, ED)
        gc(verbose = TRUE)
        
        # Overlay-Layer MAP_3 hinzufügen >> showGroup(L) 
        
        for (L in LA){
          
          leafletProxy(map = 'MAP_3', session = session) %>%
            showGroup(L) %>%
            htmlwidgets::onRender("function(el, x, data) { this.invalidateSize(); }")
          
        }
        
        # Löst Performance-Loading MAP_3 aus - aktiviert 'showGroup(L)'
        
        MAP_3_TRIGGER(MAP_3_TRIGGER() + 1)
        
      })
      
      gc()
      
      # RUN-Button 'Netzwerkanalyse' aktivieren (MAP_3)
      
      shinyjs::enable("RUN_NET_2")
      
    }
    
  }, ignoreNULL = FALSE)
  
  # Textausgabe (UI) >> Ergebnisse der Netzwerkanalyse (MAP_3)
  
  output$text_3_1 = renderText(TXT$text_3_1) # Anzahl Netzwerke
  output$text_3_2 = renderText(TXT$text_3_2) # Flächen in Hauptnetzwerk [%]
  output$text_3_3 = renderText(TXT$text_3_3) # Fläche Hauptnetzwerk
  
}
