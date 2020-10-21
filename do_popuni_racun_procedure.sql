create or replace procedure do_popuni_racun
(
    p_broj IN racuni.broj%TYPE,
    p_str IN stranke.id%TYPE
)
    AS
    
        v_datum racuni.datum_dospijeca%TYPE:=TO_DATE('01-01-2008','DD-MM-YYYY')+round(dbms_random.value(1,60));
        v_pzd proizvodi.id%TYPE:= round(dbms_random.value(1,5));
        v_kol stavke_racuna.kolicina%TYPE:=round(dbms_random.value(1,9999));
        v_jc  proizvodi.jed_cijena%TYPE;
        v_cijena stavke_racuna.cijena%TYPE;
        v_rcn racuni.id%TYPE;
        v_id stranke.id%TYPE;
        ex EXCEPTION;
        CURSOR cur 
        IS
        SELECT id 
        FROM stranke 
        WHERE id = p_str;
        
    BEGIN
        OPEN cur;
        LOOP    
            FETCH cur INTO v_id;
            IF v_id IS NULL
            THEN
                RAISE ex;
            ELSE
                EXIT WHEN cur%NOTFOUND;
                INSERT INTO racuni(broj,datum_dospijeca,str_id)
                VALUES(p_broj,v_datum,p_str);
                
            END IF;
       END LOOP;
       CLOSE cur;
   
    SELECT jed_cijena INTO v_jc FROM proizvodi WHERE id = v_pzd;
    
    v_cijena:= v_kol * v_jc;
    
    SELECT MAX(id) INTO v_rcn FROM racuni;
    
    INSERT INTO stavke_racuna(kolicina,cijena,rcn_id,pzd_id)
    VALUES(v_kol,v_cijena,v_rcn,v_pzd);
  
EXCEPTION 
    WHEN ex THEN
        RAISE_APPLICATION_ERROR(-20000,'ERROR, NO ID!');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000,'ERROR, OTHER SOMETING!');
END;
/