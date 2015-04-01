*&---------------------------------------------------------------------*
*& Report  Z_PALET_ICERIK
*&
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT Z_PALET_ICERIK.

TABLES:VEKP, VEPO, MARA, LTAP, KNA1, LIKP, ZWM_T_PICKING.
TYPE-POOLS: SLIS.
DATA: GT_FIELDCAT_LIST1 TYPE SLIS_T_FIELDCAT_ALV,
      GT_FIELDCAT_LIST2 TYPE SLIS_T_FIELDCAT_ALV,
      GT_FIELDCAT_LIST3 TYPE SLIS_T_FIELDCAT_ALV,
      GT_FIELDCAT_LIST4 TYPE SLIS_T_FIELDCAT_ALV.
DATA : PALET LIKE VEKP-EXIDV.

DATA : BEGIN OF GT_LIST1 OCCURS 0,
         MATNR       LIKE VEPO-MATNR,  "malzeme numarası
         COUNT_KUTU  LIKE VEPO-VEMNG,  "kutu sayısı
         TOTAL_KUTU  LIKE VEPO-VEMNG,  "toplam miktar
         BRGEW       LIKE MARA-BRGEW,  "tek bir malzemeye ait birim brut agirlik kg
         TOTAL_BRGEW LIKE VEKP-BRGEW,  "toplam kg
       END OF GT_LIST1.

DATA : BEGIN OF GT_LIST2 OCCURS 0 ,

         EXIDV LIKE VEKP-EXIDV2,   "TAŞIMA BİRİMİ
         EXIDV2  LIKE VEKP-EXIDV,   "TAŞIMA BİRİMİ
         MATNR  LIKE MARA-MATNR,   "MALZEME
         VEMNG  LIKE VEPO-VEMNG,   "K.İÇ AD
         BRGEW  LIKE VEKP-BRGEW,   "kg
         AENAM  LIKE VEKP-AENAM,   "kullanıcı
         AEDAT  LIKE VEKP-AEDAT,   "okutulduğu tarih

       END OF GT_LIST2.

DATA : BEGIN OF GT_LIST3 OCCURS 0,
         LGNUM  LIKE VEKP-LGNUM,   "DEPO KODU
         VPOBJ  TYPE STRING,
         STATUS TYPE STRING,
         PLT_NO LIKE VEKP-EXIDV,
         NLPLA  LIKE LTAP-NLPLA,
         BRGEW  LIKE VEKP-BRGEW,

       END OF GT_LIST3.

DATA : BEGIN OF GT_LIST4 OCCURS 0 ,

         EXIDV      LIKE VEKP-EXIDV,  "TAŞIMA BİRİMİ
         MATNR      LIKE MARA-MATNR,  "MALZEME
         VEMNG      LIKE VEPO-VEMNG,  "K.İÇ AD
         BRGEW      LIKE VEKP-BRGEW,  "kg
         COUNT_KUTU LIKE VEPO-VEMNG,
       END OF GT_LIST4.

DATA : BEGIN OF GT_KNA1 OCCURS 0,
         NAME1 LIKE KNA1-NAME1,
         EXIDV LIKE VEKP-EXIDV,
       END OF GT_KNA1.

SELECTION-SCREEN BEGIN OF BLOCK BLK1.   "seçim kriterleri
PARAMETERS PALET_NO TYPE VEKP-EXIDV .
SELECTION-SCREEN END OF BLOCK BLK1.

START-OF-SELECTION.
  PERFORM TABLOLARI_DOLDUR.
  PERFORM ALANKATALOGU_OLUSTUR.
  PERFORM TABLOLARI_GOSTER.

FORM TABLOLARI_DOLDUR .

  "MALZEME BİLGİLERİ
  SELECT KTD~MATNR
         SUM( KTD~VEMNG )    AS TOTAL_KUTU
         COUNT(*)            AS COUNT_KUTU
         MAR~BRGEW AS TOTAL_BRGEW
      FROM VEKP AS PLT
INNER JOIN VEPO AS PLD ON PLT~VENUM = PLD~VENUM
INNER JOIN VEKP AS KTU ON PLD~UNVEL = KTU~VENUM
INNER JOIN VEPO AS KTD ON KTU~VENUM = KTD~VENUM
INNER JOIN MARA AS MAR ON KTD~MATNR = MAR~MATNR
      INTO CORRESPONDING FIELDS OF TABLE GT_LIST1
       WHERE PLT~EXIDV = PALET_NO OR PLT~EXIDV2 = PALET_NO
  GROUP BY KTD~MATNR MAR~BRGEW
  ORDER BY KTD~MATNR.

  LOOP AT GT_LIST1.
    GT_LIST1-TOTAL_BRGEW =  GT_LIST1-TOTAL_BRGEW * GT_LIST1-TOTAL_KUTU.
    MODIFY GT_LIST1.
  ENDLOOP.

  """"""""""""""""""""""""""""""

  "KUTU BİLGİLERİ
  SELECT PLT~EXIDV AS EXIDV2
         KTU~EXIDV
         KTD~MATNR
         KTD~VEMNG
         MAR~BRGEW
         KTU~AENAM
         KTU~AEDAT
    FROM   VEKP AS PLT
INNER JOIN VEPO AS PLD ON PLT~VENUM = PLD~VENUM
INNER JOIN VEKP AS KTU ON PLD~UNVEL = KTU~VENUM
INNER JOIN VEPO AS KTD ON KTU~VENUM = KTD~VENUM
INNER JOIN MARA AS MAR ON KTD~MATNR = MAR~MATNR
    INTO CORRESPONDING FIELDS OF TABLE GT_LIST2
    WHERE PLT~EXIDV = PALET_NO OR PLT~EXIDV2 = PALET_NO
  ORDER BY KTD~MATNR KTU~EXIDV.

  LOOP AT GT_LIST2.
    GT_LIST2-BRGEW =  GT_LIST2-BRGEW * GT_LIST2-VEMNG.
    MODIFY GT_LIST2.
  ENDLOOP.

  """"""""""""""""""""""""""""""""

  "BAŞLIK LİSTESİ
  SELECT V~EXIDV
         V~LGNUM
         V~STATUS
         V~VPOBJ
         L~NLPLA
         V~BRGEW
         FROM VEKP AS V
    INNER JOIN LTAP AS L ON V~EXIDV = L~NLENR
    INTO CORRESPONDING FIELDS OF TABLE  GT_LIST3
       WHERE V~EXIDV = PALET_NO
  GROUP BY V~EXIDV V~LGNUM V~STATUS V~VPOBJ L~NLPLA V~BRGEW.

  LOOP AT GT_LIST3.

    GT_LIST3-PLT_NO = PALET_NO.

    SELECT SINGLE EXIDV FROM ZWM_T_PICKING INTO PALET
    WHERE EXIDV = PALET_NO.

    IF SY-SUBRC NE 0 .                         " bağımsız palet
      GT_LIST3-STATUS = 'BAĞIMSIZ'.
      GT_LIST3-VPOBJ = GT_LIST3-NLPLA.

    ELSE .
      READ TABLE GT_KNA1 WITH KEY EXIDV = GT_LIST3-PLT_NO.

      IF GT_LIST3-VPOBJ = '01' AND GT_LIST3-STATUS = '0020'.

        GT_LIST3-STATUS = 'MAL ÇIKIŞI YAPILMADI'.
        GT_LIST3-VPOBJ = GT_KNA1-NAME1.

      ELSEIF GT_LIST3-VPOBJ = '01' AND GT_LIST3-STATUS = '0050'.

        GT_LIST3-STATUS = 'MAL ÇIKIŞI YAPILDI'.
        GT_LIST3-VPOBJ = GT_KNA1-NAME1.
      ELSE.
      ENDIF.

    ENDIF.

    MODIFY GT_LIST3.
  ENDLOOP.

  """"""""""""""""""""""""""""""

  "YAVRU PALETLER
  SELECT   PLT~EXIDV
           KTD~MATNR
           KTD~VEMNG
           MAR~BRGEW
           COUNT(*)            AS COUNT_KUTU
      FROM   VEKP AS PLT
  INNER JOIN VEPO AS PLD ON PLT~VENUM = PLD~VENUM
  INNER JOIN VEKP AS KTU ON PLD~UNVEL = KTU~VENUM
  INNER JOIN VEPO AS KTD ON KTU~VENUM = KTD~VENUM
  INNER JOIN MARA AS MAR ON KTD~MATNR = MAR~MATNR
      INTO CORRESPONDING FIELDS OF TABLE GT_LIST4
      WHERE PLT~EXIDV2 = PALET_NO OR PLT~EXIDV = PALET_NO "YAVRU PALETLER
    GROUP BY KTD~MATNR MAR~BRGEW PLT~EXIDV KTD~VEMNG
    ORDER BY KTD~MATNR  PLT~EXIDV.

  LOOP AT GT_LIST4.
    GT_LIST4-BRGEW =  GT_LIST4-BRGEW * GT_LIST4-VEMNG.
    MODIFY GT_LIST4.
  ENDLOOP.

  """""""""""""""""""""""""

  SELECT K~NAME1
         Z~EXIDV
         FROM LIKP AS L
INNER JOIN ZWM_T_PICKING AS Z ON Z~VBELN_VL = L~VBELN
INNER JOIN KNA1 AS K ON K~KUNNR = L~KUNNR
    INTO CORRESPONDING FIELDS OF TABLE  GT_KNA1
       WHERE Z~EXIDV = PALET_NO
  GROUP BY Z~EXIDV K~NAME1.

ENDFORM.

FORM ALANKATALOGU_OLUSTUR .

  DATA : GS_FIELDCAT  TYPE SLIS_FIELDCAT_ALV.
  GS_FIELDCAT-COL_POS    = 1.
  GS_FIELDCAT-FIELDNAME  = 'LGNUM'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST3'.
  GS_FIELDCAT-SELTEXT_M  = 'DEPO KODU'.
  GS_FIELDCAT-OUTPUTLEN   = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST3.
  GS_FIELDCAT-COL_POS    = 2.
  GS_FIELDCAT-FIELDNAME  = 'STATUS'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST3'.
  GS_FIELDCAT-SELTEXT_M  = 'DURUM'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST3.
  GS_FIELDCAT-COL_POS    = 3.
  GS_FIELDCAT-FIELDNAME  = 'VPOBJ'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST3'.
  GS_FIELDCAT-SELTEXT_M  = 'AÇIKLAMA'.
  GS_FIELDCAT-OUTPUTLEN   = 19.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST3.
  GS_FIELDCAT-COL_POS    = 4.
  GS_FIELDCAT-FIELDNAME  = 'PLT_NO'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST3'.
  GS_FIELDCAT-SELTEXT_M  = 'PALET NO'.
  GS_FIELDCAT-OUTPUTLEN   = 15.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST3.
  GS_FIELDCAT-COL_POS    = 5.
  GS_FIELDCAT-FIELDNAME  = 'BRGEW'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST3'.
  GS_FIELDCAT-SELTEXT_M  = 'PALET AĞIRLIĞI'.
  GS_FIELDCAT-OUTPUTLEN   = 15.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST3.

  GS_FIELDCAT-COL_POS    = 1.
  GS_FIELDCAT-FIELDNAME  = 'MATNR'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST1'.
  GS_FIELDCAT-SELTEXT_M  = 'MALZEME NUMARASI'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST1.
  GS_FIELDCAT-COL_POS    = 2.
  GS_FIELDCAT-FIELDNAME  = 'COUNT_KUTU'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST1'.
  GS_FIELDCAT-SELTEXT_M  = 'KUTU SAYISI'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST1.
  GS_FIELDCAT-COL_POS    = 3.
  GS_FIELDCAT-FIELDNAME  = 'TOTAL_KUTU'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST1'.
  GS_FIELDCAT-SELTEXT_M  = 'TOPLAM MİKTAR.'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST1.
  GS_FIELDCAT-COL_POS    = 4.
  GS_FIELDCAT-FIELDNAME  = 'TOTAL_BRGEW'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST1'.
  GS_FIELDCAT-SELTEXT_M  = 'TOPLAM KG'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST1.

  GS_FIELDCAT-COL_POS    = 1.
  GS_FIELDCAT-FIELDNAME  = 'EXIDV'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST4'.
  GS_FIELDCAT-SELTEXT_M  = 'PALET NO'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST4.
  GS_FIELDCAT-COL_POS    = 2.
  GS_FIELDCAT-FIELDNAME  = 'MATNR'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST4'.
  GS_FIELDCAT-SELTEXT_M  = 'MALZEME'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST4.
  GS_FIELDCAT-COL_POS    = 3.
  GS_FIELDCAT-FIELDNAME  = 'VEMNG'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST4'.
  GS_FIELDCAT-SELTEXT_M  = 'KUTU İÇİ ADET'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST4.
  GS_FIELDCAT-COL_POS    = 4.
  GS_FIELDCAT-FIELDNAME  = 'BRGEW'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST4'.
  GS_FIELDCAT-SELTEXT_M  = 'KG'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST4.
  GS_FIELDCAT-COL_POS    = 5.
  GS_FIELDCAT-FIELDNAME  = 'COUNT_KUTU'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST4'.
  GS_FIELDCAT-SELTEXT_M  = 'KUTU SAYISI'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST4.

  GS_FIELDCAT-COL_POS    = 1.
  GS_FIELDCAT-FIELDNAME  = 'EXIDV2'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST2'.
  GS_FIELDCAT-SELTEXT_M  = 'PALET NO'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST2.
  GS_FIELDCAT-COL_POS    = 2.
  GS_FIELDCAT-FIELDNAME  = 'EXIDV'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST2'.
  GS_FIELDCAT-SELTEXT_M  = 'KUTU NUMARASI'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST2.
  GS_FIELDCAT-COL_POS    = 3.
  GS_FIELDCAT-FIELDNAME  = 'MATNR'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST2'.
  GS_FIELDCAT-SELTEXT_M  = 'MALZEME'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST2.
  GS_FIELDCAT-COL_POS    = 4.
  GS_FIELDCAT-FIELDNAME  = 'VEMNG'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST2'.
  GS_FIELDCAT-SELTEXT_M  = 'KUTU İÇİ ADET'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST2.
  GS_FIELDCAT-COL_POS    = 5.
  GS_FIELDCAT-FIELDNAME  = 'BRGEW'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST2'.
  GS_FIELDCAT-SELTEXT_M  = 'KG'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST2.
  GS_FIELDCAT-COL_POS    = 6.
  GS_FIELDCAT-FIELDNAME  = 'AENAM'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST2'.
  GS_FIELDCAT-SELTEXT_M  = 'KİŞİ'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST2.
  GS_FIELDCAT-COL_POS    = 7.
  GS_FIELDCAT-FIELDNAME  = 'AEDAT'.
  GS_FIELDCAT-TABNAME    = 'GT_LIST2'.
  GS_FIELDCAT-SELTEXT_M  = 'OKUTULDUĞU TARİH'.
  GS_FIELDCAT-OUTPUTLEN   = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT_LIST2.

ENDFORM. " ALANKATALOGU_OLUSTUR


FORM TABLOLARI_GOSTER .

  DATA : LV_REPID  TYPE SY-REPID,
         LS_LAYOUT TYPE SLIS_LAYOUT_ALV,
         LT_EVENTS TYPE SLIS_T_EVENT.
  LV_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
    EXPORTING
      I_CALLBACK_PROGRAM = LV_REPID.
  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
    EXPORTING
      IS_LAYOUT                  = LS_LAYOUT
      IT_FIELDCAT                = GT_FIELDCAT_LIST3
      I_TABNAME                  = 'GT_LIST3'
      IT_EVENTS                  = LT_EVENTS
    TABLES
      T_OUTTAB                   = GT_LIST3
    EXCEPTIONS
      PROGRAM_ERROR              = 1
      MAXIMUM_OF_APPENDS_REACHED = 2
      OTHERS                     = 3.

  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
    EXPORTING
      IS_LAYOUT                  = LS_LAYOUT
      IT_FIELDCAT                = GT_FIELDCAT_LIST1
      I_TABNAME                  = 'GT_LIST1'
      IT_EVENTS                  = LT_EVENTS
    TABLES
      T_OUTTAB                   = GT_LIST1
    EXCEPTIONS
      PROGRAM_ERROR              = 1
      MAXIMUM_OF_APPENDS_REACHED = 2
      OTHERS                     = 3.

  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
    EXPORTING
      IS_LAYOUT                  = LS_LAYOUT
      IT_FIELDCAT                = GT_FIELDCAT_LIST4
      I_TABNAME                  = 'GT_LIST4'
      IT_EVENTS                  = LT_EVENTS
    TABLES
      T_OUTTAB                   = GT_LIST4
    EXCEPTIONS
      PROGRAM_ERROR              = 1
      MAXIMUM_OF_APPENDS_REACHED = 2
      OTHERS                     = 3.

  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
    EXPORTING
      IS_LAYOUT                  = LS_LAYOUT
      IT_FIELDCAT                = GT_FIELDCAT_LIST2
      I_TABNAME                  = 'GT_LIST2'
      IT_EVENTS                  = LT_EVENTS
    TABLES
      T_OUTTAB                   = GT_LIST2
    EXCEPTIONS
      PROGRAM_ERROR              = 1
      MAXIMUM_OF_APPENDS_REACHED = 2
      OTHERS                     = 3.

  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_DISPLAY'
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                  " TABLOLARI_GOSTER
