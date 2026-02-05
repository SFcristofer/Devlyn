public with sharing class ETC_UtilityMetadata {
    
    public static Endpoint__mdt getCustomMetadataRecord(String myName) {
        return [SELECT Id, DeveloperName, Response__c, Request__c,Token__c, Method__c, Relative_Endpoint__c, Named_Credential__c, Minuto_de_Ejecucion__c, Timer__c,Activar_Log__c FROM Endpoint__mdt WHERE DeveloperName = :myName LIMIT 1];
     }
 
     public static String getCRONString(String endpointName) {
         Endpoint__mdt mdt =  getCustomMetadataRecord(endpointName);
         Integer timer = Integer.valueOf(mdt.Timer__c);
         Integer minutos = Integer.valueOf(mdt.Minuto_de_Ejecucion__c);
         DateTime nextRunTime  = DateTime.newinstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day(), DateTime.now().hour(), minutos, Datetime.now().second()).addMinutes(timer);
         
         String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
             nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
             nextRunTime.month() + ' ? ' + nextRunTime.year();
 
         return cronString;
     }
 
     public static String getCRONString(){
         return '0 '+System.now().addMinutes(1).minute()+' '+System.now().hour()+' ' +System.now().day() +' '+system.now().month()+' ? '+system.now().year();
     }
     public static User getUser(String recordId){
         return [SELECT Id,
             Email,
             MobilePhone,
             Name
         FROM User WHERE Id=:recordId LIMIT 1];
     }
 
     public static User getAdminUser(){
         return [SELECT Id, profile.Name, EmployeeNumber FROM User WHERE profile.Name = 'Administrador del sistema' AND IsActive=True LIMIT 1];
     }
 }