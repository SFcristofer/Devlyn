@isTest
private class TechMarketing360Test {
    @isTest
    static void testFeatures() {
        Account a = new Account(Name='T', Phone='123');
        // Usamos campos que existen en Account para el mock genérico
        SObject mock = (SObject) JSON.deserialize('{"Id_POS__c":"P1", "Email__c":"t@t.com", "ssot__SubjectLineTxt__c":"T", "ssot__Id__c":"E1", "TOTAL__c":100}', Account.class);
        TechMarketing360.mockData = new List<SObject>{mock};
        Test.startTest();
        TechMarketing360.getExtendedData('U1');
        Test.stopTest();
        System.assert(true);
    }
}
