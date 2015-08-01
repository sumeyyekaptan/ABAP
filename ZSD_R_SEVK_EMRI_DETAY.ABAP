*&---------------------------------------------------------------------*
*& Report  ZSD_R_SEVK_EMRI_DETAY
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZSD_R_SEVK_EMRI_DETAY.

TABLES:VBAP,
       VBAK,
       KNA1,
       MARA ,
       ZSD_ORDERS,
       MARC.

TYPE-POOLS:SLIS,TRUXS.

DATA:BEGIN OF GT_OUT OCCURS 0,
       SEVNO        LIKE ZSD_ORDERS-SEVNO,
       KUNNR        LIKE KNA1-KUNNR,
       NAME1        LIKE KNA1-NAME1,
       MATNR        LIKE MARA-MATNR,
       MAKTX        LIKE MAKT-MAKTX,
       OPKWMENG     LIKE VBAP-KWMENG,  " ACIK SİPARİŞ MİK
       OUTSVMNG     LIKE VBAP-KWMENG,  " SEVK EMRİ AÇILMAMIŞ
       INSVMNG      LIKE VBAP-KWMENG,
       RZMNG        LIKE VBAP-KWMENG,
       BEKLEYEN_MIK LIKE VBAP-KWMENG,
       TOP_SIP_TL   LIKE VBAP-NETWR,
       TOP_REZ_TL   LIKE VBAP-NETWR,
       TOP_SEVK_TL  LIKE VBAP-NETWR,
       BEKLEYEN_TL  LIKE VBAP-NETWR,
       GLTRP        LIKE AFKO-GSTRP,  "PP_END_DATE
       EINDT        LIKE EKET-EINDT,  "PURCHASE_DATE
       EBELN        LIKE EKPO-EBELN,
       EBELP        LIKE EKPO-EBELP,
     END OF GT_OUT.

DATA : ID(20) TYPE N.

DATA: BEGIN OF LT_KNA1 OCCURS 0,
        KUNNR LIKE KNA1-KUNNR,
        NAME1 LIKE KNA1-NAME1,
        NAME2 LIKE KNA1-NAME2,
      END OF LT_KNA1.

DATA: BEGIN OF LT_MAKT OCCURS 0,
        MATNR LIKE MARA-MATNR,
        MAKTX LIKE MAKT-MAKTX,
      END OF LT_MAKT.

DATA: BEGIN OF LT_ORDERS OCCURS 0.       "ZSD_ORDERS DAKİ TÜM ALANLAR VE AŞAĞIDA TANIMLANANLAR
        INCLUDE STRUCTURE ZSD_ORDERS.
DATA: BEKLEYEN_MIK   LIKE VBAP-KWMENG.
DATA: TOP_SIP_TL     LIKE VBAP-NETWR.
DATA: TOP_REZ_TL     LIKE VBAP-NETWR.
DATA: TOP_SEVK_TL    LIKE VBAP-NETWR.
DATA: BEKLEYEN_TL    LIKE VBAP-NETWR.
DATA: NAME1          LIKE KNA1-NAME1.
DATA: MAKTX          LIKE MAKT-MAKTX.
DATA END OF LT_ORDERS.

DATA :GT_OUT2 LIKE TABLE OF GT_OUT WITH HEADER LINE.
DATA: LV_TABIX LIKE SY-TABIX.

DATA: FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.
DATA: GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.

DATA: IT_FIELDCAT  TYPE LVC_T_FCAT,
      WA_FIELDCAT  TYPE LVC_S_FCAT,
      GD_TAB_GROUP TYPE SLIS_T_SP_GROUP_ALV,
      GD_LAYOUT    TYPE LVC_S_LAYO,
      GD_REPID     LIKE SY-REPID.

RANGES: GR_VKGRP FOR KNVV-VKGRP.
RANGES: GR_KUNAG FOR KNA1-KUNNR.
DATA  : YETKI    TYPE ZSD_T_YETKI-VKGRP.

DATA  : ERSDA TYPE ERSDA,
        ERZET TYPE ERZET.
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS:S_SEVNO FOR ZSD_ORDERS-SEVNO,  "SEVK EMRİ NO
               S_KUNNR FOR KNA1-KUNNR,        "MÜŞTERİ NO
               S_MATNR FOR MARA-MATNR,        "MALZEME NO
               S_DISPO FOR MARC-DISPO,        "MİP SORUMLUSU
               S_FEVOR FOR MARC-FEVOR.        "ÜRETİM SORUMLUSU
SELECTION-SCREEN END OF BLOCK B1.

START-OF-SELECTION.                    "başlık listesinde görüntülenecek kısım

  SELECT SINGLE ERSDA ERZET
    INTO ( ERSDA , ERZET )
    FROM ZSD_ORDERS.


PERFORM GET_DATA.

END-OF-SELECTION.

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

  SELECT KUNNR
         NAME1
INTO TABLE LT_KNA1
    FROM KNA1.

  SELECT MATNR
         MAKTX
INTO TABLE LT_MAKT
    FROM MAKT
    WHERE SPRAS = 'TR'.

  SELECT MAX( ID ) FROM ZSD_ORDERS
    INTO ID .

SELECT  SINGLE VKGRP                           "yetki kontrolü
          INTO YETKI
          FROM ZSD_T_YETKI
         WHERE UNAME EQ SY-UNAME.

  IF YETKI = '*'.

    SELECT *
      FROM ZSD_ORDERS AS ORD
INNER JOIN MAKT ON ORD~MATNR = MAKT~MATNR
INNER JOIN MARC ON MARC~MATNR = MAKT~MATNR
 LEFT JOIN KNA1 ON ORD~KUNNR = KNA1~KUNNR
      INTO CORRESPONDING FIELDS OF TABLE LT_ORDERS
     WHERE ORD~ID = ID
       AND ORD~OPENCLOSE = 1
       AND ORD~WERKS2 = '1100'
       AND ORD~MATNR  IN S_MATNR
       AND ORD~KUNNR  IN S_KUNNR
       AND ORD~SEVNO  IN S_SEVNO
       AND MARC~DISPO IN S_DISPO
       AND MARC~FEVOR IN S_FEVOR
       AND MAKT~SPRAS = 'TR'
       AND ORD~AUART IN ('Z001',
                             'Z002',
                              'Z003',
                              'Z004',
                              'Z005',
                              'Z006',
                              'Z008',
                              'Z009',
                              'Z010',
                              'Z011',
                              'Z012',
                              'Z013',
                              'Z014',
                              'Z015',
                              'Z017',
                              'Z018',
                              'ZSAS').

  ELSE.
    PERFORM YETKI TABLES GR_VKGRP
                         GR_KUNAG
                   USING 'K'.

    SELECT *
      FROM ZSD_ORDERS AS ORD
INNER JOIN MAKT ON ORD~MATNR = MAKT~MATNR
INNER JOIN MARC ON MARC~MATNR = MAKT~MATNR
 LEFT JOIN KNA1 ON ORD~KUNNR = KNA1~KUNNR
      INTO CORRESPONDING FIELDS OF TABLE LT_ORDERS
     WHERE ORD~ID = ID
       AND ORD~OPENCLOSE = 1
       AND ORD~WERKS2 = '1100'
       AND ORD~MATNR  IN S_MATNR
       AND ORD~KUNNR  IN GR_KUNAG
       AND ORD~SEVNO  IN S_SEVNO
       AND MARC~DISPO IN S_DISPO
       AND MARC~FEVOR IN S_FEVOR
       AND MAKT~SPRAS = 'TR'
       AND ORD~AUART  IN ('Z001',
                             'Z002',
                              'Z003',
                              'Z004',
                              'Z005',
                              'Z006',
                              'Z008',
                              'Z009',
                              'Z010',
                              'Z011',
                              'Z012',
                              'Z013',
                              'Z014',
                              'Z015',
                              'Z017',
                              'Z018',
                              'ZSAS').

  ENDIF.

  SORT :LT_ORDERS BY VBELN POSNR.
  SORT :LT_MAKT   BY MATNR.
  SORT :LT_KNA1  BY KUNNR.

  LOOP AT  LT_ORDERS.

    "LT_ORDERS-KZWI4TL      = LT_ORDERS-KZWI4TL.
    LT_ORDERS-TOP_SIP_TL   = LT_ORDERS-OPKWMENG * LT_ORDERS-KZWI4TL.
    LT_ORDERS-TOP_REZ_TL   = LT_ORDERS-RZMNG    * LT_ORDERS-KZWI4TL.
    LT_ORDERS-TOP_SEVK_TL  = LT_ORDERS-INSVMNG  * LT_ORDERS-KZWI4TL.
    LT_ORDERS-BEKLEYEN_MIK = LT_ORDERS-INSVMNG - LT_ORDERS-RZMNG.

    LT_ORDERS-BEKLEYEN_TL  = LT_ORDERS-BEKLEYEN_MIK * LT_ORDERS-KZWI4TL.
    MODIFY LT_ORDERS.

    READ TABLE LT_MAKT WITH KEY MATNR = LT_ORDERS-MATNR
                                BINARY SEARCH.
    LT_ORDERS-MAKTX = LT_MAKT-MAKTX.

    IF LT_ORDERS-ORDTY = 2.
      LT_ORDERS-NAME1 = 'ZSAS'.
    ENDIF.

    MODIFY LT_ORDERS.

  ENDLOOP.

  MOVE-CORRESPONDING LT_ORDERS[] TO GT_OUT[].

  SORT : GT_OUT BY KUNNR MATNR.

  LOOP AT GT_OUT.

    READ TABLE GT_OUT2 WITH KEY KUNNR = GT_OUT-KUNNR
                                MATNR = GT_OUT-MATNR
                                SEVNO = GT_OUT-SEVNO
                                BINARY SEARCH.
    IF SY-SUBRC = 0.

      LV_TABIX = SY-TABIX .

      GT_OUT2-OPKWMENG     = GT_OUT2-OPKWMENG + GT_OUT-OPKWMENG.
      GT_OUT2-OUTSVMNG     = GT_OUT2-OUTSVMNG + GT_OUT-OUTSVMNG.
      GT_OUT2-INSVMNG      = GT_OUT2-INSVMNG  + GT_OUT-INSVMNG.
      GT_OUT2-RZMNG        = GT_OUT2-RZMNG    + GT_OUT-RZMNG .
      GT_OUT2-BEKLEYEN_MIK = GT_OUT2-BEKLEYEN_MIK + GT_OUT-BEKLEYEN_MIK.
      GT_OUT2-TOP_SIP_TL   = GT_OUT2-TOP_SIP_TL   + GT_OUT-TOP_SIP_TL.
      GT_OUT2-TOP_REZ_TL   = GT_OUT2-TOP_REZ_TL   + GT_OUT2-TOP_REZ_TL .
      GT_OUT2-TOP_SEVK_TL  = GT_OUT2-TOP_SEVK_TL  + GT_OUT-TOP_SEVK_TL.
      GT_OUT2-BEKLEYEN_TL  = GT_OUT2-BEKLEYEN_TL  + GT_OUT-BEKLEYEN_TL.

      MODIFY GT_OUT2 INDEX LV_TABIX .

    ELSE.
      MOVE-CORRESPONDING GT_OUT TO GT_OUT2.
      APPEND GT_OUT2.
    ENDIF.
  ENDLOOP.

  SORT :GT_OUT2 BY SEVNO.

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

    WA_FIELDCAT-FIELDNAME   = &1 .
    WA_FIELDCAT-SCRTEXT_M   = &2.
    FIELDCATALOG-OUTPUTLEN  = 20.
    WA_FIELDCAT-COL_POS     = lv_colpos .
    lv_colpos = lv_colpos + 1 .
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR  WA_FIELDCAT.
  END-OF-DEFINITION.

  "** MAKRO ILE FIELD CATALOG YANI ALV DÜZENI OLUŞTURULUR.
  ADD_FCTALOG   'SEVNO'           'Sevk Emri No' .                 "1
  ADD_FCTALOG   'KUNNR'           'Müşteri'  .                     "2
  ADD_FCTaLOG   'NAME1'           'Müşteri Adı' .                  "3
  ADD_FCTALOG   'MATNR'           'Malzeme'  .                     "4
  ADD_FCTALOG   'MAKTX'           'Malzeme Açıklama'  .            "5
  ADD_FCTALOG   'OUTSVMNG'        'Sevk Emri Açılmamış Sip.' .     "6
  ADD_FCTALOG   'INSVMNG'         'Açık Sevk Emri Mik.'  .         "7
  ADD_FCTALOG   'RZMNG'           'Rezerv Mik.'  .                 "8
  ADD_FCTALOG   'BEKLEYEN_MIK'    'Bekleyen Mik.'  .               "9
  ADD_FCTALOG   'TOP_SIP_TL'      'Sipariş Tutar TL'  .            "10
  ADD_FCTALOG   'TOP_REZ_TL'      'Rezerv Tutar TL'   .            "11
  ADD_FCTALOG   'TOP_SEVK_TL'     'SevkEmri Tutar TL'  .           "12
  ADD_FCTALOG   'BEKLEYEN_TL'     'Bekleyen Tutar TL'  .           "13
  ADD_FCTALOG   'GLTRP'           'İşEmri Termini'  .  .           "14
  ADD_FCTALOG   'EINDT'           'Satınalma Termini'  .           "15
  ADD_FCTALOG   'EBELP'           'Açık Sipariş Mik'  .            "16
  ADD_FCTALOG   'EBELN'           'SAS No'  .                      "17
  ADD_FCTALOG   'EBELP'           'SAS Sıra No'.                   "18
  ADD_FCTALOG   'BEZEI'           'Satış Temsilcisi'.              "19

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
"----------------------------------denemeeeeeeeeee---------

FORM TOP-OF-PAGE.
*ALV Header declarations
  DATA: T_HEADER      TYPE SLIS_T_LISTHEADER,
        WA_HEADER     TYPE SLIS_LISTHEADER,
        T_LINE        LIKE WA_HEADER-INFO,
        LD_LINES      TYPE I,
        LD_LINESC(10) TYPE C.
*TITLE

*DATE
  WA_HEADER-TYP = 'S'.
  WA_HEADER-KEY = 'Date: '.
  CONCATENATE ERSDA+6(2) '.'
  ERSDA+4(2) '.'
  ERSDA(4) INTO WA_HEADER-INFO. "todays date
  APPEND WA_HEADER TO T_HEADER.
  CLEAR: WA_HEADER.

  WA_HEADER-TYP = 'S'.
  WA_HEADER-KEY = 'Time: '.
  CONCATENATE ERZET(2) '.'
  ERZET+2(2) '.'
  ERZET+4(2) INTO WA_HEADER-INFO. "todays date
  APPEND WA_HEADER TO T_HEADER.
  CLEAR: WA_HEADER.

  WA_HEADER-TYP = 'S'.
  WA_HEADER-INFO = 'Tarih ve Saati itibariyle Güncel Veriler'.
  APPEND WA_HEADER TO T_HEADER.
  CLEAR WA_HEADER.

  WA_HEADER-TYP = 'A'.
  WA_HEADER-INFO = T_LINE.
  APPEND WA_HEADER TO T_HEADER.
  CLEAR: WA_HEADER, T_LINE.

  WA_HEADER-TYP = 'A'.
  WA_HEADER-INFO = T_LINE.
  APPEND WA_HEADER TO T_HEADER.
  CLEAR: WA_HEADER, T_LINE.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = T_HEADER.
ENDFORM.

FORM DISPLAY_ALV_REPORT .
  GD_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM      = GD_REPID
      I_CALLBACK_TOP_OF_PAGE  = 'TOP-OF-PAGE'
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
      IS_LAYOUT_LVC           = GD_LAYOUT
      IT_FIELDCAT_LVC         = IT_FIELDCAT
      I_SAVE                  = 'X'
    TABLES
      T_OUTTAB                = GT_OUT2
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " DISPLAY_ALV_REPORT

FORM YETKI TABLES EPR_VKGRP
                  EPR_KUNAG
            USING IPV_TYPE.

  CLEAR :EPR_VKGRP,
         EPR_VKGRP[],
         EPR_KUNAG,
         EPR_KUNAG[].


  CALL FUNCTION 'ZSD_FM_YETKI'
    EXPORTING
      IPV_UNAME = SY-UNAME
      IPV_TYPE  = IPV_TYPE
    TABLES
      ER_VKGRP  = EPR_VKGRP[]
      ER_KUNAG  = EPR_KUNAG[].


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_FULL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
