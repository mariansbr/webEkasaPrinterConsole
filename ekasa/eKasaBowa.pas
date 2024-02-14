unit eKasaBowa;

interface

uses
  uEkasaPrinters, DelUp;

resourcestring
  rs_VkladHot = 'Vklad hotovosti';
  rs_VybHot = 'V˝ber hotovosti';
  rs_FakturaC = 'Fakt˙ra Ë.: ';
  rs_Uhrada = '⁄hrada ';
  rs_JednotkovaCena = 'jednotkov· cena (%s)';

  rs_PAYMENTTYPE_HOTOV = 'Hotovosù';
  rs_PAYMENTTYPE_KARTA = 'Karta';
  rs_PAYMENTTYPE_SEK = 'äek';
  rs_PAYMENTTYPE_UVER = '⁄ver';

  rs_Err20H = '(32) Nespr·vny poËet poloûiek v prÌkaze';
  rs_Err21H = '(33) Nespr·vny poËet znakov v niektorej poloûke prÌkazu';
  rs_Err22H = '(34) Nezn·me platidlo';
  rs_Err23H =
    '(35) Cena Celkom je nespr·vna, hl·si ak je zapnut˝ GP pre kontrolu Medzis˙Ëtu (GP1=1)';
  rs_Err24H = '(36) Cena Celkom nie je v minim·lnom platidle';
  rs_Err25H = '(37) V poloûk·ch platby nie s˙ ûiadne znaky';
  rs_Err26H = '(38) V poloûke Pon˙knut· suma alebo Cena celkom je chyba';
  rs_Err27H = '(39) V poloûke Kurz je chyba';
  rs_Err28H = '(40) V poloûke Popis s˙ nepovolenÈ znaky';
  rs_Err2AH = '(42) Preplatenie platidlom nie je povolenÈ';
  rs_Err30H = '(48) Odpojen· tlaËiareÚ /preruöen˝ loop na doske FM/';
  rs_Err31H = '(49) Nespr·vne heslo v prÌkaze vyûaduj˙com heslo';
  rs_Err32H =
    '(50) Odmietnutie op‰tovnej fiskaliz·cie /FM uû je zfiskalizovan˝/';
  rs_Err33H =
    '(51) Odmietnutie dalöieho otvorenia dÚa do 24:00h po vykonanej z·vierke';
  rs_Err34H = '(52) Nezn·my, alebo nepovolen˝ prÌkaz v danom stave FM';
  rs_Err35H =
    '(53) Ne˙speön· fiskaliz·cia, lebo FP nie je vloûen· alebo nie je Ëist·';
  rs_Err40H =
    '(64) Znak EOT v prÌkaze nepriöiel do 3 s. od zaËiatku prenosu /time over pri prÌjme prÌkazu z PC'
    + #13 + '/ resp. chyba ËasovÈho r·mca /time over Ëakania na prÌkaz z PC pri blokov˝ch prenosoch/';
  rs_Err41H =
    '(65) ChybnÈ BCC v prÌkaze od PC, /a doposiaæ aj chyba ËÌslovania riadku prÌkazu/';
  rs_Err42H = '(66) Nespr·vny form·t d·tumu, Ëasu';
  rs_Err43H =
    '(67) Chyba ËÌslovania riadkov v prÌkazoch /rozdelenie chyby 41H/';
  rs_Err46H =
    '(70) Nastavovan˝ d·tum do RTC je menöÌ ako d·tum poslednej DU z FP ak DU existuje'
    + #13 + 'a ak FM je zfiskalizovan˝';
  rs_Err50H = '(80) Nevloûen· FP';
  rs_Err51H = '(81) Cudzia FP /inÈ SN a DKP/';
  rs_Err52H = '(82) FP s dosiahnut˝mi limitmi';
  rs_Err53H = '(83) »ist· FP /FP bez z·pisov/';
  rs_Err54H = '(84) Nezasunut· µSD karta pre kontroln˝ z·znam (ELJ)';
  rs_Err55H = '(85) Cudzia µSD karta /inÈ SN a DKP/';
  rs_Err56H = '(86) Odpojen˝ displej';
  rs_Err57H = '(87) Chybn˝ z·pis do µSD karty';
  rs_Err58H = '(88) Chybn˝ z·pis do FP';
  rs_Err59H = '(89) SD karta je zapÌsan· do max. kapacity';
  rs_Err60H = '(96) Chyba parametra v prÌkaze';
  rs_Err61H =
    '(97) Odmietnutie prÌkazu otvorenia ˙Ëtenky z dÙvodu prechodu 24:00h bez z·vierky';
  rs_Err62H =
    '(98) Odmietnutie inÈho prÌkazu ako potvrdenie o servisnej prehliadke a Get variable';
  rs_Err63H =
    '(99) Odmietnutie inÈho prÌkazu ako potvrdenie o zostatkoch DU vo FP a Get variable';
  rs_Err64H =
    '(100) Odmietnutie prÌkazu zmeÚ heslo z dÙvodu, ûe HW prepÌnaË je v polohe nedovoæuj˙cej'
    + #13 + 'meniù heslo tzn. v tejto polohe platÌ default heslo.';
  rs_Err65H =
    '(101) NepovolenÈ pouûitie DU. V danom dni je otvoren· druh· smena';
  rs_Err66H =
    '(102) Odmietnutie prÌkazu vykonania servisnej prehliadky, nakoæko doposiaæ nebola oznamovan·'
    + #13 + 'inform·cia o tejto potrebe.';
  rs_Err67H =
    '(103) Odmietnutie prÌkazu z dÙvodu, ûe SPI nebola identifikovan·, tzn., ûe doölo k HW z·vade'
    + #13 + 'na SPI odstr·nitelnej len servisn˝m z·sahom. Zariadenie je v stave S120. Povolen˝'
    + #13 + 'prÌkaz GET variable.';
  rs_Err68H =
    '(104) Odmietnutie prÌkazu z dÙvodu, ûe nastala z·vada pri z·pise d·t ñback up ˙dajov do SPI,'
    + #13 + 'tzn., ûe doölo k HW z·vade na SPI., ktor˙ je moûnÈ odstr·niù v˝mazom back up ˙dajov'
    + #13 + 'a n·sledn˝m z·pisom aktu·lnych back up ˙dajov. Zariadenie je v stave S121.'
    + #13 + 'Povolen˝ prÌkaz GET variable a prÌkaz obnovy SPI.=kode 78H.';
  rs_Err69H =
    '(105) Odmietnutie prÌkazu z dÙvodu, ûe nastala z·vada pri z·pise d·t do MMC. FM bude v stave S122.'
    + #13 + 'PovolenÈ prÌkazy s˙ Get variable, Get back up, Test HW.';
  rs_Err6AH =
    '(106) Odmietnutie prÌkazu z dÙvodu, ûe nastala z·vada na RTC /RTC d·va nere·lne d·tumy a Ëasy/.'
    + #13 + 'FM bude v stave S123. PovolenÈ prÌkazy s˙ Get variable, Get back up, Test HW.';
  rs_Err6BH =
    '(107) Odmietnutie prÌkazu z dÙvodu, ûe nastala z·vada na FP poËas z·pisu d·t. FM bude'
    + #13 + 'v stave S124. PovolenÈ prÌkazy s˙ Get variable.';
  rs_Err6CH =
    '(108) Odmietnutie prÌkazu init FM z dÙvodu, ûe sÌce SN a DKP, MMC a SN, FP a SN,'
    + #13 + 'DKP FM s˙ zhodnÈ, ale d·tum a ËÌslo poslednej z·vierky z FP a d·tum a ËÌslo'
    + #13 + 'poslednej z·vierky z ELJ nie s˙ zhodnÈ.';
  rs_Err6DH =
    '(109) Chyba overenia CRC ELJ. CRC z ELJ nie je totoûnÈ s CRC z ELJ uloûenÈ vo FP.';
  rs_Err81H =
    '(129) Pon˙knut· suma nie je n·sobkom minim·lneho platidla hlavnej meny(mena 16 alebo'
    + #13 + 'platidlo s kurzom 0) ide o chybu parametra v prÌkaze.';
  rs_Err82H =
    '(130) Minim·lne platidlo akumul·torov 1..16 pri zadefinovanom kurze 0 (Ëiûe hlavn· mena je'
    + #13 + 'platidlo 16) nie je n·sobkom najmenöej moûnej jednotky Ëiûe vmp.(virtu·lne minim·lne'
    + #13 + 'platidlo) toto nastane iba ak virtu·l min. teraz natvrdo=0.01 by nebolo celistv˝m'
    + #13 + 'n·sobkom min. platidiel, tak to nastane a vysvieti sa chyba parametra.';
  rs_Err83H =
    '(131) Pon˙knut· suma vedlajöÌch mien nie je n·sobkom minim·lneho platidla t˝chto mien.'
    + #13 + 'Ide o platidlo zahr. mena, ked by pon˙knut· suma nebola celistv˝m n·sobkom min.'
    + #13 + 'platidla danej zahr. meny, chyba parametra.';
  rs_Err84H =
    '(132) Virtu·lne minim·lne platidlo, alebo minim·lne platidlo je nulovÈ. Chyba nastavenia min.'
    + #13 + 'platidla.';
  rs_Err85H =
    '(133) Preplatenie nie je dovolenÈ. Pon˙knut· suma je v‰cöia ako suma na doplatenie.'
    + #13 + 'Ide o nedovolene preplatenie.';
  // Chyby komunikacie so SFS
  rs_SFS_Err_2 = '(-2) ZlÈ vstupnÈ hodnoty.'; // -2
  rs_SFS_Err_8 =
    '(-8) T·to verzia integraËnÈho rozhrania uû nie je naÔalej podporovan·.';
  // -8
  rs_SFS_Err_10 = '(-10) Chyba v podpise d·tovej spr·vy.'; // -10
  rs_SFS_Err_12 = '(-12) Nespr·vny form·t certifik·tu.'; // -12
  rs_SFS_Err_13 = '(-13) Pouûit˝ certifik·t nie je platn˝.'; // -13
  rs_SFS_Err_100 = '(-100) Nespr·vna hodnota PKP.'; // -100
  rs_SFS_Err_101 =
    '(-101) DI» v d·tovej spr·ve sa nezhoduje s DI» z certifik·tu.'; // -101
  rs_SFS_Err_102 =
    '(-102) KÛd ORP v d·tovej spr·ve sa nezhoduje s kÛdom ORP z certifik·tu.';
  // -102
  rs_SFS_Err_103 =
    '(-103) D·tum a Ëas vyhotovenia dokladu je neskoröÌ ako d·tum a Ëas spracovania.';
  // -103
  rs_SFS_Err_104 =
    '(-104) D·tum a Ëas vytvorenia dokladu je neskoröÌ ako d·tum a Ëas spracovania.';
  // -104
  rs_SFS_Err_105 =
    '(-105) D·tum a Ëas vytvorenia dokladu je skoröÌ ako d·tum a Ëas spracovania.';
  // -105
  rs_SFS_Err_106 =
    '(-106) D·tum a Ëas vyhotovenia dokladu je skoröÌ ako d·tum a Ëas spustenia systÈmu.';
  // -106
  rs_SFS_Err_107 =
    '(-107) D·tum a Ëas vytvorenia dokladu je skoröÌ ako d·tum a Ëas spustenia systÈmu.';
  // -107
  rs_SFS_Err_108 =
    '(-108) D·tum a Ëas vytvorenia ˙dajov o polohe je neskoröÌ ako d·tum a Ëas spracovania.';
  // -108
  rs_SFS_Err_109 =
    '(-109) D·tum a Ëas vytvorenia ˙dajov o polohe je skoröÌ ako d·tum a Ëas spracovania.';
  // -109
  rs_SFS_Err_110 =
    '(-110) D·tum a Ëas vytvorenia ˙dajov o polohe je skoröÌ ako d·tum a Ëas spustenia systÈmu.';
  // -110
  rs_SFS_Err_111 = '(-111) Nespr·vna hodnota OKP.'; // -111
  rs_SFS_Err_112 =
    '(-112) »Ìslo fakt˙ry musÌ byù vyplnenÈ pre typ dokladu: ⁄hrada fakt˙ry.';
  // -112
  rs_SFS_Err_113 =
    '(-113) Rozpis DPH nesmie byt vyplnenÈ pre typ dokladu: ⁄hrada fakt˙ry, Vklad, V˝ber.';
  // -113
  rs_SFS_Err_114 =
    '(-114) Typ dokladu: ⁄hrada fakt˙ry, Vklad, V˝ber nesmie obsahovaù poloûky.';
  // -114
  rs_SFS_Err_115 =
    '(-115) »Ìslo fakt˙ry nesmie byù vyplnenÈ pre typ dokladu: Platn˝ doklad, Neplatn˝ doklad, Vklad, V˝ber.';
  // -115
  rs_SFS_Err_116 =
    '(-116) Typ dokladu: Platn˝ doklad, Neplatn˝ doklad musÌ obsahovaù poloûky.';
  // -116
  rs_SFS_Err_117 =
    '(-117) Pre typ poloûky: Vr·ten·, Opravn· musÌ byù vyplnenÈ referenËnÈ ËÌslo dokladu, ku ktorÈmu sa vr·tenie, oprava vzùahuje.';
  // -117
  rs_SFS_Err_118 =
    '(-118) Pre typ poloûky: Kladn·, Vr·tenÈ obaly, Zæava nesmie byù vyplnenÈ referenËnÈ ËÌslo dokladu.';
  // -118
  rs_SFS_Err_119 =
    '(-119) Rozpis DPH musÌ byù vyplnenÈ pre typ dokladu: Platn˝ doklad, Neplatn˝ doklad.';
  // -119
  rs_SFS_Err_120 =
    '(-120) Suma dane z·kladnej sadzby a Z·klad z·kladnej sadzby dane musia byù vyplnenÈ obe, alebo ani jedno.';
  // -120
  rs_SFS_Err_121 =
    '(-121) Suma dane znÌûenej sadzby a Z·klad znÌûenej sadzby dane musia byù vyplnenÈ obe, alebo ani jedno.';
  // -121
  rs_SFS_Err_122 =
    '(-122) ID kupuj˙ceho a Typ ID kupuj˙ceho musia byù vyplnenÈ obe, alebo ani jedno.';
  // -122
  rs_SFS_Err_123 =
    '(-123) ID kupuj˙ceho a Typ ID kupuj˙ceho nesm˙ byù vyplnenÈ pre typ dokladu: Neplatn˝ doklad, Vklad, V˝ber.';
  // -123
  rs_SFS_Err_124 =
    '(-124) »Ìslo paragÛnu je povinnÈ v prÌpade evidovania paragÛnu.'; // -124
  rs_SFS_Err_125 =
    '(-125) »Ìslo paragÛnu mÙûe byù vyplnenÈ iba v prÌpade evidovania paragÛnu.';
  // -125
  rs_SFS_Err_126 =
    '(-126) ParagÛn nie je moûnÈ zaevidovaù pre typ dokladu: Neplatn˝ doklad, Vklad, V˝ber.';
  // -126
  rs_SFS_Err_127 = '(-127) Typ poloûky: Kladn· nesmie maù z·porn˙ cenu.';
  // -127
  rs_SFS_Err_128 =
    '(-128) Typ poloûky: Vr·tenÈ obaly, Vr·ten·, Zæava, OdpoËÌtan· z·loha, V˝mena poukazu nesmie maù kladn˙ cenu.';
  // -128
  rs_SFS_Err_129 =
    '(-129) ID pred·vaj˙ceho a Typ ID pred·vaj˙ceho musia byù vyplnenÈ obe, alebo ani jedno.';
  // -129
  rs_SFS_Err_130 =
    '(-130) Pre priradenie dane: 20, 10 nesmie byù vyplnen· Slovn· inform·cia.';
  // -130
  rs_SFS_Err_131 =
    '(-131) Pre typ poloûky: Kladn·, Vr·tenÈ obaly, Vr·ten·, Zæava, OdpoËÌtan· z·loha nesmie byù vyplnenÈ »Ìslo jedno˙ËelovÈho poukazu.';
  // -131
  rs_SFS_Err_132 = '(-132) Nespr·vna Ëasov· zÛna.'; // -132
  // Chyby komunikacie so SFS end
  rs_ErrD0H = '(208) S˙bor sa nenaöiel';
  rs_ErrD1H = '(209) Chyba ËÌtania alebo zapisovania do s˙boru';
  rs_ErrFDH = '(253) Chyba PPEKK (podæa 1.1 zoznamu öpecifick˝ch ch˝b PPEKK)';
  rs_ErrFEH = '(254) Chyba datab·zy';
  // Zoznam öpecifick˝ch ch˝b PPEKK
  rs_PPEKK_Err_1 = 'uû je vytvoren· inötancia s inou datab·zou';
  rs_PPEKK_Err_2 = 'nepodarilo sa inicializovaù datab·zu';
  rs_PPEKK_Err_3 = 'nepodarilo sa inicializovaù CHD⁄';
  rs_PPEKK_Err_4 = 'nepodarilo sa inicializovaù tlaËiareÚ';
  rs_PPEKK_Err_5 = 'pokus o spracovanie nepodporovanej spr·vy';
  rs_PPEKK_Err_6 =
    'komunik·cia s PPEKK pre inÈ UUID (pokus o hacknutie systÈmu)';
  rs_PPEKK_Err_7 = 'ned· sa pripojiù k CHD⁄';
  rs_PPEKK_Err_8 = 'v CHD⁄ sa nenaöli d·ta';
  rs_PPEKK_Err_9 = 'v CHD⁄ s˙ ˙daje v zlom tvare';
  rs_PPEKK_Err_10 = 'CHD⁄ nie je konfigurovanÈ';
  rs_PPEKK_Err_11 = 'chyba pri pr·ci s datab·zou';
  rs_PPEKK_Err_12 = 'ned· sa öifrovaù pr·ca s datab·zou';
  rs_PPEKK_Err_13 = 'chyba pri generovanÌ tlaËe';
  rs_PPEKK_Err_14 = 'chyba dÂûky parametra';
  rs_PPEKK_Err_15 =
    'nastavovacÌ parameter neexistuje, alebo je jeho hodnota zl·';
  rs_PPEKK_Err_16 = 'nepodporovan· sekvencia';
  rs_PPEKK_Err_17 = 'neplatn· sadzba DPH';
  rs_PPEKK_Err_18 = 'zle vypoËÌtanÈ hodnoty DPH pre doklad';
  rs_PPEKK_Err_19 = 'chyba v komunikaËnom module na SFS';
  rs_PPEKK_Err_20 = 'SFS vr·tilo chybu odoslanej spr·vy';
  rs_PPEKK_Err_21 = 'chyba pri pr·ci s CFG';
  rs_PPEKK_Err_22 = 'nie s˙ nahratÈ autentifikaËnÈ ˙daje';
  rs_PPEKK_Err_23 = 'tlaËiareÚ nie je pripraven·';
  rs_PPEKK_Err_24 = 'intern· chyba pri spracovanÌ aplik·cie';
  rs_PPEKK_Err_25 = 'zle zadanÈ mnoûstvo';
  rs_PPEKK_Err_26 = 'zle zadan· jednotkov· cena';
  rs_PPEKK_Err_27 = 'zle zadan· cena za poloûku';
  rs_PPEKK_Err_28 = 'zlÈ identifikaËnÈ ˙daje';
  rs_PPEKK_Err_29 = 'zlÈ autentifikaËnÈ heslo';
  rs_PPEKK_Err_30 = 'je viac rovnak˝ch kategÛriÌ DPH pre jednu sadzbu';
  rs_PPEKK_Err_31 = '˙daje na CHD⁄ a PPEKK s˙ rÙzne';
  rs_PPEKK_Err_32 = 'zl˝ form·t autentifikaËn˝ch ˙dajov';
  rs_PPEKK_Err_33 = 'neplatn˝ certifik·t autentifikaËn˝ch ˙dajov';
  rs_PPEKK_Err_34 = 'DI», DKP nesedia pre toto CHD⁄';
  rs_PPEKK_Err_35 = 'zl˝ form·t identifikaËn˝ch ˙dajov';
  rs_PPEKK_Err_36 = 'DI», DKP nesedia pre toto CHD⁄';
  rs_PPEKK_Err_37 = 'chyba pri p·rovanÌ opravovanej a pokazenej transackcie';
  rs_PPEKK_Err_38 = 'zlÈ pouûitie J⁄P';
  rs_PPEKK_Err_39 = 'nepodarilo sa vygenerovaù swid';
  rs_PPEKK_Err_40 = 'ch˝baj˙ca licencia';
  rs_PPEKK_Err_41 = 'CHD⁄ bolo odpojenÈ poËas norm·lneho reûimu komunik·cie';
  rs_PPEKK_Err_42 =
    'pokus o synchroniz·ciu medzi PPEKK a CHD⁄, keÔ to nie je moûnÈ';
  rs_PPEKK_Err_43 = 'chyba komunik·cie s CHD⁄';
  rs_PPEKK_Err_44 = 'CHD⁄ prekroËilo timeout na vykonanie oper·cie';
  rs_PPEKK_Err_45 = 'chyba upgrade CHD⁄';
  rs_PPEKK_Err_46 =
    'PPEKK nem· niË na opravenie, hoci ûiadate o opravn˝ doklad';
  rs_PPEKK_Err_47 =
    'pouûÌva sa d·tum vytvorenia dokladu skoröÌ ako je povolenÈ';
  rs_PPEKK_Err_48 = 'parameter k oprave z·pisu je nespr·vny';
  rs_PPEKK_Err_49 = 'zl˝ inicializaËn˝ string';
  rs_PPEKK_Err_50 = 'je vyûadovan· aspoÚ jedna poloûka';
  rs_PPEKK_Err_51 = 'chyba ËasovÈho p·sma';
  rs_PPEKK_Err_52 = 'niektor˝ z parametrov prÌkazu je nespr·vny';
  rs_PPEKK_Err_53 = 'chyba ukladania config s˙boru, bol vykonan˝ rollback';

  rs_S0 = 'SystÈmovÈ nastavenia';
  rs_S1 = 'Otvorenie predajnÈho dÚa';
  rs_S2 = 'Predaj / telo ˙Ëtenky';
  rs_S3 = 'Vykonanie platby';
  rs_S4 = 'UkonËenie ˙Ëtenky';
  rs_S10 = 'Intern˝ doklad';
  rs_S20 = 'Vklad / v˝ber';
  rs_S70 = '';
  rs_S100 = 'HW z·vada';
  rs_S101 = 'Cudzia fiök·lna pam‰ù';
  rs_S102 = 'Cudzia pam‰ù µSD';
  rs_S103 = 'Limit fiök·lnÈ pam‰te';
  rs_S104 = 'Nevloûen· fiök·lna pam‰ù';
  rs_S105 = '»ist· fiök·lna pam‰ù';
  rs_S106 = 'Odpojen· tlaËiareÚ';
  rs_S107 = 'Odpojen˝ displej';
  rs_S108 = 'Nezasunut· µSD';
  rs_S109 = 'Pln· µSD';
  rs_S113 = 'Hl·senie SERVISN¡ PREHLIADKA';
  rs_S114 = 'Hl·senie LIMIT DU pod 50 z·pisov';

const
  rs_connection_error =
    '{"errorCode":500,"error":"Nepodarilo sa spojenie s Bowa. Skontrolujte ju!"}';

  C_ESC_CHAR = '~';

  C_VAR_SEP = ';'; // Oddelovac poli v retezci vracenem getVariable
  C_VAR_12 = '12'; // TAX data A ~ TAX data E local
  C_VAR_E4 = 'E41'; // Pouzivane typy platidel
  C_VAR_E7 = 'E7'; // PAYMENTTYPE data 1(E71) ~ PAYMENTTYPE data G (E7G) local
  C_VAR_F6 = 'F61'; // Flag S90 ñ Ñvyn˙ten·ì DU
  C_VAR_B51 = 'B51';
  // VyËÌtanie poslednej chyby PPEKK a poslednej chyby datab·zy FM

  // Danove hladiny
  C_VAT_A = 'A';
  C_VAT_B = 'B';
  C_VAT_C = 'C';
  C_VAT_D = 'D';
  C_VAT_E = 'E';
  C_VAT_F = 'F';

  C_LEN_PAYMENT = 10;
  C_LEN_DISCOUNT = 18;
  C_LEN_DEPOSITE = 20; // depositeInDrawer
  C_LEN_ANNOUCEMENTNF = 39;
  C_LEN_ANNOUCEMENT = 40;
  C_LEN_5 = 5;
  C_LEN_10 = 10;
  C_LEN_50 = 50; // setClientID, setSellerID

  C_DEVICENUMBER = 1;
  C_PASSWORD = 'Pegas006';
  C_SALEMODE_TEST = 0;
  C_SALEMODE_FISKAL = 1;
  FM_INTERFACE_LINK = '127.0.0.1:30000';

  C_DEPOSITEINDRAWER_VKLAD = 0;
  C_DEPOSITEINDRAWER_VYBER = 1;

  C_ITEMDISCOUNT_SLEVAHOD = 0; // hodnotov· zæava
  C_ITEMDISCOUNT_PRIRAZKAHOD = 1; // hodnotov· prir·ûka

  C_SALETYPE_0 = 0; // Maloobchod (ceny s DPH)
  C_SALETYPE_1 = 1; // Veækoobchod (ceny bez DPH)
  C_SALETYPE_2 = 2; // Intern˝ doklad (bez orezu)
  C_SALETYPE_3 = 3; // Intern˝ doklad (bin·rny)
  C_SALETYPE_5 = 5; // Vklad/vyber
  C_SALETYPE_6 = 6; // Intern˝ doklad
  C_SALETYPE_9 = 9; // Fakt˙ra

  C_TYPPRENOSU_ROW = 0;
  C_TYPPRENOSU_BLOCK = 1;

  C_PARAGONTYPE_PLUS = 0; // kladny blocek
  C_PARAGONTYPE_MINUS = 1; // zaporny blocek

  C_TYPREKAP_SHORT = 0; // zkracena rekapitulace
  C_TYPREKAP_ALL = 1; // plna rekapitulace

  C_GRAPHICSHDR_NO = 0; // bez graficke hlavicky

  C_PAYMENTTYPE_KARTA = 1;
  C_PAYMENTTYPE_SEK = 2;
  C_PAYMENTTYPE_STRAV = 3;
  C_PAYMENTTYPE_ZAHR = 4;
  C_PAYMENTTYPE_UVER = 5; // USR5
  C_PAYMENTTYPE_USR6 = 6;
  C_PAYMENTTYPE_USR7 = 7;
  C_PAYMENTTYPE_USR8 = 8;
  C_PAYMENTTYPE_USR9 = 9;
  C_PAYMENTTYPE_USR10 = 10;
  C_PAYMENTTYPE_USR11 = 11;
  C_PAYMENTTYPE_USR12 = 12;
  C_PAYMENTTYPE_USR13 = 13;
  C_PAYMENTTYPE_USR14 = 14;
  C_PAYMENTTYPE_USR15 = 15;
  C_PAYMENTTYPE_HOTOV = 16;

type
  TStavBowa = record
    PKod: string;
    StavSDC: integer;
    StavPRN: integer;
    StavPC: integer;
    CRiadku: integer;
    StavS: integer;
    StavF: integer;
    VerziaF: integer;
  end;

  TDUBowa = record
    PKod: string;
    CisloDU: integer;
    DatCasDU: string;
    StavDU: integer;
    DatCasDS: string;
  end;

  TCHDUBowa = record
    chdu: string;
    ppekk: string;
    lastTransactionNumber: string;
    storageSize: string;
    sectorSize: string;
  end;

  TSFSBowa = record
    numberUnsentMessages: string;
    validitySignatureCertificate: string;
  end;

  TVats = array [1 .. 5] of currency;

procedure internalInit();
procedure internalClose();

function eKasaBowaInit: boolean;
function eKasaBowaWork(action: TEkasaActions): string;

function internalReadVariable(variableCode: string;
  onlyVariable: boolean = false): string;
function internalReadStavFM: TStavBowa;
function internalReadStavDU: TDUBowa;
function internalReadStavCHDU(): TCHDUBowa;
function internalReadStavSFS(): TSFSBowa;
procedure internalReadVats();

function errorStr(errCode: integer): string;
function sfsError(errCode: integer): boolean;
function sfsErrorStr(errCode: integer): string;
function ppekkErrorStr(errCode: integer): string;

implementation

uses
  Classes, SysUtils, StrUtils, Windows, uSettings, uCommon, payPackageUtils,
  superObject, uEkasaHelper;

var
  vats: TVats;
  bowaOpen: boolean = false;
  cashRoundSupport: integer = -1;
  // -1 nebolo zistene, 0 nepodporovane, 1 podporovane
  C_LEN_LINE: integer = 0;
  dllHandle: THandle;

  _openFM: function(pszPortName: PAnsiChar): integer; cdecl;
  _closeFM: procedure(); cdecl;
  // Paragon begin, paragon end, selling day begin
  _paragonBegin: function(deviceNumber, rowNumber, saleType, communicationType,
    paragonType, recapitulationType, graphicHeader: integer): integer; cdecl;
  _paragonEnd: function(deviceNumber, rowNumber, graphicHeader: integer)
    : integer; cdecl;
  _repeatParagon: function(deviceNumber: integer): integer; cdecl;
  _destroyParagon: function(deviceNumber, rowNumber: integer;
    description: PAnsiChar): integer; cdecl;
  _sellingDayBegin: function(deviceNumber, saleMode: integer): integer; cdecl;
  // Payment
  _payment_int: function(deviceNumber, rowNumber, paymentNumber: integer;
    total_2, payedAmount_2, exchangeRate_2: integer; description: PAnsiChar)
    : integer; cdecl;
  // ItemSale
  _setPreline: function(deviceNumber: integer; description: PAnsiChar)
    : integer; cdecl;
  _setPostline: function(deviceNumber: integer; description: PAnsiChar)
    : integer; cdecl;
  _itemSale_int: function(deviceNumber, rowNumber: integer;
    commodityName: PAnsiChar; totalPrice_2: integer; vat: PAnsiChar;
    amount_3, unitPrice_4: integer; unit1: PAnsiChar): integer; cdecl;
  _itemReturn_int: function(deviceNumber, rowNumber: integer;
    commodityName: PAnsiChar; totalPrice_2: integer; vat: PAnsiChar;
    amount_3, unitPrice_4: integer; unit1, receiptNumber: PAnsiChar)
    : integer; cdecl;
  _itemNegative_int: function(deviceNumber, rowNumber: integer;
    commodityName: PAnsiChar; totalPrice_2: integer; vat: PAnsiChar;
    amount_3, unitPrice_4: integer; unit1: PAnsiChar): integer; cdecl;
  _itemDiscount_int: function(deviceNumber, rowNumber: integer;
    description: PAnsiChar; operationType, discountValue_2: integer;
    vat: PAnsiChar): integer; cdecl;

  _getVariable: function(deviceNumber: integer; variableCode, result: PAnsiChar;
    resultLength: integer): integer; cdecl;
  _setParameter: function(deviceNumber: integer; password: PAnsiChar;
    paramNumber, paramValue: integer): integer; cdecl;
  _setDateTime: function(deviceNumber: integer; date: PAnsiChar)
    : integer; cdecl;
  _printAnnouncement: function(deviceNumber, rowNumber: integer;
    text: PAnsiChar): integer; cdecl;
  _printAnnouncementNF: function(deviceNumber, rowNumber: integer;
    text: PAnsiChar): integer; cdecl;
  _depositeInDrawer_int: function(deviceNumber, rowNumber: integer;
    description: PAnsiChar; operationType, amount_2, paymentNumber: integer)
    : integer; cdecl;
  _confirmNote: function(deviceNumber: integer): integer; cdecl;

  // PegasOnline v1.1
  _setClientID: function(deviceNumber: integer; number: PAnsiChar;
    type1: integer): integer; cdecl;
  _printIssuedParagon: function(deviceNumber, orderNumber: integer;
    dateTime: PAnsiChar): integer; cdecl;
  _setInvoiceNumber: function(deviceNumber: integer; invoiceNumber: PAnsiChar)
    : integer; cdecl;
  _redeemVoucher: function(deviceNumber: integer; title: PAnsiChar;
    amount: double; vat: PAnsiChar; price: double; voucherNumber: PAnsiChar)
    : integer; cdecl;
  _redeemVoucher_str: function(deviceNumber: integer; title: PAnsiChar;
    amount: PAnsiChar; vat: PAnsiChar; price: PAnsiChar;
    voucherNumber: PAnsiChar): integer; cdecl;
  _getParagonIDs_str: function(deviceNumber: integer;
    inputType, input, result: PAnsiChar; resultLength: integer): integer; cdecl;
  _getParagonIDs_ResultObject: function(deviceNumber: integer;
    inputType, input, resultObject: PAnsiChar): integer; cdecl;
  _getParagonIDs_str_ResultObject: function(deviceNumber: integer;
    inputType, input, resultObject: PAnsiChar): integer; cdecl;
  _setTransactionID: function(deviceNumber: integer; internalCode: PAnsiChar)
    : integer; cdecl;
  _setLocationGPS: function(deviceNumber: integer; vertX, vertY: double)
    : integer; cdecl;
  _setLocationAddress: function(deviceNumber: integer;
    municipality, street, number, subNumber, zip: PAnsiChar): integer; cdecl;
  _setLocationOther: function(deviceNumber: integer; description: PAnsiChar)
    : integer; cdecl;
  _printUnsentSFSpackets: function(deviceNumber: integer): integer; cdecl;
  _sendUnsentSFSpackets: function(deviceNumber: integer): integer; cdecl;
  _printReport_str: function(deviceNumber: integer; reportType: PAnsiChar;
    reportNumber: integer): integer; cdecl;
  _Popis0DPH_str: function(deviceNumber: integer; type1: PAnsiChar)
    : integer; cdecl;
  _printJournalStructU: function(deviceNumber: integer; paragonSn: PAnsiChar)
    : integer; cdecl;
  _setRawLogginOn: procedure(fileName: PAnsiChar); cdecl;
  _seRawLogginOff: procedure(); cdecl;
  _printDisplay: function(deviceNumber, displayType: integer;
    escSequence, text: PAnsiChar): integer; cdecl;
  _clearDisplay: function(deviceNumber, displayType: integer;
    escSequence: PAnsiChar): integer; cdecl;
  _setEscapeSequence: function(deviceNumber: integer; sequence: PAnsiChar)
    : integer; cdecl;
  _setEmail: function(deviceNumber: integer; email: PAnsiChar): integer; cdecl;
  _setSMTP: function(deviceNumber: integer; type1: PAnsiChar;
    ipAddress: PAnsiChar; port: integer; localDir: PAnsiChar): integer; cdecl;
  _opravaDokladu: function(deviceNumber: integer; errCode: PAnsiChar)
    : integer; cdecl;
  _setSellerID_str: function(deviceNumber: integer; number, type1: PAnsiChar)
    : integer; cdecl;
  _synchronizationToPPEKK: function(deviceNumber: integer): integer; cdecl;
  _setLicense: function(deviceNumber: integer; licenseCode: PAnsiChar)
    : integer; cdecl;
  _getLastTransactionPackets: function(deviceNumber, transactionCount: integer)
    : integer; cdecl;

  // Prepisane funkcie DLL s osetrenim dlzky retazcov
function openFM(sPortName: string): integer;
begin
  result := _openFM(PAnsiChar(StrToAStr(sPortName)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_openFM(%s) = %d', [sPortName, result]));
end;

procedure closeFM();
begin
  _closeFM();
  if fSettings.B['ekasa.withLog'] then
    addLog('_closeFM()');
end;

function paragonBegin(rowNumber, saleType, communicationType, paragonType,
  recapitulationType, graphicHeader: integer): integer;
begin
  result := _paragonBegin(C_DEVICENUMBER, rowNumber, saleType,
    communicationType, paragonType, recapitulationType, graphicHeader);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_paragonBegin(%d,%d,%d,%d,%d,%d,%d) = %d',
      [C_DEVICENUMBER, rowNumber, saleType, communicationType, paragonType,
      recapitulationType, graphicHeader, result]));
end;

function paragonEnd(rowNumber, graphicHeader: integer): integer;
begin
  result := _paragonEnd(C_DEVICENUMBER, rowNumber, graphicHeader);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_paragonEnd(%d,%d,%d) = %d', [C_DEVICENUMBER, rowNumber,
      graphicHeader, result]));
end;

function repeatParagon(): integer;
begin
  result := _repeatParagon(C_DEVICENUMBER);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_repeatParagon(%d) = %d', [C_DEVICENUMBER, result]));
end;

function destroyParagon(rowNumber: integer; description: string): integer;
begin
  description := LeftStr(description, C_LEN_LINE);
  result := _destroyParagon(C_DEVICENUMBER, rowNumber,
    PAnsiChar(StrToAStr(description)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_destroyParagon(%d,%d,%s) = %d', [C_DEVICENUMBER, rowNumber,
      description, result]));
end;

function setInvoiceNumber(invoiceNumber: string): integer;
begin
  result := _setInvoiceNumber(C_DEVICENUMBER,
    PAnsiChar(StrToAStr(invoiceNumber)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setInvoiceNumber(%d,%s) = %d', [C_DEVICENUMBER,
      invoiceNumber, result]));
end;

function redeemVoucher(title: string; amount: double; vat: string;
  price: double; voucherNumber: string): integer;
var
  decSep: Char;
begin
  decSep := FormatSettings.DecimalSeparator;
  try
    FormatSettings.DecimalSeparator := '.';
    title := LeftStr(title, C_LEN_LINE);
    vat := LeftStr(vat, 1);
    voucherNumber := LeftStr(voucherNumber, C_LEN_50);
    result := _redeemVoucher(C_DEVICENUMBER, PAnsiChar(StrToAStr(title)),
      Zaok(amount, 2, 0), PAnsiChar(StrToAStr(vat)), Abs(Zaok(price, 2, 0)),
      PAnsiChar(StrToAStr(voucherNumber)));
  finally
    FormatSettings.DecimalSeparator := decSep;
  end;
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_redeemVoucher(%d,%s,%d,%s,%d,%s) = %d',
      [C_DEVICENUMBER, title, Zaok(amount, 2, 0), vat, Abs(Zaok(price, 2, 0)),
      voucherNumber, result]));
end;

function setClientID(number: string; type1: integer): integer;
begin
  number := LeftStr(number, C_LEN_50);
  // typ:1 - ICO, 2 - DIC, 3 - ICDPH, 4 - INE
  result := _setClientID(C_DEVICENUMBER, PAnsiChar(StrToAStr(number)), type1);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setClientID(%d,%s,%d) = %d', [C_DEVICENUMBER, number, type1,
      result]));
end;

function payment_int(rowNumber, paymentNumber: integer;
  total_2, payedAmount_2, exchangeRate_2: integer; description: string)
  : integer;
begin
  description := LeftStr(description, C_LEN_PAYMENT);
  result := _payment_int(C_DEVICENUMBER, rowNumber, paymentNumber, total_2,
    payedAmount_2, exchangeRate_2, PAnsiChar(StrToAStr(description)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_payment_int(%d,%d,%d,%d,%d,%d,%s) = %d',
      [C_DEVICENUMBER, rowNumber, paymentNumber, total_2, payedAmount_2,
      exchangeRate_2, description, result]));
end;

function sendUnsentSFSpackets(): integer;
begin
  result := _sendUnsentSFSpackets(C_DEVICENUMBER);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_sendUnsentSFSpackets(%d) = %d', [C_DEVICENUMBER, result]));
end;

function printUnsentSFSpackets(): integer;
begin
  result := _printUnsentSFSpackets(C_DEVICENUMBER);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_printUnsentSFSpackets(%d) = %d', [C_DEVICENUMBER, result]));
end;

function getVariable(variableCode: string; var sresult: string): integer;
const
  C_LEN_BUFF = 1024;
var
  Buff: array [1 .. C_LEN_BUFF] of AnsiChar;
begin
  sresult := '';

  result := _getVariable(C_DEVICENUMBER, PAnsiChar(StrToAStr(variableCode)),
    @Buff, C_LEN_BUFF);
  Sleep(5);
  if result = 0 then
    sresult := AStrToStr(StrPas(PAnsiChar(@Buff)))
  else
    sresult := '';
  if fSettings.B['ekasa.withLog'] then
  begin
    addLog(Format('_getVariable(%d,%s) = %d', [C_DEVICENUMBER, variableCode,
      result]));
    addLog(Format('_getVariable.sresult = %s', [sresult]));
  end;
end;

function setParameter(paramNumber, paramValue: integer): integer;
begin
  result := _setParameter(C_DEVICENUMBER, PAnsiChar(StrToAStr(C_PASSWORD)),
    paramNumber, paramValue);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setParameter(%d,%s,%d,%d) = %d', [C_DEVICENUMBER,
      C_PASSWORD, paramNumber, paramValue, result]));

end;

function setDateTime(date_s: string): integer;
begin
  result := _setDateTime(C_DEVICENUMBER, PAnsiChar(StrToAStr(date_s)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setDateTime(%d,%s) = %d', [C_DEVICENUMBER, date_s,
      result]));
end;

function confirmNote(): integer;
begin
  result := _confirmNote(C_DEVICENUMBER);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_confirmNote(%d) = %d', [C_DEVICENUMBER, result]));
end;

function sellingDayBegin(saleMode: integer): integer;
begin
  result := _sellingDayBegin(C_DEVICENUMBER, saleMode);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_sellingDayBegin(%d,%d) = %d', [C_DEVICENUMBER, saleMode,
      result]));
end;

function depositeInDrawer_int(rowNumber: integer; description: string;
  operationType, amount_2, paymentNumber: integer): integer;
begin
  description := LeftStr(description, C_LEN_DEPOSITE);
  result := _depositeInDrawer_int(C_DEVICENUMBER, rowNumber,
    PAnsiChar(StrToAStr(description)), operationType, amount_2, paymentNumber);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_depositeInDrawer_int(%d,%d,%s,%d,%d,%d) = %d',
      [C_DEVICENUMBER, rowNumber, description, operationType, amount_2,
      paymentNumber, result]));
end;

function printAnnouncement(rowNumber: integer; text: string): integer;
begin
  text := LeftStr(text, C_LEN_ANNOUCEMENT);
  result := _printAnnouncement(C_DEVICENUMBER, rowNumber,
    PAnsiChar(StrToAStr(text)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_printAnnouncement(%d,%d,%s) = %d',
      [C_DEVICENUMBER, rowNumber, text, result]));
end;

function printAnnouncementNF(rowNumber: integer; text: string): integer;
begin
  text := LeftStr(text, C_LEN_ANNOUCEMENTNF);
  result := _printAnnouncementNF(C_DEVICENUMBER, rowNumber,
    PAnsiChar(StrToAStr(text)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_printAnnouncementNF(%d,%d,%s) = %d',
      [C_DEVICENUMBER, rowNumber, text, result]));
end;

function setPreline(description: string): integer;
begin
  description := LeftStr(description, C_LEN_LINE);
  result := _setPreline(C_DEVICENUMBER, PAnsiChar(StrToAStr(description)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setPreline(%d,%s) = %d', [C_DEVICENUMBER, description,
      result]));
end;

function setPostline(description: string): integer;
begin
  description := LeftStr(description, C_LEN_LINE);
  result := _setPostline(C_DEVICENUMBER, PAnsiChar(StrToAStr(description)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setPostline(%d,%s) = %d', [C_DEVICENUMBER, description,
      result]));
end;

function itemSale_int(rowNumber: integer; commodityName: string;
  totalPrice_2: integer; vat: string; amount_3, unitPrice_4: integer;
  unit1: string): integer;
begin
  commodityName := LeftStr(commodityName + StringOfChar(' ', C_LEN_LINE),
    C_LEN_LINE);
  vat := LeftStr(vat, 1);
  unit1 := LeftStr(unit1, 3);
  result := _itemSale_int(C_DEVICENUMBER, rowNumber,
    PAnsiChar(StrToAStr(commodityName)), totalPrice_2, PAnsiChar(StrToAStr(vat)
    ), amount_3, unitPrice_4, PAnsiChar(StrToAStr(unit1)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_itemSale_int(%d,%d,%s,%d,%s,%d,%d,%s) = %d',
      [C_DEVICENUMBER, rowNumber, commodityName, totalPrice_2, vat, amount_3,
      unitPrice_4, unit1, result]));
end;

function itemReturn_int(rowNumber: integer; commodityName: string;
  totalPrice_2: integer; vat: string; amount_3, unitPrice_4: integer;
  unit1, receiptNumber: string): integer;
begin
  commodityName := LeftStr(commodityName, C_LEN_LINE);
  vat := LeftStr(vat, 1);
  unit1 := LeftStr(unit1, 3);
  receiptNumber := LeftStr(receiptNumber, 44);
  result := _itemReturn_int(C_DEVICENUMBER, rowNumber,
    PAnsiChar(StrToAStr(commodityName)), totalPrice_2, PAnsiChar(StrToAStr(vat)
    ), amount_3, unitPrice_4, PAnsiChar(StrToAStr(unit1)),
    PAnsiChar(StrToAStr(receiptNumber)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_itemReturn_int(%d,%d,%s,%d,%s,%d,%d,%s,%s) = %d',
      [C_DEVICENUMBER, rowNumber, commodityName, totalPrice_2, vat, amount_3,
      unitPrice_4, unit1, receiptNumber, result]));
end;

function itemNegative_int(rowNumber: integer; commodityName: string;
  totalPrice_2: integer; vat: string; amount_3, unitPrice_4: integer;
  unit1: string): integer;
begin
  commodityName := LeftStr(commodityName, C_LEN_LINE);
  vat := LeftStr(vat, 1);
  unit1 := LeftStr(unit1, 3);
  result := _itemNegative_int(C_DEVICENUMBER, rowNumber,
    PAnsiChar(StrToAStr(commodityName)), totalPrice_2, PAnsiChar(StrToAStr(vat)
    ), amount_3, unitPrice_4, PAnsiChar(StrToAStr(unit1)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_itemNegative_int(%d,%d,%s,%d,%s,%d,%d,%s) = %d',
      [C_DEVICENUMBER, rowNumber, commodityName, totalPrice_2, vat, amount_3,
      unitPrice_4, unit1, result]));
end;

function itemDiscount_int(rowNumber: integer; description: string;
  operationType, discountValue_2: integer; vat: string): integer;
begin
  description := LeftStr(description, C_LEN_DISCOUNT);
  vat := LeftStr(vat, 1);
  result := _itemDiscount_int(C_DEVICENUMBER, rowNumber,
    PAnsiChar(StrToAStr(description)), operationType, discountValue_2,
    PAnsiChar(StrToAStr(vat)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_itemDiscount_int(%d,%d,%s,%d,%d,%s) = %d',
      [C_DEVICENUMBER, rowNumber, description, operationType, discountValue_2,
      vat, result]));
end;

function printIssuedParagon(orderNumber: integer; dateTime: string): integer;
begin
  result := _printIssuedParagon(C_DEVICENUMBER, orderNumber,
    PAnsiChar(StrToAStr(dateTime)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_printIssuedParagon(%d,%d,%s) = %d',
      [C_DEVICENUMBER, orderNumber, dateTime, result]));
end;

procedure seRawLogginOff();
begin
  _seRawLogginOff();
  if fSettings.B['ekasa.withLog'] then
    addLog('_seRawLogginOff()');
end;

procedure setRawLogginOn(fileName: string);
begin
  _setRawLogginOn(PAnsiChar(StrToAStr(fileName)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setRawLogginOn(%s)', [fileName]));
end;

function setLocationGPS(vertX, vertY: double): integer;
begin
  result := _setLocationGPS(C_DEVICENUMBER, vertX, vertY);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setLocationGPS(%d,%10.6f,%10.6f) = %d',
      [C_DEVICENUMBER, vertX, vertY, result]));
end;

function setLocationAddress(municipality, street, number, subNumber,
  zip: string): integer;
begin
  result := _setLocationAddress(C_DEVICENUMBER,
    PAnsiChar(StrToAStr(municipality)), PAnsiChar(StrToAStr(street)),
    PAnsiChar(StrToAStr(number)), PAnsiChar(StrToAStr(subNumber)),
    PAnsiChar(StrToAStr(zip)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setLocationAddress(%d,%s,%s,%s,%s,%s) = %d',
      [C_DEVICENUMBER, municipality, street, number, subNumber, zip, result]));
end;

function setLocationOther(description: string): integer;
begin
  result := _setLocationOther(C_DEVICENUMBER,
    PAnsiChar(StrToAStr(description)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setLocationOther(%d,%s) = %d', [C_DEVICENUMBER, description,
      result]));
end;

function printReport_str(reportType: string; reportNumber: integer): integer;
begin
  reportType := LeftStr(reportType, 1);
  result := _printReport_str(C_DEVICENUMBER, PAnsiChar(StrToAStr(reportType)),
    reportNumber);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_printReport_str(%d,%s,%d) = %d', [C_DEVICENUMBER,
      reportType, reportNumber, result]));
end;

function Popis0DPH_str(type1: string): integer;
begin
  result := _Popis0DPH_str(C_DEVICENUMBER, PAnsiChar(StrToAStr(type1)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_Popis0DPH_str(%d,%s) = %d', [C_DEVICENUMBER, type1,
      result]));
end;

function setTransactionID(internalCode: string): integer;
begin
  internalCode := LeftStr(internalCode, C_LEN_50);
  result := _setTransactionID(C_DEVICENUMBER,
    PAnsiChar(StrToAStr(internalCode)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setTransactionID(%d,%s) = %d', [C_DEVICENUMBER,
      internalCode, result]));
end;

function printJournalStructU(paragonSn: string): integer;
begin
  paragonSn := LeftStr(paragonSn, 44);
  result := _printJournalStructU(C_DEVICENUMBER,
    PAnsiChar(StrToAStr(paragonSn)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_printJournalStructU(%d,%s) = %d', [C_DEVICENUMBER,
      paragonSn, result]));
end;

function printDisplay(displayType: integer; escSequence, text: string): integer;
begin
  text := LeftStr(text, C_LEN_LINE);
  result := _printDisplay(C_DEVICENUMBER, displayType,
    PAnsiChar(StrToAStr(escSequence)), PAnsiChar(StrToAStr(text)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_printDisplay(%d,%d,%s,%s) = %d', [C_DEVICENUMBER,
      displayType, escSequence, text, result]));
end;

function clearDisplay(displayType: integer; escSequence: string): integer;
begin
  result := _clearDisplay(C_DEVICENUMBER, displayType,
    PAnsiChar(StrToAStr(escSequence)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_clearDisplay(%d,%d,%s) = %d', [C_DEVICENUMBER, displayType,
      escSequence, result]));

end;

function setEscapeSequence(sequence: string): integer;
begin
  result := _setEscapeSequence(C_DEVICENUMBER, PAnsiChar(StrToAStr(sequence)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setEscapeSequence(%d,%s) = %d', [C_DEVICENUMBER, sequence,
      result]));
end;

function setEmail(email: string): integer;
begin
  email := LeftStr(email, 254);
  result := _setEmail(C_DEVICENUMBER, PAnsiChar(StrToAStr(email)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setEmail(%d,%s) = %d', [C_DEVICENUMBER, email, result]));
end;

function setSMTP(type1, ipAddress, localDir: string; port: integer): integer;
begin
  type1 := '1'; // 0-SMTP, 1-Directory, 2-SMTP + Directory
  ipAddress := '0123456';
  port := 1;
  ipAddress := LeftStr(ipAddress, C_LEN_LINE);
  localDir := LeftStr(localDir, 255);
  result := _setSMTP(C_DEVICENUMBER, PAnsiChar(StrToAStr(type1)),
    PAnsiChar(StrToAStr(ipAddress)), port, PAnsiChar(StrToAStr(localDir)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setSMTP(%d,%s,%s,%d,%s) = %d', [C_DEVICENUMBER, type1,
      ipAddress, port, localDir, result]));
end;

function opravaDokladu(errCode: string): integer;
begin
  result := _opravaDokladu(C_DEVICENUMBER, PAnsiChar(StrToAStr(errCode)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_opravaDokladu(%d,%s) = %d', [C_DEVICENUMBER, errCode,
      result]));
end;

function setSellerID_str(number, type1: string): integer;
begin
  result := _setSellerID_str(C_DEVICENUMBER, PAnsiChar(StrToAStr(number)),
    PAnsiChar(StrToAStr(type1)));
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('_setSellerID_str(%d,%s,%s) = %d', [C_DEVICENUMBER, number,
      type1, result]));

end;

procedure clearVats;
var
  i: integer;
begin
  for i := Low(TVats) to High(TVats) do
    vats[i] := -1;
end;

function isClearVats: boolean;
var
  i: integer;
begin
  result := true;
  for i := Low(TVats) to High(TVats) do
    if vats[i] >= 0 then
    begin
      result := false;
      break;
    end;
end;

function internalReadVariable(variableCode: string;
  onlyVariable: boolean = false): string;
var
  err: integer;
begin
  result := '';
  err := getVariable(variableCode, result);
  if (err <> 0) then
    exit;

  if onlyVariable then
  begin
    if AnsiStartsText(variableCode + C_VAR_SEP, result) then
      System.Delete(result, 1, Length(variableCode + C_VAR_SEP))
    else
      result := '';
  end;
end;

function internalReadStavFM: TStavBowa;
const
  CMD_STAVFM = 'F11';
var
  s: string;
  i: integer;
begin
  s := internalReadVariable(CMD_STAVFM);

  with result do
  begin
    i := Pos(C_VAR_SEP, s);
    PKod := LeftStr(s, i - 1);
    System.Delete(s, 1, i);

    i := Pos(C_VAR_SEP, s);
    StavSDC := StrToInt(LeftStr(s, i - 1));
    System.Delete(s, 1, i);

    i := Pos(C_VAR_SEP, s);
    StavPRN := StrToInt(LeftStr(s, i - 1));
    System.Delete(s, 1, i);

    i := Pos(C_VAR_SEP, s);
    StavPC := StrToInt(LeftStr(s, i - 1));
    System.Delete(s, 1, i);

    i := Pos(C_VAR_SEP, s);
    CRiadku := StrToInt(LeftStr(s, i - 1));
    System.Delete(s, 1, i);

    i := Pos(C_VAR_SEP, s);
    StavS := StrToInt(LeftStr(s, i - 1));
    System.Delete(s, 1, i);

    i := Pos(C_VAR_SEP, s);
    StavF := StrToInt(LeftStr(s, i - 1));
    System.Delete(s, 1, i);

    VerziaF := StrToInt(s);
  end;
end;

function internalReadStavDU: TDUBowa;
const
  CMD_STAVFM = 'E81';
var
  s: string;
  dt: string;
  i: integer;
begin
  s := internalReadVariable(CMD_STAVFM);

  with result do
  begin
    i := Pos(C_VAR_SEP, s);
    PKod := LeftStr(s, i - 1);
    System.Delete(s, 1, i);

    i := Pos(C_VAR_SEP, s);
    CisloDU := StrToInt(LeftStr(s, i - 1));
    System.Delete(s, 1, i);

    i := Pos(C_VAR_SEP, s);
    dt := LeftStr(s, i - 1);
    Insert(FormatSettings.TimeSeparator, dt, 11);
    Insert(' ', dt, 9);
    Insert(FormatSettings.DateSeparator, dt, 5);
    Insert(FormatSettings.DateSeparator, dt, 3);
    DatCasDU := dt;
    System.Delete(s, 1, i);

    i := Pos(C_VAR_SEP, s);
    StavDU := StrToInt(LeftStr(s, i - 1));
    System.Delete(s, 1, i);

    dt := s;
    Insert(FormatSettings.DateSeparator, dt, 5);
    Insert(FormatSettings.DateSeparator, dt, 3);
    DatCasDS := dt;
  end;
end;

function internalReadStavCHDU(): TCHDUBowa;
const
  CMD_B11 = 'B11';
  CMD_F71 = 'F71';
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Clear;
    sl.LineBreak := C_VAR_SEP;
    sl.text := internalReadVariable(CMD_B11);
    with result do
    begin
      chdu := sl.Strings[1] + ' ' + sl.Strings[2];
      lastTransactionNumber := sl.Strings[3];
      storageSize := sl.Strings[7];
      sectorSize := sl.Strings[5];
    end;
    sl.Clear;
    sl.LineBreak := C_VAR_SEP;
    sl.text := internalReadVariable(CMD_F71);
    result.ppekk := Trim(Copy(sl.Strings[4], 12, Length(sl.Strings[4])));
  finally
    sl.Free;
  end;
end;

function internalReadStavSFS(): TSFSBowa;
const
  CMD_B21 = 'B21';
  CMD_B31 = 'B31';
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Clear;
    sl.LineBreak := C_VAR_SEP;
    sl.text := internalReadVariable(CMD_B21);
    result.numberUnsentMessages := sl.Strings[1];

    sl.Clear;
    sl.text := internalReadVariable(CMD_B31);
    result.validitySignatureCertificate := Copy(sl.Strings[1], 1, 2) + '.' +
      Copy(sl.Strings[1], 3, 2) + '.' + Copy(sl.Strings[1], 5, 4);
  finally
    sl.Free;
  end;
end;

procedure internalReadVats();

  function readVat(variableCode: string): currency;
  var
    s: string;
    i: integer;
  begin
    result := -1;
    s := internalReadVariable(variableCode);
    i := Pos(C_VAR_SEP, s);
    if i > 0 then
    begin
      System.Delete(s, 1, i);
      i := Pos(C_VAR_SEP, s);
      if i > 0 then
      begin
        s := LeftStr(s, i - 1);
        result := DecStrToCurrDef(s, -1);
      end;
    end;
  end;

const
  CMD_DPH_A = C_VAR_12 + '1';
  CMD_DPH_B = C_VAR_12 + '2';
  CMD_DPH_C = C_VAR_12 + '3';
  CMD_DPH_D = C_VAR_12 + '4';
  CMD_DPH_E = C_VAR_12 + '5';
begin
  clearVats;
  vats[1] := readVat(CMD_DPH_A);
  vats[2] := readVat(CMD_DPH_B);
  vats[3] := readVat(CMD_DPH_C);
  vats[4] := readVat(CMD_DPH_D);
  vats[5] := readVat(CMD_DPH_E);
end;

procedure internalReadLengthLine();
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Clear;
    sl.LineBreak := C_VAR_SEP;
    sl.text := internalReadVariable('F41');
    C_LEN_LINE := StrToIntDef(sl.Strings[3], 40);
  finally
    sl.Free;
  end;
end;

procedure internalOtvorSmenu;
var
  err: integer;
  stav: TStavBowa;
  date_s: string;
begin
  // Zjistit aktualni stav
  stav := internalReadStavFM;

  if (stav.StavS = 70) then
  begin
    date_s := FormatDateTime('DDMMYYYYHHNNSS', now);
    err := setDateTime(date_s);
    if (err <> 0) then
      exit;
  end;

  stav := internalReadStavFM;
  if (stav.StavS = 113) or (stav.StavS = 114) then
  begin
    err := confirmNote();
    if (err <> 0) then
      exit;
  end
  else if stav.StavS >= 100 then
  begin
    exit;
  end
  else if stav.StavS = 0 then
  begin
    // TODO nastavenie platcu/neplatcu => pokial som toto nenastavil tak mi nechcel pocitat so sadzbou
    err := setParameter(0, ifThenEx(fSettings.B['ekasa.vatPayer'], 0, 1));
    if (err <> 0) then
      exit;
    // zaciatok predajneho dna/smeny
    sellingDayBegin(C_SALEMODE_FISKAL);
  end;
end;

function getReference(): string;
const
  CMD_B41 = 'B41';
var
  CPD, UID, OKP, QRKod, PKP: string;
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Clear;
    sl.LineBreak := C_VAR_SEP;
    sl.text := internalReadVariable(CMD_B41);
    CPD := sl.Strings[1];
    UID := sl.Strings[2];
    OKP := sl.Strings[3];
    QRKod := sl.Strings[4];
    PKP := sl.Strings[5];
  finally
    sl.Free;
  end;

  result := UID;
  if result = 'null' then
  // Pozn·mka: ak nebol doklad skomunikovan˝ na SFS, UID je 0
    result := OKP;
end;

function getBowaDateTime(sDateTime: string): string;
begin
  result := Copy(sDateTime, 9, 2) + Copy(sDateTime, 6, 2) +
    Copy(sDateTime, 1, 4) + // DDMMYYYY
    Copy(sDateTime, 12, 2) + Copy(sDateTime, 15, 2) + Copy(sDateTime, 18, 2);
  // hhnnss
end;

procedure internalInit();
var
  err: integer;
begin
  if not bowaOpen then
  begin
    // spojenie s eKasou bude prebiehat cez "FM GUID CLIENT" EKasaPPEKK_x.bat
    err := openFM(fSettings.s['ekasa.hostAddress']);
    if (err <> 0) then
      exit;
    bowaOpen := true;
  end;
end;

procedure internalClose();
begin
  try
    closeFM();
  finally
    bowaOpen := false;
  end;
end;

function init_eKasaBowa: integer;
const
  C_LIB_NAME = 'FMInterfaceDLL.dll';
  C_VER: TFileVersion = (Build: 1; Release: 0; Minor: 19; Major: 2);
  CMD_B11 = 'B11';
  CMD_F71 = 'F71';
  CMD_B91 = 'B91';
var
  dllPath, s: string;
  sl: TStringList;
  chduVer, ppekkVer, license: integer;
begin
  result := -1;
  isEkasaInit := false;

  if (fSettings.i['ekasa.typ'] = ord(ftEBowa)) then
    if not CheckInstalledPackage(pckgBowa, true) then
      exit;

  if (fSettings.i['ekasa.typ'] = ord(ftEVaros)) then
    if not CheckInstalledPackage(pckgVaros, true) then
      exit;

  if dllHandle = 0 then
  begin
    { Zavedenie DLL }
    dllPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)) +
      'dll') + C_LIB_NAME;
    if not FileExists(dllPath) then
    begin
      lastError := Format('S˙bor "%s" nebol n·jden˝.', [C_LIB_NAME]);
      exit;
    end;

    try
      dllHandle := LoadLibrary(PChar(dllPath));
      if dllHandle = 0 then
      begin
        lastError := 'Nie je moûnÈ zaviesù potrebn˙ dynamick˙ kniûnicu!';
        exit;
      end;
      _openFM := GetProcAddress(dllHandle, 'openFM');
      _closeFM := GetProcAddress(dllHandle, 'closeFM');
      _paragonBegin := GetProcAddress(dllHandle, 'paragonBegin');
      _paragonEnd := GetProcAddress(dllHandle, 'paragonEnd');
      _itemSale_int := GetProcAddress(dllHandle, 'itemSale_int');
      _itemNegative_int := GetProcAddress(dllHandle, 'itemNegative_int');
      _itemDiscount_int := GetProcAddress(dllHandle, 'itemDiscount_int');
      _itemReturn_int := GetProcAddress(dllHandle, 'itemReturn_int');
      _sellingDayBegin := GetProcAddress(dllHandle, 'sellingDayBegin');
      _repeatParagon := GetProcAddress(dllHandle, 'repeatParagon');
      _destroyParagon := GetProcAddress(dllHandle, 'destroyParagon');
      _payment_int := GetProcAddress(dllHandle, 'payment_int');
      _printAnnouncement := GetProcAddress(dllHandle, 'printAnnouncement');
      _printAnnouncementNF := GetProcAddress(dllHandle, 'printAnnouncementNF');
      _setPreline := GetProcAddress(dllHandle, 'setPreline');
      _setPostline := GetProcAddress(dllHandle, 'setPostline');
      _printDisplay := GetProcAddress(dllHandle, 'printDisplay');
      _clearDisplay := GetProcAddress(dllHandle, 'clearDisplay');
      _setEscapeSequence := GetProcAddress(dllHandle, 'setEscapeSequence');
      _setParameter := GetProcAddress(dllHandle, 'setParameter');
      _setDateTime := GetProcAddress(dllHandle, 'setDateTime');
      _printReport_str := GetProcAddress(dllHandle, 'printReport_str');
      _getVariable := GetProcAddress(dllHandle, 'getVariable');
      _depositeInDrawer_int := GetProcAddress(dllHandle,
        'depositeInDrawer_int');
      _confirmNote := GetProcAddress(dllHandle, 'confirmNote');
      _setClientID := GetProcAddress(dllHandle, 'setClientID');
      _printIssuedParagon := GetProcAddress(dllHandle, 'printIssuedParagon');
      _setInvoiceNumber := GetProcAddress(dllHandle, 'setInvoiceNumber');
      _redeemVoucher := GetProcAddress(dllHandle, 'redeemVoucher');
      _redeemVoucher_str := GetProcAddress(dllHandle, 'redeemVoucher_str');
      _getParagonIDs_str := GetProcAddress(dllHandle, 'getParagonIDs_str');
      _getParagonIDs_ResultObject := GetProcAddress(dllHandle,
        'getParagonIDs_ResultObject');
      _getParagonIDs_str_ResultObject := GetProcAddress(dllHandle,
        'getParagonIDs_str_ResultObject');
      _setTransactionID := GetProcAddress(dllHandle, 'setTransactionID');
      _setLocationGPS := GetProcAddress(dllHandle, 'setLocationGPS');
      _setLocationAddress := GetProcAddress(dllHandle, 'setLocationAddress');
      _setLocationOther := GetProcAddress(dllHandle, 'setLocationOther');
      _printUnsentSFSpackets := GetProcAddress(dllHandle,
        'printUnsentSFSpackets');
      _sendUnsentSFSpackets := GetProcAddress(dllHandle,
        'sendUnsentSFSpackets');
      _Popis0DPH_str := GetProcAddress(dllHandle, 'Popis0DPH_str');
      _printJournalStructU := GetProcAddress(dllHandle, 'printJournalStructU');
      _seRawLogginOff := GetProcAddress(dllHandle, 'seRawLogginOff');
      _setRawLogginOn := GetProcAddress(dllHandle, 'setRawLogginOn');
      _setSMTP := GetProcAddress(dllHandle, 'setSMTP');
      _setEmail := GetProcAddress(dllHandle, 'setEmail');
      _opravaDokladu := GetProcAddress(dllHandle, 'opravaDokladu');
      _setSellerID_str := GetProcAddress(dllHandle, 'setSellerID_str');
      _synchronizationToPPEKK := GetProcAddress(dllHandle,
        'synchronizationToPPEKK');
      _setLicense := GetProcAddress(dllHandle, 'setLicense');
      _getLastTransactionPackets := GetProcAddress(dllHandle,
        'getLastTransactionPackets');
    except
      lastError := 'Nie je moûnÈ zaviesù potrebn˙ dynamick˙ kniûnicu!';
      exit;
    end;
  end;

  if (cashRoundSupport = -1) then
  begin
    internalInit();
    try
      if bowaOpen then
      begin
        cashRoundSupport := 0;
        sl := TStringList.Create;
        try
          // chdu
          sl.Clear;
          sl.LineBreak := C_VAR_SEP;
          sl.text := internalReadVariable(CMD_B11);
          s := sl.Strings[2];
          s := StringReplace(s, '.', '', [rfReplaceAll]);
          chduVer := StrToInt(s);
          // ppekk
          sl.Clear;
          sl.LineBreak := C_VAR_SEP;
          sl.text := internalReadVariable(CMD_F71);
          s := UpperCase(sl.Strings[4]);
          s := StringReplace(s, 'BOWA S.R.O. EKASASK1 ', '', [rfReplaceAll]);
          // F71;121;21;1.4b01;BOWA s.r.o. eKasaSK1 1.4d
          // F71;122;22;1.4b01;BOWA s.r.o. eKasaSK1 1.5d
          s := DelNotNumChar(s);
          ppekkVer := StrToInt(s);
          // licenia pre zaokruhlovanie
          sl.Clear;
          sl.LineBreak := C_VAR_SEP;
          sl.text := internalReadVariable(CMD_B91);
          s := UpperCase(sl.Strings[1]);
          license := StrToIntDef(s, 0);
          // Momentalne platne kombinacie su
          // CHDU CHDUA1 1.3 - PPEKK eKasaSK1 1.4/1.5 a CHDU CHDUA1 2.3 - PPEKK eKasaSK1 2.4
          // plus musi mat aktivnu licenciu
          if ((chduVer >= 13) and (ppekkVer >= 14)) or
            ((chduVer >= 23) and (ppekkVer >= 24)) then
          begin
            cashRoundSupport := ifThenEx(license = 1, 1, -1);
          end;
        finally
          sl.Free;
        end;
      end;
    finally
      internalClose();
    end;
  end;

  isEkasaInit := (cashRoundSupport = 0) or (cashRoundSupport = 1);
  if isEkasaInit then
    result := 0;
end;

function eKasaBowaInit: boolean;
begin
  if not isEkasaInit then
  begin
    init_eKasaBowa;
  end;
  result := isEkasaInit;
end;

function stavStr(stav: integer): string;
begin
  case stav of
    0:
      result := rs_S0;
    1:
      result := rs_S1;
    2:
      result := rs_S2;
    3:
      result := rs_S3;
    4:
      result := rs_S4;
    10:
      result := rs_S10;
    20:
      result := rs_S20;
    70:
      result := rs_S70;
    100:
      result := rs_S100;
    101:
      result := rs_S101;
    102:
      result := rs_S102;
    103:
      result := rs_S103;
    104:
      result := rs_S104;
    105:
      result := rs_S105;
    106:
      result := rs_S106;
    107:
      result := rs_S107;
    108:
      result := rs_S108;
    109:
      result := rs_S109;
    113:
      result := rs_S113;
    114:
      result := rs_S114;
  else
    result := '';
  end;
end;

function errorStr(errCode: integer): string;
var
  s, addError: string;
  PPEKK_LAST_ERROR, SFS_LAST_ERROR: integer;
begin
  addError := '';
  s := internalReadVariable(C_VAR_B51);
  System.Delete(s, 1, Pos(C_VAR_SEP, s));
  PPEKK_LAST_ERROR := StrToIntDef(LeftStr(s, Pos(C_VAR_SEP, s) - 1), 0);
  System.Delete(s, 1, Pos(C_VAR_SEP, s));
  System.Delete(s, 1, Pos(C_VAR_SEP, s));
  SFS_LAST_ERROR := StrToIntDef(s, 0);

  if (PPEKK_LAST_ERROR = 20) then
    addError := sfsErrorStr(SFS_LAST_ERROR)
  else
    addError := ppekkErrorStr(PPEKK_LAST_ERROR);

  case errCode of
    $20:
      result := rs_Err20H;
    $21:
      result := rs_Err21H;
    $22:
      result := rs_Err22H;
    $23:
      result := rs_Err23H;
    $24:
      result := rs_Err24H;
    $25:
      result := rs_Err25H;
    $26:
      result := rs_Err26H;
    $27:
      result := rs_Err27H;
    $28:
      result := rs_Err28H;
    $2A:
      result := rs_Err2AH;
    //
    $30:
      result := rs_Err30H;
    $31:
      result := rs_Err31H;
    $32:
      result := rs_Err32H;
    $33:
      result := rs_Err33H;
    $34:
      result := rs_Err34H;
    //
    $40:
      result := rs_Err40H;
    $41:
      result := rs_Err41H;
    $42:
      result := rs_Err42H;
    $43:
      result := rs_Err43H;
    //
    $50:
      result := rs_Err50H;
    $51:
      result := rs_Err51H;
    $52:
      result := rs_Err52H;
    $53:
      result := rs_Err53H;
    $54:
      result := rs_Err54H;
    $55:
      result := rs_Err55H;
    $56:
      result := rs_Err56H;
    $57:
      result := rs_Err57H;
    $58:
      result := rs_Err58H;
    $59:
      result := rs_Err59H;
    //
    $60:
      result := rs_Err60H;
    $61:
      result := rs_Err61H;
    $62:
      result := rs_Err62H;
    $63:
      result := rs_Err63H;
    $64:
      result := rs_Err64H;
    $65:
      result := rs_Err65H;
    $66:
      result := rs_Err66H;
    $67:
      result := rs_Err67H;
    $68:
      result := rs_Err68H;
    $69:
      result := rs_Err69H;
    $6A:
      result := rs_Err6AH;
    $6B:
      result := rs_Err6BH;
    $6C:
      result := rs_Err6CH;
    $6D:
      result := rs_Err6DH;
    //
    $81:
      result := rs_Err81H;
    $82:
      result := rs_Err82H;
    $83:
      result := rs_Err83H;
    $84:
      result := rs_Err84H;
    $85:
      result := rs_Err85H;
    //
    $90 .. $B5:
      result := Format('(%d) SFS vr·til chybu odoslanej spr·vy:', [errCode]);
    //
    $D0:
      result := rs_ErrD0H;
    $D1:
      result := rs_ErrD1H;
    $FD:
      result := rs_ErrFDH;
    $FE:
      result := rs_ErrFEH;
  else
    result := IntToStr(errCode);
  end;
  result := result + #13 + addError;
end;

function sfsError(errCode: integer): boolean;
begin
  result := ((errCode >= 144) and (errCode <= 181));
end;

function sfsErrorStr(errCode: integer): string;
begin
  case errCode of
    - 1:
      result := '(-1) Server FS je zanepr·zdnen˝';
    -2:
      result := rs_SFS_Err_2;
    -8:
      result := rs_SFS_Err_8;
    -10:
      result := rs_SFS_Err_10;
    -12:
      result := rs_SFS_Err_12;
    -13:
      result := rs_SFS_Err_13;
    -100:
      result := rs_SFS_Err_100;
    -101:
      result := rs_SFS_Err_101;
    -102:
      result := rs_SFS_Err_102;
    -103:
      result := rs_SFS_Err_103;
    -104:
      result := rs_SFS_Err_104;
    -105:
      result := rs_SFS_Err_105;
    -106:
      result := rs_SFS_Err_106;
    -107:
      result := rs_SFS_Err_107;
    -108:
      result := rs_SFS_Err_108;
    -109:
      result := rs_SFS_Err_109;
    -110:
      result := rs_SFS_Err_110;
    -111:
      result := rs_SFS_Err_111;
    -112:
      result := rs_SFS_Err_112;
    -113:
      result := rs_SFS_Err_113;
    -114:
      result := rs_SFS_Err_114;
    -115:
      result := rs_SFS_Err_115;
    -116:
      result := rs_SFS_Err_116;
    -117:
      result := rs_SFS_Err_117;
    -118:
      result := rs_SFS_Err_118;
    -119:
      result := rs_SFS_Err_119;
    -120:
      result := rs_SFS_Err_120;
    -121:
      result := rs_SFS_Err_121;
    -122:
      result := rs_SFS_Err_122;
    -123:
      result := rs_SFS_Err_123;
    -124:
      result := rs_SFS_Err_124;
    -125:
      result := rs_SFS_Err_125;
    -126:
      result := rs_SFS_Err_126;
    -127:
      result := rs_SFS_Err_127;
    -128:
      result := rs_SFS_Err_128;
    -129:
      result := rs_SFS_Err_129;
    -130:
      result := rs_SFS_Err_130;
    -131:
      result := rs_SFS_Err_131;
    -132:
      result := rs_SFS_Err_132;
  end;
end;

function ppekkErrorStr(errCode: integer): string;
begin
  case errCode of
    1:
      result := rs_PPEKK_Err_1;
    2:
      result := rs_PPEKK_Err_2;
    3:
      result := rs_PPEKK_Err_3;
    4:
      result := rs_PPEKK_Err_4;
    5:
      result := rs_PPEKK_Err_5;
    6:
      result := rs_PPEKK_Err_6;
    7:
      result := rs_PPEKK_Err_7;
    8:
      result := rs_PPEKK_Err_8;
    9:
      result := rs_PPEKK_Err_9;
    10:
      result := rs_PPEKK_Err_10;
    11:
      result := rs_PPEKK_Err_11;
    12:
      result := rs_PPEKK_Err_12;
    13:
      result := rs_PPEKK_Err_13;
    14:
      result := rs_PPEKK_Err_14;
    15:
      result := rs_PPEKK_Err_15;
    16:
      result := rs_PPEKK_Err_16;
    17:
      result := rs_PPEKK_Err_17;
    18:
      result := rs_PPEKK_Err_18;
    19:
      result := rs_PPEKK_Err_19;
    20:
      result := rs_PPEKK_Err_20;
    21:
      result := rs_PPEKK_Err_21;
    22:
      result := rs_PPEKK_Err_22;
    23:
      result := rs_PPEKK_Err_23;
    24:
      result := rs_PPEKK_Err_24;
    25:
      result := rs_PPEKK_Err_25;
    26:
      result := rs_PPEKK_Err_26;
    27:
      result := rs_PPEKK_Err_27;
    28:
      result := rs_PPEKK_Err_28;
    29:
      result := rs_PPEKK_Err_29;
    30:
      result := rs_PPEKK_Err_30;
    31:
      result := rs_PPEKK_Err_31;
    32:
      result := rs_PPEKK_Err_32;
    33:
      result := rs_PPEKK_Err_33;
    34:
      result := rs_PPEKK_Err_34;
    35:
      result := rs_PPEKK_Err_35;
    36:
      result := rs_PPEKK_Err_36;
    37:
      result := rs_PPEKK_Err_37;
    38:
      result := rs_PPEKK_Err_38;
    39:
      result := rs_PPEKK_Err_39;
    40:
      result := rs_PPEKK_Err_40;
    41:
      result := rs_PPEKK_Err_41;
    42:
      result := rs_PPEKK_Err_42;
    43:
      result := rs_PPEKK_Err_43;
    44:
      result := rs_PPEKK_Err_44;
    45:
      result := rs_PPEKK_Err_45;
    46:
      result := rs_PPEKK_Err_46;
    47:
      result := rs_PPEKK_Err_47;
    48:
      result := rs_PPEKK_Err_48;
    49:
      result := rs_PPEKK_Err_49;
    50:
      result := rs_PPEKK_Err_50;
    51:
      result := rs_PPEKK_Err_51;
    52:
      result := rs_PPEKK_Err_52;
    53:
      result := rs_PPEKK_Err_53;
  end;
end;

procedure incRowNumber(out rowNumber: integer);
begin
  Inc(rowNumber);
  rowNumber := (rowNumber mod 10);
end;

function bowaState: string;
var
  stav: TStavBowa;
  DU: TDUBowa;
  CHDUBowa: TCHDUBowa;
  SFSBowa: TSFSBowa;
  o: ISuperObject;
begin
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      stav := internalReadStavFM();
      DU := internalReadStavDU();
      CHDUBowa := internalReadStavCHDU();
      SFSBowa := internalReadStavSFS();
      if isClearVats then
        internalReadVats();
      o := SO();
      o.s['arr[]'] := 'Status ekasy';
      o.s['arr[]'] := '=========================';
      o.s['arr[]'] := Format('stav µSD karty: %d (0=OK, 1=chybn·)',
        [stav.StavSDC]);
      o.s['arr[]'] := Format('stav tlaËiarne: %d (0=aktÌvna, 1=obsaden·)',
        [stav.StavPRN]);
      o.s['arr[]'] := Format('stav PC: %d (0=pripojenÈ, 1= odpojenÈ)',
        [stav.StavPC]);
      o.s['arr[]'] :=
        'ËÌslo riadku poslednÈho vykonanÈho prÌkazu v r·mci otvorenej';
      o.s['arr[]'] := Format('˙Ëtenky: %d', [stav.CRiadku]);
      o.s['arr[]'] :=
        Format('stav procesu: S%d%s (S0-S4, S10, S20, S70 ñprocesnÈ, >=S100 -chybovÈ)',
        [stav.StavS, ' ' + stavStr(stav.StavS)]);
      o.s['arr[]'] :=
        Format('stav fiskaliz·cie: %d (1=po fiskaliz·cii, 0=pred fiskaliz·ciou/SK⁄äKA POKLADNICE)',
        [stav.StavF]);
      o.s['arr[]'] := Format('verzia firmware: %d (zmeny firmware)',
        [stav.VerziaF]);
      o.s['arr[]'] := '';
      o.s['arr[]'] := 'Sadzby DPH';
      o.s['arr[]'] := '=========================';
      o.s['arr[]'] := Format('A = %6.2f%%', [vats[1]]);
      o.s['arr[]'] := Format('B = %6.2f%%', [vats[2]]);
      o.s['arr[]'] := Format('C = %6.2f%%', [vats[3]]);
      o.s['arr[]'] := Format('D = %6.2f%%', [vats[4]]);
      o.s['arr[]'] := Format('E = %6.2f%%', [vats[5]]);
      o.s['arr[]'] := 'Stav dennej uz·vierky';
      o.s['arr[]'] := '=========================';
      o.s['arr[]'] := Format('ËÌslo poslednej vykonanej DU: %d', [DU.CisloDU]);
      o.s['arr[]'] := Format('d·tum a Ëas poslednej vykonanej DU: %s',
        [DU.DatCasDU]);
      o.s['arr[]'] :=
        Format('DU v r·mci dna uû bola: %d (0=nevykonan·, 1=vykonan·)',
        [DU.StavDU]);
      o.s['arr[]'] := Format('d·tum otvorenia poslednej smeny: %s',
        [DU.DatCasDS]);
      o.s['arr[]'] := 'VyËÌtanie stavu CHD⁄ a PPEKK';
      o.s['arr[]'] := '=========================';
      o.s['arr[]'] := Format('CHD⁄: %s', [CHDUBowa.chdu]);
      o.s['arr[]'] := Format('PPEKK: %s', [CHDUBowa.ppekk]);
      o.s['arr[]'] := Format('»Ìslo poslednej transakcie: %s',
        [CHDUBowa.lastTransactionNumber]);
      o.s['arr[]'] := Format('Veækosù ˙loûiska: %s', [CHDUBowa.storageSize]);
      o.s['arr[]'] := Format('Veækosù sektora: %s', [CHDUBowa.sectorSize]);
      o.s['arr[]'] := 'NeodoslanÈ spr·vy na SFS';
      o.s['arr[]'] := '=========================';
      o.s['arr[]'] := Format('PoËet neodoslan˝ch spr·v na SFS: %s',
        [SFSBowa.numberUnsentMessages]);
      o.s['arr[]'] := Format('Platnosù podpisovÈho certifik·tu SFS: %s',
        [SFSBowa.validitySignatureCertificate]);
      result := o['arr'].AsString;
    end
    else
      result := rs_connection_error;
  finally
    internalClose();
  end;
end;

function bowaCopyLast(): string;
var
  err: integer;
begin
  err := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      err := repeatParagon();
      if (err <> 0) then
        exit;

      result := '{"message":"OK"}';
    end;
  finally
    if (err <> 0) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
    internalClose();
  end;
end;

function bowaCopyByUuid(): string;
const
  C_LEN_BUFF = 1024;
var
  err: integer;
  Buff: array [1 .. C_LEN_BUFF] of AnsiChar;
  sl: TStringList;
  uuidCopy: string;
begin
  err := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      uuidCopy := paramByName('uuid', reqParams);
      if (uuidCopy = '') then
        exit;

      err := _getParagonIDs_str(C_DEVICENUMBER, PAnsiChar(StrToAStr('2')),
        PAnsiChar(StrToAStr(uuidCopy)), @Buff, C_LEN_BUFF);

      if err = 0 then
      begin
        sl := TStringList.Create;
        try
          sl.Clear;
          sl.LineBreak := C_VAR_SEP;
          sl.text := AStrToStr(StrPas(PAnsiChar(@Buff)));
          err := printJournalStructU(sl.Strings[2]);
        finally
          sl.Free;
        end;
      end;

      result := '{"message":"OK"}';
    end;
  finally
    if (err <> 0) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
    internalClose();
  end;
end;

function bowaReceipt(): string;
var
  err: integer;
  reqObj: ISuperObject;
  rowNumber: integer;
  operationType: integer;
  amount_2: integer;
  description, uidOkp: string;
  vat, s: string;
  totalPrice_2: integer;
  amount_3: integer;
  unitPrice_4: integer;
  text: string;
  bRefund, vatPayer: boolean;
  item: ISuperObject;
  commodityName: string;
  total_2, payedAmount_2: integer;

  function checkRefund: boolean;
  var
    item: ISuperObject;
  begin
    result := false;
    for item in reqObj['ReceiptData.Items'] do
    begin
      if (item.C['Quantity'] < 0) then
      begin
        if not(isReturnType(item.s['Custom.Unit'])) then
        begin
          result := true;
          break;
        end;
      end
      else
      begin
        result := false;
        break;
      end;
    end;
  end;

  function get_vatID(vatRate: string): string;
  var
    vatRateCurr: currency;
  begin
    vatRate := ReplaceStr(vatRate, '%', '');
    vatRate := ReplaceStr(vatRate, 'OOD', '');
    vatRate := ReplaceStr(vatRate, 'PDP', '');
    vatRate := ReplaceStr(vatRate, 'CK', '');
    vatRate := ReplaceStr(vatRate, 'PT', '');
    vatRate := ReplaceStr(vatRate, 'UD', '');
    vatRate := ReplaceStr(vatRate, 'ZPS', '');
    vatRate := ReplaceStr(vatRate, 'INE', '');
    vatRateCurr := StrToCurrDef(vatRate, 0);
    result := C_VAT_A;
    if vats[1] = vatRateCurr then
      result := C_VAT_A
    else if vats[2] = vatRateCurr then
      result := C_VAT_B
    else if vats[3] = vatRateCurr then
      result := C_VAT_C
    else if vats[4] = vatRateCurr then
      result := C_VAT_D
    else if vats[5] = vatRateCurr then
      result := C_VAT_E
  end;

  function specialRegulation(taxType: string): string;
  begin
    result := '2';
    if (taxType = 'OOD') then
      result := '1'
    else if (taxType = 'PDP') then
      result := '0'
    else if (taxType = 'CK') then
      result := '2'
    else if (taxType = 'PT') then
      result := '3'
    else if (taxType = 'UD') then
      result := '4'
    else if (taxType = 'ZPS') then
      result := '5';
  end;

  function get_SellerIdType(sellerIdType: string): string;
  begin
    if (sellerIdType = 'DIC') then
      result := '0'
    else if (sellerIdType = 'IC_DPH') then
      result := '1'
    else
      result := '0';
  end;

begin
  err := 0;
  rowNumber := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      reqObj := SO(reqData);

      if (reqObj.s['ReceiptData.ReceiptType'] = 'PD') then
      begin
        // printPosReceipt();

        bRefund := checkRefund();
        if isClearVats then
          internalReadVats();
        if (C_LEN_LINE = 0) then
          internalReadLengthLine();

        err := setSMTP('1', '', fSettings.s['ekasa.mailPath'], 1);
        if (err <> 0) then
          exit;
        // zaciatok predajneho dna/smeny
        internalOtvorSmenu;
        vatPayer := fSettings.B['ekasa.vatPayer'];
        err := paragonBegin(rowNumber, ifThenEx(vatPayer, C_SALETYPE_0,
          C_SALETYPE_1), C_TYPPRENOSU_ROW, C_PARAGONTYPE_PLUS, C_TYPREKAP_SHORT,
          fSettings.i['ekasa.headerBitmap']);
        if (err <> 0) then
          exit;

        // Nastavenie ID interneho kodu nadradenej app (jedinecnost riesi aplikacia)
        err := setTransactionID(reqObj.s['Uuid']);
        if (err <> 0) then
          exit;

        // identifikacia dokladu ako paragonu
        if (reqObj.B['ReceiptData.Paragon']) then
        begin
          err := printIssuedParagon
            (StrToIntDef(reqObj.s['ReceiptData.ParagonNumber'], 1),
            getBowaDateTime(reqObj.s['ReceiptData.IssueDate']));
          if (err <> 0) then
            exit;
        end;

        for item in reqObj['ReceiptData.Items'] do
        begin

          vat := get_vatID(item.s['VatRate']);
          amount_3 := Trunc(Zaok(item.C['Quantity'] * 1000, 0, 0));
          totalPrice_2 := Trunc(Zaok(item.C['Price'] * 100, 0, 0));
          unitPrice_4 := Trunc(Zaok(item.C['Custom.PriceUnit'] * 10000, 0, 0));

          // tlac celeho nazvu, alebo jeho orezanie na dlzku 40 znakov
          // TODO ??? otazka na tych malych prn pegassino
          commodityName := item.s['Name'];
          if (Length(commodityName) > C_LEN_LINE) then
          begin
            if fSettings.B['ekasa.printFullName'] then
            begin
              text := LeftStr(commodityName, C_LEN_LINE);
              err := setPreline(text);
              if (err <> 0) then
                exit;
              System.Delete(commodityName, 1, C_LEN_LINE);
            end;
            commodityName := LeftStr(commodityName, C_LEN_LINE);
          end;

          // Pokial je cenaMJ na viac ako 2DM, tak vypisat
          if (decPlCount(item.C['Custom.PriceUnit']) > 2) then
          begin
            description := Format(rs_JednotkovaCena,
              [value_x(item.C['Custom.PriceUnit'],
              decPlCount(item.C['Custom.PriceUnit']))]);
            err := setPostline(description);
            if (err <> 0) then
              exit;
          end;
          (*
            KLADN¡        K  Kladn· poloûka ñ suma poloûky za predaj tovaru alebo poskytnutie sluûby
            VRATEN…OBALY  VO Z·porn· poloûka - suma poloûky za vyk˙penÈ z·lohovanÈ obaly
            VRATEN¡       V  Z·porn· poloûka - zruöenie evidovanej poloûky po jej vystavenÌ na pokladniËnom doklade pri vr·tenÌ tovaru alebo sluûby
            OPRAVN¡       O  Kladn· alebo z·porn· poloûka - neg·cia poloûky uû zaevidovanÈho dokladu v systÈme e-kasa v prÌpade jej opravy
            ZºAVA         Z  Z·porn· poloûka ñ suma poskytnut˝ch zliav
          *)
          { K - kladna polozka (+)
            VO - vratne obaly (-)
            V - vratenie (-)
            O - opravna (+/-)
            Z - zlava (-)
            OZ - odpocet zalohy (-)
            VP - vymennny poukaz (-) }

          if (item.s['ItemType'] = 'K') then
          begin
            incRowNumber(rowNumber);
            err := itemSale_int(rowNumber, commodityName, totalPrice_2, vat,
              amount_3, unitPrice_4, item.s['Custom.Unit']);
            if (err <> 0) then
              exit;
          end

          else if (item.s['ItemType'] = 'Z') then
          begin
            operationType := C_ITEMDISCOUNT_SLEVAHOD;
            description := item.s['Name'];
            totalPrice_2 := Trunc(Zaok(item.C['Price'] * 100, 0, 0));
            incRowNumber(rowNumber);
            err := itemDiscount_int(rowNumber, description, operationType,
              totalPrice_2, vat);
            if (err <> 0) then
              exit;
          end

          else if MatchStr(UpperCase(item.s['ItemType']), ['V', 'VO', 'O']) then
          begin
            amount_3 := amount_3 * -1;
            unitPrice_4 := unitPrice_4 * -1;

            if (isReturnType(item.s['Custom.Unit'])) then
            begin
              incRowNumber(rowNumber);
              err := itemNegative_int(rowNumber, commodityName, totalPrice_2,
                vat, amount_3, unitPrice_4, item.s['Custom.Unit']);
              if (err <> 0) then
                exit;
            end
            else
            begin
              incRowNumber(rowNumber);
              err := itemReturn_int(rowNumber, commodityName, totalPrice_2, vat,
                amount_3, unitPrice_4, item.s['Custom.Unit'],
                item.s['ReferenceReceiptId']);
              if (err <> 0) then
                exit;
            end;

          end;

          // priznak, ktory blizsie specifikuje priradenie dane s hodnotou 0
          if (item.s['SpecialRegulation'] <> '') then
          begin
            err := Popis0DPH_str
              (specialRegulation(item.s['SpecialRegulation']));
            if (err <> 0) then
              exit;
          end;

          // identifikacia predavajuceho v ktoreho mene bol predany tovar, alebo poskytnuta sluzba
          if not Empty(item.s['SellerId']) then
          begin
            err := setSellerID_str(item.s['SellerId'],
              get_SellerIdType(item.s['SellerIdType']));
            if err <> 0 then
              exit;
          end;

        end;

        // Zaslanie dokladu mailom
        if not Empty(reqObj.s['ReceiptData.Custom.Email']) then
          if not Empty(fSettings.s['ekasa.mailPath']) then
          begin
            err := setEmail(reqObj.s['ReceiptData.Custom.Email']);
            if (err <> 0) then
              exit;
          end;

        // PLATBY - UHRADY
        total_2 := Trunc(Zaok(reqObj.C['ReceiptData.Amount'] * 100, 0, 0));
        // celkove sucty
        if bRefund then
        begin // pri storno/vrateni nie je povolena kombinacia platieb
          if (reqObj.C['ReceiptData.Custom.PaymentCard'] <> 0) then
          begin
            // Karta - storno/vratenie - posiela sa nezaokruhlena hodnota sumy dokladu celkom
            payedAmount_2 :=
              Trunc(Zaok(reqObj.C['ReceiptData.Custom.PaymentCard'] *
              100, 0, 0));
            description := rs_PAYMENTTYPE_KARTA;
            incRowNumber(rowNumber);
            err := payment_int(rowNumber, C_PAYMENTTYPE_KARTA, total_2,
              payedAmount_2, 0, description);
            if (err <> 0) then
              exit;
          end
          else
          begin
            // Hotovost - storno/vratenie - posiela sa zaokruhlena hodnota sumy dokladu celkom na 5 centy
            // v tomto pripade ju uz tak mam zaokruhlenu v dmAgendy.mdtKasaPLATENE.AsCurrency
            payedAmount_2 :=
              Trunc(Zaok(reqObj.C['ReceiptData.Custom.PaymentCash'] -
              reqObj.C['ReceiptData.Custom.CashReturn'] * 100, 0, 0));
            description := rs_PAYMENTTYPE_HOTOV;
            incRowNumber(rowNumber);
            err := payment_int(rowNumber, C_PAYMENTTYPE_HOTOV, total_2,
              payedAmount_2, 0, description);
            if (err <> 0) then
              exit;
          end;
        end
        else
        begin
          // Sek - nesmie sa preplacat
          payedAmount_2 :=
            Trunc(Zaok(reqObj.C['ReceiptData.Custom.PaymentCheck'] *
            100, 0, 0));
          if (total_2 > 0) and (payedAmount_2 > 0) then
          begin // protoze na sek nelze vracet, testujeme total_2 na > 0
            description := rs_PAYMENTTYPE_SEK;
            incRowNumber(rowNumber);
            err := payment_int(rowNumber, C_PAYMENTTYPE_SEK, total_2,
              payedAmount_2, 0, description);
            if (err <> 0) then
              exit;
            if (total_2 > 0) and (payedAmount_2 > total_2) then
              payedAmount_2 := total_2;
            total_2 := total_2 - payedAmount_2
          end;
          // Karta - moze sa preplacat
          payedAmount_2 :=
            Trunc(Zaok(reqObj.C['ReceiptData.Custom.PaymentCard'] * 100, 0, 0));
          if (total_2 <> 0) and (payedAmount_2 <> 0) then
          begin
            description := rs_PAYMENTTYPE_KARTA;
            incRowNumber(rowNumber);
            err := payment_int(rowNumber, C_PAYMENTTYPE_KARTA, total_2,
              payedAmount_2, 0, description);
            if (err <> 0) then
              exit;
            if (total_2 > 0) and (payedAmount_2 > total_2) then
              payedAmount_2 := total_2;
            total_2 := total_2 - payedAmount_2
          end;
          // Uver - nesmie sa preplacat
          payedAmount_2 :=
            Trunc(Zaok(reqObj.C['ReceiptData.Custom.PaymentOther'] *
            100, 0, 0));
          if (total_2 > 0) and (payedAmount_2 > total_2) then
            payedAmount_2 := total_2;
          if (total_2 > 0) and (payedAmount_2 > 0) then
          begin // protoze na uver nelze vracet, testujeme total_2 na > 0
            description := rs_PAYMENTTYPE_UVER;
            incRowNumber(rowNumber);
            err := payment_int(rowNumber, C_PAYMENTTYPE_UVER, total_2,
              payedAmount_2, 0, description);
            if (err <> 0) then
              exit;
            total_2 := total_2 - payedAmount_2
          end;
          // Hotovost - moze sa preplacat
          payedAmount_2 :=
            Trunc(Zaok((reqObj.C['ReceiptData.Custom.PaymentCash'] -
            reqObj.C['ReceiptData.Custom.CashReturn']) * 100, 0, 0));
          if (total_2 <> 0) and
            ((payedAmount_2 <> 0) or (reqObj.C['ReceiptData.Custom.CashReturn']
            <> 0)) then
          begin
            description := rs_PAYMENTTYPE_HOTOV;
            incRowNumber(rowNumber);
            err := payment_int(rowNumber, C_PAYMENTTYPE_HOTOV, total_2,
              payedAmount_2, 0, description);
            if (err <> 0) then
              exit;
          end;
        end;
        (*
          // tlac potvrdenia z POS
          // 1. => pouziva sa POS a bola platba kartou
          if ((CardPOS.EPType = eptCSOB_ECR2) and
          (CardPOS.EPTypStvrzenky in [ord(tsBoth),ord(tsCustomer)]) and
          (dmFm.tblHlvPLATKAR.AsCurrency <> 0)) then
          // 2. => POS netlaci potvrdenku a mame nejake data pre tlac potvrdenku
          if ((CardPOS.EPTerminalTisk = false) and (CardPOS.CardPOSTransaction.IsEmpty = false)) then begin
          incRowNumber(rowNumber);
          err := printAnnouncement(rowNumber, ' ');
          if (err <> 0) then exit;
          incRowNumber(rowNumber);
          err := printAnnouncement(rowNumber, 'Potvrdenka pre z·kaznÌka');
          if (err <> 0) then exit;
          incRowNumber(rowNumber);
          err := printAnnouncement(rowNumber, '------------------------');
          if (err <> 0) then exit;

          sl := TStringList.Create;
          try
          sl.LineBreak := #$D#$A;
          sl.Text := CardPOS.CardPOSTransaction.PrintedText(true, tsCustomer);
          for i := 0 to sl.Count - 1 do begin
          incRowNumber(rowNumber);
          err := printAnnouncement(rowNumber, sl.Strings[i]);
          if (err <> 0) then exit;
          end;
          finally
          sl.Free;
          end;
          incRowNumber(rowNumber);
          err := printAnnouncement(rowNumber, ' ');
          if (err <> 0) then exit;
          end;
        *)
        // ukoncit paragon
        incRowNumber(rowNumber);
        err := paragonEnd(rowNumber, fSettings.i['ekasa.footerBitmap']);
        if (err <> 0) then
          exit;

        uidOkp := getReference();
        result := Format
          ('{"message":"Doklad UID:%s ˙speöne zaevidovan˝ a odoslan˝ do tlaËiarne.",'
          + '"uid":"%s"}', [uidOkp, uidOkp]);

        if sfsError(err) then
          result := Format
            ('{"message":"Doklad UID:%s ˙speöne zaevidovan˝ a odoslan˝ do tlaËiarne.",'
            + '"uid":"%s",' + '"messageAdd":"%s"}',
            [uidOkp, uidOkp, sfsErrorStr(err)]);

      end;

      if (reqObj.s['ReceiptData.ReceiptType'] = 'UF') then
      begin
        if isClearVats then
          internalReadVats();
        if (C_LEN_LINE = 0) then
          internalReadLengthLine();

        err := setSMTP('1', '', fSettings.s['ekasa.mailPath'], 1);
        if (err <> 0) then
          exit;
        // zaciatok predajneho dna/smeny
        internalOtvorSmenu;
        err := paragonBegin(rowNumber, C_SALETYPE_9, C_TYPPRENOSU_ROW,
          C_PARAGONTYPE_PLUS, C_TYPREKAP_SHORT, C_GRAPHICSHDR_NO);
        if (err <> 0) then
          exit;

        // Nastavenie ID interneho kodu nadradenej app (jedinecnost riesi aplikacia)
        err := setTransactionID(reqObj.s['Uuid']);
        if (err <> 0) then
          exit;

        // identifikacia dokladu ako paragonu
        if (reqObj.B['ReceiptData.Paragon']) then
        begin
          err := printIssuedParagon
            (StrToIntDef(reqObj.s['ReceiptData.ParagonNumber'], 1),
            getBowaDateTime(reqObj.s['ReceiptData.IssueDate']));
          if (err <> 0) then
            exit;
        end;

        vat := C_VAT_A; // Faktura ma tabulkovy index A
        totalPrice_2 := Trunc(Zaok(reqObj.C['ReceiptData.Amount'] * 100, 0, 0));
        amount_3 := Trunc(Zaok(1 * 1000, 0, 0));
        unitPrice_4 :=
          Trunc(Zaok(Abs(reqObj.C['ReceiptData.Amount']) * 10000, 0, 0));
        s := LeftStr(rs_Uhrada + reqObj.s['ReceiptData.InvoiceNumber'],
          C_LEN_LINE);
        //
        incRowNumber(rowNumber);
        if (reqObj.C['ReceiptData.Amount'] < 0) then
        begin
          totalPrice_2 := totalPrice_2 * -1;
          err := itemReturn_int(rowNumber, s, totalPrice_2, vat, amount_3,
            unitPrice_4, '', '');
          if (err <> 0) then
            exit;
        end
        else
        begin
          err := itemSale_int(rowNumber, s, totalPrice_2, vat, amount_3,
            unitPrice_4, '');
          if (err <> 0) then
            exit;
        end;

        err := setInvoiceNumber(reqObj.s['ReceiptData.InvoiceNumber']);
        if (err <> 0) then
          exit;

        // Zaslanie dokladu mailom
        if not Empty(reqObj.s['ReceiptData.Custom.Email']) then
          if not Empty(fSettings.s['ekasa.mailPath']) then
          begin
            err := setEmail(reqObj.s['ReceiptData.Custom.Email']);
            if (err <> 0) then
              exit;
          end;

        // Vypada to, ze u faktury se na celkove soucty nehraje
        if (reqObj.C['ReceiptData.Custom.PaymentCard'] <> 0) then
        begin // kartou
          incRowNumber(rowNumber);
          err := payment_int(rowNumber, C_PAYMENTTYPE_KARTA, 0, 0, 0,
            rs_PAYMENTTYPE_KARTA);
          if (err <> 0) then
            exit;

        end;
        if (reqObj.C['ReceiptData.Custom.PaymentCash'] <> 0) then
        begin // hotovost
          incRowNumber(rowNumber);
          err := payment_int(rowNumber, C_PAYMENTTYPE_HOTOV, 0, 0, 0,
            rs_PAYMENTTYPE_HOTOV);
          if (err <> 0) then
            exit;
        end;

        // vytlaci meno a ucel
        if not Empty(reqObj.s['ReceiptData.Custom.Cashier']) then
        begin
          text := 'Meno: ' + reqObj.s['ReceiptData.Custom.Cashier'];
          incRowNumber(rowNumber);
          err := printAnnouncementNF(rowNumber, text);
          if (err <> 0) then
            exit;
        end;

        if not Empty(reqObj.s['ReceiptData.Custom.Purpose']) then
        begin
          text := '⁄Ëel: ' + reqObj.s['ReceiptData.Custom.Purpose'];
          incRowNumber(rowNumber);
          err := printAnnouncementNF(rowNumber, text);
          if (err <> 0) then
            exit;
        end;

        // ukoncit paragon
        incRowNumber(rowNumber);
        err := paragonEnd(rowNumber, C_GRAPHICSHDR_NO);
        if (err <> 0) then
          exit;

        uidOkp := getReference();
        result := Format
          ('{"message":"Doklad UID:%s ˙speöne zaevidovan˝ a odoslan˝ do tlaËiarne.",'
          + '"uid":"%s"}', [uidOkp, uidOkp]);

        if sfsError(err) then
          result := Format
            ('{"message":"Doklad UID:%s ˙speöne zaevidovan˝ a odoslan˝ do tlaËiarne.",'
            + '"uid":"%s",' + '"messageAdd":"%s"}',
            [uidOkp, uidOkp, sfsErrorStr(err)]);
      end;

      if (reqObj.s['ReceiptData.ReceiptType'] = 'VK') then
      begin
        operationType := C_DEPOSITEINDRAWER_VKLAD;
        description := rs_VkladHot;
        if (C_LEN_LINE = 0) then
          internalReadLengthLine();
        // zaciatok predajneho dna/smeny
        internalOtvorSmenu;
        err := paragonBegin(rowNumber, C_SALETYPE_5, C_TYPPRENOSU_ROW,
          C_PARAGONTYPE_PLUS, C_TYPREKAP_ALL, C_GRAPHICSHDR_NO);
        if (err <> 0) then
          exit;

        incRowNumber(rowNumber);
        amount_2 := Trunc(Zaok(Abs(reqObj.C['ReceiptData.Amount']) *
          100, 0, 0));
        err := depositeInDrawer_int(rowNumber, description, operationType,
          amount_2, C_PAYMENTTYPE_HOTOV);
        if (err <> 0) then
          exit;

        // ukoncit paragon
        incRowNumber(rowNumber);
        err := paragonEnd(rowNumber, C_GRAPHICSHDR_NO);
        if (err <> 0) then
          exit;

        uidOkp := getReference();
        result := Format
          ('{"message":"Doklad UID:%s ˙speöne zaevidovan˝ a odoslan˝ do tlaËiarne.",'
          + '"uid":"%s"}', [uidOkp, uidOkp]);

        if sfsError(err) then
          result := Format
            ('{"message":"Doklad UID:%s ˙speöne zaevidovan˝ a odoslan˝ do tlaËiarne.",'
            + '"uid":"%s",' + '"messageAdd":"%s"}',
            [uidOkp, uidOkp, sfsErrorStr(err)]);
      end;

      if (reqObj.s['ReceiptData.ReceiptType'] = 'VY') then
      begin
        operationType := C_DEPOSITEINDRAWER_VYBER;
        description := rs_VybHot;
        if (C_LEN_LINE = 0) then
          internalReadLengthLine();
        // zaciatok predajneho dna/smeny
        internalOtvorSmenu;
        err := paragonBegin(rowNumber, C_SALETYPE_5, C_TYPPRENOSU_ROW,
          C_PARAGONTYPE_PLUS, C_TYPREKAP_ALL, C_GRAPHICSHDR_NO);
        if (err <> 0) then
          exit;

        incRowNumber(rowNumber);
        amount_2 := Trunc(Zaok(Abs(reqObj.C['ReceiptData.Amount']) *
          100, 0, 0));
        err := depositeInDrawer_int(rowNumber, description, operationType,
          amount_2, C_PAYMENTTYPE_HOTOV);
        if (err <> 0) then
          exit;

        // ukoncit paragon
        incRowNumber(rowNumber);
        err := paragonEnd(rowNumber, C_GRAPHICSHDR_NO);
        if (err <> 0) then
          exit;

        uidOkp := getReference();
        result := Format
          ('{"message":"Doklad UID:%s ˙speöne zaevidovan˝ a odoslan˝ do tlaËiarne.",'
          + '"uid":"%s"}', [uidOkp, uidOkp]);

        if sfsError(err) then
          result := Format
            ('{"message":"Doklad UID:%s ˙speöne zaevidovan˝ a odoslan˝ do tlaËiarne.",'
            + '"uid":"%s",' + '"messageAdd":"%s"}',
            [uidOkp, uidOkp, sfsErrorStr(err)]);
      end;

    end;
  finally
    if (err <> 0) then
    begin
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
      incRowNumber(rowNumber);
      destroyParagon(rowNumber, 'destroyParagon');
    end;
    internalClose();
  end;
end;

function bowaLocationGps(): string;
var
  err: integer;
  reqObj: ISuperObject;
begin
  err := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      reqObj := SO(reqData);
      err := setLocationGPS(reqObj.D['Gps.AxisX'], reqObj.D['Gps.AxisY']);
      if (err <> 0) then
        exit;

      result := '{"message":"Poloha ˙speöne zaevidovan·"}';
    end;
  finally
    if (err <> 0) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
    internalClose();
  end;
end;

function bowaLocationAddress(): string;
var
  err: integer;
  reqObj: ISuperObject;
begin
  err := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      reqObj := SO(reqData);
      err := setLocationAddress(reqObj.s['PhysicalAddress.Municipality'],
        reqObj.s['PhysicalAddress.StreetName'],
        reqObj.s['PhysicalAddress.PropertyRegistrationNumber'],
        reqObj.s['PhysicalAddress.BuildingNumber'],
        reqObj.s['PhysicalAddress.PostalCode']);
      if (err <> 0) then
        exit;

      result := '{"message":"Poloha ˙speöne zaevidovan·"}';
    end;
  finally
    if (err <> 0) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
    internalClose();
  end;
end;

function bowaLocationOther(): string;
var
  err: integer;
  reqObj: ISuperObject;
begin
  err := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      reqObj := SO(reqData);
      err := setLocationOther(reqObj.s['Other']);
      if (err <> 0) then
        exit;

      result := '{"message":"Poloha ˙speöne zaevidovan·"}';
    end;
  finally
    if (err <> 0) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
    internalClose();
  end;
end;

function bowaProReport(): string;
var
  err: integer;
  report: string;
begin
  err := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      report := paramByName('type', reqParams);
      if (Lowercase(report) = 'zreport') then
      begin
        err := printReport_str('Z', 1);
        if (err <> 0) then
          exit;
      end
      else if (Lowercase(report) = 'xreport') then
      begin
        err := printReport_str('X', 1);
        if (err <> 0) then
          exit;
      end
      else
      begin
        result := '{"errorCode":500,"error":"unsupported request"}';
        exit;
      end;

      result := '{"message":"OK"}'
    end;
  finally
    if (err <> 0) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
    internalClose();
  end;
end;

function bowaUnsent(): string;
var
  err: integer;
begin
  err := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      err := printUnsentSFSpackets();
      if (err <> 0) then
        exit;

      result := '{"message":"OK"}';
    end;
  finally
    if (err <> 0) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
    internalClose();
  end;
end;

function bowaSendunsent(): string;
var
  err: integer;
begin
  err := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      err := sendUnsentSFSpackets();
      if (err <> 0) then
        exit;

      result := '{"message":"Odosielanie neodoslan˝ch d·tov˝ch spr·v na server eKASA FS spustenÈ"}';
    end;
  finally
    if (err <> 0) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
    internalClose();
  end;
end;

function TxtEsc2BowaEsc(sEsc: string): string;
var
  Esc: string;
  EscBin: AnsiString;
  i: integer;
begin
  result := '';
  if TxtToBin(sEsc, Esc) then
  begin
    EscBin := StrToAStr(Esc);
    for i := 1 to Length(EscBin) do
      result := result + C_ESC_CHAR + IntToHex(ord(EscBin[i]), 2);
  end;
end;

function internalEscapeSequence(EscSeq: string; ErrMsg: string = ''): integer;
begin
  if Pos(C_ESC_CHAR, EscSeq) = 0 then
    EscSeq := TxtEsc2BowaEsc(EscSeq);
  result := setEscapeSequence(EscSeq);
end;

function bowaPrncdkick(): string;
const
  C_DRAWER1_OPEN = '~1B~70~00~20~80';
  C_DRAWER2_OPEN = '~1B~70~01~20~80';
var
  err: integer;
begin
  err := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      case fSettings.i['ekasa.drawer'] of
        0:
          err := internalEscapeSequence(C_DRAWER1_OPEN);
        1:
          err := internalEscapeSequence(C_DRAWER2_OPEN)
      end;
      if (err <> 0) then
        exit;

      result := '{"message":"Odosielanie neodoslan˝ch d·tov˝ch spr·v na server eKASA FS spustenÈ"}';
    end;
  finally
    if (err <> 0) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
    internalClose();
  end;
end;

function bowaSenderror(): string;
var
  err: integer;
begin
  err := 0;
  result := '';
  internalInit();
  try
    if (bowaOpen) then
    begin
      err := opravaDokladu(FormatDateTime('DDMMYYYYhhnnss', now));
      if (err <> 0) then
        exit;

      result := '{"message":"OK"}';
    end;
  finally
    if (err <> 0) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [err, errorStr(err)]);
    internalClose();
  end;
end;

function eKasaBowaWork(action: TEkasaActions): string;
begin
  result := '';
  case action of
    actState:
      result := bowaState;
    actSettingsGet:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actSettingsPost:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actCopyLast:
      result := bowaCopyLast;
    actCopyByUuid:
      result := bowaCopyByUuid;
    actCopyById:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actReceipt:
      result := bowaReceipt;
    actReceiptStateId:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actLocationGps:
      result := bowaLocationGps;
    actLocationAddress:
      result := bowaLocationAddress;
    actLocationOther:
      result := bowaLocationOther;
    actReport:
      result := bowaProReport;
    actUnsent:
      result := bowaUnsent;
    actSendunsent:
      result := bowaSendunsent;
    actPrncdkick:
      result := bowaPrncdkick;
    actPrnfreeprint:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actSenderror:
      result := bowaSenderror;
    actExamplereceipt:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actSelectpayments:
      result := '{"errorCode":500,"error":"unsupported request"}';
  end;
end;

initialization

clearVats();

end.
