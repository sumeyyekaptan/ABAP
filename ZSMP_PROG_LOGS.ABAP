*&---------------------------------------------------------------------*
*& Report  ZSMP_PROG_LOGS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZSMP_PROG_LOGS.


DATA : BEGIN OF GT_TIME_OUT OCCURS 0 ,
         ID       LIKE ZTEST_TABLE_5-ID,
         TIME     LIKE ZTEST_TABLE_5-TIME,
         E_DATUM  LIKE ZTEST_TABLE_5-E_DATUM,
         S_DATUM  LIKE ZTEST_TABLE_5-S_DATUM,
         TO_DATUM LIKE ZTEST_TABLE_5-TO_DATUM,
         S_UZEIT  LIKE ZTEST_TABLE_5-S_UZEIT,
         DATUM    LIKE ZTEST_TABLE_5-DATUM,
       END OF GT_TIME_OUT.
DATA : TO_UZEIT TYPE UZEIT.

SELECT Z~ID
       Z~TIME
       Z~E_DATUM
       Z~S_DATUM
       Z~DATUM
       Z~TO_DATUM
  FROM ZTEST_TABLE_5       AS Z
  INTO CORRESPONDING FIELDS OF TABLE GT_TIME_OUT
 WHERE Z~STATU <> '9'
   AND  ( Z~E_DATUM = '00000000'
    OR Z~TIME > '010000' ).

LOOP AT GT_TIME_OUT.

  GET TIME FIELD TO_UZEIT.

  GT_TIME_OUT-TO_DATUM = SY-DATUM.

  GT_TIME_OUT-DATUM = GT_TIME_OUT-TO_DATUM - GT_TIME_OUT-S_DATUM.

  IF TO_UZEIT - GT_TIME_OUT-S_UZEIT > 010000 OR GT_TIME_OUT-DATUM > '00000000'
      OR GT_TIME_OUT-TIME > '010000'.

      UPDATE ZTEST_TABLE_5 SET STATU    = '9'
                               TO_UZEIT = TO_UZEIT
                               TO_DATUM = SY-DATUM
                               DATUM    = GT_TIME_OUT-DATUM
       WHERE ID = GT_TIME_OUT-ID.

  ENDIF.

   IF  GT_TIME_OUT-TIME = '000000'.

    GT_TIME_OUT-TIME  = TO_UZEIT - GT_TIME_OUT-S_UZEIT.

      UPDATE ZTEST_TABLE_5 SET STATU    = '9'
                               TO_UZEIT = TO_UZEIT
                               TO_DATUM = SY-DATUM
                               DATUM    = GT_TIME_OUT-DATUM
                               TIME     = GT_TIME_OUT-TIME
       WHERE ID = GT_TIME_OUT-ID.

  ENDIF.

ENDLOOP.
