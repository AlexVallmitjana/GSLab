function html2docx(filename_in,filename_out, visible)
% Convert HTML file to DOC, DOCX, TXT, PDF or RTF, file.
% It starts Microsft Word (through ActiveX), then opens the HTML file as new document,
% then saves it to disk, and closes the document, and quits Word
% 
%   html2docx(filename_in,filename_out)
%
% or
%
%   html2docx(filename_in,filename_out, visible)
%
%   filename_in : a file with extension supported by your Microsoft Word version
%   filename_out : output filename with type supported by your Microsoft Word version
%   visible : Microsoft Word application visibible during conversion false (default) or true
% 
% % Example
%
% filename_in  = 'index.html';
% filename_out = 'index.docx';
%
% html2docx(filename_in,filename_out)
%
% Written by D.Kroon 05-04-2024 at Demcon
% Adapted by AlexVL

if(nargin<3)
    visible = false;
end

% Make filename paths absolute
[folder_in, name_in,ext_in]=fileparts(filename_in);
[folder_out, name_out,ext_out]=fileparts(filename_out);
if(isempty(folder_in))
    folder_in = cd;
end
if(isempty(folder_out))
    folder_out = cd;
end
filename_in = fullfile(folder_in, [name_in,ext_in]);
filename_out = fullfile(folder_out, [name_out,ext_out]);

% Get output type as integer
switch lower(ext_out)
    case '.docx'
        doc_type_index = 16;
    case '.doc'
        doc_type_index = 0;
    case '.txt'
        doc_type_index = 2;
    case '.pdf'
        doc_type_index = 17;
    case '.html'
        doc_type_index = 8;
    case '.rtf'
        doc_type_index = 6;
    otherwise
        doc_type_index = 1;
        % Handle any other cases here (if needed)
        warning('Unknown file extension.');
end

% Perform the conversion
word_already_open = false;
try
    wordApp  = actxserver('Word.Application');
    wordApp .Visible = visible;
catch
    word_already_open = true;
    wordApp = actxGetRunningServer('Word.Application');
end
doc = wordApp.Documents.Open(filename_in);
doc.PageSetup.Orientation = 0; % 0 = Portrait, 1 = Landscape
mg=18;
doc.PageSetup.TopMargin = mg; % Set top margin (in points, 36 pts = 0.5 inch)
doc.PageSetup.BottomMargin = mg; % Set bottom margin
doc.PageSetup.LeftMargin = mg; % Set left margin
doc.PageSetup.RightMargin = mg; % Set right margin
doc.PageSetup.PaperSize = 2; %  2 = Letter, etc.

doc.SaveAs2(filename_out, 17);
doc.Close(false);          
if(word_already_open == false)
    wordApp.Quit;           
    delete(wordApp);           
end
