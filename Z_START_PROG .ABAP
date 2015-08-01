FUNCTION Z_TEST4_START_PROG .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(TCODE) TYPE  TCODE
*"     REFERENCE(UNAME) TYPE  UNAME
*"     REFERENCE(REPID) TYPE  REPID
*"     REFERENCE(ID)
*"     REFERENCE(STATU)
*"  EXPORTING
*"     REFERENCE(S_UZEIT) TYPE  UZEIT
*"     REFERENCE(S_DATUM) TYPE  DATUM
*"----------------------------------------------------------------------
  "WRITE:/ 'HARUN'.

  " s_uzeit = sy-uzeit.

  GET TIME FIELD S_UZEIT.
  S_DATUM = SY-DATUM.

  DATA G_KAYIT TYPE ZTEST_TABLE_5.

  G_KAYIT-ID = ID.

  G_KAYIT-UNAME = UNAME.

  G_KAYIT-REPID = REPID.

  G_KAYIT-TCODE = TCODE.

  G_KAYIT-S_DATUM = S_DATUM.

  G_KAYIT-S_UZEIT = S_UZEIT.

  G_KAYIT-STATU = STATU.

  INSERT ZTEST_TABLE_5 FROM G_KAYIT.

ENDFUNCTION.
