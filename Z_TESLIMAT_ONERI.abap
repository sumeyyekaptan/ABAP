*&---------------------------------------------------------------------*
*& Report  ZWM_R_TESLIMAT_ONERI
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZWM_R_TESLIMAT_ONERI.

TABLES : ZWM_T_SEVK_EMRI , LQUA, ZWM_T_RAFSORUMLU, MARM, LIPS,VBFA.

TYPE-POOLS: SLIS.

DATA : FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.
DATA : IT_FIELDCAT  TYPE LVC_T_FCAT,
       WA_FIELDCAT  TYPE LVC_S_FCAT,
       GD_TAB_GROUP TYPE SLIS_T_SP_GROUP_ALV,
       GD_LAYOUT    TYPE LVC_S_LAYO,
       GD_REPID     LIKE SY-REPID.

DATA : LV_TABIX LIKE SY-TABIX.

*********************TESLİMAT ÖNERİ TABLOSU*************************

DATA : BEGIN OF GT_TESLIMAT OCCURS 0 ,
         BOLGE       LIKE ZWM_T_RAFSORUMLU-RAFBOLGE, "
         MATNR       LIKE ZWM_T_SEVK_EMRI-MATNR, "
         RAF_NO      LIKE ZWM_T_SEVK_EMRI-LGPLA, "
         TESLIMAT    LIKE ZWM_T_SEVK_EMRI-VBELN, "
         RAF_STOK    LIKE LQUA-VERME, "
         KDMAT       LIKE KNMT-KDMAT, "
         KIADET      LIKE MARM-UMREZ, "
         EXIDV       LIKE ZWM_T_PALETONERI-EXIDV, "

         TESLIMAT_MIKTARI  LIKE LIPS-LFIMG, "
         CEKILEN_MIKTAR    LIKE ZWM_T_SEVK_EMRI-OKUNAN, "
         CEKILMEDEN_KALAN  LIKE ZWM_T_SEVK_EMRI-OKUNAN, "

         ONERILEN_ADET     LIKE ZWM_T_SEVK_EMRI-MENGE, "
         OKUNAN_ADET       LIKE ZWM_T_SEVK_EMRI-OKUNAN, "
         EKSIK             LIKE LIPS-LFIMG, "

         OTB         LIKE ZWM_T_SEVK_EMRI-MENGE, "
         CTB         LIKE ZWM_T_SEVK_EMRI-OKUNAN, "
         FARK        LIKE ZWM_T_SEVK_EMRI-OKUNAN, "
       END OF GT_TESLIMAT.

DATA : GT_ONERI LIKE TABLE OF GT_TESLIMAT WITH HEADER LINE.

DATA : BEGIN OF GT_RAF OCCURS 0 ,
         RAFBOLGE    LIKE ZWM_T_RAFSORUMLU-RAFBOLGE,
         LGPLA_FIRST LIKE ZWM_T_RAFSORUMLU-LGPLA_FIRST,
         LGPLA_LAST  LIKE ZWM_T_RAFSORUMLU-LGPLA_LAST,
       END OF GT_RAF.

*****************************RAF STOK*****************************

DATA : BEGIN OF GT_STOK OCCURS 0 ,
         MATNR LIKE LQUA-MATNR,
         LGPLA LIKE LQUA-LGPLA,
         VERME LIKE LQUA-VERME,
       END OF GT_STOK.

*****************************PALET NUMARASI**************************

DATA : BEGIN OF GT_PALET OCCURS 0 ,
         EXIDV LIKE ZWM_T_PALETONERI-EXIDV,
         LGPLA LIKE LQUA-LGPLA,
         VBELN LIKE ZWM_T_PALETONERI-VBELN_VL,
         MATNR LIKE ZWM_T_SEVK_EMRI-MATNR,
       END OF GT_PALET.

*********************TESLİMAT MİKTARI**********************************

DATA : BEGIN OF LT_CEKILEN OCCURS 0 ,
         VBELN       LIKE LIPS-VBELN,
         MATNR       LIKE LIPS-MATNR,
         OKUNAN      LIKE VBFA-RFMNG,
       END OF LT_CEKILEN.

DATA : BEGIN OF LT_GERICEKILEN OCCURS 0 ,
         VBELN  LIKE LIPS-VBELN,
         MATNR  LIKE LIPS-MATNR,
         OKUNAN LIKE VBFA-RFMNG,
       END OF LT_GERICEKILEN.

********************************ÇAPRAZ KOD**************************

DATA : BEGIN OF GT_LIKP OCCURS 0 ,
         KUNNR LIKE LIKP-KUNNR,
         VBELN LIKE ZWM_T_SEVK_EMRI-VBELN,
         KDMAT LIKE KNMT-KDMAT,
         MATNR LIKE KNMT-MATNR,
       END OF GT_LIKP.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME
                                       TITLE TEXT-011.
PARAMETERS: PVBELN TYPE LIPS-VBELN OBLIGATORY VALUE CHECK.

SELECTION-SCREEN END OF BLOCK BLOCK1.

PERFORM GET_DATA.
PERFORM BUILD_FIELDCATALOG.
PERFORM BUILD_LAYOUT.
PERFORM DISPLAY_ALV_REPORT.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .

"********************************GT_RAF****************************
  " Bölgelerin raf aralıkları alınıyor.

  SELECT ZR~RAFBOLGE
         ZR~LGPLA_LAST
         ZR~LGPLA_FIRST
    FROM ZWM_T_RAFSORUMLU     AS ZR
 INTO CORRESPONDING FIELDS OF TABLE GT_RAF.


  "********************************GT_STOK****************************
  " Teslimatın raf stoklarının miktarları

  SELECT L~MATNR
         L~LGPLA
         SUM( L~VERME ) AS VERME
    FROM LQUA     AS L
 INNER JOIN LIPS  AS T ON L~MATNR = T~MATNR
       INTO CORRESPONDING FIELDS OF TABLE GT_STOK
      WHERE T~VBELN = PVBELN
    GROUP BY L~MATNR L~LGPLA .

  "**********************************GT_LIKP*************************
  " Çapraz stok kodları

  SELECT L~KUNNR
         L~VBELN
         K~KDMAT
         K~MATNR
    FROM LIKP       AS L
INNER JOIN KNMT       AS K ON K~KUNNR = L~KUNNR
    INTO CORRESPONDING FIELDS OF TABLE GT_LIKP
   WHERE L~VBELN = PVBELN.

 """"""""""""""""""""""""""   GT_PALET  """""""""""""""""""""""""""""
 "önerinin yapıldığı taşıma birimi

  SELECT Z~MATNR
         L~LGPLA
         Z~VBELN
         V~EXIDV
    FROM ZWM_T_SEVK_EMRI  AS Z
INNER JOIN LQUA             AS L ON L~MATNR = Z~MATNR
                               AND Z~LGPLA = L~LGPLA
INNER JOIN ZWM_T_PALETONERI AS V ON L~LENUM = V~EXIDV
                               and L~vbeln = V~VBELN_VL
    INTO CORRESPONDING FIELDS  OF TABLE GT_PALET
   WHERE Z~VBELN = PVBELN.
     "AND V~VBELN_VL = PVBELN.

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  "teslimat kalemi için toplam çekme miktarı
    SELECT LIPS~VBELN LIPS~MATNR SUM( VBFA~RFMNG ) AS OKUNAN
      INTO CORRESPONDING FIELDS OF TABLE LT_CEKILEN
      FROM VBFA
INNER JOIN LIPS ON LIPS~VBELN = VBFA~VBELV
               AND LIPS~POSNR = VBFA~POSNV
     WHERE VBFA~VBELV   = PVBELN AND
           VBFA~VBTYP_N = 'Q'     AND
           VBFA~TAQUI   = 'X'     AND
           VBFA~PLMIN NE '-'
  GROUP BY LIPS~VBELN LIPS~MATNR.

 " TESLIMAT KALEMI IÇIN ÇEKME IPTALI YAPILAN MIKTAR
     SELECT LIPS~VBELN LIPS~MATNR SUM( VBFA~RFMNG ) AS OKUNAN
       INTO CORRESPONDING FIELDS OF TABLE LT_GERICEKILEN
       FROM VBFA
 INNER JOIN LIPS ON LIPS~VBELN = VBFA~VBELV
                AND LIPS~POSNR = VBFA~POSNV
      WHERE VBFA~VBELV   = PVBELN   AND
            VBFA~VBTYP_N = 'Q'      AND
            VBFA~TAQUI   = 'X'      AND
            VBFA~PLMIN   = '-'
   GROUP BY LIPS~VBELN LIPS~MATNR.

  SORT LT_CEKILEN     BY MATNR ASCENDING.
  SORT LT_GERICEKILEN BY MATNR ASCENDING.

 LOOP AT LT_CEKILEN.

   READ TABLE LT_GERICEKILEN WITH KEY VBELN = LT_CEKILEN-VBELN
                                      MATNR = LT_CEKILEN-MATNR
                                      BINARY SEARCH.
    IF SY-SUBRC = 0.
     LT_CEKILEN-OKUNAN = LT_CEKILEN-OKUNAN - LT_GERICEKILEN-OKUNAN.
    ENDIF.
    MODIFY LT_CEKILEN.

 ENDLOOP.

  "********************************gt_teslimat**************************

  SELECT LP~MATNR          ,                           "SAMPA NO
         Z~LGPLA          AS RAF_NO    ,               "RAF_NO
         Z~MENGE          AS ONERILEN_ADET,            "ÖNERİLEN ADET
         Z~OKUNAN         AS OKUNAN_ADET  ,            "OKUNAN adet
         M~UMREZ          AS KIADET      ,             "kutu içi adet
         Z~VBELN          AS TESLIMAT    ,             "teslimat numarası
         SUM( LP~LFIMG )  AS TESLIMAT_MIKTARI          "TESLIMAT_MIKTARI
    INTO CORRESPONDING FIELDS  OF TABLE @GT_TESLIMAT
    FROM LIPS AS LP
LEFT JOIN ZWM_T_SEVK_EMRI  AS Z ON LP~MATNR = Z~MATNR
                              AND Z~VBELN = LP~VBELN
LEFT JOIN MARM             AS M ON M~MATNR = LP~MATNR
                              AND M~MEINH = 'KTU'
   WHERE LP~VBELN = @PVBELN
GROUP BY LP~MATNR ,Z~LGPLA,  Z~OKUNAN,
        M~UMREZ, Z~VBELN, Z~MENGE.

SORT : GT_TESLIMAT BY MATNR ASCENDING.
SORT : GT_LIKP     BY MATNR ASCENDING.
SORT : GT_STOK     BY MATNR ASCENDING.
SORT : GT_PALET    BY MATNR ASCENDING.
LOOP AT GT_TESLIMAT.

    IF GT_TESLIMAT-KIADET <> 0.
      GT_TESLIMAT-CTB = GT_TESLIMAT-OKUNAN_ADET / GT_TESLIMAT-KIADET.
      GT_TESLIMAT-OTB = GT_TESLIMAT-ONERILEN_ADET / GT_TESLIMAT-KIADET.
      GT_TESLIMAT-FARK = GT_TESLIMAT-OTB - GT_TESLIMAT-CTB.
      MODIFY GT_TESLIMAT.
    ENDIF.

    READ TABLE LT_CEKILEN WITH KEY MATNR = GT_TESLIMAT-MATNR
 BINARY SEARCH.
            IF SY-SUBRC = 0.
               GT_TESLIMAT-CEKILEN_MIKTAR = LT_CEKILEN-OKUNAN.
               MODIFY GT_TESLIMAT.
            ENDIF.

    GT_TESLIMAT-CEKILMEDEN_KALAN = GT_TESLIMAT-TESLIMAT_MIKTARI - GT_TESLIMAT-CEKILEN_MIKTAR.

    MODIFY GT_TESLIMAT.

    LOOP AT GT_RAF.
      IF GT_TESLIMAT-RAF_NO BETWEEN GT_RAF-LGPLA_FIRST
                             AND GT_RAF-LGPLA_LAST.
         GT_TESLIMAT-BOLGE = GT_RAF-RAFBOLGE.
         MODIFY GT_TESLIMAT.

      ENDIF.
    ENDLOOP.

    READ TABLE GT_STOK
      WITH KEY MATNR = GT_TESLIMAT-MATNR
               LGPLA = GT_TESLIMAT-RAF_NO
 BINARY SEARCH.
            IF SY-SUBRC = 0.
               GT_TESLIMAT-RAF_STOK = GT_STOK-VERME.
               MODIFY GT_TESLIMAT.
            ENDIF.

    READ TABLE GT_LIKP
      WITH KEY MATNR = GT_TESLIMAT-MATNR
 BINARY SEARCH.
            IF SY-SUBRC = 0.
               GT_TESLIMAT-KDMAT = GT_LIKP-KDMAT.
               MODIFY GT_TESLIMAT.
            ENDIF.


    READ TABLE GT_PALET
      WITH KEY MATNR = GT_TESLIMAT-MATNR
               LGPLA = GT_TESLIMAT-RAF_NO
 BINARY SEARCH.
            IF SY-SUBRC = 0.
               GT_TESLIMAT-EXIDV = GT_PALET-EXIDV.
               MODIFY GT_TESLIMAT.
            ENDIF.

    IF GT_TESLIMAT-EXIDV = '' AND GT_TESLIMAT-OTB <> ''.
       GT_TESLIMAT-EXIDV = 'KUTU'.
    ELSEIF GT_TESLIMAT-EXIDV <> ''.
       GT_TESLIMAT-EXIDV = 'PALET'.
    ENDIF.
    MODIFY GT_TESLIMAT.

ENDLOOP.

LOOP AT GT_TESLIMAT.

    READ TABLE GT_ONERI
      WITH KEY MATNR = GT_TESLIMAT-MATNR
 BINARY SEARCH.
            IF SY-SUBRC = 0.
               LV_TABIX = SY-TABIX.
               GT_ONERI-ONERILEN_ADET = GT_ONERI-ONERILEN_ADET + GT_TESLIMAT-ONERILEN_ADET.
               GT_ONERI-OKUNAN_ADET   = GT_ONERI-OKUNAN_ADET + GT_TESLIMAT-OKUNAN_ADET.
               GT_ONERI-OTB   = GT_ONERI-OTB + GT_TESLIMAT-OTB.
               GT_ONERI-CTB   = GT_ONERI-CTB + GT_TESLIMAT-CTB.
               GT_ONERI-FARK  = GT_ONERI-FARK + GT_TESLIMAT-FARK.

               MODIFY GT_ONERI INDEX LV_TABIX.
           ELSE.
             MOVE-CORRESPONDING GT_TESLIMAT TO GT_ONERI.
             APPEND GT_ONERI.
           ENDIF.
ENDLOOP.

LOOP AT  GT_ONERI.

      IF GT_ONERI-CEKILEN_MIKTAR = GT_ONERI-OKUNAN_ADET.

         GT_ONERI-EKSIK = GT_ONERI-TESLIMAT_MIKTARI - GT_ONERI-ONERILEN_ADET.
         MODIFY GT_ONERI.
      ELSE.
         GT_ONERI-EKSIK = GT_ONERI-CEKILMEDEN_KALAN - GT_ONERI-ONERILEN_ADET .
         MODIFY GT_ONERI.
      ENDIF.

ENDLOOP.

DELETE GT_ONERI WHERE CEKILMEDEN_KALAN = 0 .

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCATALOG .

DATA LV_COLPOS TYPE I .
  DEFINE ADD_FCTALOG .
    WA_FIELDCAT-FIELDNAME   = &1 .        "alan adı
    WA_FIELDCAT-SCRTEXT_M   = &2.         "alanın başlığı
    WA_FIELDCAT-OUTPUTLEN   = '10'.       "alan genişliği 20
    WA_FIELDCAT-COL_POS     = lv_colpos . "rapordaki sıra
    lv_colpos = lv_colpos + 1 .
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR  WA_FIELDCAT.
  END-OF-DEFINITION.

  ADD_FCTALOG 'BOLGE'                      'Bölge'.                    "TEXT-002.
  ADD_FCTALOG 'MATNR'                      'Malzeme'.                  "TEXT-003.
  ADD_FCTALOG 'KDMAT'                      'Çapraz Kod'.               "TEXT-004.
  ADD_FCTALOG 'RAF_NO'                     'Raf Adresi'.               "TEXT-005.
  ADD_FCTALOG 'RAF_STOK'                   'Raf Stoğu'.                "TEXT-006.

  ADD_FCTALOG 'TESLIMAT_MIKTARI'           'Teslimat Miktarı'.         "TEXT-007.
  ADD_FCTALOG 'CEKILEN_MIKTAR'             'Çekilen Miktar'.           "TEXT-008.
  ADD_FCTALOG 'CEKILMEDEN_KALAN'           'Çekilmeden Kalan'.         "TEXT-009.

  ADD_FCTALOG 'ONERILEN_ADET'              'Önerilen Adet'.            "TEXT-010.
  ADD_FCTALOG 'OKUNAN_ADET'                'Okunan Adet'.              "TEXT-011.
  ADD_FCTALOG 'EKSIK'                      'Önerilmeyen Adet'.         "TEXT-012.

  ADD_FCTALOG 'OTB'                        'Önerilen Taşıma Birimi'.   "TEXT-013.
  ADD_FCTALOG 'CTB'                        'Çekilen Taşıma Birimi'.    "TEXT-014.
  ADD_FCTALOG 'FARK'                       'Taşıma Birimi Farkı'.      "TEXT-015.
  ADD_FCTALOG 'EXIDV'                      'Taşıma Birimi'.            "TEXT-016.

ENDFORM.                    " BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_LAYOUT .

  GD_LAYOUT-STYLEFNAME = 'FIELD_STYLE'.
  GD_LAYOUT-ZEBRA      = 'X'.
  GD_LAYOUT-CWIDTH_OPT = 'X'.


ENDFORM.                    " BUILD_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV_REPORT .

  GD_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM      = GD_REPID
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
      IS_LAYOUT_LVC           = GD_LAYOUT
      IT_FIELDCAT_LVC         = IT_FIELDCAT
      I_SAVE                  = 'X'
    TABLES
      T_OUTTAB                = GT_ONERI
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.

ENDFORM.                    " DISPLAY_ALV_REPORT
