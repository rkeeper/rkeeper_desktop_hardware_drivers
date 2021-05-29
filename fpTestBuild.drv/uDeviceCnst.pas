unit uDeviceCnst;
interface
uses
  uCommon
;

const S_DEFAULT_DESCRIPTION = 'test';

type  //  параметры LowDriverParams
  TeParameter = (
     par_LogLevel      //  0...5 (ErrorOnly...Talkative), def = 0
    ,par_FiscRegTypeID
    ,par_FileNameLogWithUFRInitXMLReturn
    ,par_Options
    ,par_ChangeFromTypeIndexes
  );
const
  S_PARAM_NAME: array[TeParameter] of AnsiString = ( //  названия параметров в XML-файле конфигурации
     'LogLevel'                         // par_LogLevel
    ,'FiscRegTypeID'                           // par_FiscRegTypeID
    ,'FileNameLogWithUFRInitXMLReturn'  // par_FileNameLogWithUFRInitXMLReturn
    ,'Options'                          // par_Options
    ,'ChangeFromTypeIndexes'            // par_ChangeFromTypeIndexes
  );
  IS_PARAM_INT: array[TeParameter] of Boolean = ( // численный (целый) ли параметр
     True  // parLogLevel
    ,True  // par_FiscRegTypeID
    ,False // par_FileNameLogWithUFRInitXMLReturn
    ,False // par_Options
    ,False // par_ChangeFromTypeIndexes
  );
  S_PARAM_DEF_VAL: array[TeParameter] of AnsiString = ( // значения по умолчанию
     '3'            // par_LogLevel
    ,'183'          // par_FiscRegTypeID
    ,''             // par_FileNameLogWithUFRInitXMLReturn
    ,''             // par_Options
    ,''             // par_ChangeFromTypeIndexes
  );

implementation
end.
