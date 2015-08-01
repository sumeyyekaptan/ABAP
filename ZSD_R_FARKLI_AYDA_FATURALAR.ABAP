*&---------------------------------------------------------------------*
*& Report  ZSD_R_FARKLI_AYDA_FATURALAR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZSD_R_FARKLI_AYDA_FATURALAR.

TABLES : KNA1,
         LIKP,
         BKPF,
         MARA,
         LIPS.

TYPE-POOLS: SLIS.

DATA: FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.

DATA: BASLA TYPE UZEIT.
DATA: BITIR TYPE UZEIT.

DATA: IT_FIELDCAT  TYPE LVC_T_FCAT,
      WA_FIELDCAT  TYPE LVC_S_FCAT,
      GD_TAB_GROUP TYPE SLIS_T_SP_GROUP_ALV,
      GD_LAYOUT    TYPE LVC_S_LAYO,
      GD_REPID     LIKE SY-REPID.

DATA : YIL TYPE BKPF-GJAHR.                        " MALİ YIL DEĞİŞKENİ
DATA : MONAT LIKE BKPF-MONAT.                      " MALİ AY DEĞİŞKENİ

DATA : BASLANGIC TYPE DATE.                        " MALİ YIL DEĞİŞKENİ
DATA : BITIS     TYPE DATE.                        " MALİ AY DEĞİŞKENİ

******************************yıl tablosu****************************************

DATA : BEGIN OF DATE OCCURS 0,  " İNTERNAL TABLOMUZ
         LOW   LIKE BKPF-BUDAT, " BELGEDEKİ KAYIT TARİHİ
         HIGH  LIKE BKPF-BUDAT, " BELGEDEKİ KAYIT TARİHİ
         MONAT LIKE BKPF-MONAT, " MALİ AY
       END OF DATE.

************Farklı Ayda Faturalanan Teslimatların tablosu************************

DATA : BEGIN OF GT_FATURA OCCURS 0 ,
         VBELN     LIKE LIKP-VBELN,                " Teslimat
         BLDAT     LIKE LIKP-BLDAT,                " Teslimat Belge Tarihi
         WADAT_IST LIKE LIKP-WADAT_IST,            " Teslimat Fiili Mal Çıkış Tarihi
         FKDAT     LIKE VBRK-FKDAT,                " Faturalama Tarihi
         KUNNR     LIKE LIKP-KUNNR,                " Müşteri Kodu
         NAME1     LIKE KNA1-NAME1,                " Müşteri Adı
         MATNR     LIKE MARA-MATNR,                " Malzeme Kodu
         ARKTX     LIKE LIPS-ARKTX,                " Malzeme Tanımı
         MIKTAR     LIKE LIPS-LFIMG,               " Miktar
         VERPR     LIKE MBEW-VERPR,                " Birim Fiyat
         TUTAR     TYPE P DECIMALS 2,              " Tutar
         WAERK     LIKE LIKP-WAERK,                " Belge Para Birimi
       END OF GT_FATURA.


DATA : BEGIN OF GT_MIKTAR OCCURS 0 ,
         VBELN     LIKE LIKP-VBELN,                " Teslimat
         MATNR     LIKE MARA-MATNR,                " Malzeme Kodu
         VERPR     LIKE MBEW-VERPR,                " Birim Fiyat
         MIKTAR    LIKE LIPS-LFIMG,               " Miktar
       END OF GT_MIKTAR.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME
                                                 TITLE TEXT-001.
SELECT-OPTIONS: PVSTEL FOR  LIKP-VSTEL.                      "üretim yeri
SELECT-OPTIONS: PLGORT FOR  LIPS-LGORT.                      "depo yeri
SELECT-OPTIONS: PWADAT FOR  LIKP-WADAT_IST OBLIGATORY.       "Teslimat Fiili Mal Çıkış Tarihi
SELECT-OPTIONS: PLFART FOR  LIKP-LFART.                      "Belge Türü

SELECTION-SCREEN END OF BLOCK BLOCK1.

*********GİRİLEN TARİHDEKİ MALİ YILA GÖRE AYLARIN İLK VE SON GÜNLERİ**********
YIL = PWADAT-LOW+0(4).

DO 12 TIMES.                                       " 12 DEFA HER AY İÇİN DÖNECEK
  MONAT = MONAT + 1.                               " AYLARIN SIRASINI MONAT TUTUYOR

  CALL FUNCTION 'PERIOD_DAY_DETERMINE'
    EXPORTING                                      "(FONKSİYONA GÖNDERDİĞİMİZ DEĞERLER)
      I_GJAHR = YIL                                " MALİ YIL parameterdan geliyor
      I_MONAT = MONAT                              " YILIN MONAT INCI AYI (ÖRNEK: 2. AY ŞUBAT)
      I_PERIV = 'K4'                               " MALİ YIL VARYANTI
    IMPORTING                                      " (FONKSİYONDAN GERİ GELEN DEĞERLER)
      E_FDAY  = DATE-LOW                           " MONAT AYININ İLK GÜNÜ
      E_LDAY  = DATE-HIGH.                         " MONAT AYININ SON GÜNÜ

  DATE-MONAT = MONAT.                              " İNTERNAL TABLODA AYIN SIRASI
  APPEND DATE.                                     " İNTERNAL TABLOYA VERİLER EKLENDİ
  CLEAR DATE.                                      " İNTERNAL TABLONUN BAŞLIĞI SİLİNDİ

ENDDO.

*******************************************************************************

PERFORM GET_DATA.
PERFORM BUILD_FIELDCATALOG.
PERFORM BUILD_LAYOUT.
PERFORM DISPLAY_ALV_REPORT.

FORM GET_DATA.

"girilen tarih aralığının ait olduğu mali ay başlangıç ve bitiş tarihleri hesaplanıyor

  LOOP AT DATE.
    IF  PWADAT-LOW BETWEEN DATE-LOW AND DATE-HIGH.
        BASLANGIC = DATE-LOW.
        BITIS     = DATE-HIGH.
    ENDIF.
  ENDLOOP.

**********************gt_fatura****************************

    SELECT LIK~VBELN
           LIK~BLDAT
           LIK~WADAT_IST
           VBR~FKDAT
           LIK~KUNNR
           KNA~NAME1
           LIP~MATNR
           LIP~ARKTX
           LIK~WAERK
      FROM LIKP          AS LIK
INNER JOIN KNA1          AS KNA ON KNA~KUNNR = LIK~KUNNR
INNER JOIN LIPS          AS LIP ON LIP~VBELN = LIK~VBELN
INNER JOIN VBFA          AS VBF ON VBF~VBELV = LIP~VBELN
                               AND VBF~POSNV = LIP~POSNR
INNER JOIN VBRK          AS VBR ON VBR~VBELN = VBF~VBELN AND VBR~VBTYP = 'M'
INNER JOIN MBEW          AS MBE ON MBE~MATNR = LIP~MATNR  AND MBE~BWKEY = LIP~WERKS
      INTO CORRESPONDING FIELDS OF TABLE GT_FATURA
     WHERE LIK~VSTEL     IN PVSTEL
       AND LIP~LGORT     IN PLGORT
       AND LIK~WADAT_IST  BETWEEN BASLANGIC AND BITIS
       AND LIK~LFART     IN PLFART
       AND ( VBR~FKDAT > BITIS OR VBR~FKDAT < BASLANGIC ).

    SELECT LIK~VBELN
           MBE~VERPR
           LIP~MATNR
           SUM( LIP~LFIMG ) AS MIKTAR
      FROM LIKP             AS LIK
INNER JOIN LIPS             AS LIP ON LIP~VBELN = LIK~VBELN
INNER JOIN MBEW             AS MBE ON MBE~MATNR = LIP~MATNR
                                  AND MBE~BWKEY = LIP~WERKS
      INTO CORRESPONDING FIELDS OF TABLE GT_MIKTAR
  GROUP BY LIK~VBELN
           LIP~MATNR
           MBE~VERPR.

SORT GT_FATURA BY MATNR VBELN ASCENDING.
SORT GT_MIKTAR BY MATNR VBELN ASCENDING.

LOOP AT GT_FATURA.

        READ TABLE GT_MIKTAR WITH KEY MATNR = GT_FATURA-MATNR
                                      VBELN = GT_FATURA-VBELN
                                      BINARY SEARCH.
              IF SY-SUBRC = 0.
                   GT_FATURA-MIKTAR = GT_MIKTAR-MIKTAR.
                   GT_FATURA-VERPR = GT_MIKTAR-VERPR.
                   MODIFY GT_FATURA.
              ENDIF.

        GT_FATURA-TUTAR = GT_FATURA-MIKTAR * GT_FATURA-VERPR.
        MODIFY GT_FATURA.

ENDLOOP.

 SORT GT_FATURA BY WADAT_IST ASCENDING.
ENDFORM.

FORM BUILD_FIELDCATALOG .

  WA_FIELDCAT-FIELDNAME   = 'VBELN'.
  WA_FIELDCAT-SCRTEXT_M   = 'Teslimat'."TEXT-002.
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 1.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'BLDAT'.
  WA_FIELDCAT-SCRTEXT_M   = 'Teslimat Belge Tarihi'."TEXT-002.
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 2.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'WADAT_IST'.
  WA_FIELDCAT-SCRTEXT_M   = 'Teslimat Fiili Mal Çıkış Tarihi'."TEXT-003.
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 3.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'FKDAT'.
  WA_FIELDCAT-SCRTEXT_M   = 'Faturalama Tarihi'."TEXT-004.
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 4.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'KUNNR'.
  WA_FIELDCAT-SCRTEXT_M   = 'Müşteri Kodu'."TEXT-005.
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 5.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'NAME1'.
  WA_FIELDCAT-SCRTEXT_M   = 'Müşteri Adı'."TEXT-006.
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 6.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'MATNR'.
  WA_FIELDCAT-SCRTEXT_M   = ' Malzeme Kodu'."TEXT-007. KZWI4 AUDAT
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 7.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'ARKTX'.
  WA_FIELDCAT-SCRTEXT_M   = ' Malzeme Tanımı'."TEXT-007. KZWI4 AUDAT
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 7.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'VERPR'.
  WA_FIELDCAT-SCRTEXT_M   = 'Birim Fiyat'."TEXT-007.
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 7.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'MIKTAR'.
  WA_FIELDCAT-SCRTEXT_M   = 'Miktar'."TEXT-006.
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 8.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'WAERK'.
  WA_FIELDCAT-SCRTEXT_M   = 'Belge Para Birimi'."TEXT-006.
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 8.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME   = 'TUTAR'.
  WA_FIELDCAT-SCRTEXT_M   = 'Tutar'."TEXT-007.
  FIELDCATALOG-OUTPUTLEN   = 5.
  WA_FIELDCAT-COL_POS     = 9.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
  CLEAR  WA_FIELDCAT.

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
      T_OUTTAB                = GT_FATURA
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
  IF SY-SUBRC <> 0.

  ENDIF.

ENDFORM.                    " DISPLAY_ALV_REPORT
