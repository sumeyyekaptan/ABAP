*&---------------------------------------------------------------------*
*& Report  ZMM_RAPOR_ORNEK
*&
*&
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT zmm_rapor_ornek.

TABLES : zmm_tlp_hvz , kna1.

TYPE-POOLS: slis.

DATA : BEGIN OF gt_list OCCURS 0 ,

         sorgu_tar LIKE zmm_tlp_hvz-sorgu_tar,
         oem_no    LIKE zmm_tlp_hvz-oem_no,
         miktar    LIKE zmm_tlp_hvz-miktar,
         ip_adr    LIKE zmm_tlp_hvz-ip_adr,
         kunnr     LIKE zmm_tlp_hvz-kunnr,
         kaynak    LIKE zmm_tlp_hvz-kaynak,
         ukle      LIKE zmm_tlp_hvz-ukle,
         name1     LIKE kna1-name1,
         land1     LIKE kna1-land1,
         hrc_drm   LIKE zmm_tlp_hvz-hrc_drm,

       END OF gt_list.

DATA : BEGIN OF gt_kna1 OCCURS 0 ,


         kunnr LIKE kna1-kunnr,

         name1 LIKE kna1-name1,
         land1 LIKE kna1-land1,


       END OF gt_kna1.

"DATA : gt_kna1 TYPE kna1 OCCURS 0 WITH HEADER LINE.


DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE.
DATA: it_fieldcat  TYPE lvc_t_fcat,     "slis_t_fieldcat_alv WITH HEADER LINE,
      wa_fieldcat  TYPE lvc_s_fcat,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE lvc_s_layo,     "slis_layout_alv,
      gd_repid     LIKE sy-repid.

SELECTION-SCREEN BEGIN OF BLOCK blk1. "seçim kriterleri
SELECT-OPTIONS: so_tarih  FOR zmm_tlp_hvz-sorgu_tar .
SELECT-OPTIONS: sorgu     FOR zmm_tlp_hvz-kaynak .
SELECT-OPTIONS: musteri   FOR zmm_tlp_hvz-kunnr .
SELECTION-SCREEN END OF BLOCK blk1.

PARAMETERS: h_durumu AS CHECKBOX DEFAULT 'X'.

PERFORM get_data.
PERFORM build_fieldcatalog.
PERFORM build_layout.
PERFORM display_alv_report.
*&---------------------------------------------------------------------*
*&      Form  GET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_list FROM zmm_tlp_hvz
  WHERE sorgu_tar IN so_tarih
   AND zmm_tlp_hvz~kunnr IN musteri
   AND hrc_drm = h_durumu
   AND zmm_tlp_hvz~kaynak IN sorgu.

  SELECT * FROM kna1 INTO CORRESPONDING FIELDS OF TABLE gt_kna1.

  LOOP AT gt_list.

    IF gt_list-kaynak = 'B2B' AND gt_list-kunnr = '' OR gt_list-kaynak ='SIP' AND gt_list-kunnr = ''.

      gt_list-name1 = 'HATALI KAYIT'.
      gt_list-land1 = 'XXX'.
      MODIFY gt_list.

    ELSEIF gt_list-kunnr <> ''.
      READ TABLE gt_kna1 WITH KEY kunnr = gt_list-kunnr.
      IF sy-subrc = 0.

        gt_list-name1 = gt_kna1-name1.
        gt_list-land1 = gt_kna1-land1.

      ENDIF.
      MODIFY gt_list.

    ENDIF.
  ENDLOOP.


ENDFORM.                    " GET_DATE
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcatalog . " listede görüntülenecek olanlar

  wa_fieldcat-fieldname   = 'sorgu_tar'.
  wa_fieldcat-scrtext_m   = text-001. " 'Tarih'.
  fieldcatalog-outputlen   = 10.
  wa_fieldcat-col_pos     = 1.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'oem_no'.
  wa_fieldcat-scrtext_m   = text-002. "'Oem No'.
  fieldcatalog-outputlen   = 10.
  wa_fieldcat-col_pos     = 2.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'MIKTAR'.
  wa_fieldcat-scrtext_m   = text-003. "'Miktar'.
  fieldcatalog-outputlen   = 10.
  wa_fieldcat-col_pos     = 3.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'IP_ADR'.
  wa_fieldcat-scrtext_m   = text-004. "'Ip'.
  fieldcatalog-outputlen   = 10.
  wa_fieldcat-col_pos     = 4.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'KUNNR'.
  wa_fieldcat-scrtext_m   = text-005. "'Müsteri Kodu'.
  fieldcatalog-outputlen   = 10.
  wa_fieldcat-col_pos     = 5.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'NAME1'.
  wa_fieldcat-scrtext_m   = text-006. "'Müşteri Adı'.
  fieldcatalog-outputlen   = 10.
  wa_fieldcat-col_pos     = 6.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'UKLE'.
  wa_fieldcat-scrtext_m   = text-007. "'Sorgulanan Ülke'.
  fieldcatalog-outputlen   = 10.
  wa_fieldcat-col_pos     = 7.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'LAND1'.
  wa_fieldcat-scrtext_m   = text-008. "'Müşteri Ülkesi'.
  fieldcatalog-outputlen   = 10.
  wa_fieldcat-col_pos     = 8.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'hrc_drm'.
  wa_fieldcat-scrtext_m   = text-009. "'Harici Durumu'.
  fieldcatalog-outputlen   = 10.
  wa_fieldcat-col_pos     = 9.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'KAYNAK'.
  wa_fieldcat-scrtext_m   = text-010. "'Sorguladığı Kaynak'.
  fieldcatalog-outputlen   = 10.
  wa_fieldcat-col_pos     = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

ENDFORM.                    " BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_layout .

  gd_layout-stylefname = 'FIELD_STYLE'.
  gd_layout-zebra      = 'X'.
  gd_layout-cwidth_opt = 'X'.

ENDFORM.                    " BUILD_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv_report .
  gd_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program      = gd_repid
      i_callback_user_command = 'USER_COMMAND'
      is_layout_lvc           = gd_layout
      it_fieldcat_lvc         = it_fieldcat
      i_save                  = 'X'
    TABLES
      t_outtab                = gt_list
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV_REPORT

DATA: BEGIN OF lt_kaynak OCCURS 0,
        kaynak LIKE zmm_tlp_hvz-kaynak,
        "marka_txt  LIKE zmm_urun_markat-marka_txt,
      END OF lt_kaynak.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR  : sorgu-low.
  PERFORM marka_searchhelp.

INITIALIZATION.
  PERFORM init_selection.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR  : sorgu-high.
  PERFORM marka_searchhelp.

INITIALIZATION.
  PERFORM init_selection.
FORM marka_searchhelp .

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'KAYNAK'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'SORGU'
      value_org       = 'S'
      window_title    = 'Kaynak Arama'
    TABLES
      value_tab       = lt_kaynak[]
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. "   IF sy-subrc <> 0.

*  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
*    EXPORTING
*      functioncode           = 'ENTR'
*    EXCEPTIONS
*      function_not_supported = 0
*      OTHERS                 = 0.


ENDFORM.                    " MARKA_SEARCHHELP
*&---------------------------------------------------------------------*
*&      Form  INIT_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_selection .

  SELECT DISTINCT kaynak FROM zmm_tlp_hvz
  INTO CORRESPONDING FIELDS OF TABLE
  lt_kaynak.
ENDFORM.                    " INIT_SELECTION