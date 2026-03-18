function actualizeaza_RC()
    % Obține obiectul curent (popupmenu-ul pentru valori)
    valoare_menu = findobj('Style', 'popupmenu', 'Position', [0.75, 0.2, 0.25, 0.18]);
    
    % Obține valoarea selectată din popupmenu
    index = get(valoare_menu, 'Value');
    
    % Valorile corespunzătoare din serii (exemplu pentru E6)
    valori = [1.0, 1.5, 2.2, 3.3, 4.7, 6.8];  % Poți adăuga mai multe serii dacă este necesar
    
    % Alege valorile corespunzătoare seriei selectate
    RC = valori(index);
    

    assignin('base', 'RC', RC); % Actualizează în Workspace
end