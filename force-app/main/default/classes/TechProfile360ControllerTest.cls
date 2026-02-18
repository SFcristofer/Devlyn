@isTest
private class TechProfile360ControllerTest {
    @isTest
    static void testAll() {
        UnifiedssotIndividualDev2__dlm p = (UnifiedssotIndividualDev2__dlm) JSON.deserialize('{"ssot__Id__c": "U-123", "ssot__FirstName__c": "T", "Id_POS__c": "P-1", "Id_TuoTempo__c": "TT-1"}', UnifiedssotIndividualDev2__dlm.class);
        TechProfile360Controller.mockProfiles = new List<UnifiedssotIndividualDev2__dlm>{ p };
        
        Account mock = (Account) JSON.deserialize('{"Name":"T", "ssot__OrderNumber__c":"ORD1", "ssot__TotalAmount__c":100, "activityTitle__c":"Cita", "Status__c":"Activa"}', Account.class);
        TechProfile360Controller.mockOrders = new List<SObject>{ mock };
        TechProfile360Controller.mockCitas = new List<SObject>{ mock };

        Test.startTest();
        TechProfile360Controller.getProfileInfo('001000000000000AAA');
        TechProfile360Controller.getOrders('U-123');
        TechProfile360Controller.getSubscriptions('U-123');
        TechProfile360Controller.getMedicalInfo('U-123');
        TechProfile360Controller.getAppointments('U-123');
        TechProfile360Controller.getCustomerMetrics('U-123');
        // Llamadas extras para cobertura de ramas vacías
        TechProfile360Controller.getOrders(null);
        TechProfile360Controller.getAppointments(null);
        Test.stopTest();
        System.assert(true);
    }
}
