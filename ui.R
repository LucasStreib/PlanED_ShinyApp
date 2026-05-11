
### UI: Layout, Styles, Navigation Shiny-App + Statische Projektinhalte (Texte | Bilder)

ui = bootstrapPage(
  
  # Bootstrap-Themes („yeti“ - https://rstudio.github.io/shinythemes/)
  
  theme = shinytheme('yeti'),
  
  # Globale CSS-Definitionen
  
  tags$style(
    
    # Steuerungs-Panels (absolutePanel)
    
    '#controls {background-color: transparent; color: black; opacity: 0.75; border-color: transparent;}',
    '#NetMea {background-color: transparent; color: black; opacity: 0.75; border-color: transparent;}',
    '#controls2 {background-color: transparent; color: black; opacity: 1; border-color: transparent; border-width: 1.75px; border-radius: 5px;}',
    
    # Unterdrücken Shiny-Fehlermeldungen im UI
    
    '.shiny-output-error { visibility: hidden; }',
    '.shiny-output-error:before { visibility: hidden; }',
    
    # Globale Schriftdefinition
    
    'body {font-family: Helvetica;}',
    
    # Anpassung Leaflet-Messwerkzeug  
    
    '.leaflet-control-measure {background-size: 14px 14px; box-shadow: none; border-width: 2px; border-style: solid; border-color: #C1C1C1; }',
    '.leaflet-control-measure-toggle, .leaflet-control-measure-toggle:hover { width: 30px !important; height: 30px !important; background-size: 10px 10px !important; }',
    
    # Entfernen Datei-Upload-Fortschrittsbalkens
    
    '.shiny-file-input-progress {display: none}',
    
    # Fortschrittsbalken (z. B. bei Berechnungen)
    
    '.progress {height: 24px; background-color: white !important;  border-radius: 12px; background-color: #e0e0e0; margin-top: 100px}',
    '.progress-bar {max-width: 98% !important; background: #636363 !important; border-radius: 12px;}',
    
    # Shiny-Benachrichtigungen (zentriert, transparent)
    
    '.shiny-notification {text-align: center; background-color: transparent !important; border: none; height: 37.5px; width: 200px; position:fixed; font-weight: bold;}',
    
    # Styling Buttons & Download-Links
    
    '.input-group .form-control {display: none}',
    '.input-group-btn .btn-default {margin: 2.5%; padding: 5%; background-color: white; border-radius: 3.75px; box-shadow: none; border-width: 2px; border-style: solid; border-color: white; }',
    '.panel .shiny-download-link {margin: 2.5%; padding: 5%; background-color: white; border-radius: 3.75px; box-shadow: none; border-width: 2px; border-style: solid; border-color: white; }',
    
    # Tabellen in Leaflet-Popups
    
    HTML("
      .leafpop-table {width: 100%; border-collapse: collapse;}
      .leafpop-table td {text-align: right; padding: 1px; border: 0px solid #ccc;}
      .leafpop-table th {text-align: left; padding: 1px; border: 0px solid #ccc;}
         "),
    
    # Leaflet-Popup-Design
    
    HTML("
      .leaflet-popup-content-wrapper {border-radius: 0 !important;box-shadow: none !important; border: 0px solid #333; opacity: 0.875 !important;}
      .leaflet-popup-tip {display: none !important; opacity: 0.875 !important;}
         "),
    
    # BS-TooTip-Design
    
    HTML("
      .tooltip > .tooltip-inner {width: 100px; color: black; background-color: white;}
      .tooltip .tooltip-arrow { display: none !important;}
         "),
    
    # Reaktive BS-TooTips
    
    HTML('
      shinyBS.addTooltip = function(id, type, opts) {
        var $id = shinyBS.getTooltipTarget(id);
        if(type == "tooltip") {$id.tooltip("destroy");setTimeout(function() { $id.tooltip(opts); }, 100);}
        }
        '),
    
  ),
  
  

  
  # Styles Navigation & Tabs
  
  tags$head(
    tags$style(
      HTML("
        .navbar-nav {overflow-x: auto; white-space: nowrap; flex-wrap: nowrap;}
        .navbar-nav > li {float: none; display: inline-block;}
        .navbar-nav::-webkit-scrollbar {height: 8px;  /* Höhe der horizontalen Scrollbar */}
        .navbar-nav::-webkit-scrollbar-track {background: #333333;}
        .navbar-nav::-webkit-scrollbar-thumb {background-color: #505050;}
        .tabset-panel .nav-tabs > li > a,
        .nav-tabs > li > a {font-size: 14px !important; color: grey !important; padding: 5px 10px !important;}
        .nav-tabs {display: flex; justify-content: center;}
           ")
    )
  ),
  
  # Zentrierung Shiny-Notifications über Leaflet-Karten für Sidebar-Fnkt.
  
  tags$script(
    HTML("
     const observer = new MutationObserver(function(mutations) {
      document.querySelectorAll('.shiny-notification').forEach(function(el) {
      var map = document.getElementById('MAP_3');
      if (!map) return;
      var rect = map.getBoundingClientRect();
      el.style.left = (rect.left + rect.width/2 - el.offsetWidth/2) + 'px';
      el.style.top  = (rect.top + rect.height/2-37.5 - el.offsetHeight/2) + 'px';
      el.style.position = 'fixed';
    });
  });
  observer.observe(document.body, { childList: true, subtree: true });
    ")
    ),
  
  # Abstand Top für fixed Navbar 
  
  tags$style(type="text/css", "body {padding-top: 60px;}"),
  
  # Leaflet-Control-Tooltips in Deutsch
  
  tags$head(
    tags$script(HTML("
      var leafletOutputs = ['MAP_3', 'MAP_1', 'MAP_2'];

      function setGermanControls(mapId) {
       var attempts = 0;
       var maxAttempts = 40;

       var interval = setInterval(function() {
        attempts++;

        var mapDiv = document.getElementById(mapId);
        if (!mapDiv) return;

        // Zoom
        var zoomIn  = mapDiv.querySelector('.leaflet-control-zoom-in');
        var zoomOut = mapDiv.querySelector('.leaflet-control-zoom-out');
        if (zoomIn)  zoomIn.title  = 'Hineinzoomen';
        if (zoomOut) zoomOut.title = 'Herauszoomen';

        // RESET VIEW (addResetMapButton = easyButton → class: .easy-button-button)
        var resetBtn = mapDiv.querySelector('.easy-button-button');
        if (resetBtn) {
          resetBtn.title = 'Ansicht zurücksetzen';
          console.log('Reset-Button übersetzt!');
          clearInterval(interval);
        }

        if (attempts >= maxAttempts) {
          clearInterval(interval);
        }

      }, 50);
    }

    $(document).on('shiny:value', function(event) {
      var id = event.target.id;
      if (leafletOutputs.includes(id)) {
        setGermanControls(id);
      }
      
    });
  "))
  ),
  
  # Sidebar-Layout >> Scrollbar lange Inhalte
  
  tags$head(
    tags$style(
      HTML(".scrollable-sidebar {height: 90vh;  /* 90% of viewport height */ overflow-y: auto;}")
    )
  ),
  
  ### Navbar 'Hauptnavigation' (https://shiny.posit.co/r/reference/shiny/0.13.2/navbarpage.html)
  
  navbarPage(id = "panels", 'PlanED',
             
             position = "fixed-top",
             
             # JavaScript Funktionen in Shiny aktivieren
             
             shinyjs::useShinyjs(),
             
             ### Projektvorstellung
             
             tabPanel('1. Start',
                      
                      ## Zentrales HTML-Element (<div>) >> zentrierte Darstellung, Textbreite für bessere Lesbarkeit, Blocksatz für längere Fließtexte
                      
                      tags$div(style = "text-align: justify; margin:0 auto; max-width:875px; line-height: 1.5;",
                               
                               # Haupttitel 
                               
                               tags$h1('PlanED', style = 'text-align: center; font-weight: bold;  font-size: 66px;  line-height: 1.5;'), 
                               
                               # Link offizielle DBU-Projektseite
                               
                               tags$h4('Entwicklung und Anwendung digitaler Planungswerkzeuge für ökologische Aufwertungsmaßnahmen von Eh da-Flächen auf Landschaftsebene am Beispiel einer Modellregion', style = 'font-weight: bold; line-height: 1.5;'), 
                               tags$a(href='https://www.dbu.de/projektdatenbank/38150-01/', target = '_blank', rel = 'noopnener', 'Projekt 38150-01'), 
                               tags$br(),
                               tags$br(),
                               tags$hr(),
                               
                               # Logos Projektpartner mit Links
                               
                               tags$figure(style = 'text-align: center;', 
                                           tags$a(href='https://www.dbu.de/projektdatenbank/38150-01/', target = '_blank', tags$img(src = 'dbu.png', width = 'auto', height = '100px')), 
                                           HTML('&nbsp;&nbsp;&nbsp;'), 
                                           tags$a(href='http://www.eh-da-flaechen.de', target = '_blank', rel = 'noopnener', rel = 'noopnener', tags$img(src = 'ehda.png', width = 'auto', height = '100px')), 
                                           HTML('&nbsp;&nbsp;&nbsp;'), 
                                           tags$a(href='https://www.neu-ulrichstein.de', target = '_blank', rel = 'noopnener', tags$img(src = 'fnu.png', width = 'auto', height = '75px')),
                                           HTML('&nbsp;&nbsp;&nbsp;'), 
                                           tags$a(href='https://www.dlr-rnh.rlp.de/DLR-RNH/Aktuelles/Ueberblick', target = '_blank', tags$img(src = 'dlr.png', width = 'auto', height = '100px')),
                                           HTML('&nbsp;&nbsp;&nbsp;'), 
                                           tags$a(href='https://www.homberg.de', target = '_blank', rel = 'noopnener', tags$img(src = 'hom.png', width = 'auto', height = '75px')),
                                           HTML('&nbsp;&nbsp;&nbsp;'), 
                                           tags$a(href='https://www.stadt-kirtorf.de', target = '_blank', rel = 'noopnener', tags$img(src = 'kir.png', width = 'auto', height = '75px'))
                               ),
                               
                               # Text: Projektbeschreibung
                               
                               tags$hr(),
                               'Hallo und herzlich Willkommen,', 
                               tags$p(style="margin:15px;"),
                               'auf dem StoryBoard des PlanED-Projekts! Nebst diverser Hintergründe, Fortschritte sowie Tipps für ökologische Aufwertungsmaßnahmen beinhaltet diese projektbegleitende Webseite das Planungswerkzeug zur landschaftsbezogenen Aufwertung von Eh da-Flächen in der hessischen Modellregion bestehend aus der Stadt Homberg (Ohm) und der Stadt Kirtorf.',
                               tags$br(),
                               'Das Planungswerkzeug ist das zentrale Element des von der Deutschen Bundesstiftung Umwelt (DBU) von März 2023 bis März 2026 geförderten Projekts \'PlanED: Entwicklung und Anwendung digitaler Planungswerkzeuge für ökologische Aufwertungsmaßnahmen von Eh da-Flächen auf Landschaftsebene\'.',
                               tags$br(),
                               'Es wird vom Projektträger, der Technischen Zentralstelle des Dienstleistungszentrums Ländlicher Raum Rheinhessen-Nahe-Hunsrück (DLR RNH), erstellt. Bis März 2024 war die (Abteilung „Anwendungen der Digitalisierung“ der) RLP AgroScience gGmbH die Projektträgerin, die im April 2024 in das DLR RNH übergegangen ist. Zum vorliegenden StoryBoard beigetragen haben außerdem die Verbundpartner \'Forschungszentrum Neu-Ulrichstein GmbH & Co KG (FNU)\', \'Stadt Homberg (Ohm)\' sowie \'Stadt Kirtorf\'. Weiterhin unterstützt haben die assoziierten Partner \'Untere Naturschutzbehörde Vogelsbergkreis\', sowie das \'Amt für Bodenmanagement Fulda\'.',
                               tags$br(),
                               tags$hr(), 
                               
                               # Inhaltsverzeichnis StoryBoard: actionLink() für  Umschalten Tabs in App-GUI ('server'-Skript)
                               
                               tags$h3('Inhalte StoryBoard', style = 'line-height: 1.5;'), 
                               tags$p(style="margin:15px;"),
                               actionLink("L1", '1. Start'),
                               tags$br(),
                               actionLink("L2", '2. Aktuelles'),
                               tags$br(),
                               actionLink("L3", "3. Karten & Werkzeuge"),
                               tags$br(),
                               actionLink("L4", '4. Maßnahmenkatalog'),
                               tags$br(),
                               actionLink("L5", '5. Hintergrund'),
                               # tags$br(),
                               # actionLink("L6", '6. Bedienungsanleitung'),
                               # tags$br(),
                               # actionLink("L7", '7. Modellierte Ergebnisse/Simulationen/Was-wäre-wenn-Analysen'),
                               # tags$br(),
                               # actionLink("L8", '8. Maßnahmenkatalog'),
                               tags$br(),
                               actionLink("L9", 'Impressum & Datenschutzinformation'),
                               tags$br(),
                               tags$hr(),
                               
                               # Text: Fachlicher Hintergrund
                               
                               tags$h3('Einführung', style = 'line-height: 1.5;'), 
                               tags$p(style="margin:15px;"),
                               'Vor dem Hintergrund des nachgewiesenen Rückgangs von Insekten in Deutschland sind Konzepte im Rahmen des Insektenschutzes gefragt, die „verfügbare Flächen“ als notwendige Ressource identifizieren und diese effizient und an die Bedürfnisse der Insekten angepasst aufwerten (vgl. KÜNAST 2023). Eh da-Flächen stellen als wirtschaftlich und naturschutzfachlich ungenutzte Fläche ein solches Flächenpotenzial dar (vgl. DEUBERT et al. 2016). Diese Flächen sind i.d.R. in öffentlicher Hand und können auf Grundlage amtlicher Geodaten für Kommunen erfasst und in Relation zu anderen Flächenkategorien gesetzt werden. Mit Blick auf die räumliche Verteilung und Vernetzung der Flächen kann der Bezug zur Landschaft hergestellt werden. Die Bewertung der Flächen hinsichtlich ihrer Bedeutung für die (Biotop-)Vernetzung wird mit unterschiedlichen Paketen für die Programmiersprache R realisiert, wie zum Beispiel dem gdistance-Packet, das Funktionen bereitstellt, um Distanzmaße und Routen zu berechnen.',
                               tags$br(),
                               tags$br(),
                               
                               # Abbildung 'Planungstool'
                               
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = 'toolBSP.png', width = '500px', height = 'auto'))),
                               tags$h6('Einblick Planungwerkzeug bzgl. Vernetzungswirkung'),
                               tags$br(),
                               'Um spezifische und wirkungsvolle Aufwertungsmaßnahmen auf geeigneten (Eh da-)Flächen priorisieren und planen zu können, wird das Planungswerkzeug entwickelt. Dies wird in der hessischen Modellregion, beispielhaft angewandt, um interkommunale ökologische Aufwertungsmaßnahmen zur Förderung der Insektenvielfalt zu planen und steuern. Ausgewählte Maßnahmen werden beispielhaft durch die Kommunen umgesetzt und durch begleitende Drohnenbefliegungen vorher und nachher dokumentiert und bewertet. Das Planungswerkzeug wird so konzipiert, dass es nicht nur Experten wie Kommunalbedienstete – die häufig keine freien Ressourcen für zusätzliche Aufgaben haben – sondern auch nicht-fachspezifische Akteure nutzen können. Es wird mit Open-Source-Software entwickelt und der Quellcode nach Abschluss veröffentlicht, um nach Projektende eine Übertragung auf andere Kommunen zu ermöglichen. Die Ausgaben bzw. Ergebnisdaten des Planungswerkzeugs können in gängigen Datenformaten exportiert werden, wodurch die Konnektivität zu anderen Geodatenplattformen oder Datenbanken (z.B. von Naturschutz- oder Landwirtschaftsbehörden) gegeben ist.',
                               tags$br(),
                               tags$br(),
                               
                               # Abbildung 'Drohnenbefliegung'
                               
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = 'uav.png', width = '375px', height = 'auto'))),
                               tags$h6('Drohnenbefliegung der aufgewerteten Eh da-Fläche am Schulzentrum Homberg am 01.10.2025'),
                               tags$br(),
                               'Durch integrative Workshops wird in der Modellregion projektbegleitend ein Netzwerk diverser Akteure (darunter gezielt auch Landwirte:innen, Naturschützende und Schulen) geschaffen und etabliert. Dies gelingt durch Öffentlichkeitsarbeit und transparente Information (z.B. via Zeitungsartikel, Veranstaltungen, Webseite, Infotafeln), denn ein gesellschaftliche Akzeptanz zum Thema Insektenvielfalt und Aufwertungsmaßnahmen ist für die Weiterführung (u.a. der insektenfreundlichen Flächenpflege) unerlässlich.',
                               tags$br(),
                               tags$hr(), 
                               
                               # Kontaktinformationen >> Projektleitung, Verbundpartner & Fördermittelgeber
                               
                               tags$h3('Kontakt', style = 'line-height: 1.5;'), 
                               tags$p(style="margin:25px;"),
                               tags$p('Dr. Lucas Streib', style = 'font-weight: bold;'),
                               tags$p(style="margin:2.5px;"),
                               'Dienstleistungszentrum Ländlicher Raum Rheinhessen-Nahe-Hunsrück – DLR RNH – Technische Zentralstelle', 
                               tags$p(style="margin:2.5px;"),
                               tags$a(href='mailto:Lucas.Streib@dlr.rlp.de', target = '_blank', rel = 'noopnener', fa("envelope", fill = "dodgerblue")), tags$span(style = 'color: dodgerblue; font-style: italic;', 'Lucas.Streib@dlr.rlp.de'),
                               tags$br(),
                               tags$p(style="margin:25px;"),
                               tags$p('Prof. Dr. Peter Ebke', style = 'font-weight: bold;'),
                               tags$p(style="margin:2.5px;"),
                               'Forschungszentrum Neu-Ulrichstein - FNU',
                               tags$p(style="margin:2.5px;"),
                               tags$a(href='mailto:Ebke@mesocosm.de', target = '_blank', rel = 'noopnener', fa("envelope", fill = "dodgerblue")), tags$span(style = 'color: dodgerblue; font-style: italic;', 'Ebke@mesocosm.de'), 
                               tags$br(),
                               tags$p(style="margin:25px;"),
                               tags$p('Dr. Steffen Walther', style = 'font-weight: bold;'),  
                               tags$p(style="margin:2.5px;"),
                               'Deutsche Bundesstiftung Umwelt - DBU',
                               tags$p(style="margin:2.5px;"),
                               tags$a(href='mailto:S.Walther@dbu.de', target = '_blank', rel = 'noopnener', fa("envelope", fill = "dodgerblue")), tags$span(style = 'color: dodgerblue; font-style: italic;', 'S.Walther@dbu.de'), 
                               tags$br(),
                               tags$hr(),
                               'Letzte Änderung:', format(Sys.Date(), format = "%d.%m.%Y"),
                               tags$hr(),
                               
                      )
             ),
             
             ### Chronologische Dokumentation Projektentwicklung
             
             tabPanel('2. Aktuelles',
                      
                      ## Zentrales HTML-Element (<div>) >> zentrierte Darstellung, Textbreite für bessere Lesbarkeit, Blocksatz für längere Fließtexte
                      
                      tags$div(style = "text-align: justify; margin:0 auto; max-width:875px;",
                               
                               # Überschrift & Kurzbeschreibung
                               
                               tags$h3('Aktuelles'),
                               tags$h6('Hier werden ausgewählte Entwicklungsschritte des vom 28.03.2023 bis 27.03.2026 laufenden Projekts dokumentiert.'),     
                               tags$hr(),  
                               
                               # redaktionelle Inhalte >> Datum + Überschrift / Ereignis + Beschreibungstext +optionale Medien (Bilder, Links, iFrames)
                               
                               
                               tags$h5('14.04.2026'),
                               tags$h4('Projektabschluss'),
                               'Das offizielle Projektende ist auf den 27. März 2026 datiert. Wegen abgestimmter Verzögerungen kann der Abschlussworkshop erst am 14. April durchgeführt werden. Am Vortag werden ausgewählte aufgewertete Eh da-Flächen abschließend per Drohne beflogen, um Vorher-Nachher-Vergleiche anstellen und dokumentierendes Bild- (und Video-)material zusammentragen zu können. Die jeweiligen Erkenntnisse dieser beiden beschließenden Parts sollen dem ausstehenden Abschlussbericht nicht vorenthalten bleiben. Die Fertigstellung des Berichts ist für Juni geplant. Außerdem sind Publikationen geplant, um die wesentlichen Ergebnisse weiter nutzen zu können.',       
                               tags$hr(),
                               tags$h5('02.03.2026'),
                               tags$h4('Bewerbung von Eh da-Flächen von der DBU'),
                               'Über mehrere Kanäle weist die Deutschen Bundesstiftung Umwelt (DBU) auf die Bedeutung von Eh da-Flächen hin.',
                               br(),
                               'Der monatlichen Newsletter der DBU aus dem Februar 2026 enthält den Titel „Mehr Raum für Insekten: Ökologische Aufwertung von „Eh da-Flächen“:',
                               tags$a(href='https://www.dbu.de/newsletter/dbuaktuell-februar-2026/mehr-raum-fuer-insekten-oekologische-aufwertung-von-eh-da-flaechen/', rel = 'noopnener', 'https://www.dbu.de/newsletter/dbuaktuell-februar-2026/mehr-raum-fuer-insekten-oekologische-aufwertung-von-eh-da-flaechen/'),    
                               br(),
                               'Über ihren Kanal auf der Social-Media-Plattform „X“ teilt die DBU dies:',
                               tags$a(href='https://x.com/umweltstiftung/status/2028422688868343833', rel = 'noopnener', 'https://x.com/umweltstiftung/status/2028422688868343833'),                                 
                               br(),
                               'Und über den Facebookkanal teilt die DBU das:',
                               tags$a(href='https://www.facebook.com/DeutscheBundesstiftungUmwelt/photos/stell-dir-einen-spaziergang-%C3%BCber-eine-bunte-wiese-vor-summende-insekten-bl%C3%BChende/1370044518500721/', rel = 'noopnener', 'https://www.facebook.com/DeutscheBundesstiftungUmwelt/photos/stell-dir-einen-spaziergang-%C3%BCber-eine-bunte-wiese-vor-summende-insekten-bl%C3%BChende/1370044518500721/'),  
                               tags$hr(), 
                               tags$h5('03.02.2026'),
                               tags$h4('Update Planungswerkzeug'),
                               'Die Neuerungen dienen vor allem der Benutzerfreundlichkeit des Planungswerkzeugs unter „3. Karten & Werkzeuge“ und dem neu geschaffenen Reiter „4. Maßnahmenkatalog“. Unter 3. wurden die erläuternden Texte vereinfacht und ergänzt sowie erklärende Beschriftungen und Popups eingefügt. Der 4. Reiter mit flächenbezogenen Aufwertungsmaßahmen zur Förderung der Artenvielfalt wurde in Form einer sortier- und downloadbaren Tabelle inkl. Beispielfotos und Bezugsquellen integriert.',       
                               tags$hr(), 
                               tags$h5('02.02.2026'),
                               tags$h4('Eh da-Flächen als ein Baustein der DBU-Förderinitiative „Digital.Natur.Landschaft“'),
                               'In der Förderinitiative „Digital.Natur.Landschaft“ der Deutschen Bundesstiftung Umwelt (DBU) wird die „Ökologische Aufwertung von Eh da-Flächen“ als ein thematisch passendes Projektbeispiel angeführt:',
                               tags$a(href='https://www.dbu.de/themen/foerderinitiativen/digital-natur-landschaft/', rel = 'noopnener', 'https://www.dbu.de/themen/foerderinitiativen/digital-natur-landschaft/'),        
                               tags$hr(), 
                               tags$h5('13.01.2026'),
                               tags$h4('Simulation von Szenarien'),
                               'Einsatz des Kosten-Distanz-Planungswerkzeugs zur Simulation verschiedener Szenarien – einschließlich ihrer Kombinationen – und deren Auswirkungen auf die betrachteten Netzwerkindizes. Dabei wurden Landschaftsveränderungen, variierende Barrierewirkungen des Verkehrs, unterschiedliche Kostenbudgets sowie verschiedene Auswahlen von Potentialflächen simuliert und analysiert. Ziel ist es, Effekte von Veränderungen im landschaftlichen Kontext zu quantifizieren und so deren Bedeutung für die ökologische Vernetzung zu bestimmen. Die Ergebnisse werden im Abschlussbericht sowie in geplanten Publikationen ausführlich dargestellt.',       
                               tags$hr(), 
                               
                               tags$h5('15.10.2025'),
                               tags$h4('Generalupdate PlanED-Webportal'),
                               'Mit einem umfassenden Update der projektbegleitenden Webseite wurden sämtliche Inhalte überabeitet und v.a. die enthaltene Planungsplattform um zahlreiche Funktionen ergänzt. So können nun u.a. Editierungen vorgenommen und deren Auswirkungen auf den Landschaftsverbund quasi live berechnet werden. Beispiele hierfür sind das Einzeichnen von Barrieren oder das Ändern der „Qualität“ vorhandener Trittsteinflächen wie Eh da-Flächen.',       
                               tags$hr(),  
                               tags$h5('01.10.2025'),
                               tags$h4('Dritte Drohnenbefliegung & Flächenbegehung'),
                               'Mit der dritten und vorerst letzten Drohnenbefliegung und damit verbundenen Flächenbegehungen wurden die Entwicklungen der umgesetzten Maßnahmen auf den ausgewählten Eh da-Flächen in der Modellregion (Homberg (Ohm) & Kirtorf) dokumentiert. Bei bestem Flugwetter wurden viele gelungene und auch weniger gelungene Maßnahmen erfasst. Besonders erfreulich waren die noch in voller Blüte stehenden Blühsaatflächen, z.B. an der Ohmtalschule.',
                               tags$br(), 
                               tags$br(), 
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = 'Picture1.png', width = '375px', height = 'auto'))),
                               tags$h6('Beflogene Blühsaatfläche bei der Ohmtalschule. Foto: M.Deubert, 01.10.2025'),
                               tags$hr(), 
                               tags$h5('29.09.2025'),
                               tags$h4('Aktionstag an der Grundschule Kirtorf'),
                               'Der Schulleiter der Grundschule Kirtorf hat alle Schülerinnen und Schüler auf der Eh da-Fläche vor der Schule versammelt, um vom Biologen Prof. Dr. Peter Ebke (FNU) die örtlichen Aufwertungsmaßnahmen zur Förderung der Artenvielfalt veranschaulicht und erläutert zu bekommen. Dabei wurden regional gesammelte Samen der Wilden Möhre auf eine vorbereitete Fläche ausgesät und weitere „Owwerhessische Dubbe“ markiert.',
                               tags$br(), 
                               tags$br(), 
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = 'Picture2.png', width = '375px', height = 'auto'))),
                               tags$h6('Aussaatfläche für Wilde Möhre. Foto: M.Deubert, 01.10.2025'),
                               tags$hr(), 
                               tags$h5('15.09.2025'),
                               tags$h4('Zeitungsartikel über Staudenpflanzung & „Owwerhessische Dubbe“'),
                               'Die Alsfelder Allgemeine titelte mit ',                                                 
                               tags$a(href='https://www.giessener-allgemeine.de/vogelsbergkreis/homberg-ort848784/stauden-an-der-schule-gesetzt-93937026.html', target = '_blank', rel = 'noopnener', 'Stauden an der Schule gesetzt'), 
                               ', Oberhessen-live mit ',      
                               tags$a(href='https://www.oberhessen-live.de/2025/09/16/gemeinsame-pflanzaktionen-im-rahmen-der-eh-da-flaechen-ein-schritt-fuer-ein-grueneres-morgen/', target = '_blank', rel = 'noopnener', 'Ein Schritt für ein grüneres Morgen'), 
                               '. Neben den Pflanzaktionen waren auch die sogenannten „Owwerhessische Dubbe“ zentrale Inhalte, die durch „Stempel“ bzw. Holzstangen kleine Teilbereiche (einer Eh da-Fläche) sichtbar markieren, welche zur Förderung der Artenvielfalt nicht gemäht werden sollen. Die Dubbe können auch im Privaten umgesetzt und die „Stempel“ über die Kommune angefragt werden.',
                               tags$br(), 
                               tags$br(), 
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = 'Picture3.png', width = '375px', height = 'auto'))),
                               tags$h6('Markierung eines „Owwerhessische Dubbe“ durch „Dubbestempel“. Foto: M.Deubert, 01.10.2025'),
                               tags$hr(), 
                               tags$h5('14.07.2025'),
                               tags$h4('Zeitungsartikel über Workshop'),
                               'Mehrere Artikel über den 3. Workshop wurden von regionalen Zeitungen verfasst. Die Alsfelder Allgemeine titelte mit ',                                                 
                               tags$a(href='https://www.giessener-allgemeine.de/vogelsbergkreis/homberg-ort848784/initialtreffen-fuer-die-modellregion-93834235.html', target = '_blank', rel = 'noopnener', 'Initialtreffen für die Modellregion'), 
                               ', die Oberhessische Zeitung mit ',      
                               tags$a(href='https://www.oberhessische-zeitung.de/vogelsbergkreis/homberg/bluehende-zukunft-fuer-ungenutzte-flaechen-93837784.html', target = '_blank', rel = 'noopnener', 'Blühende Zukunft für ungenutzte Flächen'), 
                               '.',
                               tags$hr(), 
                               tags$h5('24.06.2025'),
                               tags$h4('3. Workshop in Neu-Ulrichstein'),
                               'Am vor Ort in der Modellregion ansässigen FNU fand auch der 3. Projektworkshop statt. Rund 20 Interessierte, darunter unmittelbar beteiligte Akteure sowie Vertretende örtlicher Vereine, informierten sich und diskutierten über die Projektfortschritte. Ein Schwerpunkt war das Abstimmen künftiger Aktivitäten und Beteiligungsmöglichkeiten sowie die Entwicklungen rund um die Maßnahmenumsetzungen auf den ausgewählten Eh da-Flächen. Über letzteres hatten die zuständigen Personen beider Städte, die Klimaschutzmanagerin Fr. Rüger (Homberg) und der Bauhofleiter Hr. Fröhlich (Kirtorf) vorgetragen.',
                               tags$hr(),       
                               tags$h5('28.05.2025'),
                               tags$h4('Weitere Maßnahmenumsetzungen'),
                               'Vor Ausbringung der regiozertifizierten Blühsaatmischungen wurden in Homberg (Ohm) zahlreiche der ausgewählten Eh da-Flächen durch den Bauhof bzw. einen Schmalspurschlepper vorbereitet, darunter die Flächen „Speedway“, „Nieder-Ofleiden“ und „Vier Linden“ (vgl. „2. Übersichtskarte“ und „5. Planungswerkzeug“ auf der Projektwebseite):',                                                 tags$a(href='https://geobox-i.de/planed.info/', target = '_blank', rel = 'noopnener', 'https://geobox-i.de/planed.info/'),     
                               tags$hr(), 
                               tags$h5('22.05.2025'),
                               tags$h4('Pflanzaktion bei der Homberger Ohmtalschule & Kita'),
                               'Ein weiterer Teil der mit den Fördermitteln des RPGI beschafften regiozertifizierten insektenfreundlichen Wildstauden und biozertifizierten insektenfreundlichen Gehölzpflanzen wurde von zahlreichen Helfenden, darunter auch Schüler:innen, auf Eh da-Flächen der Ohmtalschule gepflanzt.',
                               tags$br(), 
                               tags$br(), 
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = 'Picture5.png', width = '375px', height = 'auto'))),
                               tags$h6('Helfer:Innen bei der Pflanzaktion an der Ohmtalschule. Foto: A.Rüger, 22.05.2025'),
                               tags$hr(), 
                               tags$h5('11.05.2025'),
                               tags$h4('Ankündigung 3. Workshop am 24.06.2025'),
                               'Am vor Ort in der Modellregion ansässigen Kooperationspartner „Forschungszentrum Neu-Ulrichstein“ findet am 24.06.2025 der nächste und damit 3. Workshop statt. Interessierte können ihr Kommen gerne per Email an',
                               tags$a(href='mailto:Ute.Schneider@neu-ulrichstein.de', target = '_blank', rel = 'noopnener', fa("envelope", fill = "dodgerblue")), tags$span(style = 'color: dodgerblue; font-style: italic;', ' Ute.Schneider@neu-ulrichstein.de'),
                               'anmelden. Inhalte sind Ergebnisse des vergangenen Jahres bzw. der Projektstand sowie künftige gemeinsame Aktivitäten und Beteiligungsmöglichkeiten.',
                               tags$hr(), 
                               tags$h5('30.04.2025'),
                               tags$h4('Zeitungsartikel über Treffen mit Bau- & Umweltausschuss'),
                               'Am FNU erläuterte Prof. Dr. Peter Ebke den Mitgliedern des Bau- und Umweltausschusses das Konzept der Eh da-Flächen bzw. die Projektinhalte von „PlanED“, darunter die Bürgermeisterin, Klimaschutzmanagerin sowie Ortsvorsteher:innen. Darüber berichtet die Alsfelder Allgemeine in folgendem Artikel:',
                               tags$a(href='https://www.giessener-allgemeine.de/vogelsbergkreis/homberg-ort848784/blueten-fuer-schmetterlinge-93709129.html', target = '_blank', rel = 'noopnener', 'https://www.giessener-allgemeine.de/vogelsbergkreis/homberg-ort848784/blueten-fuer-schmetterlinge-93709129.html'),        
                               tags$hr(), 
                               tags$h5('01.04.2025'),
                               tags$h4('Beginn Aussaat Blühsaatmischungen'),
                               'Der Beginn der Vegetationsperiode ist ein geeigneter Zeitpunkt für die Aussaat von Blühmischungen. Insgesamt wurden, spezifische abgestimmt auf die ausgewählten Standorte, 8 regiozertifizierte Blühsaatmischungen ausgewählt, die nach Herstellerangaben mehrjährige Standzeiten (ca. 5 Jahre) haben. Die beiden Bauhöfe führen das Aussäen in Abstimmung nach und nach durch. Sämtliche Maßnahmen, sowie auch die Blühsaatflächen, werden nach und nach in der projektbegleitenden Webseite (2. Übersichtskarte und 5. Planungswerkzeug) hinterlegt und damit einsehbar gemacht ',
                               tags$a(href='https://geobox-i.de/planed.info/', target = '_blank', rel = 'noopnener', 'https://geobox-i.de/planed.info/'),            
                               tags$hr(), 
                               tags$h5('27.03.2025'),
                               tags$h4('Zwischenbericht'),
                               'Pünktlich zum Stichtag wurde ein umfassender Zwischenbericht zur Dokumentation der Projektarbeiten beim Fördermittelgeber, der Deutschen Bundesstiftung Umwelt (DBU), vorgelegt. Die wesentlichsten Ergebnisse werden beim kommenden 3. Workshop vorgestellt.',
                               tags$hr(), 
                               tags$h5('24.02.2025'),
                               tags$h4('Zeitungsartikel mit „owwerhessische Dubbe“'),
                               'Die Alsfelder Allgemeine (Vogelsbergkreis) veröffentlichte einen Artikel basierend auf dem Pressebericht von Mitte des Monats, in dem die schonende Flächenpflege v.a. durch intelligente Mahd von „Dubbe“ im Fokus steht:',
                               tags$a(href='https://www.giessener-allgemeine.de/vogelsbergkreis/homberg-ort848784/projekt-fuer-mehr-artenvielfalt-93592105.html', 'https://www.giessener-allgemeine.de/vogelsbergkreis/homberg-ort848784/projekt-fuer-mehr-artenvielfalt-93592105.html'),                       
                               tags$hr(), 
                               tags$h5('19.12.2024'),
                               tags$h4('Kostenneutrale Verlängerung'),
                               'Der Fördermittelgeber, die Deutsche Bundesstiftung Umwelt (DBU), hat dem Antrag auf kostenneutrale Projektverlängerung um 1 Jahr zugestimmt. Damit können die anstehenden Arbeitsschritte nun bis zum 27.03.2026 vollumfänglich umgesetzt und erweitert werden. Dadurch wird eine positive motivierende Wirkung für alle bereits involvierten Akteur*innen und die Region erwartet.',
                               tags$hr(), 
                               tags$h5('01.12.2024'),
                               tags$h4('Infotafeln für ausgewählte Eh da-Flächen'),
                               'In Homberg (Ohm) und Kirtorf werden je 3 Infotafeln zur transparenten Erläuterung von Aufwertungsmaßnahmen auf Eh da-Flächen aufgestellt, die ebenfalls vom Regierungspräsidium Gießen gefördert werden. Deren Inhalte wurden einerseits mit allen Projektpartnern abgestimmt und andererseits fachlich von der oberen Naturschutzbehörde geprüft. Anfang 2025 werden sie auf den 6 Flächen (vgl. Reiter „2. Übersichtskarte“) aufgestellt.',
                               tags$hr(), 
                               tags$h5('26.11.2024'),
                               tags$h4('Pflanzaktionen in Homberg'),
                               'Durch die Fördermittel des RPGI wurden für Stadt Homberg (Ohm) mit ihren 14 Stadtbezirken und insg. knapp 7500 Einwohnenden 208 regiozertifizierte insektenfreundliche Wildstauden und 35 biozertifizierte insektenfreundliche Gehölzpflanzen beschafft und mit der Pflanzaktion am alten Bahnhof beginnend auf den 14 dafür ausgewählten Eh da-Flächen gepflanzt. Unter den zahlreichen Helfenden war wie auf dem Foto zu sehen auch ein Pflanzteam der Ohmtalschule.',
                               tags$br(), 
                               tags$br(), 
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = '20241126_PE.jpg', width = '375px', height = 'auto'))),
                               tags$h6('Gehölz- und Staudenpflanzung auf der innerstädtischen Eh da-Fläche beim alten Bahnhof Homberg, Foto: 26.11.2024, P.Ebke'),
                               tags$hr(), 
                               tags$h5('25.11.2024'),
                               tags$h4('Pflanzaktionen in Kirtorf'),
                               'Durch die Fördermittel des RPGI wurden für Stadt Kirtorf mit ihren 7 Stadtteilen und insg. knapp 3100 Einwohnenden 120 regiozertifizierte insektenfreundliche Wildstauden und 22 biozertifizierte insektenfreundliche Gehölzpflanzen beschafft und auf den 11 dafür ausgewählten Eh da-Flächen gepflanzt. Insbesondere der städtische Bauhof führte diese Stauden- und Gehölzpflanzungen noch rechtzeitig vor dem Frost durch, während für die noch ausstehenden Aussaaten zertifizierter Saatgutmischungen geeignetere Keimbedingungen innerhalb der kommenden Vegetationsperiode abgewartet werden.',
                               tags$br(), 
                               tags$br(), 
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = '20241128_HF.png', width = '375px', height = 'auto'))),
                               tags$h6('Gehölz- und Staudenpflanzung auf einer wegbegleitenden Eh da-Fläche bei Ober-Gleen, Foto: 28.11.2024, H.Fröhlich'),
                               tags$hr(), 
                               tags$h5('13.11.2024'),
                               tags$h4('Pflanzmaterial eingetroffen'),
                               'Endlich sind die lang erwarteten und vom Regierungspräsidium Gießen geförderten Pflanzen vor Ort am FNU in Homberg (Ohm) eingetroffen. Dies sind 8 unterschiedliche regiozertifizierte Saatmischungen, 328 regiozertifizierte Wildstauden und 57 bio-zertifizierte Wildgehölze, die diverse Blühspektren und Blühzeiträume abdecken und dadurch besonders zur Förderung der Insektenvielfalt beitragen. Die robusten Wildstauden und -gehölze werden noch vor dem Frost Ende 2024 ausgepflanzt, während für die Saatmischungen bessere Keimbedingungen in der kommenden Vegetationsperiode abgewartet werden.',
                               tags$br(), 
                               tags$br(), 
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = '20241015_PE.jpg', width = '250px', height = 'auto'))),
                               tags$h6('Erfolgte Wildstaudenlieferung, Foto: 15.10.2024, P.Ebke'),
                               tags$hr(),
                               tags$h5('01.11.2024'),
                               tags$h4('Erweiterungen & Update Planungsplattform'),
                               'Auf der projektbegleitenden Webseite unter',
                               tags$a(href='https://geoservice.service24.rlp.de/planed.info/ ', 'https://geoservice.service24.rlp.de/planed.info/'), 
                               'sind unter dem Reiter „5.2 Planungswerkzeug CD“ umfangreiche Erweiterungen freigeschaltet worden. Nun wird je nach Bedeutung einer Fläche für das jeweils ausgewählte Netzwerk die Fläche bzw. der Netzwerkknoten unterschiedlich gefärbt und groß dargestellt. Neben der optischen Darstellung wurden die zur Bewertung des Netzwerks ausgegebenen Maßzahlen optimiert: Jetzt sind es die drei Indices „Anzahl von Netzwerken“, „Anteil von Flächen innerhalb des Hauptnetzwerks“ und „Flächengröße des Hauptnetzwerks“. Weitere Erweiterungen, wie das selbständige Editieren (Hinzufügen, Ändern & Löschen) von (Netzwerk-)Flächen, sind in Umsetzung.',
                               tags$hr(), 
                               tags$h5('22.10.2024'),
                               tags$h4('Zweiter Workshop'),
                               'Der zweite Workshop ist in zwei Schwerpunkte gegliedert: Zum einen wird digital das Planungswerkzeug vorgeführt, zum anderen umgesetzte Maßnahmen vor Ort begangen. Darüber hinaus wurde ein erweiterter Personen- bzw. Institutionenkreis eingeladen, um noch besser lokale und regionale Akteure (v.a. Vertreter aus Kommunen, der Landwirtschaft, des Naturschutzes, von Bildungseinrichtungen) mit einzubeziehen. Abrundend referiert die Koordinatorin des Projekts „WegAS“ (s. Beitrag vom 16.04.2024) durch einen Impulsvortrag über das Schnittmengenthema „Biodiversität am Wegrand“.',
                               tags$br(), 
                               tags$br(), 
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = '20241022_MD.jpg', width = '375px', height = 'auto'))),
                               tags$h6('Workshop am FNU in Homberg (Ohm), Foto: 22.10.2024, M.Deubert'),
                               tags$hr(), 
                               tags$h5('17./18.10.2024'),
                               tags$h4('Zweite Drohnenbefliegung & Begehung'),
                               'Gegenüber der bei der ersten Drohnenbefliegung (s. 07.03.2024) und Begehung berücksichtigten Eh da-Flächen haben sich Änderungen ergeben. Einerseits mussten zu Beginn berücksichtigte Flächen aus dem Planungspool herausgenommen werden, andererseits konnten durch die Finanzierungszusage des RPGI (s. 14.08.2024) mehr Maßnahmen finanziert werden. So hat sich die Anzahl der Flächen, auf denen Maßnahmen erfolgen werden, von 16 auf derzeit 30 erhöht. Mit Ausnahme einiger weniger wegen gesetzlicher Vorgaben nicht zu befliegender Flächen wurden bzw. werden alle Maßnahmeflächen beflogen, um einen vorher/nacher-Vergleich zu dokumentieren.',
                               tags$br(), 
                               tags$br(), 
                               tags$figure(style = 'text-align: center;', tags$a(tags$img(src = '20241017_MD.jpg', width = '250px', height = 'auto'))),
                               tags$h6('Drohnenbefliegung einer Eh da-Fläche in der Agrarlandschaft bei Deckenbach, Foto: 17.10.2024, M.Deubert'),
                               tags$hr(), 
                               tags$h5('16.09.2024'),
                               tags$h4('Serverumzug & neue URL'),
                               'Das am 14.02.2024 gelaunchte projektbegleitende StoryBoard, das auch die Planungswerkzeuge beinhalten wird, wurde nun auf einen Webserver des Landesbetrieb Daten und Information Rheinland-Pfalz (LDI) umgezogen und ist ab sofort erreichbar unter:',
                               tags$a(href='https://geoservice.service24.rlp.de/planed.info/', 'https://geoservice.service24.rlp.de/planed.info/'), 
                               tags$hr(), 
                               tags$h5('14.08.2024'),
                               tags$h4('Maßnahmenplanung & -förderung'),
                               'Zur praktischen Umsetzung und visuellen Verankerung des Vorhabens in der Region werden ausgewählte Eh da-Flächen gemeinsam mit lokalen Akteuren ökologisch aufgewertet. Dazu hat das Regierungspräsidium Gießen (RPGI) eine zweigeteilte Förderzusage v.a. für regiozertifiziertes Pflanzgut und naturschutzfachlich geprüfte Infotafeln.',
                               tags$hr(), 
                               tags$h5('22.07.2024'),
                               tags$h4('Zeitungsartikel „Für artenreiche Blühwiesen“'),
                               'Der Lauterbacher Anzeiger (Vogelsbergkreis) veröffentlichte nun einen eigenen Artikel basierend auf dem Pressebericht von Anfang des Monats: ',
                               tags$a(href='https://www.lauterbacher-anzeiger.de/vogelsbergkreis/homberg/fuer-artenreiche-bluehwiesen-93201576.html', 'https://www.lauterbacher-anzeiger.de/vogelsbergkreis/homberg/fuer-artenreiche-bluehwiesen-93201576.html'), 
                               tags$hr(), 
                               tags$h5('06.07.2024'),
                               tags$h4('Pressebericht „Erste positive Zwischenbilanz“'),
                               'Prof. Dr. Peter Ebke traf sich mit Bauhofbediensteten auf Eh da-Flächen, um erste umgesetzte Maßnahmen zu begutachten und das weitere Vorgehen zu besprechen. Alle Vertreter beider Kommunen (Homberg sowie Kirtorf) zeigten sich mit dem derzeitigen Verlauf sehr zufrieden, s. resultierender Pressebericht: ',
                               tags$a(href='https://m.osthessen-news.de/n11762927/erste-positive-zwischenbilanz-vielfaltsflachen-werden-sichtbar.html', 'https://m.osthessen-news.de/n11762927/erste-positive-zwischenbilanz-vielfaltsflachen-werden-sichtbar.html'), 
                               tags$hr(),       
                               tags$h5('14. & 16.05.2024'),
                               tags$h4('Abstimmungsworkshops mit den Bauhöfen'),
                               'Mit den Bauhofleitern beider Projekt-Kommunen wurden insgesamt über 50 Eh da-Flächen bezüglich der Umsetzbarkeit von Aufwertungsmaßnahmen abgestimmt. Die 30 aus Geodatenanalysen detektierten und am 7. und 8. März beflogenen und begangenen Flächen wurden um 20 potenziell zur Aufwertung geeigneten Flächen ergänzt. Diese bieten nun auch eine breitere Ausgangsdatenbasis für die in der Entwicklung befindliche Planungsplattform, deren fertiggestellte Funktionalitäten diskutiert wurden. Es ist angestrebt mindestens 10 Eh da-Flächen je Stadt aufzuwerten.',
                               tags$hr(), 
                               tags$h5('16.04.2024'),
                               tags$h4('Bekanntmachung mit dem Projekt „WegAS“'),
                               'Mit dem ebenfalls in Hessen laufenden Vorhaben „WegAS“ bearbeitet die Justus-Liebig-Universität Giessen (JLU) das „Potential am Wegrand – Resiliente Agrarlandschaften der Zukunft“, s.',
                               tags$a(href='https://www.uni-giessen.de/de/fbz/fb09/institute/ilr/loek/forschung/aktuelle_projekte/wegas', '(https://www.uni-giessen.de/de/fbz/fb09/institute/ilr/loek/forschung/aktuelle_projekte/wegas).'), 
                               'Bei dem äußerst konstruktiven Austausch wurden die grundsätzliche Bereitschaft zur projektbezogenen Zusammenarbeit sowie die Betreuung der avisierten „PlanED-Masterarbeit“ durch eine Wissenschaftlerin der JLU abgestimmt.',
                               tags$hr(), 
                               tags$h5('01.04.2024'),
                               tags$h4('Änderungen beim Projektträger'),
                               'Die das Projekt tragende Abteilung „Anwendungen der Digitalisierung“ der RLP AgroScience wurde zum 1. April samt ihrer laufenden Projekte in die „Technische Zentralstelle“ (TZ) des Dienstleistungszentrums Ländlicher Raum Rheinhessen-Nahe-Hunsrück (DLR RNH) eingegliedert. Damit trägt die neue Abteilung „Digitalisierung der Landwirtschaft“ der TZ bei gleichbleibenden Projektbearbeiter:innen, s. Reiter „Impressum“.',
                               tags$hr(), 
                               tags$h5('27.03.2024'),
                               tags$h4('Zwischenbericht der Hälfte der Projektlaufzeit'),
                               'Zur Hälfte der Projektlaufzeit wurde ein umfassender Zwischenbericht zur Dokumentation aller durchgeführten und noch durchzuführenden Arbeiten angefertigt. Bei Bedarf kann dieser in Abstimmung mit dem Fördermittelgeber (DBU) und dem Konsortium (über den Projektträger) eingesehen werden.',
                               tags$hr(), 
                               tags$h5('11.03.2024'),
                               tags$h4('Maßnahmenplanung für ausgewählte Flächen'),
                               'Auf Grundlage der Befliegung und Begehung am 7. und 8. März wurden standortspezifische Aufwertungsmaßnahmen für die ausgewählten Eh da-Flächen geplant. Je nach Ausgangszustand der Fläche beinhalten diese eben die gezielte Förderung von Nist- und oder Nahrungsmöglichkeiten für Insekten. Die Untere Naturschutzbehörde (UNB) Vogelsbergkreis hatte vorab eine Förderung der Maßnahmen signalisiert. Erste Maßnahmenumsetzungen sind ab Sommer angestrebt.',
                               tags$hr(), 
                               tags$h5('07./08.03.2024'),
                               tags$h4('Drohnenbefliegung & Begehung ausgewählter Flächen'),
                               'In Abstimmung mit den beiden Kommunen werden im PlanED-Projekt ausgewählte Eh da-Flächen beispielhaft ökologisch aufgewertet. Zur Dokumentation des Ausgangszustands wurden sie mit einer Quadrocopter-Drohne beflogen und begangen. Dabei wurden grob vorhandene (Nist-)Strukturen sowie die Pflanzengesellschaft erfasst. Die ausgewählten Flächen sowie zugehörige Fotos werden als einzelne Layer in der Übersichtskarte hinterlegt.',
                               tags$hr(), 
                               tags$h5('29.02.2024'),
                               tags$h4('Abgabe projektbegleitender Bachelorarbeit'),
                               'Unter dem Titel „Using landscape metrics to assess the ecological significance of ehda-areas“ hat Frau Meyer zu Hörste erfolgreich ihre an der Rheinland-Pfälzischen Technischen Universität Kaiserslautern-Landau (RPTU) durchgeführte Bachelorarbeit fertiggestellt. Auf Grundlage von Geodaten wurde darin schwerpunktmäßig die ökologische Bedeutung von Eh da-Flächen im Vergleich zu anderen biodiversitätsrelevanten Flächenkategorien anhand von Landschaftsstrukturmaßen bewertet.',
                               tags$hr(), 
                               tags$h5('28.02.2024'),
                               tags$h4('Auftakttreffen für Bauhofmitarbeitende'),
                               'Zur Schulung der Bauhofmitarbeitenden und sonstigen maßnahmenumsetzenden Akteuren in der Modellregion lädt das FNU zu einem Auftakttreffen in seinen Seminarraum. Anschließend werden Begehungen von Beispielflächen durchgeführt.',
                               tags$hr(), 
                               tags$h5('14.02.2024'),
                               tags$h4('Launch des StoryBoards'),
                               'Nach langer Recherche nach einem geeigneten Server konnte endlich die erste Version des StoryBoards veröffentlicht werden. Auf selbigem Server bzw. „neben“ dem StoryBoard wird letztlich auch das zu entwickelnde Planungswerkzeug platziert. Link zum StoryBoard:',
                               tags$br(),
                               tags$a(href='http://www.planed.info', 'http://www.planed.info'), 
                               tags$hr(), 
                               tags$h5('19.12.2023'),
                               tags$h4('Jahresabschluss online'),
                               'Die Kooperationspartner treffen sich zum Resümieren zurückliegender Projektarbeiten und Planen bevorstehender Aufgaben. Mit dem ersten Projektviertel zeigen sich alle zufrieden, da sämtliche Arbeitsschritte erfolgreich umgesetzt werden konnten. Lediglich Drohnenbefliegungen mussten aus organisatorischen Gründe in das Frühjahr 2024 verschoben werden. Die dafür notwendige Auswahl zu befliegender Eh da-Flächen werden festgelegt. Als weitere wichtige nächste Schritte wurden Zeiträume für Workshops fixiert und kommende (geodatenbasierte) Analyseschritte diskutiert. Außerdem wurden erste Maßnahmenpläne für ausgewählte Flächen konzipiert, da diese im Falle einer potenziellen Fördermittelbewilligung rechtzeitig bei der zuständigen Unteren Naturschutzbehörde (UNB) Vogelsbergkreis einzureichen sind.',
                               tags$hr(), 
                               tags$h5('14.12.2023'),
                               tags$h4('Zugewinn von Hochschulabsolvierenden'),
                               'Im August 2023 hatte sich bereits eine Bachelorandin der Rheinland-Pfälzische Technische Universität Kaiserslautern-Landau (RPTU) gefunden, die schwerpunktmäßig mittels geographischer Informationssysteme (GIS) bzw. Landschaftsstrukturmaßen (LSM) die räumliche Lage von Eh da-Flächen im Vergleich zu anderen biodiversitätsrelevanten Flächenkategorien in der Modellregion analysieren wird. Nach einer Ausschreibung für Masterarbeiten an der Justus-Liebig-Universität Gießen konnte nun eine weitere Absolvierende gewonnen werden.',
                               tags$hr(),
                               tags$h5('16.11.2023'),
                               tags$h4('PlanED in Online-Projektdatenbank der DBU'),
                               'Das PlanED-Projekt ist ab sofort in der Online-Projektdatenbank der Deutschen Bundesstiftung Umwelt (DBU) eingetragen, u.a. mit Hintergründen, Zwischenergebnissen sowie weiterführenden Links:',
                               tags$br(),
                               tags$a(href='https://www.dbu.de/projektdatenbank/38150-01/', 'https://www.dbu.de/projektdatenbank/38150-01/'), 
                               tags$br(),
                               tags$br(),
                               tags$iframe(src="https://www.linkedin.com/embed/feed/update/urn:li:share:7135181205750067202", height = 250, width = '20%', frameborder=.125, allowfullscreen=""),
                               tags$hr(), 
                               tags$h5('15.11.2023'),
                               tags$h4('Öffentlichkeitsarbeit'),
                               'Im Anschluss an den 1. Workshop bediente die FNU die sog. virtuelle Redaktion, woraus drei Presseartikel (darunter in der Oberhessischen Zeitung und der Gießener Allgemeine) entstanden sind. Begleitend dazu hat die RLP AgroScience Beiträge im sozialen Netzwerk „LinkedIn“ veröffentlicht.',
                               tags$br(),
                               tags$a(href='https://www.giessener-allgemeine.de/vogelsbergkreis/homberg-ort848784/vom-wert-der-randstreifen-92692316.html', 'https://www.giessener-allgemeine.de/vogelsbergkreis/homberg-ort848784/vom-wert-der-randstreifen-92692316.html'), 
                               tags$br(),
                               tags$br(),
                               tags$iframe(src="https://www.linkedin.com/embed/feed/update/urn:li:share:7130827169315876864", height = 250, width = '20%', frameborder=.125, allowfullscreen=""),
                               tags$br(),
                               tags$hr(), 
                               tags$h5('09.10.2023'),
                               tags$h4('Entwicklungsbeginn Planungswerkzeug'),
                               'Die Entwicklung des Planungtools wurde mit Hilfe der Open Source Software „Shiny“ begonnen. Dabei wurde zunächst das zugehörige StoryBoard konzipiert, sein Layout gestaltet und erste Inhalte (v.a. Texte und interaktive Karten) geschaffen, die ab sofort projektbegleitend weitergeführt werden und in Kürze auf einen Webserver überspielt bzw. via URL veröffentlicht werden.',
                               tags$hr(), 
                               tags$h5('21.09.2023'),
                               tags$h4('1. Workshop vor Ort'),
                               'Die zentralen Akteure, darunter zahlreiche Vertretende der Kooperationspartner RLP AgroScience, FNU, Stadt Homberg (Ohm) und Stadt Kirtorf sowie der assoziierten Projektpartner UNB Vogelsbergkreis, sowie AfB Fulda trafen sich in Homberg (Ohm). Dabei wurden v.a. die spezifischen Belange der Kommunen am Projekt insgesamt bzw. dem zentralen Planungswerkzeug im Speziellen erörtert.',
                               tags$br(),
                               tags$a(href='https://data.dbu.de/api/mediakennblatt/getImg?id=1481', 'https://data.dbu.de/api/mediakennblatt/getImg?id=1481'), 
                               tags$hr(), 
                               tags$h5('31.05.2023'),
                               tags$h4('Geodatenakquise'),
                               'Nachdem über das hessische Open Data Portal',
                               tags$a(href='https://gds.hessen.de', '(https://gds.hessen.de)'), 
                               'sämtliche Geobasisdaten (v.a. Liegenschaftskataster) und über',
                               tags$a(href='https://natureg.hessen.de', '(https://natureg.hessen.de)'), 
                               'Fachdaten (v.a. Schutzgebiete und Kompensationsflächen) direkt heruntergeladen werden konnten, übermittelte Ende Mai das Amt für Bodenmanagement (AfB) Fulda die zur Erfassung von Eh da-Flächen ebenfalls benötigten hochauflösenden 4-Kanal-Luftbilder (inkl. nahem Infrarot).',
                               tags$hr(), 
                               tags$h5('02.08.2023'),
                               tags$h4('Potenzialkarte berechnet'),
                               'Auf Grundlage der akquirierten Geo(basis)daten wurden Eh da-Flächen (s. Tab „Datengrundlagen“) berechnet und für einen ersten Überblick in Form einer digitalen Karte (als JPG-Datei) lokalisiert bzw. sichtbar gemacht. Neben Eh da-Flächen enthält diese erste Potenzialkarte auch weitere biodiversitätsrelevante (Nachbar-)Flächen wie Schutzgebiete, Kompensationsflächen sowie Biotope, vgl. ',
                               tags$a(href='https://data.dbu.de/api/mediakennblatt/getImg?id=1482', 'https://data.dbu.de/api/mediakennblatt/getImg?id=1482'), 
                               tags$hr(),
                               tags$h5('15.05.2023'),
                               tags$h4('Online-Auftakttreffen'),
                               'Kennenlernen der Kooperationspartner und Abstimmung erster Schritte, darunter das Eruieren relevanter lokaler Akteure und Projekte.',
                               tags$hr()
                      ),
             ),
             
             ### Interaktive Karten & Analysewerkzeuge (Tab-Navigation)
             
             tabPanel('3. Karten & Werkzeuge', 
                      
                      ## Untergliederung Werkzeuge in 3 Sub-Tabs 
                      
                      tabsetPanel(type = "tabs",
                                  
                                  ## Sub_TAB 1 >> Darstellung Projektgebiet + Visualisierung aller relevanten Geodaten + Landschaftsklassen in (definierten) Buffer um 'Potentialflächen' + Digitalisierung / Editieren / Löschen & Import / Export (Format .gpkg) von (neuen)  'Potentialflächen' (Polygonen)
                                  
                                  tabPanel("Übersichtskarte",
                                           
                                           ## Sidebar (Erklärung & Kontext) + MainPanel (Leaflet-Karte + Funktionen)
                                           
                                           layout_sidebar(
                                             
                                             sidebar = sidebar(open="closed", fluid = TRUE, width = '20%', style = "text-align: justify; margin:0 auto; max-width:875px;", class = "scrollable-sidebar",
                                                               
                                                               div(id ="Sidebar_1", 
                                                                   
                                                                   # Beschreibung Übersichtskarte
                                                                   
                                                                   helpText(
                                                                            p("Übersichtskarte", style = "font-size:18px; font-weight: bold; text-align: center; line-height: 1.5;"),
                                                                            hr(),
                                                                            p("Die ", tags$b("Übersichtskarte"), " zeigt das", tags$b("Projektgebiet"), "sowie die im PlanED-Projekt verwendeten ", tags$b("Geodaten"),"(Polygon-Layer und WMS-Dienste; siehe ", actionLink("L5", "5. Hintergrund"), "). Die ", tags$b("Potentialflächen"), " sind kommunale Flächen der Modellregion für ökologische Aufwertungsmaßnahmen. Das Raster", tags$b("Landschaftsklassifikation"), "basiert auf NDVI und nDOM und unterscheidet fünf Landschaftsklassen.", style = "font-size:12px; line-height: 1.5;"),
                                                                            hr(),
                                                                            p("Über ", tags$b("Buffer-Distanz"), " werden entsprechend der Eingabe Pufferzonen um die ", tags$b("Potentialflächen"), " erzeugt. Die ", tags$b("Landschaftsanteile"), " innerhalb des Buffers werden automatisch berechnet und in flächenspezifischen ", tags$b("Popups"), " angezeigt.", style = "font-size:12px; line-height: 1.5;"),
                                                                            hr(),
                                                                            p("Mit dem ", tags$b("Zeichenwerkzeug"), " können ", tags$b("Potentialflächen"), " digitalisiert, editiert oder gelöscht werden. Flächen lassen sich als ", tags$b(".gpkg-Datei"), " über den ", tags$b("Download-Button"), " speichern oder über den ", tags$b("Upload-Button"),"laden.", style = "font-size:12px; line-height: 1.5;")
                                                                            ),
                                                                   
                                                                   width = 2
                                                                   
                                                               )
                                                               
                                             ),
                                             
                                             mainPanel(
                                               
                                               # Leaflet-Karte (MAP_1 definiert in 'server') mit Spinner (zeitintensive Berechungen)
                                               
                                               shinycssloaders::withSpinner(leafletOutput('MAP_1', height = '85vh'), type = 1, color = "grey"),
                                               
                                               # Buffer-Berechnung Landschaftsklassen um 'Potentialflächen'
                                               
                                               absolutePanel(id = 'controls', class = 'panel panel-default', fixed = F, draggable = T, top ='auto', bottom = '7.5vh', left = '1.25vw', right = 'auto', width = 250, height = 125, style = 'z-index: 9999;',   
                                                             
                                                             # Auswahl Buffer-Distanz
                                                             
                                                             pickerInput('I1BUF', choices=c('20 m','50 m','200 m','500 m'), options = list(`actions-box` = T, size = 5, title = 'Meter', header = 'Buffer-Distanz'), label = 'Buffer-Distanz', multiple = F, selected = NULL),
                                                             
                                                             # Start Berechnung per Button
                                                             
                                                             fluidRow(column(width = 12, align = "center",
                                                                             actionButton('RUN_BUF_1', '',   title = 'Start Berechnung', icon = icon('play'), size = 'large', style = 'background: #FFFFFF; border-color: lightgrey;'))),  
                                                             
                                               ),
                                               
                                               # Export & Import 'Potentialflächen' 
                                               
                                               absolutePanel(id = 'controls', class = 'panel panel-default', fixed = F, draggable = F, top = '40vh', bottom = 'auto', left = 'auto', right = '.5vw', width = '2.5%', height = '2.5%', style="display:table-cell; text-align: left;",
                                                             
                                                             downloadButton('download_R', '', width='0px'),
                                                             bsTooltip('download_R', 'DOWNLOAD Potentialflächen (.gpkg)'),
                                                             p(style = "margin-bottom:-20px;"),
                                                             div(
                                                               id = "upload_R_TT",
                                                               fileInput(
                                                                 'upload_R',
                                                                  '',
                                                                 buttonLabel = icon("upload"),
                                                                 placeholder = "FILE"
                                                               )
                                                             ),
                                                             bsTooltip('upload_R_TT', 
                                                                       'UPLOAD Potentialflächen (.gpkg)',
                                                                       options = list(offset = '0.20')
                                                                       ),
                                                             
                                               ),
                                               
                                               width = 12),
                                             
                                           ),
                                           
                                  ),
                                  
                                  ## SubTab 2 Netzwerkanalyse 'Euklidische Distanz'
                                  
                                  tabPanel('Luflinien Distanz',
                                           
                                           # Sidebar (Erklärung & Kontext) + MainPanel (Leaflet-Karte + Funktionen)
                                           
                                           layout_sidebar(
                                             
                                             sidebar = sidebar(open="closed", fluid = TRUE, width = '20%', style = "text-align: justify; margin:0 auto; max-width:875px;", class = "scrollable-sidebar",
                                                               
                                                               div(id ="Sidebar_2",
                                                                   
                                                                   # Text: Erklärung Methoden & Indizes
                                                                   
                                                                   helpText(
                                                                     p("Luftlinie Distanz", style = "font-size:16px; font-weight: bold; text-align: center; line-height: 1.5;"),
                                                                     hr(),     p(
                                                                       "Diese Variante des ", tags$b("PlanED-Planungswerkzeugs"), " berechnet potenzielle ", tags$b("Netzwerke"), " auf Grundlage der ausgewählten ", tags$b("Potentialflächen."), " Die Verbindung zwischen den Flächen erfolgt über ", tags$b("Luftlinien-"), " bzw. ",tags$b("euklidische Distanzen."), style = "font-size:12px; line-height: 1.5;"),
                                                                     hr(),
                                                                     p("Die Qualität des entstehenden ", tags$b("Netzwerks"), " wird mithilfe der folgenden ", tags$b("Indizes"), " bewertet:", style = "font-size:12px; line-height: 1.5;"),
                                                                     p("1. Anzahl Netzwerke", style = "font-size:12px; text-decoration:underline;"),
                                                                     p("Zeigt, wie viele voneinander getrennte ", tags$b("Netzwerke"), " aus den ausgewählten ", tags$b("Potentialflächen"), " entstehen. Eine geringe Anzahl weist auf eine gute ", tags$b("räumliche Vernetzung"), " hin."),
                                                                     
                                                                     p("2. Flächen im Hauptnetzwerk [%]", style = "font-size:12px; text-decoration:underline;"),
                                                                     p("Gibt an, welcher Anteil der ", tags$b("Potentialflächen"), " zum größten zusammenhängenden ", tags$b("Hauptnetzwerk"), " gehört. Hohe Werte bedeuten eine gute Einbindung der Flächen in ein gemeinsames Netzwerk."),
                                                                     
                                                                     p("3. Größe Hauptnetzwerk [km²]", style = "font-size:12px; text-decoration:underline;"),
                                                                     p("Beschreibt die räumliche Ausdehnung des größten ", tags$b("Netzwerks"), ". Die Fläche ergibt sich aus den erreichbaren Bereichen rund um die ", tags$b("Potentialflächen"), " innerhalb der gewählten ", tags$b("Distanz."), " Das Hauptnetzwerk wird im ", tags$b("Kartenfenster"), " als oranges Polygon dargestellt."),
                                                                     
                                                                     p("4. ", tags$a(href='https://networkx.org/documentation/stable/reference/algorithms/generated/networkx.algorithms.centrality.betweenness_centrality.html', target = '_blank', rel = 'noopener', 'Betweenness centrality'),  style = "font-size:12px; text-decoration:underline;"),
                                                                     p("Zeigt die Bedeutung einzelner ", tags$b("Flächen"), " für die Verbindung innerhalb des ", tags$b("Netzwerks."), " Flächen mit hohen Werten fungieren als wichtige ", tags$b("Trittsteine"), " oder Verbindungselemente. Die Bedeutung wird über die ", tags$b("Punktgröße"), " dargestellt."),
                                                                     
                                                                     p("5. ", tags$a(href='https://r.igraph.org/reference/cluster_fast_greedy.html', target = '_blank', rel = 'noopener', 'Group fast greedy'), style = "font-size:12px; text-decoration:underline;"),
                                                                     p("Identifiziert ", tags$b("Teilgemeinschaften"), " innerhalb eines Netzwerks mit besonders stark verbundenen ", tags$b("Flächen."), " Diese Gruppen werden im ", tags$b("Kartenfenster"), " durch unterschiedliche ", tags$b("Punktfarben"), " dargestellt."),
                                                                     hr(),
                                                                     p("Die maximale potenzielle ", tags$b("Ausbreitungsdistanz"), " einer Art wird über den Button ", tags$b("Distanz"), " festgelegt.", style = "font-size:12px; line-height: 1.5;"),
                                                                     br()
                                                                   ),
    
                                                                   width = 2
                                                                   
                                                               )),
                                             
                                             mainPanel(
                                               
                                               # Leaflet-Karte (MAP_2 definiert in 'server') mit Spinner (zeitintensive Berechungen)
                                               
                                               shinycssloaders::withSpinner(leafletOutput('MAP_2', height = '85vh'), type = 1, color = "grey"),
                                               
                                               # Interaktive Netzwerkanalyse für selektierte 'PotentialFlächen'
                                               
                                               absolutePanel(id = 'controls', class = 'panel panel-default', fixed = F, draggable = T, top ='auto', bottom = '7.5vh', left = '1.25vw', right = 'auto', width = 250, height = 125, style = 'z-index: 9999;',  
                                                             
                                                             # Auswahl 'Potentialflächen' 
                                                             
                                                             pickerInput('I1', choices=sort(unique(BFS$Standort)), pickerOptions(actionsBox = T, title = 'Auswahl über ID', header = 'Potentialfläche', size = 5, selectAllText = "Alle auswählen", deselectAllText = "Alle abwählen"), label = 'Potentialfläche', multiple = T, selected = NULL),      
                                                             
                                                             # Auswahl Distanz + Wertebereich
                                                             
                                                             tagList(
                                                               numericInput('I2', 'Distanz [m]', value = 2500, min = 0, max = 10000, step = NA, width = NULL),
                                                               tags$small(class = "text-muted", style = "font-size: 0.75em; margin-top: -10px; display: block;", "100 - 10000")
                                                             ),
                                                             
                                                             # Button >> Start Berechnung 
                                                             
                                                             fluidRow(column(width = 12, align = "center",
                                                                             actionButton('RUN_NET_1', '', title = 'Start Berechnung', icon = icon('play'), size = 'large', style = 'background: #FFFFFF; border-color: lightgrey;'))),  
                                                             
                                               ),
                                               
                                               # Darstellung (dynamische) Netzwerkindizes 
                                               
                                               absolutePanel(id = 'NetMea', class = 'panel panel-default', fixed = F, draggable = T, top ='auto', bottom = '7.5vh', left = 'calc(50% - 100px)', right = 'auto', width = 200, height = 150,  
                                                             p("Anzahl Netzwerke", style = "margin-bottom:4px; font-size:12px;"),
                                                             verbatimTextOutput("text_2_1", placeholder = TRUE),
                                                             p("Flächen in Hauptnetzwerk [%]", style = "margin-bottom:4px; font-size:12px;"),
                                                             verbatimTextOutput("text_2_2", placeholder = TRUE),
                                                             p("Größe Hauptnetzwerk [km²]", style = "margin-bottom:4px; font-size:12px;"),
                                                             verbatimTextOutput("text_2_3", placeholder = TRUE),
                                                             align="center"
                                               ),
                                               
                                               width = 12),
                                             
                                           )),
                                  
                                  ## SubTab 3 >> Netzwerkanalyse 'Kosten-Distanz' >> Ausbreitungskosten pro Landschaftsklasse + Digitalisierung / Editieren / Löschen & Import / Export (Format .gpkg) von (neuen) Polygonen mit definierbaren Kostenwerten
                                  
                                  tabPanel('Kosten Distanz',
                                           
                                           # Sidebar (Erklärung & Kontext) + MainPanel (Leaflet-Karte + Funktionen)
                                           
                                           layout_sidebar(
                                             
                                             sidebar = sidebar(open="closed", fluid = TRUE, width = '20%', style = "text-align: justify; margin:0 auto; max-width:875px;", class = "scrollable-sidebar",
                                                               
                                                               div(id ="Sidebar_3", 
                                                                   
                                                                   # Erklärung Methoden & Indizes
                                                                   
                                                                   helpText(
                                                                     p("Kosten Distanz", style = "font-size:16px; font-weight: bold; text-align: center; line-height: 1.5;"),
                                                                     hr(),
                                                                     p("Diese Variante des ", tags$b("PlanED-Planungswerkzeugs"), " berechnet ökologische ", tags$b("Netzwerke"), " auf Grundlage der ausgewählten ", tags$b("Potentialflächen."),"Die Verbindungen zwischen den Flächen werden über ein ", tags$b("Kostenraster"), " bestimmt, das aus der ", tags$b("Landschaftsklassifikation"), " abgeleitet wird.", style = "font-size:12px; line-height:1.5;"), 
                                                                     hr(),
                                                                     p("Die Qualität des entstehenden ", tags$b("Netzwerks"), " wird mithilfe der folgenden ", tags$b("Indizes"), " bewertet:", style = "font-size:12px; line-height:1.5;"),
                                                                     p(tags$b("1. Anzahl Netzwerke"), style = "font-size:12px; text-decoration:underline;"),
                                                                     p("Zeigt, wie viele voneinander getrennte ", tags$b("Netzwerke"), " aus den ausgewählten ", tags$b("Potentialflächen"), " entstehen. Eine geringe Anzahl weist auf eine gute ", tags$b("räumliche Vernetzung"), " hin."),
                                                                     p(tags$b("2. Flächen im Hauptnetzwerk [%]"), style = "font-size:12px; text-decoration:underline;"),
                                                                     p("Gibt an, welcher Anteil der ", tags$b("Potentialflächen"), " zum größten zusammenhängenden ", tags$b("Hauptnetzwerk"), " gehört. Hohe Werte bedeuten eine gute Einbindung der Flächen in ein gemeinsames Netzwerk."),
                                                                     p(tags$b("3. Größe Hauptnetzwerk [km²]"), style = "font-size:12px; text-decoration:underline;"),
                                                                     p("Beschreibt die räumliche Ausdehnung des größten ", tags$b("Netzwerks."), " Die Fläche ergibt sich aus den erreichbaren Bereichen rund um die ", tags$b("Potentialflächen"), " innerhalb des gewählten ", tags$b("Kosten-Budgets."),"Das Hauptnetzwerk wird im ", tags$b("Kartenfenster"), " als oranges Polygon dargestellt."),
                                                                     p(tags$b("4. "), tags$a(href='https://networkx.org/documentation/stable/reference/algorithms/generated/networkx.algorithms.centrality.betweenness_centrality.html', target = '_blank', rel = 'noopener', tags$b("Betweenness centrality")), style = "font-size:12px; text-decoration:underline;"),
                                                                     p("Zeigt die Bedeutung einzelner ", tags$b("Flächen"), " für die Verbindung innerhalb des ", tags$b("Netzwerks."),"Flächen mit hohen Werten fungieren als wichtige ", tags$b("Trittsteine"), " oder Verbindungselemente. Die Bedeutung wird über die ", tags$b("Punktgröße"), " dargestellt."),
                                                                     p(tags$b("5. "), tags$a(href='https://r.igraph.org/reference/cluster_fast_greedy.html', target = '_blank', rel = 'noopener', tags$b("Group fast greedy")), style = "font-size:12px; text-decoration:underline;"),
                                                                     p("Identifiziert ", tags$b("Teilbereiche"), " innerhalb eines Netzwerks mit besonders stark verbundenen ", tags$b("Flächen."), " Diese Gruppen werden im ", tags$b("Kartenfenster"), " durch unterschiedliche ", tags$b("Punktfarben"),"dargestellt."),
                                                                     hr(),
                                                                     p("Über ", tags$b("Kosten-Budget"), " wird die maximale ", tags$b("Ausbreitungsdistanz"), " einer Art unter Berücksichtigung der ", tags$b("Landschaftsdurchlässigkeit"), " festgelegt. Gut geeignete Bereiche des ", tags$b("Kostenrasters"), " verursachen geringe, schwer passierbare Bereiche höhere ", tags$b("Bewegungskosten."),"Dazu wird die angenommene maximale Ausbreitungsdistanz der Art unter optimalen Bedingungen (i.e., Landschaftstyp mit niedrigstem Kostenwert) in ", tags$b("Landschaftskosten"), " umgerechnet:", style = "font-size:12px; line-height:1.5;"),
                                                                     
                                                                     p(tags$b("Kosten-Budget = (max. Distanz / min. Kosten) × Pixelgröße"), style = "font-size:12px; line-height:1.5;"),
                                                                     p("Das artspezifische ", tags$b("Kosten-Budget"), " gibt an, wie viele ", tags$b("Ausbreitungskosten"), " ausgegeben werden können, bis die poteniell maximale Ausbreitungsdistanz erreicht ist.", style = "font-size:12px; line-height:1.5;"),
                                                                     hr(),
                                                                     p("Mit dem ", tags$b("Zeichenwerkzeug"), " der Karte können Flächen mit individuellen ", tags$b("Kostenwerten"), " digitalisiert, bearbeitet oder gelöscht werden. Neu digitalisierten Flächen muss ein ", tags$b("Kostenwert"), " zugewiesen werden. Manuell erstellte Flächen mit individuellen (landschaftsunabhängigen) Kosten werden direkt in das ", tags$b("Kostenraster"), " integriert. Diese Flächen können über den ", tags$b("Download-Button"), " als ", tags$b(".gpkg-Datei"), " gespeichert oder über den ", tags$b("Upload-Button"), " geladen werden.", style = "font-size:12px; line-height:1.5;"),
                                                                     br()
                                                                   ),
                                                                   
                                                                   width = 2
                                                                   
                                                               )),
                                             
                                             mainPanel(
                                               
                                               # Leaflet-Karte (MAP_3 definiert in 'server') mit Spinner (zeitintensive Berechungen)
                                               
                                               shinycssloaders::withSpinner(leafletOutput('MAP_3', height = '85vh'), type = 1, color = "grey"),
                                               
                                               # Interaktive Netzwerkanalyse für selektierte 'PotentialFlächen'
                                               
                                               absolutePanel(id = 'controls', class = 'panel panel-default', fixed = F, draggable = T, top ='auto', bottom = '7.5vh', left = '1.25vw', right = 'auto', width = 250, height = 125, style = 'z-index: 9999;', 
                                                             
                                                             #Auswahl 'PotentialFlächen' 
                                                             
                                                             pickerInput('I1_3', choices=sort(unique(BFS$Standort)), pickerOptions(actionsBox = T, title = 'Auswahl über ID', header = 'Potentialfläche', size = 5, selectAllText = "Alle auswählen", deselectAllText = "Alle abwählen", ), label = 'Potentialfläche', multiple = T, selected = NULL),      
                                                             
                                                             # Auswahl 'Kosten-Budget' + Wertebereich
                                                             
                                                             tagList(
                                                             numericInput('I2_3', 'Kosten-Budget',  value = 625, min = 50, max = 5000, step = NA, width = NULL),
                                                             tags$small(class = "text-muted", style = "font-size: 0.75em; margin-top: -10px; display: block;", "50 - 5000"),
                                                             bsTooltip(id = "I2_3", title = "", placement = "right", trigger = "hover")
                                                             ),
                                                             
                                                             # Button >> Start Berechnung 
                                                             
                                                             fluidRow(column(width = 12, align = "center",
                                                                             actionButton('RUN_NET_2', '',   title = 'Start Berechnung', icon = icon('play'), size = 'large', style = 'background: #FFFFFF; border-color: lightgrey;'))),
                                                             
                                               ),
                                               
                                               
                                               ## Eingabe-Felder der Kostenwerte (dimensionslos - höherer Wert,i.e. geringere Durchlässigkeit) für die 5 Landschaftsklassen für dynamische Neu-Berechnung Kostenraster
                                               
                                               absolutePanel(id = 'controls', class = 'panel panel-default', fixed = F, draggable = T, top ='0vw', bottom = 'auto', left = 'calc(50% - 225px)', right = 'auto', width = 450, height = 100,  
                                                             column(12, style="border-radius:4px; background:transparent;", align="center",
                                                                    div("Kosten", 
                                                                        fluidRow(
                                                                          tags$head(
                                                                            tags$style(HTML("
                                                                              input[type=number] {-moz-appearance:textfield;}
                                                                              input[type=number]::{-moz-appearance:textfield;}        
                                                                              input[type=number]::-webkit-outer-spin-button,
                                                                              input[type=number]::-webkit-inner-spin-button {-webkit-appearance: none; margin: 0;}
                                                                             ")
                                                                            )
                                                                          ),
                                                                          
                                                                          # Verkehr (z. B. Straßen, Wege)
                                                                          
                                                                          column(width = 5, numericInput('C1',label=tags$span(style='font-size: 10px;', 'Verkehr'),value=75,min=0,max=1000), style = 'width: 20%; display: inline-block; vertical-align: middle;'),
                                                                          
                                                                          # Offenland (z. B. Wiesen, Ackerflächen)
                                                                          
                                                                          column(width = 5, numericInput('C2',label=tags$span(style='font-size: 10px;', 'Offenland'),value=50,min=0,max=1000), style = 'width: 20%; display: inline-block; vertical-align: middle;'),
                                                                          
                                                                          # Gehölz (z. B. Wald, Hecken)
                                                                          
                                                                          column(width = 5, numericInput('C3',label=tags$span(style='font-size: 10px;', 'Gehölz'),value=100,min=0,max=1000), style = 'width: 20%; display: inline-block; vertical-align: middle;'),
                                                                          
                                                                          # Wasser
                                                                          
                                                                          column(width = 5, numericInput('C4',label=tags$span(style='font-size: 10px;', 'Wasser'),value=25,min=0,max=1000), style = 'width: 20%; display: inline-block; vertical-align: middle;'),
                                                                          
                                                                          # Gebäude 
                                                                          
                                                                          column(width = 5, numericInput('C5',label=tags$span(style='font-size: 10px;', 'Gebäude'),value=125,min=0,max=1000), style = 'width: 20%; display: inline-block; vertical-align: middle;'),
                                                                          
                                                                          # Tooltip - Landschaftsklasse <> ID 
                                                                          
                                                                          bsTooltip(id = "C1", title = "C1"),
                                                                          bsTooltip(id = "C2", title = "C2"),
                                                                          bsTooltip(id = "C3", title = "C3"),
                                                                          bsTooltip(id = "C4", title = "C4"),
                                                                          bsTooltip(id =  "C5", title ="C5")
                                                                          
                                                                        ),
                                                                        
                                                                    ),
                                                                    
                                                                    # Button >> Start Berechnung 
                                                                    
                                                                    actionButton('RUN_CTS', '',   title = 'Start Berechnung', icon = icon('play'), size = 'large', style = 'background: #FFFFFF; border-color: lightgrey;'),
                                                                    
                                                             )),
                                               
                                               # Darstellung (dynamische) Netzwerkindizes 
                                               
                                               absolutePanel(id = 'NetMea', class = 'panel panel-default', fixed = F, draggable = T, top ='auto', bottom = '7.5vh', left = 'calc(50% - 100px)', right = 'auto', width = 200, height = 150,  
                                                             p("Anzahl Netzwerke", style = "margin-bottom:4px; font-size:12px;"),
                                                             verbatimTextOutput("text_3_1", placeholder = TRUE),
                                                             p("Flächen in Hauptnetzwerk [%]", style = "margin-bottom:4px; font-size:12px;"),
                                                             verbatimTextOutput("text_3_2", placeholder = TRUE),
                                                             p("Größe Hauptnetzwerk [km²]", style = "margin-bottom:4px; font-size:12px;"),
                                                             verbatimTextOutput("text_3_3", placeholder = TRUE),
                                                             align="center"
                                               ),
                                               
                                               # Export / Import 'Flächen spezifische Kosten' 
                                               
                                               absolutePanel(id = 'controls', class = 'panel panel-default', fixed = F, draggable = F, top = '40vh', bottom = 'auto', left = 'auto', right = '.5vw', width = '2.5%', height = '2.5%', style="display:table-cell; text-align: left;",
                                                             
                                                             downloadButton('download_R22', '', width='0px'),
                                                             bsTooltip('download_R22', 'DOWNLOAD Kosten-Feature (.gpkg)'),
                                                             p(style = "margin-bottom:-20px;"),
                                                             div(
                                                               id = "upload_R22_TT",
                                                               fileInput(
                                                                 'upload_R22',
                                                                 '',
                                                                 buttonLabel = icon("upload"),
                                                                 placeholder = "FILE"
                                                               )
                                                             ),
                                                             bsTooltip('upload_R22_TT', 
                                                                       'UPLOAD Kosten-Feature (.gpkg)',
                                                                       options = list(offset = '0.20')
                                                                       ),
                                                             
                                               ),
                                               
                                               width = 12),
                                             
                                           )),
                                  
                      ),
                      
             ),
             
             ## Maßnahmenkatalog >> Darstellung (empfohlener) ökologischer Aufwertungsmaßnahmen
             
             tabPanel('4. Maßnahmenkatalog',
                      tags$div(style = "text-align: justify; margin:0 auto; max-width:875px; line-height: 1.5;",
                               tags$h4('Hinweis'),
                               'Die Zusammenstellungen und Spezifikationen der nachfolgenden Aufwertungsmaßnahmen wurden u.a. unter Zuhilfenahme der angegebenen Quellen und eigenen Projekterfahrungen erstellt und erheben keinen Anspruch auf Vollständigkeit.',
                               tags$br(),
                               tags$hr(), 
                               tags$h3('Tabelle empfohlener Maßnahmen'),
                               tags$p(style="margin:25px;"),
                      ),
                      
                      # Tabellarische (interaktiv) Darstellung 
                      
                      div(
                        style = "width: 100%; display: flex; justify-content: center;",
                        div(
                          style = "max-width: 1400px; width: 100%;",
                          shinycssloaders::withSpinner(DT::dataTableOutput("meaTAB"), type = 1, color = "grey"),
                        ),
                      ),
                      
                      tags$div(style = "text-align: justify; margin:0 auto; max-width:875px; line-height: 1.5;",
                               tags$br(),
                               
                               # Downloadfunktion (.csv)
                               
                               div(
                                 style = "text-align: right;",
                                 downloadButton(
                                   outputId = "download_MEA",'', width='0px'
                                 )
                               ),
                               tags$hr(), 
                               
                               # Beispiele ökologischer Aufwertungsmaßnahmen >> Bildgalerie
                               
                               tags$h3('Beispiele Aufwertungsmaßnahmen'),
                               tags$p(style="margin:25px;"),
                               layout_columns(
                                 card(card_header("Biotopholz"), card_image(src = 'biotopholz.png'), 
                                      card_footer(tags$h6('Foto: K.Ullrich, Hassfurt, 12.06.2016'))),
                                 card(card_header("Blühsaatfläche"), card_image(src = 'bluehsaatflaeche.png'), 
                                      card_footer(tags$h6('Foto: M.Deubert, Homberg, 30.09.2025'))),
                                 card(card_header("Infotafel"), card_image(src = 'infotafel.png'), 
                                      card_footer(tags$h6('Foto: M.Deubert, Homberg, 30.09.2025'))),
                                 card(card_header("Insektennisthilfe"), card_image(src = 'insektennisthilfe.png'), 
                                      card_footer(tags$h6('Foto: K.Ullrich, Hassfurt, 12.06.2016'))),
                                 card(card_header("Kombinierter Lebensraum"), card_image(src = 'kom_lebensraum.png'), 
                                      card_footer(tags$h6('Foto: K.Ullrich, Hassfurt, 06.06.2017'))),
                                 card(card_header("Pflanzung"), card_image(src = 'pflanzung.png'), 
                                      card_footer(tags$h6('Foto: M.Deubert, Gimmeldingen, 07.04.2018'))),
                                 card(card_header("Rohboden"), card_image(src = 'rohboden.png'), 
                                      card_footer(tags$h6('Foto: M.Deubert, Kirtorf, 01.10.2025'))),
                                 card(card_header("Staffelmahd"), card_image(src = 'staffelmahd.png'), 
                                      card_footer(tags$h6('Foto: M.Deubert, Wahlen, 01.10.2025'))),
                                 card(card_header("Steinwerk"), card_image(src = 'steinwerk.png'), 
                                      card_footer(tags$h6('Foto: M.Deubert, Ober-Ofleiden, 30.09.2025'))),
                                 col_widths = c(2, 2, 2, 2, 2, 2, 2, 2, 2)
                               ),
                               
                               tags$hr(), 
                               
                               # Links optionalen Bezugsquellen für Materialien
                               
                               tags$h3('Mögliche Bezugsquellen'),
                               tags$p(style="margin:25px;"),
                               'Regiozertifiziertes Saatgut, (Wild-)Gehölze & Stauden:',
                               tags$p(style="margin:5px;"),
                               tags$a(href='https://www.natur-im-vww.de', target = '_blank', rel = 'noopnener', 'https://www.natur-im-vww.de'), 
                               tags$br(),
                               tags$br(),
                               'Natursteine:',
                               tags$p(style="margin:5px;"),
                               'regionale Steinbrüche, Bauhöfe', 
                               tags$br(),
                               tags$br(),
                               'Regionales Totholz:',
                               tags$p(style="margin:5px;"),
                               'Bauhöfe, Forst', 
                               tags$br(),
                               tags$hr(), 
                               
                               # Links weiterführenden Quellen
                               
                               tags$h3('Weiterführende Quellen'),    
                               tags$p(style="margin:25px;"),
                               'Bundesministerium für Landwirtschaft, Ernährung und Heimat (BMLEH) (Hrsg.) (²2025): Bienenfreundliche Pflanzen. Das Lexikon für Balkon, Garten und andere Pflanzorte.',
                               tags$a(href='https://www.bmleh.de/SharedDocs/Downloads/DE/Broschueren/BienenfreundlichePflanzen.pdf', target = '_blank', rel = 'noopnener', 'https://www.bmleh.de/SharedDocs/Downloads/DE/Broschueren/BienenfreundlichePflanzen.pdf'),
                               tags$br(),
                               tags$p(style="margin:25px;"),
                               'DEUBERT, M.; KÜNAST, C.; KÜNAST, R.; TRAPP, M. (2021): Mit Eh-da-Flächen die biologische Vielfalt fördern. Entdecken, Planen und Gestalten verfügbarer Flächen. In: Unterricht Biologie 465 (45. Jg.), 16–21.',  
                               tags$a(href='https://www.friedrich-verlag.de/biologie/oekologie/mit-eh-da-flaechen-die-biologische-vielfalt-foerdern-9481', target = '_blank', rel = 'noopnener', 'https://www.friedrich-verlag.de/biologie/oekologie/mit-eh-da-flaechen-die-biologische-vielfalt-foerdern-9481'),
                               tags$br(),
                               tags$br(),
                               tags$br(),
                      ),
             ),
             
             ## Fachliche & organisatorische Hintergründe Projekt PlanED
             
             tabPanel('5. Hintergrund',
                      
                      tags$div(style = "text-align: justify; margin:0 auto; max-width:875px; line-height: 1.5;",
                               
                               # Datengrundlagen >> Beschreibung verwendeten Geodaten, Dienste & Eh-da Flächen
                               
                               tags$h3('Datengrundlagen'),
                               tags$br(),
                               'In erster Linie wurden amtliche Geobasisdaten der Hessischen Verwaltung für Bodenmanagement und Geoinformation (HVBG) verwendet. Darunter wurden die Datenebenen „Luftbilder HVBG“ sowie „ALKIS HVBG“ über die Open Data Plattform der HVBG', 
                               tags$a(href='https://gds.hessen.de', target = '_blank', rel = 'noopnener', '(https://gds.hessen.de)'), 
                               'in Form von Geodatendiensten (WMS) im Planungswerkzeug eingebunden. Mit den beiden Datenebenen „OpenStreetMap“ sowie „ESRI-WorldImagery“ sind zwei weitere (weltweite) Geodatendienste enthalten. Fachdaten des Naturschutzes (Schutzgebiete, Biotope, Kompensationsflächen) wurden über die offiziellen Seiten des Hessischen Ministeriums für Umwelt, Klimaschutz, Landwirtschaft und Verbraucherschutz',
                               tags$a(href='https://natureg.hessen.de/infomaterial/geodaten.php ', target = '_blank', rel = 'noopnener', '(https://natureg.hessen.de/infomaterial/geodaten.php)'), 
                               'bezogen.',
                               tags$br(),
                               tags$br(),
                               'Daneben wurden auf Grundlagen amtlicher Geobasisdaten des HVBG eigene Daten generiert: Eh da-Flächen wurden durch die Verschneidung ausgewählter Kategorien aus dem digitalen Liegenschaftskataster (ALKIS) mit dem aus hochauflösenden Infrarotluftbildern gewonnenen Vegetationsindex (NDVI) berechnet (vgl. DEUBERT et al. 2016 & Abbildung). Der Ist-Zustand von Eh da-Flächen wird anschließend durch gezielte Begehungen (FNU & DLR R-N-H) und Drohnenbefliegung (DLR R-N-H) erhoben.',
                               tags$br(),
                               tags$br(),
                               'Auch die Kategorie „Garten“ wurde (zum Teil) für die Modellregion neu berechnet: Zu einem Teil setzt sie sich aus den in ALKIS enthaltenen Kategorien „Garten“, „Kleingarten“ oder „Wochenendfläche“ zusammen. Zum anderen Teil wurden sogenannte „Wohngärten“ durch die Verschneidung der ALKIS-Kategorien mit Wohnnutzung mit den aus dem NDVI gewonnenen Vegetationsanteilen berechnet.',
                               tags$br(),
                               tags$br(),
                               tags$figure(style = 'text-align: center;', tags$img(src = 'dg.png', width = '450px', height = 'auto')),
                               tags$p(style="margin:15px;"),
                               tags$h6('Geodatenbasiert erfasste potenzielle Eh da-Fläche (Deubert et al. 2016, S. 211)'),
                               tags$hr(), 
                               
                               ## Projektkonsortium >> Darstellung Projektpartner + Aufgaben
                               
                               tags$h3('Konsortium', style = 'line-height: 1.5;'), 
                               tags$p(style="margin:15px;"),
                               tags$h4('Projektträger', style = 'line-height: 1.5;'), 
                               tags$p(style="margin:25px;"),
                               tags$h5('Dienstleistungszentrum Ländlicher Raum'),
                               tags$br(),
                               tags$figure(align = 'left', tags$a(href='https://www.dlr-rnh.rlp.de', target = '_blank', rel = 'noopnener', tags$img(src = 'dlr.png', width = '175px', height = 'auto'))),
                               tags$br(),
                               'Dr. Matthias Trapp',
                               tags$br(),
                               'Breitenweg 71, 67435 Neustadt',
                               tags$br(),
                               'Telefon: +49 6321 671426',
                               tags$p(style="margin:5px;"),
                               tags$a(href='https://www.dlr-rnh.rlp.de', target = '_blank', rel = 'noopnener', 'https://www.dlr-rnh.rlp.de'), 
                               tags$p(style="margin:25px;"),
                               tags$h5('Projektaufgaben', style = 'line-height: .125;'), 
                               'Koordination, Geodatenanalysen (LSM), Entwicklung des SDSS, Korrespondenz, Drohnenbefliegungen, wissenschaftliche Betreuung (u.a. Abschlussarbeiten)',
                               tags$br(),
                               tags$br(),
                               tags$h4('Verbundpartner', style = 'line-height: 1.5;'), 
                               tags$p(style="margin:25px;"),
                               tags$h5('Forschungszentrum Neu-Ulrichstein GmbH & Co KG (FNU)'),
                               tags$br(),
                               tags$figure(align = 'left', tags$a(href='https://www.neu-ulrichstein.de', target = '_blank', tags$img(src = 'fnu.png', width = '75px', height = 'auto'))),
                               tags$br(),
                               'Prof. Dr. Klaus Peter Ebke',
                               tags$br(),
                               'Neu-Ulrichstein 5, 35315 Homberg (Ohm)',
                               tags$br(),
                               'Telefon: +49 6633 825490',
                               tags$p(style="margin:5px;"),
                               tags$a(href='https://www.neu-ulrichstein.de', target = '_blank', rel = 'noopnener', 'https://www.neu-ulrichstein.de'), 
                               tags$p(style="margin:25px;"),
                               tags$h5('Projektaufgaben', style = 'line-height: .125;'), 
                               'Moderation, Betreuung Abschlussarbeiten, Betreuung kommunaler Mitarbeiter, Fachschulungen, Öffentlichkeitsarbeit',
                               tags$br(),
                               tags$br(),
                               tags$h5('Stadt Homberg (Ohm)'),
                               tags$br(),
                               tags$figure(align = 'left', tags$a(href='https://www.homberg.de', target = '_blank', rel = 'noopnener', tags$img(src = 'hom.png', width = '75px', height = 'auto'))),
                               tags$br(),
                               'Bürgermeisterin Simke Ried',
                               tags$br(),
                               'Marktstr. 26, 35315 Homberg (Ohm)',
                               tags$br(),
                               'Telefon: +49 6633 1840',
                               tags$p(style="margin:5px;"),
                               tags$a(href='https://www.homberg.de', target = '_blank', rel = 'noopnener', 'https://www.homberg.de'), 
                               tags$p(style="margin:25px;"),
                               tags$h5('Projektaufgaben', style = 'line-height: .125;'), 
                               'Personal (Bauhof, etc.), Umsetzung Aufwertungsmaßnahmen',
                               tags$br(),
                               tags$br(),
                               tags$h5('Stadt Kirtorf'),
                               tags$br(),
                               tags$figure(align = 'left', tags$a(href='https://www.stadt-kirtorf.de', target = '_blank', rel = 'noopnener', tags$img(src = 'kir.png', width = '75px', height = 'auto'))),
                               tags$br(),
                               'Bürgermeister Christoph Lück',
                               tags$br(),
                               'Neustädter Str. 10-12, 36320 Kirtorf',
                               tags$br(),
                               'Telefon: +49 6635 180',
                               tags$p(style="margin:5px;"),
                               tags$a(href='https://www.stadt-kirtorf.de', target = '_blank', rel = 'noopnener', 'https://www.stadt-kirtorf.de'), 
                               tags$p(style="margin:25px;"),
                               tags$h5('Projektaufgaben', style = 'line-height: .125;'), 
                               'Personal (Bauhof, etc.), Umsetzung Aufwertungsmaßnahmen',
                               tags$br(),
                               tags$br(),
                               tags$h4('Assoziierte Partner'),
                               tags$p(style="margin:25px;"),
                               tags$h5('Amt für Bauen und Umwelt Vogelsberg – Untere Naturschutzbehörde'),
                               tags$p(style="margin:-10px;"),
                               tags$figure(align = 'left', tags$a(href='https://www.vogelsbergkreis.de/buerger-service/bauen-wohnen-umwelt/natur-umwelt', target = '_blank', rel = 'noopnener', tags$img(src = 'vog.png', width = '125px', height = 'auto'))),
                               'Sarah Ettling',
                               tags$br(),
                               'Königsberger Str. 8, 36341 Lauterbach',
                               tags$br(),
                               'Telefon: +49 6641 977260',
                               tags$p(style="margin:5px;"),
                               tags$a(href='https://www.vogelsbergkreis.de/buerger-service/bauen-wohnen-umwelt/natur-umwelt', 'https://www.vogelsbergkreis.de/buerger-service/bauen-wohnen-umwelt/natur-umwelt'), 
                               tags$br(),
                               tags$br(),
                               tags$h5('Amt für Bodenmanagement Fulda – Flurbereinigungsbehörde'),
                               tags$br(),
                               tags$figure(align = 'left', tags$a(href='https://hvbg.hessen.de/ueber-uns/dienststellen/amt-fuer-bodenmanagement-fulda', target = '_blank', rel = 'noopnener', tags$img(src = 'afbm.png', width = '200px', height = 'auto'))),
                               tags$br(),
                               'Timo Karl',
                               tags$br(),
                               'Washingtonallee 1, 36041 Fulda',
                               tags$br(),
                               'Telefon: +49 611 5351470',
                               tags$p(style="margin:5px;"),
                               tags$a(href='https://hvbg.hessen.de/ueber-uns/dienststellen/amt-fuer-bodenmanagement-fulda', 'https://hvbg.hessen.de/ueber-uns/dienststellen/amt-fuer-bodenmanagement-fulda'), 
                               tags$br(),
                               tags$hr(), 
                               
                               ## Publikationen + Links
                               
                               tags$h3('Publikationen (Auszug)'),
                               tags$p(style="margin:25px;"),
                               'DEUBERT, M.; TRAPP, M.; KROHN, K.; ULLRICH, K.; BOLZ, H.; KÜNAST, R.; KÜNAST, C. (2016): Das Konzept der Eh da-Flächen: Ein Weg zu mehr biologischer Vielfalt in Agrarlandschaften und im Siedlungsbereich. In: Naturschutz und Landschaftsplanung 48 (7), 2016, 209-217.',
                               tags$a(href='https://www.nul-online.de/Das-Konzept-der-Eh-da-Flaechen,QUlEPTUwOTYyMDAmTUlEPTExMTE.html', target = '_blank', rel = 'noopnener', 'https://www.nul-online.de/Das-Konzept-der-Eh-da-Flaechen,QUlEPTUwOTYyMDAmTUlEPTExMTE.html'), 
                               tags$br(),
                               tags$p(style="margin:25px;"),
                               'DEUBERT, M.; KÜNAST, C.; KÜNAST, R.; TRAPP, M. (2021): Mit Eh-da-Flächen die biologische Vielfalt fördern. Entdecken, Planen und Gestalten verfügbarer Flächen. In: Unterricht Biologie 465 (45. Jg.), 16–21.',
                               tags$br(),
                               tags$p(style="margin:25px;"),
                               'KÜNAST, C.; DEUBERT, M.; KÜNAST, R.; TRAPP, M. (2019): Die Eh da-Initiative. Mehr Platz für biologische Vielfalt in Kulturlandschaften. In: Biologie in Unserer Zeit 48, 1/2019, 28-38.',
                               tags$br(),
                               tags$p(style="margin:25px;"),
                               'KÜNAST, C. (2023): Eh da-Flächen - Mehr Lebensräume für Insekten. Verlag Dr. Friedrich Pfeil, München.',
                               tags$br(),
                               tags$p(style="margin:25px;"),
                               'KÜNAST, C.; DEUBERT, M.; KOTREMBA, C.; ULLRICH, K.; TRAPP, M. (2023): Klimaschutz, Klimaanpassung und biologische Vielfalt auf Eh da-Flächen. Synergien, Begrenzungen und potenzielle Spannungsbereiche. In: Naturschutz und Landschaftsplanung 11/2023.',
                               tags$br(),
                               tags$hr(), 
                               
                               ## Weiterführende Links
                               
                               tags$h3('Weiterführende Links'),    
                               tags$p(style="margin:25px;"),
                               'WIKI mit Publikationen',
                               tags$p(style="margin:5px;"),
                               tags$a(href='https://www.hortipendium.de/Eh_da_Flächen', target = '_blank', rel = 'noopnener', 'https://www.hortipendium.de/Eh_da_Flächen'), 
                               tags$br(),
                               tags$br(),
                               'Projektdatenbank DBU',
                               tags$p(style="margin:5px;"),
                               tags$a(href='https://www.dbu.de/projektdatenbank/38150-01/', target = '_blank', rel = 'noopnener', 'https://www.dbu.de/projektdatenbank/38150-01/'), 
                               tags$br(),
                               tags$br(),
                               tags$br(),
                      ),
             ),
             
             ## Impressum & Datenschutzinformation >> Rechtliche Pflichtangaben gemäß TMG / DDG sowie DSGVO
             
             tabPanel('Impressum & Datenschutzinformation',
                      tags$div(style = "text-align: justify; margin:0 auto; max-width:875px;",
                               
                               # IMPRESSUM
                               
                               tags$h3('Impressum'),        
                               tags$br(), 
                               'Verantwortlich für den Inhalt dieser Webseite (gemäß § 5 TMG)',
                               tags$br(),
                               tags$br(),
                               'Das vorliegende StoryBoard ist die projektbegleitende Webseite zum Vorhaben "Entwicklung und Anwendung digitaler Planungswerkzeuge für ökologische Aufwertungsmaßnahmen von Eh da-Flächen auf Landschaftsebene am Beispiel einer Modellregion (PlanED)", gefördert von der Deutschen Bundesstiftung Umwelt (DBU).',
                               tags$br(),
                               tags$br(),
                               'Herausgegeben wird es vom Dienstleistungszentrum Ländlicher Raum Rheinhessen-Nahe-Hunsrück. Verantwortlich für das gesamte Angebot sind nach § 5 DDG das Dienstleistungszentrum Ländlicher Raum Rheinhessen-Nahe-Hunsrück (DLR R-N-H).',
                               tags$br(),
                               
                               tags$h4('Kontakt'),
                               'Dienstleistungszentrum Ländlicher Raum Rheinhessen-Nahe-Hunsrück (DLR R-N-H)',
                               tags$br(),
                               'Rüdesheimer Str. 60 – 68, 55545 Bad Kreuznach',
                               tags$br(),
                               tags$p(style="margin:10px;"),
                               tags$a(fa("phone", fill = "black")), tags$span('0049 (0) 671-820-0'),
                               tags$br(),
                               tags$a(href='mailto:DLR-RNH@dlr.rlp.de', target = '_blank', rel = 'noopnener', fa("envelope", fill = "dodgerblue")), tags$span(style = 'color: dodgerblue;', 'DLR-RNH@dlr.rlp.de'),
                               tags$br(),
                               'vertreten durch Michael Lipps',
                               tags$a(href='mailto:michael.lipps@dlr.rlp.de', target = '_blank', rel = 'noopnener', fa("envelope", fill = "dodgerblue")), tags$span(style = 'color: dodgerblue;', 'michael.lipps@dlr.rlp.de'),
                               tags$br(),                                           
                               tags$br(),
                               
                               tags$h4('Haftungsausschluss'),
                               'Die Informationen auf dieser Website wurden nach bestem Wissen und Gewissen sorgfältig zusammengestellt und geprüft. Es wird jedoch keine Gewähr - weder ausdrücklich noch stillschweigend - für die Vollständigkeit, Richtigkeit oder Aktualität sowie die jederzeitige Verfügbarkeit der bereitgestellten Informationen übernommen. Für die Inhalte der Geofachdaten sind die im Quellverzeichnis benannten Stellen verantwortlich. Insbesondere übernimmt das DLR R-N-H keine Gewähr dafür, dass die Informationen den Anforderungen und Zwecken des Nutzers genügen. Die Verantwortung für die richtige Auswahl und die Folgen der Benutzung der Informationen sowie der damit beabsichtigten oder erzielten Ergebnisse trägt der Nutzer. Es kann keine Haftung übernommen werden für die Einbindung und Darstellung von externen Daten oder Diensten sowie für Schäden, die sich aus der Verwendung der abgerufenen Informationen ergeben.',
                               tags$br(),
                               tags$br(),
                               
                               tags$h4('Realisierung und Technischer Support'),
                               'DLR Rheinhessen-Nahe-Hunsrück - Technische Zentralstelle',
                               tags$br(),
                               tags$br(),
                               
                               tags$h4('Disclaimer'),
                               'Trotz sorgfältiger inhaltlicher Kontrolle übernehmen wir keine Haftung für die Inhalte externer Links. Für den Inhalt der verlinkten Seiten sind ausschließlich deren Betreiber verantwortlich.',
                               tags$br(),
                               tags$hr(), 
                               
                               # Datenschutzerklärung
                               
                               tags$h3('Datenschutzerklärung'), 
                               tags$br(), 
                               'Verantwortlicher gemäß Art. 4 Nr. 7 DSGVO ist',
                               tags$br(),
                               tags$p(style="margin:10px;"),
                               'Dienstleistungszentrum Ländlicher Raum Rheinhessen-Nahe-Hunsrück (DLR R-N-H)',
                               tags$br(),
                               'Rüdesheimer Str. 60 – 68, 55545 Bad Kreuznach, Deutschland',
                               tags$br(),
                               'Michael Lipps',
                               tags$br(),
                               tags$p(style="margin:10px;"),
                               tags$a(fa("phone", fill = "black")), tags$span('0049 (0) 0671-820-0'),
                               tags$br(),
                               tags$a(fa("fax", fill = "black")), tags$span('0049 (0) 0671-820-600'),
                               tags$br(),
                               tags$a(href='mailto:DLR-RNH@dlr.rlp.de', target = '_blank', rel = 'noopnener', fa("envelope", fill = "dodgerblue")), 
                               tags$span(style = 'color: dodgerblue;', 'DLR-RNH@dlr.rlp.de'),
                               ' | ',
                               tags$a(href='mailto:michael.lipps@dlr.rlp.de', target = '_blank', rel = 'noopnener', fa("envelope", fill = "dodgerblue")), 
                               tags$span(style = 'color: dodgerblue;', 'michael.lipps@dlr.rlp.de'),
                               tags$br(),
                               tags$a(href='https://www.dlr.rlp.de', target = '_blank', rel = 'noopnener', 'www.dlr.rlp.de'), 
                               tags$br(),
                               tags$br(),
                               
                               tags$h4('Datenschutzbeauftragter'),
                               'Für Fragen zum Datenschutz wenden Sie sich bitte an den behördlichen Datenschutzbeauftragten des DLR R-N-H, Hr. Kai Thomas.',
                               tags$br(),
                               tags$a(href='mailto:datenschutz@dlr.rlp.de', target = '_blank', rel = 'noopnener', fa("envelope", fill = "dodgerblue")), 
                               tags$span(style = 'color: dodgerblue;', 'datenschutz@dlr.rlp.de'),
                               tags$br(),
                               tags$br(),
                               tags$h4('Arten der verarbeiteten Daten'),
                               'Beim Aufruf dieser Webseite werden automatisch technische Daten verarbeitet, darunter:',             
                               tags$br(),    
                               tags$p(style="margin:10px;"),
                               'Dies sind:',
                               tags$p(style="margin:10px;"),
                               tags$li(tags$span('Besuchte Seite auf unserer Domain')),
                               tags$li(tags$span('Datum und Uhrzeit der Serveranfrage')),
                               tags$li(tags$span('Browsertyp und Browserversion')),
                               tags$li(tags$span('Referrer URL Hostname des zugreifenden Rechners')),
                               tags$li(tags$span('IP-Adresse')),
                               tags$br(),
                               'Es findet keine Zusammenführung dieser Daten mit anderen Datenquellen statt. Grundlage der Datenverarbeitung bildet Art. 6 Abs. 1 lit. e) DSGVO (Wahrnehmung einer Aufgabe im öffetnlichen Interesse) im Zusammenhang mit der Förderung durch die Bundesstiftung Umwelt (DBU).',
                               tags$br(),
                               tags$br(),
                               
                               tags$h4('Zwecke der Verarbeitung'),
                               'Die Verarbeitung erfolgt ausschließlich zum Betrieb und zur Bereitstellung dieser das PlanED-Projekt begleitenden Webseite (inkl. Geo-Dashboard) sowie zur Nutzung im Rahmen von Forschung, Lehre und Wissenstransfer.',
                               tags$br(),
                               tags$br(),
                               
                               tags$h4('Weitergabe der Daten'),
                               'Eine Weitergabe an Dritte erfolgt nicht ohne Ihre ausdrückliche Einwilligung. Projektpartner (Forschungszentrum Neu-Ulrichstein, Stadt Homberg (Ohm) und Stadt Kirtorf) sowie Fördermittelgeber (Deutsche Bundesstiftung Umwelt) erhalten ausschließlich anonymisierte bzw. aggregierte Daten.',
                               tags$br(),
                               tags$br(),
                               
                               tags$h4('Speicherdauer'),
                               'Personenbezogene Daten werden nur so lange gespeichert, wie es zur Erreichung des genannten Zwecks erforderlich ist oder gesetzliche Vorgaben dies verlangen.',
                               tags$br(),
                               tags$br(),
                               tags$h4('Rechte der betroffenen Personen'),
                               'Sie haben das Recht auf Auskunft, Berichtigung, Löschung, Einschränkung der Verarbeitung, Widerspruch sowie Datenübertragbarkeit (Art. 15–21 DSGVO).',
                               tags$br(),
                               tags$br(),
                               'Darüber hinaus besteht ein Beschwerderecht bei der zuständigen Aufsichtsbehörde:',
                               tags$br(),
                               'Der Landesbeauftragte für den Datenschutz und die Informationsfreiheit Rheinland-Pfalz',
                               tags$br(),
                               'Postfach 30 40, 55020 Mainz Deutschland',
                               tags$br(),
                               tags$br(),
                               
                               tags$h4('Cookies und Tracking'),
                               'Auf dieser Webseite werden keine Cookies zu Analyse- oder Trackingzwecken eingesetzt.',
                               tags$br(),
                               tags$br(),
                               
                               tags$h4('Datensicherheit'),
                               'Diese Webseite nutzt SSL-Verschlüsselung sowie weitere technische und organisatorische Maßnahmen, um die Sicherheit der verarbeiteten Daten zu gewährleisten.',
                               tags$br(),
                               tags$br()
                               
                      ),
             ),
  )
)
