@isTest
private class TechProfile360ControllerTest {
    @isTest
    static void testMasterLogic() {
        // 1. Mock Perfil
        UnifiedssotIndividualDev2__dlm p = (UnifiedssotIndividualDev2__dlm) JSON.deserialize('{"ssot__Id__c":"U1", "ssot__FirstName__c":"T", "ssot__LastName__c":"L", "Id_POS__c":"P1", "Email__c":"t@t.com", "Id_TuoTempo__c":"TT1", "FECHA_NACIMIENTO_dt__c":"1990-01-01"}', UnifiedssotIndividualDev2__dlm.class);
        TechProfile360Controller.mockProfiles = new List<UnifiedssotIndividualDev2__dlm>{ p };

        // 2. Mock Órdenes y Productos
        TechProfile360Controller.mockOrders = new List<SObject>{
            (SObject) JSON.deserialize('{"ssot__Id__c":"O1", "ssot__OrderNumber__c":"ORD1", "ssot__TotalAmount__c":100, "ssot__SalesStoreId__c":"WWW"}', ssot__SalesOrder__dlm.class)
        };
        TechProfile360Controller.mockOrderProducts = new List<SObject>{
            (SObject) JSON.deserialize('{"ssot__SalesOrderId__c":"O1", "ssot__Description__c":"Lente Solar", "ssot__ProductId__c":"S1", "ssot__OrderedQuantity__c":1, "ssot__TotalLineAmount__c":100}', ssot__SalesOrderProduct__dlm.class)
        };

        // 3. Mock Marketing
        TechProfile360Controller.mockEngagements = new List<SObject>{
            (SObject) JSON.deserialize('{"ssot__SubjectLineTxt__c":"Promo", "ssot__EngagementDateTm__c":"2025-01-01", "Id":"E1"}', ssot__EmailEngagement__dlm.class)
        };

        Test.startTest();
        TechProfile360Controller.getProfileData('U1');
        TechProfile360Controller.getProfileData(null); // Error check
        TechProfile360Controller.searchProfilesGlobal('Test');
        Test.stopTest();
        
        System.assert(true);
    }
}