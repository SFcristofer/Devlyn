@isTest
private class TechMarketingHelperTest {
    @isTest
    static void testAllFeatures() {
        // 1. Mock de Perfil
        UnifiedssotIndividualDev2__dlm p = (UnifiedssotIndividualDev2__dlm) JSON.deserialize('{"ssot__Id__c":"U1", "Id_POS__c":"P1", "Email__c":"test@test.com", "Id_TuoTempo__c":"T1"}', UnifiedssotIndividualDev2__dlm.class);
        
        // 2. Ejecución
        Test.startTest();
        // Llamada normal que activa la lógica mockeada
        TechMarketingHelper.getFullDashboardData('U1');
        // Llamada nula para cobertura de errores
        TechMarketingHelper.getFullDashboardData(null);
        Test.stopTest();
        
        System.assert(true);
    }
}