function [varargout] = latextableassist( m )

%LATEXTABLEASSIST select table format options and write a matrix to a LaTeX
%   table.  Allows column formatting and titles that can span rows and/or
%   columns.  Also allows the insertion of LaTeX labels and captions. It
%   generates the format specifier to be used by writelatextable.m
%
%
%   SYNTAX:
%                        latextableassist( m );
%     [ FileOutput ]   = latextableassist(...);
%
%   INPUT:
%     m          - The 2D array or cell array containing the table contents
%
%   OUTPUT (optional):
%     FileOutput - The text string that is written to the file.
%
%   DESCRIPTION:
%     Writes a LaTeX table made from a MATLAB 2-D array. It uses a 
%     graphical user interface to define the table format. Users can 
%       - enter column headings
%          - column headings can span multiple rows and columns using the
%          LaTeX multirow package
%          - column headings can use LaTeX math package 
%          (ie '$4 \displaystyle\sum_{k=0}^\infty\frac{(-1)^k}{2k+1}$')
%       - specify the table contents number format using printf style
%       format strings (ie '%5.4e')
%       - specify the column dividers
%       - enter a table caption appearing with the table
%       - enter a LaTeX label used in the tex file to refer to the table
%
%   EXAMPLE:
%     % Make the input data
%     m                 = [(10:-1:1)' rand([10,2])];
%     fileoutputcopy    = latextableassist( m );
%     
%   ---
%   MFILE:   latextableassist.m
%   VERSION: 1.0 (2011/09/13) 
%   MATLAB:  7.8.0.347 (R2009a)
%   AUTHOR:  Anthony Bathgate
%   CONTACT: tony.bathgate@usask.ca
%
%   ADDITIONAL NOTES:
%     - For headers that span columns or rows it is likely the result will
%     not work in LaTeX at all if there is overlapping elements. If the 
%     headings span columns and rows making "L" shapes or a sideways "T" 
%     shape the results are undefined.
%     - This function requires the LaTeX package "multirow"
%     
%
%   REVISIONS:
%   1.0      Released. (2011/09/13)
%   
%   DISCLAIMER:
%   latextableassist.m is provided "as is" without warranty of any kind, 
%   under the revised BSD license.
%
%   Copyright (C) 2011 Tony Bathgate, University of Saskatchewan, ISAS.

    global FileOutput_global;
    global gstruc;
    
    % Check the input
    if( nargin>0 )
        if( ~isnumeric(m) )
            error('Argument must be a 2D array')
        end
    else
        error('Argument must be a 2D array')
    end
    
    
    % Initialize the output
    FileOutput_global = '';
    
    % Store the input array and its width
    gstruc.m            = m;
    mdims               = size(gstruc.m);
    gstruc.numc         = mdims(2);
    
    % Initialize the GUI element handles
    gstruc.ccol_h       = cell([1,gstruc.numc+1]);
    gstruc.crow_h       = cell([1,1]);
    gstruc.hcol_h       = cell([1,1]);
    gstruc.hent_h       = cell([1,1]);
    gstruc.crow_h{1} 	= [];
    for colctr = 1:gstruc.numc-1
        gstruc.ccol_h{colctr}   = [];
        gstruc.hcol_h{1,colctr} = [];
    end
    for colctr = 1:gstruc.numc
        gstruc.hent_h{1,colctr} = [];
    end
    gstruc.fig_h    = [];
    gstruc.ab_h     = [];
    gstruc.rb_h     = [];
    gstruc.ph_h     = [];
    gstruc.numcf_h  = [];
    
    % Initialize the dimensions used in the GUI
    gstruc.lengut   = 6;
    gstruc.wcol     = 100;
    gstruc.hcol     = 20;
    gstruc.figw     = max( gstruc.lengut*2+...
        gstruc.wcol*(gstruc.numc*2.5+1),...
        gstruc.lengut*2+gstruc.wcol*7+gstruc.wcol);
    gstruc.t_h      = [];
    
    % Put together the gui
    assemblegui(  )
    
    % Wait for the figure to close before assigning the output
    uiwait(gstruc.fig_h);
    if( nargout>0 )
        varargout{1} = FileOutput_global;
    end
    
end

%**************************************************************************
function assemblegui(  )
% ASSEMBLEGUI - used to initially create the gui

    global gstruc
    
    % Initialize the number of header rows
    gstruc.numhr        = 1;
    
    % Calculate the height of the figure
    figh = gstruc.lengut*2+gstruc.hcol + ...
        6*gstruc.hcol + ...
        gstruc.numhr*gstruc.hcol*3+gstruc.hcol+gstruc.lengut*2;
    % Create the figure
    gstruc.fig_h = figure( 'Visible','off',...
        'Position',[200 200,gstruc.figw,figh],...
        'Resize','Off','ToolBar','none','MenuBar','none');
    
    %************
    % Output Filename and Button
    % Create a label
    l = gstruc.lengut;                  b = gstruc.lengut;
    w = gstruc.wcol;                    h = gstruc.hcol;
    gstruc.oflabl_h = uicontrol( 'Style', 'text',...
        'String', 'Output Filename:',...
        'Units','Pixels', 'Position', [l b w h] );
    % Create the text field for the filename
    l = gstruc.lengut+gstruc.wcol;      b = gstruc.lengut;
    w = gstruc.wcol;                    h = gstruc.hcol;
    gstruc.fn_h = uicontrol( 'Style', 'edit', 'String', '',...
        'Units','Pixels', 'Position', [l b w h] );
    % Create the button that generates the function
    l = gstruc.lengut+gstruc.wcol*2;    b = gstruc.lengut;
    w = gstruc.wcol;                    h = gstruc.hcol;
    uicontrol('Style','pushbutton', 'String','Generate Table', ... 
            'Units','Pixels', 'Position', [ l b w h],...
            'Callback', {@gentables_Callback});

    %************
    % Caption and LaTeX Label
    % Create the label
    l = gstruc.lengut+gstruc.wcol*3;    b = gstruc.lengut;
    w = gstruc.wcol;                    h = gstruc.hcol;
    gstruc.caplabl_h = uicontrol( 'Style', 'text',...
        'String', 'Table Caption:',...
        'Units','Pixels', 'Position', [l b w h] );
    % Create the text field for the caption
    l = gstruc.lengut+gstruc.wcol*4;    b = gstruc.lengut;
    w = gstruc.wcol*2;                  h = gstruc.hcol;
    gstruc.cap_h = uicontrol( 'Style', 'edit', 'String', '',...
        'Units','Pixels', 'Position', [l b w h] );
    % Create the label              
    l = gstruc.lengut+gstruc.wcol*6;    b = gstruc.lengut;
    w = gstruc.wcol;                    h = gstruc.hcol;
    gstruc.latlabllabl_h = uicontrol( 'Style', 'text',...
        'String', 'LaTeX label:',...
        'Units','Pixels', 'Position', [l b w h] );
    % Create the text field for the LaTeX label
    l = gstruc.lengut+gstruc.wcol*7;    b = gstruc.lengut;
    w = gstruc.wcol;                    h = gstruc.hcol;
    gstruc.latlabl_h = uicontrol( 'Style', 'edit', 'String', '',...
        'Units','Pixels', 'Position', [l b w h] );
    
    %************
    % Table Body Content Format
    % body title
    l = gstruc.lengut/2;                b = gstruc.lengut+gstruc.hcol;
    w = gstruc.figw-gstruc.lengut;      h = 6*gstruc.hcol;
    uipanel('Parent',gstruc.fig_h,'Title','Table Body:',...
        'Units','Pixels', 'Position', [l b w h]);
    
    % Column Dividers
    b = 4*gstruc.lengut+gstruc.hcol;    w = 2;
    h = 2*gstruc.lengut+gstruc.hcol*3;  l = gstruc.lengut+gstruc.wcol/4;
    uipanel('Units','Pixels','Position',[l b w h]);
    b2 = 4*gstruc.lengut+3*gstruc.hcol; w2 = gstruc.wcol/2;
    h2 = gstruc.hcol;                   l2 = gstruc.lengut;
    gstruc.ccol_h{1}=insertcoldivpopup( l2, b2, w2, h2, gstruc.ccol_h{1} );
    for colctr = 1:gstruc.numc
        l = gstruc.lengut+gstruc.wcol/4+2.5*colctr*gstruc.wcol;
        uipanel('Units','Pixels','Position',[l b w h]);
        
        l2 = l-gstruc.wcol/4;
        w2 = gstruc.wcol/2;             h2 = gstruc.hcol;
        gstruc.ccol_h{1+colctr} = insertcoldivpopup( l2, b2, w2, h2,...
            gstruc.ccol_h{1+colctr} );
    end
    
    % Number formats for each column
    for colctr = 1:gstruc.numc
        b = 4*gstruc.lengut+gstruc.hcol+2*gstruc.hcol;
        l = gstruc.lengut+gstruc.wcol*(.75+2.5*(colctr-1));

        gstruc.numcf_h(colctr).edt      = [];
        gstruc.numcf_h(colctr).pop      = [];
        gstruc.numcf_h(colctr).label    = [];
        
        gstruc.numcf_h(colctr) = insertnumformatter( l, b, ...
            gstruc.numcf_h(colctr) );
    end
    
    %************
    % Header fields
    % header title
    l = gstruc.lengut/2;            
    b = 6*gstruc.hcol+6*gstruc.lengut;
    w = gstruc.figw-gstruc.lengut;
    h = 3*gstruc.lengut+3*gstruc.numhr*gstruc.hcol;
    gstruc.t_h = uipanel('Parent',gstruc.fig_h,...
        'Title','Table Header:','Units','Pixels',...
        'Position',[l b w h]);
    
    
    b = gstruc.lengut*7+gstruc.hcol*6;
    b2 = b+gstruc.hcol;
    b3 = gstruc.lengut*7+gstruc.hcol*6;
    w3 = 2;
    h3 = 3*gstruc.numhr*gstruc.hcol;
    for colctr = 1:gstruc.numc
        % Insert a heading entry for each column
        l = gstruc.lengut+(colctr-1)*gstruc.wcol*2.5+gstruc.wcol/2;
        w = gstruc.wcol*2;
        h = gstruc.hcol*3;
        gstruc.hent_h{1,colctr} = ...
            insertheadingentry(l,b,w,h, 1,colctr,gstruc.hent_h{1,colctr});

        % Insert the column dividers
        if( colctr~= gstruc.numc)
            l = l+2*gstruc.wcol;
            w = gstruc.wcol/2;
            h = gstruc.hcol;
            gstruc.hcol_h{1,colctr}=...
                insertcoldivpopup(l,b2,w,h, gstruc.hcol_h{1,colctr} );
            
            l = l+.25*gstruc.wcol;
            gstruc.ph_h(colctr) = uipanel('Units','Pixels',...
                'Position',[l b3 w3 h3]);
        end
    end
    
    
    %************
    % The Buttons to add/remove row
    % addrow button
    b = gstruc.lengut*7+gstruc.hcol*6;
    l = gstruc.figw-gstruc.wcol-gstruc.lengut;
    w = gstruc.wcol/2;                  h = gstruc.hcol*2;
    gstruc.ab_h  = uicontrol( 'Style', 'pushbutton',...
        'String', 'Add Row','Units','Pixels',...
        'Position', [l b w h],...
        'Callback', {@addrow_Callback} );
    %removerow button
    b = gstruc.lengut*7+gstruc.hcol*6;
    l = gstruc.figw-gstruc.wcol/2-gstruc.lengut;
    w = gstruc.wcol/2;                  h = gstruc.hcol*2;
    gstruc.rb_h = uicontrol( 'Style', 'pushbutton',...
        'String', 'Remove','Units','Pixels',...
        'Position', [l b w h],...
        'Callback', {@removerow_Callback},'Visible','off' );
    if( gstruc.numhr==1 )
        set( gstruc.rb_h, 'Visible', 'off' );
    else
        set( gstruc.rb_h,'Visible', 'on' );
    end
    
    % Show the figure
    set( gstruc.fig_h, 'Visible','on' );
end

%**************************************************************************
function updategui(  )
%UPDATEGUI - resize and redraw the UI

    global gstruc;

    % resize the figure and make invisible
    figh = gstruc.lengut*2+gstruc.hcol + ...
        6*gstruc.hcol + ...
        gstruc.numhr*gstruc.hcol*3+gstruc.hcol+gstruc.lengut*2;
    pos = get( gstruc.fig_h, 'Position' );
    set( gstruc.fig_h, 'Visible','off',...
        'Position',[pos(1),pos(2),gstruc.figw,figh],...
        'Resize','Off');
    
    %Insert the Header
    %header title
    l = gstruc.lengut/2;
    b = 6*gstruc.hcol+6*gstruc.lengut;
    w = gstruc.figw-gstruc.lengut;
    h = 3*gstruc.lengut+3*gstruc.numhr*gstruc.hcol;
    set( gstruc.t_h, 'Position',[l b w h]);
    
    %Each heading entry includes a text box, and radio buttons that allow
    %users to merge heading entries
    for rowctr = 1:gstruc.numhr
        b = gstruc.lengut*7+gstruc.hcol*6+...
            3*(gstruc.numhr-rowctr)*(gstruc.hcol);
        for colctr = 1:gstruc.numc
            l = gstruc.lengut+(colctr-1)*gstruc.wcol*2.5+gstruc.wcol/2;
            gstruc.hent_h{rowctr,colctr} = ...
                insertheadingentry(l,b,gstruc.wcol*2,gstruc.hcol*3,...
                rowctr,colctr,gstruc.hent_h{rowctr,colctr});
            
            if( colctr~= gstruc.numc)
                l = l+2*gstruc.wcol;
                
                gstruc.hcol_h{rowctr,colctr}=...
                    insertcoldivpopup( l, b+gstruc.hcol, gstruc.wcol/2,...
                    gstruc.hcol, gstruc.hcol_h{rowctr,colctr} );
            end
        end
        
    end
    
    %Resize the column dividers
    b = gstruc.lengut*7+gstruc.hcol*6;
    w = 2;
    h = 3*gstruc.numhr*gstruc.hcol;
    for colctr = 1:gstruc.numc-1
        l = gstruc.lengut+(colctr-1)*gstruc.wcol*2.5+...
            gstruc.wcol/2+2*gstruc.wcol;
        set( gstruc.ph_h(colctr), 'Position',[l b w h]);
    end
    
    %The remove button is hidden when there's only one row
    if( gstruc.numhr==1 )
        set( gstruc.rb_h, 'Visible', 'off' );
    else
        set( gstruc.rb_h,'Visible', 'on' );
    end
    
    %Make the figure visible
    set( gstruc.fig_h, 'Visible','on' );
end

%**************************************************************************
function pu_h = insertcoldivpopup( l, b, w, h, varargin )
%INSERTCOLDIVPOPUP-insert or move a popupmenu to choose the format of the 
% column division
    pu_h = [];
    % move the popupmenu
    if( ~isempty(varargin) )
        if( ~isempty(varargin{1}))
            set( varargin{1}, 'Position', [l b w h] );
            pu_h = varargin{1};
        end
    end
    % create a popupmenu
    if( isempty(pu_h) )
        pu_h = uicontrol( 'Style', 'popupmenu', ...
            'String', {'none','single','double','triple'},...
            'Value',1,'Units','Pixels',...
            'Position',[l b w h]);
    end
end

%**************************************************************************
function numcf_h = insertnumformatter( l, b, numcf_h )
%INSERTNUMFORMATTER - Insert a popupmenu and text field so the user can
%choose either an integer or double value and then specify the double
%format

    global gstruc;

    % Create a text object labelling the number formatter
    w = gstruc.wcol*1.5;                h = gstruc.hcol;
    numcf_h.label = uicontrol( 'Style', 'text',...
        'String', 'Content Format',...
        'Units','Pixels', 'Position', [l b w h] );

    % Insert the popupmenu
    b = b+gstruc.lengut-gstruc.hcol;
    w = gstruc.wcol*.75;                h = gstruc.hcol;
    numcf_h.pop = uicontrol( 'Style', 'popupmenu', ...
        'String', {'double','integer'},...
        'Value',1,'Units','Pixels',...
        'Position',[l b w h ]);
    % Insert the edit field
    l = l+.75*gstruc.wcol;
    numcf_h.edt = uicontrol( 'Style', 'edit', ...
        'String', '%g',...
        'Position',[l b w h]);
    % Connect the popupmenu to a function.  If a decimal number is selected
    % then the text field is hidden.  Vice Versa.
    set(numcf_h.pop,'Callback', {@selcoldataformat_Callback,numcf_h.edt} );
end

%**************************************************************************
function [he_h] = insertheadingentry( x, y, w, h, row, col, varargin )
%INSERTHEADINGENTRY - A headingentry is made up of a text box and 
%radiobuttons for selecting.

    % If a handle was passed in, just change position.
    if( nargin>6 )
        if( ~isempty(varargin{1}) )
            set( varargin{1}, 'Position', [x y w h] );
            he_h = varargin{1};
            return;
        end
    end

    % A gui element to group the radio buttons
    he_h = uibuttongroup('Units','Pixels','Position',[x y w h]);
    % The radio button to merge this element up
    mu_h = uicontrol('Parent',he_h, 'Style', 'radiobutton',...
        'String', 'Merge Up','Value',0,'Units','Pixels', ...
        'Position',[1 2*h/3 w/2-2 h/3-2],'Visible','off');
    if( row~=1)
        set( mu_h, 'Visible', 'on' );
    end
    % The radio button to merge this element left
    ml_h = uicontrol('Parent',he_h, 'Style', 'radiobutton', ...
        'String', 'Merge Left','Value',0,'Units','Pixels',...
        'Position',[1 h/3 w/2-2 h/3-2],'Visible','off');
    if( col~=1 )
        set( ml_h, 'Visible', 'on' );
    end
    % The radio button to not merge it
    n_h = uicontrol('Parent',he_h, 'Style', 'radiobutton',...
        'String', 'neither','Value',1,'Units','Pixels',...
        'Position',[1 1 w/2-2 h/3-2]);
    if( col~=1 || row~=1 )
        set( n_h, 'Visible', 'on' );
    end
    % Make the text box
    th = uicontrol('Parent',he_h,'Style','edit','String','',...
        'Units','Pixels','Position',[w/2-3 1 w/2 h-4]);
    % Any Time the radio button changes execute this function to
    % hide/reveal the text box
    set(he_h,'SelectionChangeFcn',{@selradio_Callback,th});

end

%**************************************************************************
function selcoldataformat_Callback( source, eventdata, sf_h )
%SELCOLDATAFORMAT_CALLBACK - Hide the text box for the format string if the
%user asks for an integer value to be printed to the table
    strings = get( source, 'String' );
    if( ~strcmpi( strings{get( source, 'Value' )}, 'double' ) )
        set( sf_h, 'Visible', 'off' )
    else
        set( sf_h, 'Visible', 'on' );
    end
end

%**************************************************************************
function selradio_Callback( source, eventdata, text_h )
%SELRADIO_CALLBACK - Unless the element is not going to be merged, hide the
%text box.
    if( strcmpi(get(eventdata.NewValue,'String'),'neither'))
        set(text_h,'Visible','on');
    else
        set(text_h,'Visible','off');
    end
end

%**************************************************************************
function gentables_Callback( source, eventdata )
%GENTABLES_CALLBACK - gather the formatting information and call
%writelatextable and display the result
    
    global gstruc FileOutput_global;
    
    % Get the filename
    fn  = get( gstruc.fn_h, 'String' );
    
    % Get the column formats for the table contents
    mf  = makecolformats( gstruc.ccol_h, gstruc.numcf_h );
    % Get the format and content for the table heading
    h   = makeheaders( gstruc.hcol_h, gstruc.hent_h, gstruc.ccol_h );
    
    % Assemble the LaTeX table, write it to file, and store it in the
    % globally declared output variable
    [ FileOutput_global ] = writelatextable( ...
        fn, gstruc.m, mf, h, ...
        get( gstruc.cap_h, 'String'),...
        get(  gstruc.latlabl_h, 'String') );
    
	% Display it. The user can quickly see the output and change the format
	% if so desired.
    disp(FileOutput_global);
end

%**************************************************************************
function [mf] = makecolformats( ccol_h, colnumf_h )
% MAKECOLFORMATS - assemble the format descriptions of column dividers and
% number formats

    % Initialize output
    mf = cell([1,length(ccol_h)-1]);
    
    % Get a list of the options for the popup
    strs = get( colnumf_h(1).pop, 'String' );
    
    % Get the leftmost column divider format
    mf{1} = getcoldivformat( ccol_h{1} );
    % Loop to get the rest
    for ctr = 2:length(ccol_h)
        % If the popupmenu is set to double
        if( strcmpi( strs{get(colnumf_h(ctr-1).pop,'Value')}, 'double' ) )
            % assemble the string defining the number format and the column
            % dividers
            mf{ctr-1} = [ mf{ctr-1} 'c'...
                get( colnumf_h(ctr-1).edt,'String') ...
                getcoldivformat(  ccol_h{ctr} ) ];
        else
            % assemble the string.  The number format is always %d
            mf{ctr-1} = [mf{ctr-1} 'c%d' getcoldivformat(  ccol_h{ctr} ) ];
        end
    end
end

%**************************************************************************
function [h] = makeheaders( hcol_h, hentry_h, ccol_h )
%MAKEHEADERS - generate the struct array that defines the content of each
%column heading, as well as its format and the positions it may span

    % Initialize a temporary struct and the output
    temp = struct('text','','format','','rows',[],'cols',[]);
    h = struct('text','','format','','rows',[],'cols',[]);
    
    % Loop through all heading entries
    hdim = size( hentry_h );
    for rctr = 1:hdim(1)
        for cctr = 1:hdim(2)
            
            % Get handles to the radiobuttons and text box
            chils = get( hentry_h{rctr,cctr}, 'Children' );
            if( get( chils(2), 'Value' ) == 1 )
                % If this value is 1 make a new entry
                
                % Get the heading text
                temp(rctr,cctr).text = get( chils(1), 'String' );
                % Store the position
                temp(rctr,cctr).rows = rctr;
                temp(rctr,cctr).cols = cctr;
                
                % Assemble the format string of column dividers
                temp(rctr,cctr).format = '';
                if( cctr==1 )
                    temp(rctr,cctr).format = getcoldivformat(ccol_h{1});
                end
                if( cctr==hdim(2) )
                    temp(rctr,cctr).format = [temp(rctr,cctr).format 'c'...
                        getcoldivformat(ccol_h{end})];
                else
                    temp(rctr,cctr).format = [temp(rctr,cctr).format 'c'...
                        getcoldivformat(hcol_h{rctr,cctr})];
                end
                
            elseif( get( chils(3), 'Value' ) == 1 )
                % If this value is 1 extend the leftwards heading over to 
                % this column
                if( cctr==hdim(2) )
                    temp = mergeleft( temp, rctr, cctr-1, rctr, cctr,...
                        getcoldivformat(ccol_h{end}) );
                else
                    temp = mergeleft( temp, rctr, cctr-1, rctr, cctr, '' );
                end

            elseif( get( chils(4), 'Value' ) == 1 )
                % If this value is 1 extend the heading above down to this
                % row
                temp = mergeup( temp, rctr-1, cctr, rctr, cctr, '' );
            end
        end
    end
    
    % Take the entries in the temp array and put them in h
    outctr = 0;
    for rctr = 1:hdim(1)
        for cctr = 1:hdim(2)
            if( ~isempty( temp(rctr,cctr).text ) )
                outctr = outctr + 1;
                h(outctr).text      = temp(rctr,cctr).text;
                h(outctr).format    = temp(rctr,cctr).format;
                h(outctr).rows      = temp(rctr,cctr).rows;
                h(outctr).cols      = temp(rctr,cctr).cols;
            end
        end
    end
end

%**************************************************************************
function [tempstruct] = mergeleft( tempstruct, ra, ca, rb, cb, colfstr )
%MERGLEFT - Extend the heading at position that is to the left over to this
%one.  If there isn't a heading there, then look recursively until you find
%one

    if( tempstruct(ra,ca).rows(1)==-1 )
        mergeleft( tempstruct, ra, ca-1, rb, cb, colfstr );
    elseif( tempstruct( ra, ca).cols(1)==-1 ) 
        mergeup( tempstruct, ra-1, ca, rb, cb, colfstr );
    else
        tempstruct(ra,ca).rows      = [tempstruct(ra,ca).rows rb];
        tempstruct(ra,ca).cols      = [tempstruct(ra,ca).cols cb];
        tempstruct(ra,ca).format    = [tempstruct(ra,ca).format colfstr];
        tempstruct(rb,cb).rows      = -1;
        tempstruct(rb,cb).cols      = 0;
    end
end

%**************************************************************************
function [tempstruct] = mergeup( tempstruct, ra, ca, rb, cb, colfstr )
%MERGUP - Extend the heading at position that is above down to this
%one.  If there isn't a heading there, then look recursively until you find
%one

    if( tempstruct(ra,ca).rows(1)==-1 )
        mergeleft( tempstruct, ra, ca-1, rb, cb, colfstr );
    elseif( tempstruct( ra, ca).cols(1)==-1 ) 
        mergeup( tempstruct, ra-1, ca, rb, cb, colfstr );
    else
        tempstruct(ra,ca).rows      = [tempstruct(ra,ca).rows rb];
        tempstruct(ra,ca).cols      = [tempstruct(ra,ca).cols cb];
        tempstruct(ra,ca).format    = [tempstruct(ra,ca).format colfstr];
        tempstruct(rb,cb).rows      = 0;
        tempstruct(rb,cb).cols      = -1;
    end
end

%**************************************************************************
function [str] = getcoldivformat(h)
%GETCOLDIVFORMAT - Interpret the value as either no column divider, single
%line, double line, or triple line
    str = '';
    switch get( h, 'Value' )
        case 1
        case 2
            str =  '|';
        case 3
            str = '||';
        case 4
            str = '|||';
        otherwise
    end
end

%**************************************************************************
function addrow_Callback( source, eventdata )
%ADDROW_CALLBACK - increase the number of rows and update the gui
    global gstruc;
    gstruc.numhr = gstruc.numhr + 1;
    for colctr = 1:gstruc.numc-1
        gstruc.hcol_h{gstruc.numhr,colctr} = [];
    end
    for colctr = 1:gstruc.numc
        gstruc.hent_h{gstruc.numhr,colctr} = [];
    end
    updategui(  )
end

%**************************************************************************
function removerow_Callback( source, eventdata )
%REMOVEROW_CALLBACK - decrease the number of rows and update the gui
    global gstruc;
    for colctr = 1:gstruc.numc-1
        delete(gstruc.hcol_h{gstruc.numhr,colctr});
    end
    for colctr = 1:gstruc.numc
        delete(gstruc.hent_h{gstruc.numhr,colctr});
    end
    gstruc.numhr = gstruc.numhr - 1;
    
    temp1 = cell([gstruc.numhr gstruc.numc]);
    temp2 = cell([gstruc.numhr gstruc.numc]);
    for rowctr = 1:gstruc.numhr
        for colctr = 1:gstruc.numc-1
            temp1{rowctr,colctr}=gstruc.hcol_h{rowctr,colctr};
        end
        for colctr = 1:gstruc.numc
            temp2{rowctr,colctr}=gstruc.hent_h{rowctr,colctr};
        end
    end
    
    gstruc.hcol_h = temp1;
    gstruc.hent_h = temp2;
    
    updategui(  )
end