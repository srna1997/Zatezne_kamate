-- Trigger for auto insert ukupan iznos in table racuni

create or replace trigger unesi_ukupan_iznos
AFTER INSERT
ON stavke_racuna

DECLARE 
    v_rcn_id stavke_racuna.rcn_id%TYPE;
    v_cijena stavke_racuna.cijena%TYPE;
    
    CURSOR cur
    IS
    SELECT rcn_id FROM stavke_racuna;
    
    CURSOR cur1
    IS
    SELECT SUM(cijena) FROM stavke_racuna WHERE rcn_id = v_rcn_id;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO v_rcn_id;
        EXIT WHEN cur%NOTFOUND;
        
        OPEN cur1;
        LOOP
            FETCH cur1 INTO v_cijena;
            EXIT WHEN cur1%NOTFOUND;
            
            UPDATE racuni SET ukupan_iznos = v_cijena WHERE id = v_rcn_id;
        END LOOP;
        CLOSE cur1;
    END LOOP;
    CLOSE cur;
    
END;
