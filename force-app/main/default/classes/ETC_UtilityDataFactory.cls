@IsTest
public with sharing class ETC_UtilityDataFactory {
    public static Account addAccount(String name){
        Account record = new Account();
        record.Name = name;
        insert record;
        return record;
    }

    public static Opportunity addOpportunity(String name){
        Opportunity record = new Opportunity();
        record.Name = name;
        record.AccountId = addAccount(name).Id;
        record.StageName = 'Qualification';
        record.CloseDate = System.today();
        record.Numero_de_convenio__c = 1;
        insert record;
        return record;
    }

    public static Monto__c addReporteMonto(){
        Monto__c record = new Monto__c();
        record.Sincronizado__c = true;
        insert record;
        return record;
    }
}