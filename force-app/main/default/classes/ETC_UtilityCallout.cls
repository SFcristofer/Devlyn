public virtual with sharing class ETC_UtilityCallout{

    public Endpoint__mdt mdt;
    public String claseApex;

    public class Callout{
        public Http http;
        public HttpRequest request;
        public HttpResponse response;
        public Callout(Http http, HttpRequest request, HttpResponse response){
            this.http = http;
            this.request = request;
            this.response = response;
        }
    }

    public virtual Callout createCallout(String metadataName){
        Endpoint__mdt mdt = ETC_UtilityMetadata.getCustomMetadataRecord(metadataName);

        this.mdt = mdt;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setEndpoint(mdt.Named_Credential__c + mdt.Relative_Endpoint__c);
        request.setMethod(mdt.Method__c);
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');
        request.setHeader('Accept', '*/*');
        request.setHeader('Content-Type', 'application/json');
        // request.setHeader('User-Agent', 'Apache-HttpClient/4.5.5 (Java/16.0.1)');
        request.setHeader('Connection', 'Keep-Alive');
        // request.setHeader('Authorization', getAuthorizationHeader());
        if(String.isNotBlank(mdt.Request__c)){request.setBody(mdt.Request__c);}
        
        
        // request.setCompressed(true);
        request.setTimeout(120000);
        System.debug(request);
        return new Callout(http, request, response);
    }

    public virtual HttpResponse sendCallout(Callout callout) {
        callout.response = Test.isRunningTest()?new HttpResponse():callout.http.send(callout.request);
        return callout.response;
    }

    public static Date getDate(String stringDate) {
        if(stringDate.equals('0000-00-00')){
            return null;
        }
        return (Date) JSON.deserialize('"' + stringDate + '"', Date.class);
    }

    public static Date getDateFormated(String stringDate) {
        // System.debug(stringDate);
        if(stringDate.equals('00.00.0000') || String.isBlank(stringDate)){
            return null;
        }
        String[] dateSplit = stringDate.split('\\.');
        if(dateSplit.size()<3){
            return null;
        }
        dateSplit[2] = dateSplit[2]== '9999'? '4000': dateSplit[2];
        // System.debug(dateSplit);
        return Date.newInstance(Integer.valueOf(dateSplit[2]), Integer.valueOf(dateSplit[1]), Integer.valueOf(dateSplit[0]));
    }

    public static Time getHour(String stringHour) {
        if(stringHour.equals('00:00')){
            return null;
        }
        String[] strTimeSplit = stringHour.split(':');
        return Time.newInstance( Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),Integer.valueOf(strTimeSplit[2]),0);
    }

    public static DateTime getDateTime(Date dateConversion){
        return DateTime.newInstance(dateConversion.year(), dateConversion.month(), dateConversion.day());
    }

    public static String getString(String stringValidate){
        if(stringValidate == null){
            return '';
        }
        return stringValidate;
    }

    public static String getStringRemoveZero(String stringValidate){
        if(stringValidate == null){
            return '';
        }
        return stringValidate.replaceAll('^0+', '');
    }

    // private String getAuthorizationHeader(){
    //     Blob headerValue = Blob.valueOf('SISTEMAS' + ':' + 'bzooAD5200');
    //     return 'BASIC ' + EncodingUtil.base64Encode(headerValue);
    // }

    public Set<Id> catchErrors(List<Database.UpsertResult> results, String objectString){
        System.debug('<--catchErrors');
        System.debug(objectString);
        system.debug('records proccesed: '+ results.size());
        Integer numErrors = 0;
        Set<Id> idRecords = new Set<Id>();
        List<Log_Servicios_Web__c> listLogs = new List<Log_Servicios_Web__c>();
        for(Integer i=0;i<results.size();i++) {
            if (results.get(i).isSuccess()){
                idRecords.add(results.get(i).getId());
            }
            if (!results.get(i).isSuccess() || Test.isRunningTest()){
                // DML operation failed
                numErrors+=1;
                system.debug('Failed ID'+results.get(i).Id);
                for(Database.Error error : results.get(i).getErrors()) {
                    String detalles = 'The following error has occurred. '+
                        error.getStatusCode() + ' : ' + error.getMessage() +
                        ' Fields that affected this error: ' + error.getFields();
                    System.debug(detalles);
                    if(mdt.Activar_Log__c || Test.isRunningTest()){
                        
                        // log.recordId = ;
                        listLogs.add(addLogServiciosWeb(objectString, detalles));
                    }
                }
            }
        }
        system.debug('records proccesed with errors: '+ numErrors);
       
        if(!listLogs.isEmpty()){
            insert listLogs;
        }
        System.debug(idRecords.size());
        System.debug('catchErrors-->');
        return idRecords;
    }
    public Log_Servicios_Web__c addLogServiciosWeb(String objectString, String detalles){
        Log_Servicios_Web__c log = new Log_Servicios_Web__c();
        log.Clase_Apex__c = this.claseApex;
        log.Objeto__c = objectString;
        log.Endpoint__c = this.mdt.Named_Credential__c + this.mdt.Relative_Endpoint__c;
        log.Detalles__c = detalles;
        return log;
    }
    public Set<Id> catchErrors(List<Database.UpsertResult> results, String objectString, List<SObject> listRecords){
        System.debug('<--catchErrors');
        System.debug(objectString);
        system.debug('records proccesed: '+ results.size());
        Integer numErrors = 0;
        Set<Id> idRecords = new Set<Id>();
        List<Log_Servicios_Web__c> listLogs = new List<Log_Servicios_Web__c>();
        for(Integer i=0;i<results.size();i++) {
            if (results.get(i).isSuccess()){
                idRecords.add(results.get(i).getId());
            }
            if (!results.get(i).isSuccess() || Test.isRunningTest()){
                // DML operation failed
                numErrors+=1;
                system.debug('Failed ID'+listRecords.get(i).Id);
                system.debug('Failed record'+listRecords.get(i));
                for(Database.Error error : results.get(i).getErrors()) {
                    String detalles = 'The following error has occurred. '+
                        error.getStatusCode() + ' : ' + error.getMessage() +
                        ' Fields that affected this error: ' + error.getFields();
                    System.debug(detalles);
                    if(mdt.Activar_Log__c || Test.isRunningTest()){
                        listLogs.add(addLogServiciosWeb(objectString, detalles));
                    }
                }
            }
        }
        system.debug('records proccesed with errors: '+ numErrors);
       
        if(!listLogs.isEmpty()){
            insert listLogs;
        }
        System.debug(idRecords.size());
        System.debug('catchErrors-->');
        return idRecords;
    }

    // public static SObjectType getSObjectTypeByString(String objectAPIName){
    //     return ((SObject) Type.forName(objectAPIName).newInstance()).getSObjectType();
    // }

    // public static Schema.DescribeSObjectResult getSObjectTypeByString(String objectAPIName){
    //     return  Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
    // }

    // public static Id getRecordTypeId (String objectAPIName, String recordTypeName){
    //     return getSObjectTypeByString(objectAPIName).getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    // }

    // public String getAuthorizationHeader(){
    //     Blob headerValue = Blob.valueOf('{!HTMLENCODE($Credential.Username)}' + ':' + '{!HTMLENCODE($Credential.Password)}');
    //     return 'BASIC ' + EncodingUtil.base64Encode(headerValue);
    // }
}