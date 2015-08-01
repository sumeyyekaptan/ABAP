*&---------------------------------------------------------------------*
*& Report  ZMM_R_MALZEME_KARTI
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZMM_R_MALZEME_KARTI.

TABLES : MARA,                 "Genel malzeme verileri
         ZMM_MARA_ADD,         "MARA Ek Alanlar
         MARC,                 "Malzeme için üretim yeri verileri
         MVKE,                 "Malzeme için satış verileri
         ZMM_MARA_BARKOD.      "MARA Barkod Bilgileri Tablosu
TYPE-POOLS: SLIS.

DATA : BEGIN OF GT_LIST OCCURS 0 ,
         BARKOD2   LIKE ZMM_MARA_BARKOD-BARKOD,              "ÖZELLİK KODU
         MATNR     LIKE MARA-MATNR,                          "Malzeme
         BISMT     LIKE MARA-BISMT,                          "Eski malzeme no.
         BARKOD    LIKE ZMM_S_MARA_BARKOD-BARKOD,            "eski sistem kod
         MATNR_ORJ LIKE ZMM_MARA_ADD-MATNR_ORJ,              "Malzeme Orijinal Kodu
         MARKA     LIKE ZMM_MARA_ADD-MARKA,                  "Marka Kod tanımı
         MTART     LIKE MARA-MTART,                          "Malzeme türü
         MAKTX     LIKE MAKT-MAKTX,                          "Malzeme kısa metni
         MAKTX2    LIKE ZMM_MARA_ADD-MAKTX2,                 "Uzun Metin
         MEINS     LIKE MARA-MEINS,                          "Temel Ölçü Birimi
         SPART     LIKE MARA-SPART,                          "BÖLÜM
         MATKL     LIKE MARA-MATKL,                          "Mal grubu
         PRDHA     LIKE MARA-PRDHA,                          "Ürün hiyerarşisi
         KTGRM     LIKE MVKE-KTGRM,                          "Mlz.hsp.tayin grubu
         BESKZ     LIKE MARC-BESKZ,                          "Tedarik türü
         AMB_TYP   LIKE ZMM_MARA_ADD-AMB_TYP,                "Malzeme grubu 1 TANIM
         MVGR2     LIKE MVKE-MVGR2,                          "Malzeme grubu 2 TANIM
         DISGR     LIKE MARC-DISGR,                          "MİP grubu
         DISPO     LIKE MARC-DISPO,                          "MİP sorumlusu
         DISMM     LIKE MARC-DISMM,                          "MİP karakteristiği
         KZECH     LIKE MARC-KZECH,                          "Parti girişi
         STRGR     LIKE MARC-STRGR,                          "Planlama stratejisi grubu
         EKNAM     LIKE T024-EKNAM,                          "Satınalma grubu
         STAWN     LIKE MARC-STAWN,                          "İst.mal no/ith.kd.no
         INTON     LIKE ZMM_MARA_ADD-INTON ,                 "İnternet Açık/Kapalı
         URUN_OB   LIKE ZMM_MARA_ADD-URUN_OB,                "Ürün Ölçü Bilgileri
         TYP_TXT   LIKE ZMM_URUN_TIP-TYP_TXT,                "Ürün Tipi
         JPEG_RSM  LIKE ZMM_MARA_ADD-JPEG_RSM,               "jpeg Resmi
         JPEG_NUM  LIKE ZMM_MARA_ADD-JPEG_NUM,               "Jpeg Resim Olması Gereken
         LVORM     LIKE MARC-LVORM,                          "Silme İşareti ÜRETİM YERİ
         LVORM1    LIKE MARD-LVORM,                          "depo sılme
         VKORG1    LIKE MVKE-VKORG,                          "1000 SATIŞ ORG.
         VKORG2    LIKE MVKE-VKORG,                          "1010 SATIŞ ORG.
         LVORM2    LIKE MVKE-LVORM,                          "Silme İşareti SATIŞ ORG.
         LVORM3    LIKE MARA-LVORM,                          "Silme İşareti MALZEME
         STATU     LIKE ZMM_MARA_ADD-STATU,                  "Malzeme Statü KOD
         STATU_TXT LIKE ZMM_URUN_STATU-STATU_TXT,            "Malzeme Statü TANIMI
         IPTAL_TXT LIKE ZMM_MARA_ADD-IPTAL_TXT,              "İptallik Nedeni
         BKLAS     LIKE MBEW-BKLAS,                          "Değerleme sınıfı
         MTPOS     LIKE MVKE-MTPOS,                          "Kalem Tipi
         VMSTA     LIKE MVKE-VMSTA,                          "Dğtm.znc.mlz.drm
         MSTDV     LIKE MARA-MSTDV,                          "Gçrl.başlangıc
         AMB_TEXT  LIKE ZMM_MARA_ADD-AMB_TEXT,
         AMB_BRM  LIKE ZMM_MARA_ADD-AMB_BRM,
         MMSTA     LIKE MARC-MMSTA,                          "ÜY. ÖZGÜ MLZ. DRM.
       END OF GT_LIST.

DATA : BEGIN OF GT_LIST1 OCCURS 0 ,
         MATNR  LIKE MARA-MATNR,
         BARKOD LIKE ZMM_MARA_BARKOD-BARKOD,
         BKLAS  LIKE MBEW-BKLAS,
       END OF GT_LIST1.

DATA : BEGIN OF GT_BARKOD OCCURS 0 ,
         MATNR      LIKE ZMM_MARA_BARKOD-MATNR,
         BARKOD     LIKE ZMM_MARA_BARKOD-BARKOD,
         BARKOD_TYP LIKE ZMM_MARA_BARKOD-BARKOD_TYP,
       END OF GT_BARKOD.

DATA : BEGIN OF GT_STATU OCCURS 0 ,
         MATNR     LIKE ZMM_MARA_ADD-MATNR,
         STATU     LIKE ZMM_URUN_STATU-STATU,
         STATU_TXT LIKE ZMM_URUN_STATU-STATU_TXT,
         TYP_TXT   LIKE ZMM_URUN_TIP-TYP_TXT,
       END OF GT_STATU.

DATA : BEGIN OF GT_SILME OCCURS 0 ,
         MATNR     LIKE MARA-MATNR,
         LVORM     LIKE MARC-LVORM,
         LVORM1    LIKE MARD-LVORM,
         LVORM2    LIKE MVKE-LVORM,
         LVORM3    LIKE MARA-LVORM,
         VKORG1    LIKE MVKE-VKORG,                          "1000 SATIŞ ORG.
         VKORG2    LIKE MVKE-VKORG,                          "1010 SATIŞ ORG.
         IPTAL_TXT LIKE ZMM_MARA_ADD-IPTAL_TXT,

       END OF GT_SILME.

DATA : BEGIN OF GT_MARKA OCCURS 0 ,
         MATNR     LIKE ZMM_MARA_ADD-MATNR,
         MARKA     LIKE ZMM_URUN_MARKAT-MARKA_TXT,
         MARKA_TXT LIKE ZMM_URUN_MARKAT-MARKA_TXT,
       END OF GT_MARKA.

DATA : BEGIN OF GT_T024 OCCURS 0 ,
         MATNR LIKE MARC-MATNR, "MARC-EKGRP
         EKNAM LIKE T024-EKNAM,
       END OF GT_T024.

DATA: FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.

DATA: IT_FIELDCAT  TYPE LVC_T_FCAT,
      WA_FIELDCAT  TYPE LVC_S_FCAT,
      GD_TAB_GROUP TYPE SLIS_T_SP_GROUP_ALV,
      GD_LAYOUT    TYPE LVC_S_LAYO,
      GD_REPID     LIKE SY-REPID.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME
                                                 TITLE TEXT-001.
SELECT-OPTIONS: PBARKOD  FOR ZMM_MARA_BARKOD-BARKOD.               " Özellik Kodu
SELECT-OPTIONS: PMATNR   FOR MARA-MATNR.                           " Malzeme Kodu
SELECT-OPTIONS: PMTART   FOR MARA-MTART.                          " Malzeme Türü
SELECT-OPTIONS: PMARKA   FOR ZMM_MARA_ADD-MARKA.                   " Marka Kodu
SELECT-OPTIONS: PMATKL   FOR MARA-MATKL.                           " Mal Grubu
SELECT-OPTIONS: PPRDHA   FOR MARA-PRDHA.                           " Ürün Hiyerarşisi
SELECT-OPTIONS: PMVGR1   FOR MVKE-MVGR1.                           " Malzeme Grubu 1 (SD alanında yer alıyor, ürünlerin marka bilgi,leri seçiliyor.)
SELECT-OPTIONS: PWERKS   FOR MARC-WERKS.                           " Üretim Yeri
SELECT-OPTIONS: PAMBTYP  FOR ZMM_MARA_ADD-AMB_TYP.                 " Ambalaj Tip Kodu
SELECT-OPTIONS: PAMBTEXT FOR ZMM_MARA_ADD-AMB_TEXT.                " Ambalaj Açıklama
SELECT-OPTIONS: PAMBBRM  FOR ZMM_MARA_ADD-AMB_BRM.                " Ambalaj Not 1
SELECT-OPTIONS: PINTON   FOR ZMM_MARA_ADD-INTON.                   " İnternet Açık/Kapalı
PARAMETERS    : SILME    AS CHECKBOX DEFAULT ''."silme durmunu göster

SELECTION-SCREEN END OF BLOCK BLOCK1.

PERFORM GET_DATA.
PERFORM BUILD_FIELDCATALOG.
PERFORM BUILD_LAYOUT.
PERFORM DISPLAY_ALV_REPORT.

FORM GET_DATA.
*-----------------------BARKOD-DEĞERLEME SINIFI-----------------------------------------------------------

  SELECT MAR~MATNR MBW~BKLAS
    FROM MARA      AS MAR
INNER JOIN MBEW      AS MBW     ON MBW~MATNR = MAR~MATNR
    INTO CORRESPONDING FIELDS OF TABLE GT_LIST1
   WHERE MAR~MATNR IN PMATNR
GROUP BY MAR~MATNR MBW~BKLAS.

  SORT GT_LIST1    BY MATNR ASCENDING.
*-----------------------ESKİ BARKOD----------------------------------------------------

  SELECT Z~MATNR
         Z~BARKOD
         Z~BARKOD_TYP
    FROM ZMM_MARA_BARKOD      AS Z
    INTO CORRESPONDING FIELDS OF TABLE GT_BARKOD
   WHERE Z~MATNR IN PMATNR
     AND Z~BARKOD_TYP = '06'.

  SORT GT_BARKOD    BY MATNR ASCENDING.

*--------------------------MARKA--------------------------------------------------------

  SELECT ZMA~MATNR ZUM~MARKA ZUM~MARKA_TXT
    FROM ZMM_MARA_ADD         AS ZMA
INNER JOIN ZMM_URUN_MARKAT      AS ZUM    ON ZMA~MARKA = ZUM~MARKA
    INTO CORRESPONDING FIELDS OF TABLE GT_MARKA
   WHERE ZMA~MATNR IN PMATNR
GROUP BY ZMA~MATNR ZUM~MARKA ZUM~MARKA_TXT .


  SORT GT_MARKA    BY MATNR ASCENDING.
*--------------------------STOK--------------------------------------------------------

  SELECT MRC~MATNR T~EKNAM
    FROM MARC      AS MRC
INNER JOIN T024      AS T       ON MRC~EKGRP = T~EKGRP
    INTO CORRESPONDING FIELDS OF TABLE GT_T024
   WHERE MRC~MATNR IN PMATNR
GROUP BY MRC~MATNR T~EKNAM.

  SORT GT_T024    BY MATNR ASCENDING.
*--------------------------STATU--------------------------------------------------------

  SELECT ZMA~MATNR ZUS~STATU ZUS~STATU_TXT ZUT~TYP_TXT
    FROM ZMM_MARA_ADD         AS ZMA
INNER JOIN ZMM_URUN_TIP         AS ZUT   ON ZUT~URUN_TYP = ZMA~URUN_TYP
LEFT JOIN ZMM_URUN_STATU       AS ZUS   ON ZUS~STATU = ZMA~STATU
    INTO CORRESPONDING FIELDS OF TABLE GT_STATU
   WHERE ZMA~MATNR IN PMATNR
GROUP BY ZMA~MATNR ZUS~STATU ZUS~STATU_TXT ZUT~TYP_TXT.

  SORT GT_STATU    BY MATNR ASCENDING.
*-------------------------------SİLME ALANLARI-------------------------------------

  SELECT MAR~MATNR
         MAR~LVORM     AS LVORM3
         MRD~LVORM     AS LVORM1
         MRC~LVORM     AS LVORM
         MVK~LVORM     AS LVORM2
         MVK~VKORG     AS VKORG1
         MVK~VKORG     AS VKORG2
         ZMA~IPTAL_TXT
    FROM MARA          AS MAR
LEFT JOIN ZMM_MARA_ADD  AS ZMA    ON ZMA~MATNR = MAR~MATNR
LEFT JOIN MARD          AS MRD    ON MRD~MATNR = MAR~MATNR AND MRD~LVORM = 'X'
LEFT JOIN MVKE          AS MVK    ON MVK~MATNR = MAR~MATNR AND MVK~LVORM = 'X'
LEFT JOIN MARC          AS MRC    ON MRC~MATNR = MAR~MATNR AND MRC~LVORM = 'X'
    INTO CORRESPONDING FIELDS OF TABLE GT_SILME
   WHERE MAR~MATNR     IN PMATNR.

  SORT GT_SILME    BY MATNR ASCENDING.

  LOOP AT GT_SILME.
    IF GT_SILME-VKORG1 = '1000'.
      GT_SILME-VKORG1 = 'X'.
      MODIFY GT_SILME.
    ELSEIF GT_SILME-VKORG1 <> '1000'.
      GT_SILME-VKORG1 = ''.
      MODIFY GT_SILME.
    ENDIF.
  ENDLOOP.

  LOOP AT GT_SILME.
    IF GT_SILME-VKORG2 = '1010'.
      GT_SILME-VKORG2 = 'X'.
      MODIFY GT_SILME.
    ELSEIF GT_SILME-VKORG2 <> '1010'.
      GT_SILME-VKORG2 = ''.
      MODIFY GT_SILME.
    ENDIF.
  ENDLOOP.
*------------MARA-ZMM_MARA_ADD-MARC-MAKT TABLOLARININ ALANLARI---------------------

    SELECT MAR~MATNR,
           MAR~BISMT,
           MAR~MTART,
           MAR~MSTAV,
           MAR~MEINS,
           MAR~MSTDV,
           MVK~VMSTA,
           MAR~MEINS,
           MAR~PRDHA,
           MVK~MTPOS,
           MAR~SPART,
           MAR~MATKL,
           MAR~SPART,
           MVK~KTGRM,
           MVK~MVGR2,
           MKT~MAKTX,
           MRC~DISMM,
           MRC~BESKZ,
           MRC~DISGR,
           MRC~DISPO,
           MRC~KZECH,
           MRC~STRGR,
           MRC~MMSTA,
           MRC~EKGRP,
           MRC~STAWN,
           ZMB~BARKOD       AS BARKOD2,
           ZMA~MARKA,
           ZMA~JPEG_NUM,
           ZMA~URUN_TYP,
           ZMA~IPTAL_TXT,
           ZMA~STATU,
           ZMA~INTON,
           ZMA~MAKTX2,
           ZMA~URUN_OB,
           ZMA~AMB_TYP,
           ZMA~JPEG_RSM,
           ZMA~MATNR_ORJ,
           ZMA~AMB_TYP,
           ZMA~AMB_TEXT,
           ZMA~AMB_BRM
      INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
      FROM MARA             AS MAR
INNER JOIN ZMM_MARA_ADD     AS ZMA  ON ZMA~MATNR = MAR~MATNR
left JOIN MAKT             AS MKT  ON MKT~MATNR = MAR~MATNR
                                   AND MKT~SPRAS = 'TR'
 LEFT JOIN MARC             AS MRC  ON MRC~MATNR = ZMA~MATNR
 LEFT JOIN MVKE             AS MVK  ON MVK~MATNR = MAR~MATNR
 LEFT JOIN ZMM_MARA_BARKOD  AS ZMB  ON ZMB~MATNR = MAR~MATNR
                                   AND ZMB~BARKOD_TYP = '05'
     WHERE MAR~MATNR        IN @PMATNR
       AND ZMA~MARKA        IN @PMARKA
       AND MAR~MTART        IN @PMTART
       AND MAR~MATKL        IN @PMATKL
       AND MAR~PRDHA        IN @PPRDHA
       AND MRC~WERKS        IN @PWERKS
       AND ZMB~BARKOD       IN @PBARKOD
       AND ZMA~AMB_TYP      IN @PAMBTYP
       AND ZMA~AMB_TEXT     IN @PAMBTEXT
       AND ZMA~AMB_BRM     IN @PAMBBRM
       AND MVK~MVGR1        IN @PMVGR1
       AND ZMA~INTON        IN @PINTON
  GROUP BY MAR~MATNR,
           MAR~BISMT,
           MAR~MTART,
           MAR~MSTAV,
           MAR~MEINS,
           MAR~MSTDV,
           MVK~VMSTA,
           MAR~MEINS,
           MAR~PRDHA,
           MVK~MTPOS,
           MAR~SPART,
           MAR~MATKL,
           MAR~SPART,
           MVK~KTGRM,
           MVK~MVGR2,
           MKT~MAKTX,
           MRC~DISMM,
           MRC~BESKZ,
           MRC~DISGR,
           MRC~DISPO,
           MRC~KZECH,
           MRC~STRGR,
           MRC~MMSTA,
           MRC~EKGRP,
           MRC~STAWN,
           ZMB~BARKOD,
           ZMA~MARKA,
           ZMA~JPEG_NUM,
           ZMA~URUN_TYP,
           ZMA~IPTAL_TXT,
           ZMA~STATU,
           ZMA~INTON,
           ZMA~MAKTX2,
           ZMA~URUN_OB,
           ZMA~AMB_TYP,
           ZMA~JPEG_RSM,
           ZMA~MATNR_ORJ,
           ZMA~AMB_TYP,
           ZMA~AMB_TEXT,
           ZMA~AMB_BRM.

  SORT GT_LIST    BY MATNR ASCENDING.

  LOOP AT GT_LIST.
    IF GT_LIST-MEINS = 'ST'. "TEMEL ÖLÇÜ BİRMİ

      GT_LIST-MEINS = 'ADT'.
      MODIFY GT_LIST.

    ENDIF.

    READ TABLE GT_LIST1 WITH KEY MATNR = GT_LIST-MATNR
    BINARY SEARCH.
    IF SY-SUBRC = 0.
      GT_LIST-BKLAS      = GT_LIST1-BKLAS.
      MODIFY GT_LIST.
    ENDIF.

    READ TABLE GT_BARKOD WITH KEY MATNR = GT_LIST-MATNR
    BINARY SEARCH.
    IF SY-SUBRC = 0.
      GT_LIST-BARKOD      = GT_BARKOD-BARKOD.
      MODIFY GT_LIST.
    ENDIF.

    READ TABLE GT_MARKA  WITH KEY MATNR = GT_LIST-MATNR
    BINARY SEARCH.
    IF SY-SUBRC = 0.
      GT_LIST-MARKA      =  GT_MARKA-MARKA_TXT.
      MODIFY GT_LIST.
    ENDIF.

    READ TABLE GT_STATU  WITH KEY MATNR = GT_LIST-MATNR
    BINARY SEARCH.
    IF SY-SUBRC = 0.
      GT_LIST-STATU_TXT  =  GT_STATU-STATU_TXT.
      GT_LIST-TYP_TXT    =  GT_STATU-TYP_TXT.
      MODIFY GT_LIST.
    ENDIF.

    READ TABLE GT_T024  WITH KEY MATNR = GT_LIST-MATNR
    BINARY SEARCH.
    IF SY-SUBRC = 0.
      GT_LIST-EKNAM      =  GT_T024-EKNAM.
      MODIFY GT_LIST.
    ENDIF.

    READ TABLE GT_SILME  WITH KEY MATNR = GT_LIST-MATNR
    BINARY SEARCH.
    IF SY-SUBRC = 0.
      GT_LIST-LVORM   =  GT_SILME-LVORM.
      GT_LIST-LVORM1  =  GT_SILME-LVORM1.
      GT_LIST-LVORM2  =  GT_SILME-LVORM2.
      GT_LIST-LVORM3  =  GT_SILME-LVORM3.
      GT_LIST-VKORG1  =  GT_SILME-VKORG1.
      GT_LIST-VKORG2  =  GT_SILME-VKORG2.
      MODIFY GT_LIST.
    ENDIF.
  ENDLOOP.

  IF SILME = 'X'.

    LOOP AT GT_LIST.
      IF GT_LIST-LVORM3 = ''.
        DELETE GT_LIST INDEX SY-TABIX.
        IF GT_LIST-LVORM3 = 'X'.
          INSERT GT_LIST INDEX SY-TABIX.
          MODIFY GT_LIST.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ELSEIF SILME = ''.

    LOOP AT GT_LIST.
      IF GT_LIST-LVORM3 <> ''.
        DELETE GT_LIST INDEX SY-TABIX.

        IF GT_LIST-LVORM3 = ''.
          INSERT GT_LIST INDEX SY-TABIX.
          MODIFY GT_LIST.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

 SORT GT_LIST    BY BARKOD2 ASCENDING.

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

  ADD_FCTALOG 'BARKOD2'            'Özellik Kodu'.             "TEXT-002.
  ADD_FCTALOG 'MATNR'              'Malzeme'.                  "TEXT-003.
  ADD_FCTALOG 'BISMT'              'Eski Malzeme No'.          "TEXT-004.
  ADD_FCTALOG 'BARKOD'             'Eski Sistem Kod'.          "TEXT-005.
  ADD_FCTALOG 'MATNR_ORJ'          'Malzeme Orijinal Kodu'.    "TEXT-006.
  ADD_FCTALOG 'MARKA'              'Marka Kod Tanımı'.         "TEXT-007.
  ADD_FCTALOG 'MTART'              'Malzeme Türü'.             "TEXT-008.
  ADD_FCTALOG 'MAKTX'              'Malzeme Kısa Metni'.       "TEXT-009.
  ADD_FCTALOG 'MAKTX2'             'Uzun Metin'.               "TEXT-010.
  ADD_FCTALOG 'MEINS'              'Temel Ölçü Birimi'.        "TEXT-011.
  ADD_FCTALOG 'SPART'              'Bölüm'.                    "TEXT-012.
  ADD_FCTALOG 'MATKL'              'Mal Grubu'.                "TEXT-013.
  ADD_FCTALOG 'PRDHA'              'Ürün Hiyerarşisi'.         "TEXT-014.
  ADD_FCTALOG 'KTGRM'              'Mlz.hsp.tayin grubu'.      "TEXT-015.
  ADD_FCTALOG 'BESKZ'              'Tedarik Türü'.             "TEXT-016.
  ADD_FCTALOG 'MVGR2'              'Dahili İşlem'.             "TEXT-017.
  ADD_FCTALOG 'DISGR'              'MİP Grubu'.                "TEXT-018.
  ADD_FCTALOG 'DISPO'              'MİP Sorumlusu'.            "TEXT-019.
  ADD_FCTALOG 'DISMM'              'MİP Karakteristiği'.       "TEXT-020.
  ADD_FCTALOG 'KZECH'              'Parti Girişi'.             "TEXT-021.
  ADD_FCTALOG 'STRGR'              'Planlama Stratejisi Grubu'."TEXT-022.
  ADD_FCTALOG 'EKNAM'              'Satınalma Grubu'.          "TEXT-023.
  ADD_FCTALOG 'STAWN'              'İst.mal no/ith.kd.no'.     "TEXT-024.
  ADD_FCTALOG 'INTON'              'İnternet Açık/Kapalı'.     "TEXT-025.
  ADD_FCTALOG 'URUN_OB'            'Ürün Ölçü Bilgileri'.      "TEXT-026.
  ADD_FCTALOG 'TYP_TXT'            'Ürün Tipi'.                "TEXT-027.
  ADD_FCTALOG 'JPEG_RSM'           'Jpeg Resmi'.               "TEXT-028.
  ADD_FCTALOG 'JPEG_NUM'           'Jpeg Resim Olması Gereken'."TEXT-029.
  ADD_FCTALOG 'LVORM'              'Silme İşareti Üretim Yeri'."TEXT-030.
  ADD_FCTALOG 'LVORM2'             'Silme İşareti Satış Org.'. "TEXT-031.
  ADD_FCTALOG 'VKORG1'             '1000 Satış Org.'.          "TEXT-032.
  ADD_FCTALOG 'VKORG2'             '1010 Satış Org.'.          "TEXT-033.
  ADD_FCTALOG 'LVORM1'             'Depo Silme'.               "TEXT-034.
  ADD_FCTALOG 'LVORM3'             'Malzeme Silme'.            "TEXT-035.
  ADD_FCTALOG 'STATU'              'Malzeme Statü Kodu'.       "TEXT-036.
  ADD_FCTALOG 'STATU_TXT'          'Malzeme Statü Tanımı'.     "TEXT-037.
  ADD_FCTALOG 'IPTAL_TXT'          'İptallik Nedeni'.          "TEXT-038.
  ADD_FCTALOG 'BKLAS'              'Değerleme Sınıfı'.         "TEXT-039.
  ADD_FCTALOG 'MTPOS'              'Kalem Tipi'.               "TEXT-040.
  ADD_FCTALOG 'VMSTA'              'Dğtm.znc.mlz.drm'.         "TEXT-041.
  ADD_FCTALOG 'MSTDV'              'Gçrl.başlangıc'.           "TEXT-042.
  ADD_FCTALOG 'AMB_TYP'            'Firma'.                    "TEXT-043.
  ADD_FCTALOG 'AMB_TEXT'           'Logo Durumu'.              "TEXT-044.
  ADD_FCTALOG 'AMB_BRM'            'Kutu Durumu'.              "TEXT-045.
  ADD_FCTALOG 'MMSTA'              'ÜY`ye özgü mlz.drm'.       "TEXT-045.

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
      T_OUTTAB                = GT_LIST
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
  IF SY-SUBRC <> 0.

  ENDIF.

ENDFORM.                    " DISPLAY_ALV_REPORT

**********************ÖZELLİK KODU İÇİN SEARCH HELP********************
*
*DATA : BEGIN OF VALUES_TAB OCCURS 0 ,
*         BARKOD LIKE ZMM_MARA_BARKOD-BARKOD,            "Özellik kodu
*       END OF VALUES_TAB.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR  : PBARKOD-LOW.
*  PERFORM OZELLIK_KODU_SEARCHHELP.
*
*INITIALIZATION.
*  PERFORM INIT_SELECTION.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR  : PBARKOD-HIGH.
*  PERFORM OZELLIK_KODU_SEARCHHELP.
*
*INITIALIZATION.
*  PERFORM INIT_SELECTION.
*
*FORM OZELLIK_KODU_SEARCHHELP .
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      RETFIELD        = 'BARKOD'
*      DYNPPROG        = SY-CPROG
*      DYNPNR          = SY-DYNNR
*      DYNPROFIELD     = 'PBARKOD'
*      VALUE_ORG       = 'S'
*      WINDOW_TITLE    = 'ÖZELLİK KODU'
*    TABLES
*      VALUE_TAB       = VALUES_TAB[]
*    EXCEPTIONS
*      PARAMETER_ERROR = 1
*      NO_VALUES_FOUND = 2
*      OTHERS          = 3.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*ENDFORM.
*
*
*FORM INIT_SELECTION .
*  SELECT  BARKOD
*  FROM  ZMM_MARA_BARKOD
*  INTO  CORRESPONDING FIELDS OF TABLE VALUES_TAB
*  WHERE BARKOD_TYP = '05'
*    GROUP BY BARKOD.
*  SORT VALUES_TAB BY BARKOD ASCENDING.
*
*ENDFORM.
