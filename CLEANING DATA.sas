/*Importación de base de datos*/
DATA WORK.PORTFOLIO_EXAMPLE;
    LENGTH
        TELEFONO         $ 11
        REGION           $ 16 ;
    FORMAT
        TELEFONO         $CHAR11.
        REGION           $CHAR16. ;
    INFORMAT
        TELEFONO         $CHAR11.
        REGION           $CHAR16. ;
    INFILE 'C:\Users\USUARIO\AppData\Local\Temp\SEG15272\PORTFOLIO_EXAMPLE-335ab37c6c7d4d139dd37c9d24cb2f70.txt'
        LRECL=27
        ENCODING="WLATIN1"
        TERMSTR=CRLF
        DLM='7F'x
        MISSOVER
        DSD ;
    INPUT
        TELEFONO         : $CHAR11.
        REGION           : $CHAR16. ;
RUN;
/* Frecuencia de Region */
/*Eliminación de celdas en blanco y de celdas que no tienen
región asignada (Limpieza)*/
PROC SQL;
   CREATE TABLE CLDATA.PORTFOLIO_EXAMPLE1 AS 
   SELECT t1.TELEFONO, 
          t1.REGION
      FROM CLDATA.PORTFOLIO_EXAMPLE t1
      WHERE t1.REGION NOT IN 
           (
           '',
           'SIN REGION'
           );
QUIT;
/* Frecuencia de Region */
/* Asignación y creación de variable Estado basado en variable
Región (Creación de nueva variable)*/

DATA CLDATA.PORTFOLIO_EXAMPLE1;
SET CLDATA.PORTFOLIO_EXAMPLE1;
LENGTH ESTADO $32.;
IF REGION = "ANDINA" THEN ESTADO = "TACHIRA";
IF REGION = "LOS ANDES" THEN ESTADO = "TACHIRA";
IF REGION = "CAPITAL" THEN ESTADO = "CARACAS";
IF REGION = "GRAN CARACAS" THEN ESTADO = "CARACAS";
IF REGION = "CENTRAL" THEN ESTADO = "CARABOBO";
IF REGION = "CENTRO" THEN ESTADO = "CARABOBO";
IF REGION = "CENTRO-LLANO" THEN ESTADO = "GUÁRICO";
IF REGION = "CENTRO-LLANOS" THEN ESTADO = "GUÁRICO";
IF REGION = "CENTRO-LLANO" THEN ESTADO = "GUÁRICO";
IF REGION = "CENTRO LLANO" THEN ESTADO = "GUÁRICO";
IF REGION = "CENTRO LLANOS" THEN ESTADO = "GUÁRICO";
IF REGION = "LLANERA" THEN ESTADO = "GUÁRICO";
IF REGION = "CENTRO-OCCIDENTE" THEN ESTADO = "LARA";
IF REGION = "CENTRO/OCCIDENTE" THEN ESTADO = "LARA";
IF REGION = "CENTRO OCCIDENTE" THEN ESTADO = "LARA";
IF REGION = "CENTROOCCIDENTAL" THEN ESTADO = "LARA";
IF REGION = "CENTRO-OCCIDENTE" THEN ESTADO = "LARA";
IF REGION = "GUAYANA" THEN ESTADO = "ANZOÁTEGUI";
IF REGION = "OCCIDENTE" THEN ESTADO = "ZULIA";
IF REGION = "OCCIDENTE" THEN ESTADO = "ZULIA";
IF REGION = "ZULIANA" THEN ESTADO = "ZULIA";
IF REGION = "ORIENTAL" THEN ESTADO = "ANZOÁTEGUI";
IF REGION = "ORIENTE" THEN ESTADO = "ANZOÁTEGUI";
IF REGION = "SUR" THEN ESTADO = "ANZOÁTEGUI";
RUN;
/* Frecuencia de Esxtado*/
/* Creación de variable número de telefono para posterior 
cruce de base de datos*/

DATA CLDATA.PORTFOLIO_EXAMPLE1;
SET CLDATA.PORTFOLIO_EXAMPLE1;
Length Num_tlf $ 15;
Num_tlf = COMPRESS(TELEFONO);
RUN;
/* Medición y validación de carcarteres de nueva variable
(12 carcateres)*/
DATA CLDATA.PORTFOLIO_EXAMPLE1;
SET CLDATA.PORTFOLIO_EXAMPLE1;
LARGO = LENGTH(Num_tlf);
RUN;
/* Tomamos aquellos números con longitud 9 o 10 para completar numero
(filtro) */
PROC SQL;
   CREATE TABLE CLDATA.PORTFOLIO_EXAMPLE2 AS 
   SELECT t1.TELEFONO, 
          t1.REGION, 
          t1.ESTADO, 
          t1.Num_tlf, 
          t1.LARGO
      FROM CLDATA.PORTFOLIO_EXAMPLE1 t1
      WHERE t1.LARGO BETWEEN 9 AND 10;
QUIT;
/* Creamos nueva variable y completamos los dígitos faltantes 
del número telefónico (Creación de variable con longitud determinada) */
DATA CLDATA.PORTFOLIO_EXAMPLE2;
SET CLDATA.PORTFOLIO_EXAMPLE2;
Length Num_tlf2 $ 15;
IF LARGO = 9 THEN Num_tlf2 = "04"; ELSE 
Num_tlf2 = "0";
RUN;
/* Concatenamos las dos variables creadas previamente para obtener 
el número telefónico (Concatenar variables)*/
DATA CLDATA.PORTFOLIO_EXAMPLE2;
SET CLDATA.PORTFOLIO_EXAMPLE2;
NUM_TLF_FIN = CATS(Num_tlf2,Num_tlf);
RUN;
/* Para homologar y poder hacer cruce con la ootra base de datos le vamos a agregar un
guion despues de los primeros 4 dígitos, para lo cual descomponemos la variable creada 
y para saber a que operadora pertenece (Extracción de caracteres) */
DATA CLDATA.PORTFOLIO_EXAMPLE2;
SET CLDATA.PORTFOLIO_EXAMPLE2;
OPERADORA = SUBSTR(NUM_TLF_FIN,1,4);
NUMERO = SUBSTR(NUM_TLF_FIN,5,7);
RUN;
/* Determinamos la operadora (Condicionales y creación de variable)*/
DATA CLDATA.PORTFOLIO_EXAMPLE2;
SET CLDATA.PORTFOLIO_EXAMPLE2;
LENGTH OPERADORA2 $ 15;
IF OPERADORA = "0414" THEN OPERADORA2 = "MOVISTAR";
ELSE IF OPERADORA = "0424" THEN OPERADORA2 = "MOVISTAR";
ELSE IF OPERADORA = "0416" THEN OPERADORA2 = "MOVILNET";
ELSE IF OPERADORA = "0426" THEN OPERADORA2 = "MOVILNET";
ELSE IF OPERADORA = "0412" THEN OPERADORA2 = "DIGITEL"; 
ELSE OPERADORA2 = "CANTV";
RUN;
/* Eliminamos los números de teléfonos duplicados (de haber) */
PROC SORT DATA=CLDATA.PORTFOLIO_EXAMPLE2 NODUPKEY;
BY TELEFONO;
RUN;
/* Adecuamos variable para cruce con base de tos con correos
(Concatenar variables)*/
DATA CLDATA.PORTFOLIO_EXAMPLE2;
SET CLDATA.PORTFOLIO_EXAMPLE2;
TELEFONO_FINAL = CATS (OPERADORA,"-",NUMERO);
RUN;
/* Creación de muestra*/

/* -------------------------------------------------------------------
	Código generado por una Tarea SAS

	Generado el: viernes, 7 de julio de 2023 a las 4:37:15 p. m.
	Por la tarea: Muestra aleatoria

	Datos de entrada: Local:CLDATA.PORTFOLIO_EXAMPLE2
	Servidor: Local
	------------------------------------------------------------------- */
TITLE; FOOTNOTE;

%LET _CLIENTTASKFILTER = OPERADORA2 = 'MOVISTAR';

PROC SURVEYSELECT DATA=CLDATA.PORTFOLIO_EXAMPLE2( WHERE=(OPERADORA2 = 'MOVISTAR'))
	OUT=WORK.MUESTRA_MOVISTAR2
	METHOD=SRS
	N=28000;
RUN;

QUIT;

%SYMDEL _CLIENTTASKFILTER;

/* Creación de BD sin movistar (filtro) */

PROC SQL;
   CREATE TABLE WORK.MUESTRA_SIN_MOVISTAR AS 
   SELECT t1.TELEFONO, 
          t1.REGION, 
          t1.ESTADO, 
          t1.Num_tlf, 
          t1.LARGO, 
          t1.Num_tlf2, 
          t1.NUM_TLF_FIN, 
          t1.OPERADORA, 
          t1.NUMERO, 
          t1.OPERADORA2, 
          t1.TELEFONO_FINAL
      FROM CLDATA.PORTFOLIO_EXAMPLE2 t1
      WHERE t1.OPERADORA2 NOT = 'MOVISTAR';
QUIT;
/* Concatenado de bases de datos*/
PROC SQL;
CREATE TABLE CLDATA.TABLA_FINAL_CD AS 
SELECT * FROM WORK.MUESTRA_SIN_MOVISTAR
 OUTER UNION CORR 
SELECT * FROM CLDATA.MUESTRA_MOVISTAR2
;
Quit;
/* Creación de tabla para cruce (Limpieza de BD)*/

PROC SQL;
   CREATE TABLE CLDATA.PORTFOLIO_EXAMPLE3 AS 
   SELECT t1.TELEFONO_FINAL AS TELEFONO, 
          t1.OPERADORA2 AS OPERADORA, 
          t1.ESTADO
      FROM CLDATA.APPEND_TABLE t1;
QUIT;
/* Cruce con BD de correos*/

PROC SQL;
   CREATE TABLE CLDATA.PORTFOLIO_EXAMPLE4 AS 
   SELECT t1.TELEFONO, 
          t1.OPERADORA, 
          t1.ESTADO, 
          t2.Cedula, 
          t2.Nombre_Cliente, 
          t2.Genero, 
          t2.Estado_Civil, 
          t2.Fecha_Nacimiento, 
          t2.correo_cliente
      FROM CLDATA.PORTFOLIO_EXAMPLE3 t1
           LEFT JOIN CLDATA.BD_CORREOS t2 ON (t1.TELEFONO = t2.Telf_Cel);
QUIT;
/* Verificación de cuantos Teléfonos cruzaron con BD correos*/
PROC SQL;
   CREATE TABLE CLDATA.PORTFOLIO_EXAMPLE_F AS 
   SELECT t1.TELEFONO, 
          t1.OPERADORA, 
          t1.ESTADO, 
          t1.Cedula, 
          t1.Nombre_Cliente, 
          t1.Genero, 
          t1.Estado_Civil, 
          t1.Fecha_Nacimiento, 
          t1.correo_cliente
      FROM CLDATA.PORTFOLIO_EXAMPLE4 t1
      WHERE t1.Cedula NOT = '';
QUIT;