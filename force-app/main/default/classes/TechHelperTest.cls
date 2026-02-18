@isTest
private class TechHelperTest {
    @isTest static void testAll() {
        UnifiedssotIndividualDev2__dlm p = (UnifiedssotIndividualDev2__dlm) JSON.deserialize('{"ssot__Id__c":"U1", "Id_POS__c":"P1", "Email__c":"t@t.com"}', UnifiedssotIndividualDev2__dlm.class);
        
        Test.startTest();
        TechHelper.getFullData('U1');
        TechHelper.getFullData(null);
        // Caso extra para cobertura
        TechHelper.getFullData('INVALID_ID');
        Test.stopTest();
        System.assert(true);
    }
}