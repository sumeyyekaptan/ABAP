*&---------------------------------------------------------------------*
*& Report  ZSD_YASAKLI_URUN_ANALIZ_RAPORU
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZSD_YASAKLI_URUN_ANALIZ_RAPORU.

TABLES : ZMM_MARA_BARKOD,
         VBAK,
         ZSD_T_T002.

TYPE-POOLS: SLIS.

DATA: FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.

DATA: IT_FIELDCAT  TYPE LVC_T_FCAT,
      WA_FIELDCAT  TYPE LVC_S_FCAT,
      GD_TAB_GROUP TYPE SLIS_T_SP_GROUP_ALV,
      GD_LAYOUT    TYPE LVC_S_LAYO,
      GD_REPID     LIKE SY-REPID.

DATA : BEGIN OF GT_YASAKLIURUN OCCURS 0 ,

         BARKOD   LIKE ZMM_MARA_BARKOD-BARKOD,       "Özellik kodu
         MATNR    LIKE ZSD_ORDERS-MATNR,             "Malzeme kodu

         KUNNR    LIKE ZSD_ORDERS-KUNNR,             "Müşteri
         NAME1    LIKE KNA1-NAME1,                   "Müşteri Adı

         BEZEI1   LIKE TVGRT-BEZEI,                  "Ülke Temsilcisi
         "VKGRP    LIKE KNVV-VKGRP,                   "Ülke Temsilcisi
         VBELN    LIKE ZSD_ORDERS-VBELN,             "Sipariş Belge Numarası
         POSNR    LIKE ZSD_ORDERS-POSNR,             "Satır No

         OPKWMENG LIKE ZSD_ORDERS-OPKWMENG,          "Açık Bakiye Miktarı
         KZWI4    LIKE ZSD_ORDERS-KZWI4,             "Açık Bakiye Tutarı
         WAERK    LIKE ZSD_ORDERS-WAERK,             "para birimi
         KZWI4TL  LIKE ZSD_ORDERS-KZWI4TL,           "Açık Bakiye Tutarı
         WAERK_2  LIKE ZSD_ORDERS-WAERK,             "para birimi

         AUDAT    LIKE ZSD_ORDERS-AUDAT,             "Tarih
         LAND1    TYPE STRING,                       "Ülke
         LANDX    TYPE T005T-LANDX,                  "Ülke Adı

         ABGRU    LIKE ZSD_ORDERS-ABGRU,             "Yasak Nedeni (marka,patent…)
         BEZEI    LIKE TVAGT-BEZEI,                  "RED NEDENİ
         WERKS    LIKE ZSD_ORDERS-WERKS,             "ÜRETİM YERİ
         PARVW    TYPE STRING,                       "muhatap tipi

         BASTRH        LIKE ZSD_T_T002-BASTRH,   "başlangıç tarihi
         METIN         LIKE ZSD_T_T002-METIN,        "açıklama
         YASAKLA_NEDEN LIKE ZSD_T_T002-YASAKLA_NEDEN,          " yasaklama nedeni

         MTART         LIKE MARA-MTART,
         STATU         LIKE ZMM_MARA_ADD-STATU,
*         DURUM         LIKE     ,
       END OF GT_YASAKLIURUN.

DATA : BEGIN OF GT_REDNEDENI OCCURS 0 ,
         ABGRU  LIKE ZSD_ORDERS-ABGRU,             "Yasak Nedeni (marka,patent…)
         BEZEI  LIKE TVAGT-BEZEI,                  "RED NEDENİ
         BARKOD LIKE ZMM_MARA_BARKOD-BARKOD,
       END OF GT_REDNEDENI.

DATA : BEGIN OF GT_MUHATAP OCCURS 0 ,
         PARVW LIKE VBPA-PARVW,
         VBELN LIKE VBPA-VBELN,                    "BELGE NO
         POSNR LIKE VBPA-POSNR,                    "KALEM
         MATNR LIKE ZSD_ORDERS-MATNR,
         LAND1 LIKE T005T-LANDX,
       END OF GT_MUHATAP.

DATA : BEGIN OF GT_MARA OCCURS 0 ,
         MATNR         LIKE MARA-MATNR,
         MTART         LIKE MARA-MTART,
         STATU         LIKE ZMM_MARA_ADD-STATU,
*         DURUM         LIKE     ,
       END OF GT_MARA.

DATA : BEGIN OF GT_ZSD_T_T002 OCCURS 0 ,           "YASAKLI ÜRÜN LİSTESİ
         YANUM         LIKE ZSD_T_T002-YANUM,
         ULKE          LIKE ZSD_T_T002-ULKE,
         MATNR         LIKE ZSD_T_T002-MATNR,
         BASTRH        LIKE ZSD_T_T002-BASTRH,   "başlangıç tarihi
         METIN         LIKE ZSD_T_T002-METIN,        "açıklama
         YASAKLA_NEDEN LIKE ZSD_T_T002-YASAKLA_NEDEN,          " yasaklama nedeni
       END OF GT_ZSD_T_T002.

DATA : BEGIN OF GT_T005T OCCURS 0 ,               "müşteri ülkesi
         LAND1 LIKE T005T-LAND1,
         LANDX LIKE T005T-LANDX,
       END OF GT_T005T.

DATA: TUTAR  TYPE STRING.
TUTAR = 'TRY'.

DATA: FOUND TYPE I.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME
                                                 TITLE TEXT-099.
SELECT-OPTIONS: PBARKOD FOR ZMM_MARA_BARKOD-BARKOD.               " Özellik Kodu
SELECT-OPTIONS: PVBELN  FOR VBAK-VBELN.

SELECTION-SCREEN END OF BLOCK BLOCK1.

START-OF-SELECTION.
  PERFORM GET_DATA.

END-OF-SELECTION.

  PERFORM BUILD_FIELDCATALOG.
  PERFORM BUILD_LAYOUT.
  PERFORM DISPLAY_ALV_REPORT.

FORM GET_DATA.

**********************YASAKLI URUN TABLOSU****************************

  SELECT ZMM~BARKOD     ZSD~MATNR     KNA~NAME1
         ZSD~VBELN      ZSD~POSNR     ZSD~OPKWMENG
         ZSD~KZWI4      ZSD~AUDAT     ZSD~WERKS
         ZSD~ABGRU      ZSD~WAERK     ZSD~KUNNR
         ZSD~KZWI4TL    TVG~BEZEI AS BEZEI1" KNV~VKGRP
    FROM ZSD_ORDERS      AS ZSD
INNER JOIN KNA1            AS KNA ON KNA~KUNNR = ZSD~KUNNR
INNER JOIN ZMM_MARA_BARKOD AS ZMM ON ZMM~MATNR = ZSD~MATNR
                               AND ZMM~BARKOD_TYP = '05'
INNER JOIN KNVV            AS KNV ON KNV~KUNNR = ZSD~KUNNR
INNER JOIN TVGRT           AS TVG ON TVG~VKGRP = KNV~VKGRP
INNER JOIN VBAK            AS VBA ON VBA~VBELN = ZSD~VBELN
                               AND VBA~VKORG = KNV~VKORG
    INTO CORRESPONDING FIELDS OF TABLE GT_YASAKLIURUN
   WHERE ZMM~BARKOD      IN PBARKOD
     AND ZSD~VBELN       IN PVBELN
     AND ZSD~WERKS = '1100'
     AND ZSD~OPENCLOSE = '2'
     AND ZSD~ABGRU BETWEEN '04' AND '05'
GROUP BY ZMM~BARKOD     ZSD~MATNR     KNA~NAME1
         ZSD~VBELN      ZSD~POSNR     ZSD~OPKWMENG
         ZSD~KZWI4      ZSD~AUDAT     ZSD~WERKS
         ZSD~ABGRU      ZSD~WAERK     ZSD~KUNNR
         ZSD~KZWI4TL    TVG~BEZEI." KNV~VKGRP.

**************************RED NEDENİ TABLOSU****************************

  SELECT TVA~BEZEI
         TVA~ABGRU
    FROM TVAGT           AS TVA
    INTO CORRESPONDING FIELDS OF TABLE GT_REDNEDENI
   WHERE TVA~SPRAS = 'TR'
     AND TVA~ABGRU BETWEEN '04' AND '05'.

*******************GT_T005T*********************ÜLKELER********************

  SELECT T~LAND1
         T~LANDX
    FROM T005T AS T
    INTO CORRESPONDING FIELDS OF TABLE GT_T005T
   WHERE T~SPRAS = 'TR'.

*****************************************************************************

  LOOP AT GT_YASAKLIURUN.

    GT_YASAKLIURUN-KZWI4   = GT_YASAKLIURUN-KZWI4 * GT_YASAKLIURUN-OPKWMENG.
    GT_YASAKLIURUN-KZWI4TL = GT_YASAKLIURUN-KZWI4TL * GT_YASAKLIURUN-OPKWMENG.
    GT_YASAKLIURUN-WAERK_2 = TUTAR.
    MODIFY GT_YASAKLIURUN.

    "**********GT_MATA******MALZEME TÜRÜ STATU DURUM*****

    SELECT M~MATNR
           M~MTART
           Z~STATU
      FROM ZMM_MARA_ADD AS Z
INNER JOIN MARA AS M ON Z~MATNR = M~MATNR
      INTO CORRESPONDING FIELDS OF TABLE GT_MARA
     WHERE M~MATNR = GT_YASAKLIURUN-MATNR.

    "**********GT_ZSD_T_T002******YASAKLI ÜRÜN LİSTESİ***

    SELECT ZSD~YANUM
           ZSD~ULKE
           ZSD~MATNR
           ZSD~BASTRH            "başlangıç tarihi
           ZSD~METIN             "açıklama
           ZSD~YASAKLA_NEDEN     " yasaklama nedeni
      FROM ZSD_T_T002 AS ZSD
      INTO CORRESPONDING FIELDS OF TABLE GT_ZSD_T_T002
     WHERE ZSD~MATNR = GT_YASAKLIURUN-MATNR
     ORDER BY ZSD~ULKE.
    " WHERE ZSD~PASIF = SPACE. " Aktif satirlar cekiliyor..

    READ TABLE GT_REDNEDENI
      WITH KEY ABGRU = GT_YASAKLIURUN-ABGRU.
    IF SY-SUBRC = 0.
      GT_YASAKLIURUN-BEZEI = GT_REDNEDENI-BEZEI.
      MODIFY GT_YASAKLIURUN.
    ENDIF.

    " Muhataplar internal table bosaltiliyor..
    REFRESH GT_MUHATAP.

    SELECT V~PARVW
           V~VBELN
           V~POSNR
           V~LAND1
      FROM VBPA       AS V
      INTO CORRESPONDING FIELDS OF TABLE GT_MUHATAP
     WHERE V~VBELN = GT_YASAKLIURUN-VBELN.

    "   Muhataplar, tek tek ulkelerine erismek icin donuluyor..
    LOOP AT GT_MUHATAP.
      " Yasakli urun havuzundan ulke ve malzeme icin karsilik gelen bir satir var mi kontrolu yapiliyor..

      READ TABLE GT_ZSD_T_T002
        WITH KEY ULKE = GT_MUHATAP-LAND1
                 MATNR = GT_YASAKLIURUN-MATNR
          BINARY SEARCH.
      " suanki ulke ve malzeme icin bir yasak bulundu ise
      IF SY-SUBRC = 0.
        GT_YASAKLIURUN-LAND1 = GT_MUHATAP-LAND1.
        GT_YASAKLIURUN-PARVW = GT_MUHATAP-PARVW.
        MODIFY GT_YASAKLIURUN.
        EXIT.
      ENDIF.
    ENDLOOP.
***************************************************************************************
*    "MALZEME TÜRKİYEYE YASAKLI MI?

    LOOP AT GT_ZSD_T_T002.
      IF GT_ZSD_T_T002-ULKE = 'TR' AND GT_YASAKLIURUN-PARVW = ''.
        GT_YASAKLIURUN-LAND1 = GT_ZSD_T_T002-ULKE.
        GT_YASAKLIURUN-BASTRH = GT_ZSD_T_T002-BASTRH.
        GT_YASAKLIURUN-METIN = GT_ZSD_T_T002-METIN.
        GT_YASAKLIURUN-YASAKLA_NEDEN = GT_ZSD_T_T002-YASAKLA_NEDEN.
        MODIFY GT_YASAKLIURUN.
      ENDIF.
    ENDLOOP.

    IF GT_YASAKLIURUN-PARVW     ='AG'.
      GT_YASAKLIURUN-PARVW     ='Sipariş veren'.
    ELSEIF GT_YASAKLIURUN-PARVW ='RE'.
      GT_YASAKLIURUN-PARVW     ='Fatura alıcısı'.
    ELSEIF GT_YASAKLIURUN-PARVW ='RG'.
      GT_YASAKLIURUN-PARVW     ='Ödeyen'.
    ELSEIF GT_YASAKLIURUN-PARVW ='WE'.
      GT_YASAKLIURUN-PARVW     ='Malı teslim alan'.
    ENDIF.
    MODIFY GT_YASAKLIURUN.

    READ TABLE GT_T005T
      WITH KEY LAND1 = GT_YASAKLIURUN-LAND1.
    IF SY-SUBRC = 0.
      GT_YASAKLIURUN-LANDX = GT_T005T-LANDX.
      MODIFY GT_YASAKLIURUN.
    ENDIF.

    READ TABLE GT_MARA
      WITH KEY MATNR = GT_YASAKLIURUN-MATNR.
    IF SY-SUBRC = 0.
      GT_YASAKLIURUN-MTART = GT_MARA-MTART.
      GT_YASAKLIURUN-STATU = GT_MARA-STATU.
      MODIFY GT_YASAKLIURUN.
    ENDIF.
  ENDLOOP.
ENDFORM.

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

 ADD_FCTALOG 'BARKOD'              TEXT-001. "'Özellik kodu'."
 ADD_FCTALOG 'MATNR'               TEXT-002."'Malzeme kodu'."
 ADD_FCTALOG 'NAME1'               TEXT-003."'Müşteri'."
 ADD_FCTALOG 'BEZEI1'              TEXT-004."'Ülke Temsilcisi'."
 ADD_FCTALOG 'VBELN'               TEXT-005."'Sipariş Belge No'."
 ADD_FCTALOG 'POSNR'               TEXT-006."'Kalem No'."
 ADD_FCTALOG 'OPKWMENG'            TEXT-007."' Açık Bakiye Miktarı'."
 ADD_FCTALOG 'KZWI4TL'             TEXT-008."'Açık Bakiye Tutarı'."
 ADD_FCTALOG 'WAERK_2'             TEXT-009."'Para Birimi'."
 ADD_FCTALOG 'KZWI4'               TEXT-010."'Açık Bakiye Tutarı'."
 ADD_FCTALOG 'WAERK'               TEXT-011."'Para Birimi'."
 ADD_FCTALOG 'BEZEI'               TEXT-012."' Yasak Nedeni'."
 ADD_FCTALOG 'AUDAT'               TEXT-013."'Belge Tarihi'."
 ADD_FCTALOG 'LANDX'               TEXT-014."'Ülke'."
 ADD_FCTALOG 'PARVW'               TEXT-015."'Muhatap Tipi'."
 ADD_FCTALOG 'BASTRH'              TEXT-016."'Başlangıç Tarihi'."
 ADD_FCTALOG 'METIN'               TEXT-017."'Açıklama'."
 ADD_FCTALOG 'YASAKLA_NEDEN'       TEXT-018."'Yasaklama Nedeni'."
 ADD_FCTALOG 'MTART'               TEXT-019."'Malzeme Türü'."
 ADD_FCTALOG 'STATU'               TEXT-020."'Statü'."
 "ADD_FCTALOG 'DURUM'               TEXT-021."'Durum'."
ENDFORM.                    " BUILD_FIELDCATALOG

FORM BUILD_LAYOUT .

  GD_LAYOUT-STYLEFNAME = 'FIELD_STYLE'.
  GD_LAYOUT-ZEBRA      = 'X'.
  GD_LAYOUT-CWIDTH_OPT = 'X'.

ENDFORM.                    " BUILD_LAYOUT

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
      T_OUTTAB                = GT_YASAKLIURUN
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
  IF SY-SUBRC <> 0.

  ENDIF.

ENDFORM.                    " DISPLAY_ALV_REPORT

**********************ÖZELLİK KODU İÇİN SEARCH HELP********************

DATA : BEGIN OF VALUES_TAB OCCURS 0 ,
         BARKOD LIKE ZMM_MARA_BARKOD-BARKOD,            "Özellik kodu
       END OF VALUES_TAB.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR  : PBARKOD-LOW.
  PERFORM OZELLIK_KODU_SEARCHHELP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR  : PBARKOD-HIGH.
  PERFORM OZELLIK_KODU_SEARCHHELP.

FORM OZELLIK_KODU_SEARCHHELP .
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'BARKOD'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'PBARKOD'
      VALUE_ORG       = 'S'
      WINDOW_TITLE    = 'ÖZELLİK KODU'
    TABLES
      VALUE_TAB       = VALUES_TAB[]
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

INITIALIZATION.
  PERFORM INIT_SELECTION.

FORM INIT_SELECTION .
  SELECT  BARKOD
  FROM  ZMM_MARA_BARKOD
  INTO  CORRESPONDING FIELDS OF TABLE VALUES_TAB
  WHERE BARKOD_TYP = '05'
    GROUP BY BARKOD.
  SORT VALUES_TAB BY BARKOD ASCENDING.

ENDFORM.
