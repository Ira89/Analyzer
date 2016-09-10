unit ExcelAnalyzer;

interface

uses ComObj, LogError, SysUtils, DateUtils,
Dialogs;

const ID_FIRST_ROW_WITH_DATA = 2;

type
  file_structure = (id_date = 1, id_koeff, id_parameter_1, id_parameter_2
                    );

type
  Analyzer_for_TS_files = class

    private
      filename : String;
      excel : Variant;
      last_row, last_column : Integer;
      log_error : Logger;

      procedure initialization_file(filename : String);
      procedure analyze_date();
      procedure analyze_koeff();
      procedure analyze_parameter_1();
      procedure analyze_parameter_2();

    public
      constructor Create();
      procedure analyze_file(filename : String);
      function get_error_text() : String;
      destructor Destroy(); override;

  end;

implementation

// ***************************** public ************************************* //

constructor Analyzer_for_TS_files.Create();
begin
  excel := CreateOleObject('Excel.Application');
  log_error := Logger.Create();
end;

// facade
procedure Analyzer_for_TS_files.analyze_file(filename : String);
begin
  initialization_file(filename);
  analyze_date();
  analyze_koeff();
  analyze_parameter_1();
  analyze_parameter_2();
  // TODO
end;

function Analyzer_for_TS_files.get_error_text() : String;
begin
  Result := log_error.get_error_text();
end;

destructor Analyzer_for_TS_files.Destroy();
begin
  excel.Application.Quit;
  log_error.Free;
end;

// ***************************** private ************************************ //

procedure Analyzer_for_TS_files.initialization_file(filename : String);
begin
  excel.Workbooks.Open(filename, 0, True);
  Self.filename := ExtractFileName(filename);
  last_row := excel.ActiveSheet.UsedRange.Rows.Count;
  //last_column := excel.ActivateSheet.UsedRange.Columns.Count;
end;

procedure Analyzer_for_TS_files.analyze_date();
const
  MAX_DAY_IN_MONTH = 31;
var
  index_row : Integer;
  user_input : String;
  user_date, today : TDateTime;
begin
  today := Now;
  for index_row := ID_FIRST_ROW_WITH_DATA to last_row do begin
    user_input := excel.Cells[index_row, ord(id_date)];
    if not (TryStrToDate(user_input, user_date)) or
           (Abs(DayOfTheYear(today) - DayOfTheYear(StrToDateTime(user_input))) > MAX_DAY_IN_MONTH) then begin
      log_error.record_error(filename, ord(id_date));
      Break;
    end;
  end;
end;

procedure Analyzer_for_TS_files.analyze_koeff();
var
  index_row : Integer;
begin
  if (last_row - 1 > ID_FIRST_ROW_WITH_DATA) then begin
    for index_row := ID_FIRST_ROW_WITH_DATA + 1 to last_row do begin
      if (String(excel.Cells[index_row, ord(id_koeff)]) <> String(excel.Cells[index_row - 1, ord(id_koeff)])) then begin
        log_error.record_error(filename, ord(id_koeff));
        Break;
      end;
    end
  end;
end;

procedure Analyzer_for_TS_files.analyze_parameter_1();
var
  index_row, user_parameter : Integer;
begin
  for index_row := ID_FIRST_ROW_WITH_DATA to last_row do begin
    if (String(excel.Cells[index_row, ord(id_parameter_1)]) = '') then Continue;
    if not (TryStrToInt(excel.Cells[index_row, ord(id_parameter_1)], user_parameter)) then begin
      log_error.record_error(filename, ord(id_parameter_1));
      Break;
    end;
  end;
end;

procedure Analyzer_for_TS_files.analyze_parameter_2();
var
  index_row, user_parameter : Integer;
begin
  for index_row := ID_FIRST_ROW_WITH_DATA to last_row do begin
    if (String(excel.Cells[index_row, ord(id_parameter_2)]) = '') then Continue;
    if not (TryStrToInt(excel.Cells[index_row, ord(id_parameter_2)], user_parameter)) or
           (Length(String(excel.Cells[index_row, ord(id_parameter_2)])) <> 8) then begin
      log_error.record_error(filename, ord(id_parameter_2));
      Break;
    end;
  end;
end;

end.
