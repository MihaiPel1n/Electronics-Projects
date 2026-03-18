clear all; 
close all; 
Fig = figure('Name', 'AMPLIFICATOR CU TB IN CONFIGURATIE EMITOR COMUN', ...    
              'Units', 'normalized', ... 
              'NumberTitle', 'off', ...  
              'Position', [0.1 0.1 0.8 0.8], ... 
              'Color','#fdfdfd'); 

%Valori initiale

Vbe_on=0.6
VBE=0
B=100
A=1     %amplitudinea semnalului sinusoidal 
f=1     %frecventa semnalui sinusoidal
RB1=10
RB2=5
RC=6.8
RE=3
RL=1
VAl=18
N=1
ic=1
VB=NaN
VA=100
RL=1
Si=1
So=1
Sb=1
t=1
Av=1
VRE=0
tipr = 2;
valr = 3;
VCE=0


uicontrol('Style','pushbutton',...                 
    'Units','normalized',...           
    'Position',[0.2 0.55 0.6 .3],...           
    'string','AMPLIFICATOR CU TRANZISTOR BIPOLAR ',... 
    'FontSize',15,... 
    'Callback','schimbare_spre_schema_circuit(Fig)');
  

uicontrol('Style','pushbutton',...                 
    'Units','normalized',...           
    'Position',[0.2 0.15 0.6 .3],...
    'FontSize',15,... 
    'string','CLOSE',...           
    'Callback','close');

meniu=uimenu('Label','Documentatie');
uimenu(meniu,'Label','Documentație','Callback','deschidere_documentatie');
uimenu(meniu,'Label','Descriere proiect','Callback','deschidere_descriere_proiect');
