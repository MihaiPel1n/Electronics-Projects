function update_valori()
    % Obține obiectul curent (popupmenu-ul pentru serie)
    serie_menu = findobj('Style', 'popupmenu', 'Position', [0.5, 0.2, 0.25, 0.18]);
    
    % Obține seria selectată
    tipr = get(serie_menu, 'Value');
    
    % Determină valorile seriei selectate
    switch tipr
        case 1  % E6
            valori = [1, 1.5, 2.2, 3.3, 4.7, 6.8];
        otherwise
            valori = []; % Fallback pentru alte cazuri
    end
    
    % Actualizează meniul de valori
    valoare_menu = findobj('Style', 'popupmenu', 'Position', [0.75, 0.2, 0.25, 0.18]);
    set(valoare_menu, 'String', cellstr(num2str(valori(:))));

    
    % Resetează valoarea selectată la primul element
    set(valoare_menu, 'Value', 1);
end

