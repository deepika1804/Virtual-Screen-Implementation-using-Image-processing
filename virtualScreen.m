function varargout = virtualScreen(varargin)
% VIRTUALSCREEN MATLAB code for virtualScreen.fig
%      VIRTUALSCREEN, by itself, creates a new VIRTUALSCREEN or raises the existing
%      singleton*.
%
%      H = VIRTUALSCREEN returns the handle to a new VIRTUALSCREEN or the handle to
%      the existing singleton*.
%
%      VIRTUALSCREEN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIRTUALSCREEN.M with the given input arguments.
%
%      VIRTUALSCREEN('Property','Value',...) creates a new VIRTUALSCREEN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before virtualScreen_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to virtualScreen_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help virtualScreen

% Last Modified by GUIDE v2.5 15-Dec-2017 22:50:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @virtualScreen_OpeningFcn, ...
                   'gui_OutputFcn',  @virtualScreen_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before virtualScreen is made visible.
function virtualScreen_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no strval args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to virtualScreen (see VARARGIN)

% Choose default command line strval for virtualScreen

handles.strval = hObject;
imaqreset;

handles.vid=videoinput('macvideo',1);
set(handles.vid,'TimerPeriod', 0.05, ...
      'TimerFcn',['if(~isempty(gco)),'...
                      'handles=guidata(gcf);'...                                 % Update handles
                      'image(getsnapshot(handles.vid));'...                    % Get picture using GETSNAPSHOT and put it into axes using IMAGE
                      'set(handles.cameraAxes,''ytick'',[],''xtick'',[]),'...    % Remove tickmarks and labels that are inserted when using IMAGE
                  'end']);
              
set(handles.vid, 'ReturnedColorSpace', 'RGB');
handles.vid.FramesPerTrigger = Inf;

start(handles.vid)
axes(handles.cameraAxes);
hImage = image(zeros(720,1280,3), 'Parent',handles.cameraAxes);
preview(handles.vid,hImage);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes virtualScreen wait for user response (see UIRESUME)
% uiwait(handles.VirtualScreen);


% --- Outputs from this function are returned to the command line.
function varargout = virtualScreen_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning strval args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line strval from handles structure
varargout{1} = handles.strval;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.flag = 1;

pause(0.5);
handles.KeyBoardIm = getsnapshot(handles.vid);
%handles.KeyBoardIm = imread('original.jpg');
pause(0.5);
stop(handles.vid);

figure,imshow(handles.KeyBoardIm);
[handles.C,handles.C2,handles.bbox1,handles.leftx,handles.lefty,handles.lengthDiv,handles.widthDiv] = calibrateKeyBoard(handles.KeyBoardIm);
guidata(hObject, handles);




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

txt = [];
% fileID = fopen('strval.txt','a+');
while handles.flag
    liveImg = getsnapshot(handles.vid);
  
    crop_im=imcrop(liveImg,handles.bbox1);

    figure
    T = cp2tform(handles.C ,handles.C2,'projective');
    IT = imtransform(crop_im,T); 
    
    [x_coord,y_coord]=skinDetect2func(IT);
    
    imshow(IT);hold all;
     plot(x_coord,y_coord,"r+",'LineWidth',3);
 
    target_x = round((x_coord - handles.leftx + 25)/handles.lengthDiv);
    target_y = round((y_coord - handles.lefty)/handles.widthDiv);
    
    
    
    target_x = target_x + 1;
    if (target_y > 0 && target_y < 6) && (target_x > 0 && target_x < 11)
        disp(target_y);
        disp(target_x);
        key_value = keyboard_details();
        val = key_value{target_y,target_x};
        
%         fprintf(fileID,char(sscanf(val,'%2x')));
%         axes(handles.axes2);
%         text(0,0,char(sscanf(val,'%2x')),'FontSize',12);
%         set(handles.axes2,'String',char(sscanf(val,'%2x')));
        str = char(sscanf(val,'%2x'));
        disp(val);
        disp(str);
        string = sprintf('%s\n', str);
        uicontrol(hObject);
        txt=[txt,str];
        set(handles.edit2,'String',txt);
        drawnow();       
    end
    
    pause(3);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.vid);
delete(handles.vid);
handles.flag = 0;
close all;



function keyOut_Callback(hObject, eventdata, handles)
% hObject    handle to strval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strval as text
%        str2double(get(hObject,'String')) returns contents of strval as a double


% --- Executes during object creation, after setting all properties.
function strval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strval_Callback(hObject, eventdata, handles)
% hObject    handle to strval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strval as text
%        str2double(get(hObject,'String')) returns contents of strval as a double



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
