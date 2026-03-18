function schimbare_spre_cronograme(Fig, N,f, Si,So,Sb, t, Av, A, VB)

% Șterge toate controalele din fereastra curentă
% Șterge toate controalele UI din fereastră (imaginea și butoanele)
delete(findobj(Fig, 'Type', 'UIControl'));  % Șterge butoanele și alte controale UI

% Șterge imaginea (dacă există)
delete(findobj(Fig, 'Type', 'Image'));

% Șterge grupul de radio butoane (dacă există)
delete(findobj(Fig, 'Type', 'uibuttongroup'));



%...................................................%
%VERIFICARI 
if N<0.0001
    N=1
end
if f<0.0001
    f=1
end

%...................................................%

text1=['vi= ', num2str(A), 'sin(', num2str(2*f), 'πt)']
text2=['vo= ',num2str(A*Av), 'sin(', num2str(2*f), 'πt)']
text3= ['vB= ' , num2str(VB), '+', num2str(A), 'sin(', num2str(2*f), 'πt)']

%...................................................%
%ECUATII

T=1./f;
t=0:T/100:N*T;


Si=A*sin(2*pi*f*t); %expresia semnalului de intrare


So=Av.*Si  %expresia semnalului de iesire


Sb=VB+Si

%...................................................%

%BUTOANE DE TIP EDIT

bg=uibuttongroup('Visible','on',... 
'BackgroundColor','#fdfdfd',... 
'ForegroundColor','black',... 
'Title','Parametri:',...d9eafd 
'FontSize',20,... 
'TitlePosition','centertop',... 
'Tag','radiobutton',... 
'Position',[0, 0.8, 0.4, 0.2]); 

uicontrol('Style','text',...             
    'Units','normalized',...            %Text pt f                                                        
    'Position',[0 0.5 0.5 .48],...           
    'BackgroundColor','#f0f0f0',...           
    'string','f [KHz]',... 
    'FontSize', 15,...
    'Callback','',... 
    'Parent',bg);
uicontrol('Style','edit',...            %Edit pt f            
    'Units','normalized',...           
    'Position',[0.5 0.5 0.5 .48],...           
    'String',f,...   
    'FontSize', 15,...
    'Callback','f=str2num(get(gco,''String''))',...
    'Parent',bg);


uicontrol('Style','text',...            %Text pt N           
    'Units','normalized',...           
    'Position',[0 0 0.5 .48],...           
    'BackgroundColor','#f0f0f0',...  
    'string','N',... 
    'FontSize', 15,...
    'Callback','',... 
    'Parent',bg);        
uicontrol('Style','edit',...            %Edit pt N          
     'Units','normalized',...           
    'Position',[0.5 0 0.5 .48],...           
    'String',N,...    
    'FontSize', 15,...
    'Callback','N=str2num(get(gco,''String''))',...
    'Parent',bg);
%...................................................%
% Creează un axes în colțul din stânga sus
ax1 = axes('Position', [0.45, 0.77, 0.5, 0.2]); 
ax2 = axes('Position', [0.45, 0.45, 0.5, 0.2]);  
ax3 = axes('Position', [0.45, 0.14, 0.5, 0.2]);  

% Afișează imaginea pe axes
% imshow(img, 'Parent', ax);  % Afișează imaginea pe axes
% axis off;  % Ascunde axele pentru o prezentare mai curată


plot(ax1, t, Si); % Plot on the specific axes
xlabel(ax1, 'timp [s]');
ylabel(ax1, 'Amplitudine [V]');
title(ax1, text1);
grid(ax1, 'on'); % Add grid lines

plot(ax2, t, So); % Plot on the specific axes
xlabel(ax2, 'timp [s]');
ylabel(ax2, 'Amplitudine [V]');
title(ax2, text2);
grid(ax2, 'on'); % Add grid lines

plot(ax3, t, Sb); % Plot on the specific axes
xlabel(ax3, 'timp [s]');
ylabel(ax3, 'Amplitudine [V]');
title(ax3, text3);
grid(ax3, 'on'); % Add grid lines



%...................................................%

%BUTOANE PENTRU RECALCULARE SI INTORCERE 

uicontrol('Style','pushbutton',...              
    'Units','normalized',...           
    'Position',[0.8 0 0.2 .1],...           
    'string','INAPOI LA SCHEMA DE SEMNAL MIC',...   
    'FontWeight','bold',...
    'Callback','schimbare_spre_ca(Fig, A,f,B, N, VA, RL, ic, RC, VB, Av, VRE, Vbe_on, VCE)');

uicontrol('Style','pushbutton',...              
    'Units','normalized',...           
    'Position',[0.4 0 0.2 .1],...           
    'string','CLOSE',...   
    'FontWeight','bold',...
    'Callback','close'); 

uicontrol('Style','pushbutton',...              
    'Units','normalized',...           
    'Position',[0 0 0.2 .1],...           
    'string','RECALCULARE',...   
    'FontWeight','bold',...
    'Callback','schimbare_spre_cronograme(Fig, N,f, Si,So,Sb, t, Av, A, VB)');
%...................................................%
assignin('base', 't', t); % Actualizează în Workspace
assignin('base', 'N', N); % Actualizează în Workspace
assignin('base', 'f', f); % Actualizează în Workspace
assignin('base', 'Si', Si); % Actualizează în Workspace
assignin('base', 'So', So); % Actualizează în Workspace
assignin('base', 'Sb', Sb); % Actualizează în Workspace

end

