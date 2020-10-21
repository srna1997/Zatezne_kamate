CREATE PACKAGE pck_kamate AS

    -- procedura za kreiranje racuna
    procedure do_popuni_racun
   (
        p_broj IN racuni.broj%TYPE,
        p_str IN stranke.id%TYPE
   );
   
   --procedura za kreiranje uplata
   PROCEDURE do_popuni_uplate
   (
        p_broj IN uplate.broj%TYPE,
        p_rcn_id IN racuni.id%TYPE
    );
    
   --funkcija za dohvaæanje kamate
   FUNCTION  get_iznos_kamate
   (
        p_1 IN stavke_uplata.iznos_uplate%TYPE,
        p_2 IN racuni.ukupan_iznos%TYPE,
        p_3 IN uplate.datum%TYPE,
        p_4 IN racuni.datum_dospijeca%TYPE
    )
    RETURN NUMBER;
    
   --procedura za raèunanje kolika je kamata 
   PROCEDURE do_izracunaj_zatezne
   (
       p_broj_o IN obracuni_zateznih.broj_obracuna%TYPE,
       p_rcn_id racuni.id%TYPE
   );   
   
END pck_kamate;
/

CREATE OR REPLACE PACKAGE BODY pck_kamate AS  
    v_d DATE;
    
     -- procedura za kreiranje racuna
    PROCEDURE do_popuni_racun
    (
        p_broj IN racuni.broj%TYPE,
        p_str IN stranke.id%TYPE
    )
    
    AS 
   
        v_datum racuni.datum_dospijeca%TYPE:= TO_DATE('01-01-2008','DD-MM-YYYY')+round(dbms_random.value(1,60));
        v_pzd proizvodi.id%TYPE:= round(dbms_random.value(1,5));
        v_kol stavke_racuna.kolicina%TYPE:=round(dbms_random.value(1,9999));
        v_jc  proizvodi.jed_cijena%TYPE;
        v_cijena stavke_racuna.cijena%TYPE;
        v_rcn racuni.id%TYPE;
        v_id stranke.id%TYPE;
        v_ex EXCEPTION;
        
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
                RAISE v_ex;
            ELSE
                EXIT WHEN cur%NOTFOUND;
                INSERT INTO racuni(broj,datum_dospijeca,str_id)
                VALUES(p_broj,v_datum,p_str);
            END IF;
        END LOOP;
        CLOSE cur;
        
        SELECT jed_cijena
        INTO v_jc
        FROM proizvodi
        WHERE id = v_pzd;
        
        v_cijena:= v_kol * v_jc;
    
        SELECT max(id)
        INTO v_rcn
        FROM racuni;
    
        INSERT INTO stavke_racuna(kolicina,cijena,rcn_id,pzd_id)
        VALUES(v_kol,v_cijena,v_rcn,v_pzd);
        
    EXCEPTION 
    WHEN v_ex THEN
        RAISE_APPLICATION_ERROR(-20000,'ERROR, NO ID!');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000,'ERROR, OTHER SOMETING!');
    END do_popuni_racun; 
    
    --procedura za kreiranje uplata
    PROCEDURE do_popuni_uplate
    (
        p_broj IN uplate.broj%TYPE,
        p_rcn_id IN racuni.id%TYPE
    )
    
    AS
        v_iznos racuni.ukupan_iznos%TYPE;
        v_id uplate.id%TYPE;
        
        
        CURSOR cur 
        IS
        SELECT MAX(id) FROM uplate;
       
        BEGIN
        
            SELECT ukupan_iznos
            INTO v_iznos
            FROM racuni rcn
            WHERE rcn.id = p_rcn_id;
      
            INSERT INTO uplate (broj,datum)
            VALUES (p_broj,TO_DATE('01-02-2008', 'dd-mm-yyyy') + round(dbms_random.value(1,365)));
                    
                OPEN cur;
                LOOP
        
                    FETCH cur INTO v_id;
                    EXIT WHEN cur%NOTFOUND;
            
                    INSERT INTO stavke_uplata(upa_id,rcn_id,iznos_uplate) 
                    VALUES(v_id,p_rcn_id,v_iznos*dbms_random.value(0.1,1));
            
                END LOOP;
                CLOSE cur;
                
                INSERT INTO uplate (broj,datum) 
                VALUES (p_broj,TO_DATE('01-02-2008', 'dd-mm-yyyy') + round(dbms_random.value(1,365)));
                
                OPEN cur;
                LOOP
        
                    FETCH cur INTO v_id;
                    EXIT WHEN cur%NOTFOUND;
            
                    INSERT INTO stavke_uplata(upa_id,rcn_id,iznos_uplate) 
                    VALUES(v_id,p_rcn_id,v_iznos*dbms_random.value(0.1,1));
            
                END LOOP;
                CLOSE cur;
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000,'ERROR, NO ID!');
        
    END do_popuni_uplate;
    
    --funkcija za dohvaæanje kamate
    FUNCTION  get_iznos_kamate
    (
        p_1 IN stavke_uplata.iznos_uplate%TYPE,
        p_2 IN racuni.ukupan_iznos%TYPE,
        p_3 IN uplate.datum%TYPE,
        p_4 IN racuni.datum_dospijeca%TYPE
    )
    RETURN NUMBER
    
    AS
    
        v NUMBER(9,2);
        BEGIN

            v:=(p_1 - p_2) * (p_3 - p_4) * 0.18 * (1/365);
    
            RETURN v;
    
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR (-20000, 'Greška, podaci nisu pronaðeni');  
        
        END get_iznos_kamate;
        
    --procedura za raèunanje kolika je zatezna kamata
    PROCEDURE do_izracunaj_zatezne
   (
       p_broj_o IN obracuni_zateznih.broj_obracuna%TYPE,
       p_rcn_id racuni.id%TYPE
   )
   
   AS
        CURSOR cur 
        IS
        (SELECT rcn.ukupan_iznos,sue.iznos_uplate,rcn.datum_dospijeca, upa.datum  
        FROM racuni rcn, stavke_uplata sue,uplate upa 
        WHERE rcn.id = sue.rcn_id 
        AND upa.id = sue.upa_id
        AND rcn.id = p_rcn_id);
    
        CURSOR cur1 
        IS 
        SELECT max(id) FROM obracuni_zateznih;

        v_iznos NUMBER(9,2);
        v_ui racuni.ukupan_iznos%TYPE;
        v_iu stavke_uplata.iznos_uplate%TYPE;
        v_dd racuni.datum_dospijeca%TYPE;
        v_datum uplate.datum%TYPE;
        v_id obracuni_zateznih.id%TYPE;
        
        BEGIN
            INSERT INTO obracuni_zateznih(broj_obracuna,datum_pokretanja)
            VALUES (p_broj_o,sysdate);
    
            OPEN cur1;
                LOOP
                    FETCH cur1 INTO v_id;
                    EXIT WHEN cur1%NOTFOUND;
    
                    OPEN cur;
                        LOOP
                            FETCH cur INTO v_ui,v_iu,v_dd,v_datum;
                            EXIT WHEN cur%NOTFOUND;
        
                            IF(v_datum > v_dd)
                                THEN
                                    v_iznos:= get_iznos_kamate(v_iu,v_ui,v_dd,v_datum);
                
                                    INSERT INTO stavke_obracuna(ozh_id,rcn_id,iznos_kamate)
                                    VALUES(v_id,p_rcn_id,v_iznos);
                            ELSE
                                raise_application_error(-20000, 'Raèun je isplaæen na vrijeme, nema zateznih kamata');
                            END IF;
                        END LOOP;
                    CLOSE cur;
                END LOOP;
          CLOSE cur1;
          
        END do_izracunaj_zatezne;
        
BEGIN   
    --ispis racuna koji ima najveci iznos
    SELECT datum_dospijeca
    INTO v_d
    from racuni 
    WHERE ukupan_iznos = (SELECT max(ukupan_iznos) FROM racuni);
    DBMS_OUTPUT.PUT_LINE('Racun sa najvecim ukupnim iznosom napravljen je datuma: ' || v_d);
    
END pck_kamate;
/

--izvrsavanje procedura 
SET SERVEROUTPUT ON;
exec do_popuni_racun('123465',1);

exec pck_kamate.do_popuni_racun('456789',2);
exec pck_kamate.do_popuni_racun('965487',3);

exec pck_kamate.do_popuni_uplate('123465',1);
exec pck_kamate.do_popuni_uplate('456789',2);
exec pck_kamate.do_popuni_uplate('965487',3);

exec pck_kamate.do_izracunaj_zatezne('123465',1);
exec pck_kamate.do_izracunaj_zatezne('456789',2);
exec pck_kamate.do_izracunaj_zatezne('965487',3);
