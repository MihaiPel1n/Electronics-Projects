function schimbare_spre_schema_circuit(Fig)
% Șterge toate controalele din fereastra curentă
% Șterge toate controalele UI din fereastră (imaginea și butoanele)
delete(findobj(Fig, 'Type', 'UIControl'));  % Șterge butoanele și alte controale UI

% Șterge imaginea (dacă există)
delete(findobj(Fig, 'Type', 'Image'));

% Șterge grupul de radio butoane (dacă există)
delete(findobj(Fig, 'Type', 'uibuttongroup'));

clf;


%...................................................%
% Citește imaginea
img = imread('Amplificator cu TB.jpeg');

% Creează un axes în colțul din stânga sus
ax = axes('Position', [0, 0, 1, 1]);  % Poziționează axes în colțul stânga sus al ferestrei

% Afișează imaginea pe axes
imshow(img, 'Parent', ax);  % Afișează imaginea pe axes
axis off;  % Ascunde axele pentru o prezentare mai curată


%...................................................%
%BUTOANE PENTRU RECALCULARE, SCHEMA DE SEMNAL MIC SI INTORCERE LA MENIU

uicontrol('Style','pushbutton',...              
    'Units','normalized',...           
    'Position',[0.8 0 0.2 .1],...           
    'string','INAPOI LA MENIU',...   
    'FontWeight','bold',...
    'Callback','schimbare_initiala(Fig)'); 
 

uicontrol('Style','pushbutton',...              
    'Units','normalized',...           
    'Position',[0 0 0.2 .1],...           
    'string','SPRE SCHEMA DE CURENT CONTINUU',...   
    'FontWeight','bold',...
    'Callback','schimbare_spre_cc(Fig, VAl,Vbe_on, B, RB1, RB2, RC, RE, ic, VB, VBE, VRE,tipr,valr, VCE )'); 

meniu=uimenu('Label','Documentatie');
uimenu(meniu,'Label','Documentație','Callback','deschidere_documentatie');
uimenu(meniu,'Label','Descriere proiect','Callback','deschidere_descriere_proiect');
end

