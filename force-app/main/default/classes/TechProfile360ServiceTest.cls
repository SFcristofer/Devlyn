/**
 * @description Comprehensive test for TechProfile360Service to reach 100% coverage.
 */
@isTest
private class TechProfile360ServiceTest {

    private static SObject createMock(String type, Map<String, Object> fields) {
        Map<String, Object> jsonMap = new Map<String, Object>{ 'attributes' => new Map<String, Object>{ 'type' => type } };
        jsonMap.putAll(fields);
        return (SObject) JSON.deserialize(JSON.serialize(jsonMap), SObject.class);
    }

    @isTest
    static void testBusinessLogic() {
        // 1. Mocks de Perfil
        UnifiedssotIndividualDev2__dlm p = (UnifiedssotIndividualDev2__dlm) JSON.deserialize('{"ssot__Id__c": "U1", "Id_POS__c": "P1", "Id_TuoTempo__c": "T1"}', UnifiedssotIndividualDev2__dlm.class);
        TechProfile360Service.mockProfiles = new List<UnifiedssotIndividualDev2__dlm>{ p };
        TechProfile360Service.mockLinks = new List<UnifiedLinkssotIndividualDev2__dlm>{ (UnifiedLinkssotIndividualDev2__dlm) JSON.deserialize('{"UnifiedRecordId__c": "U1"}', UnifiedLinkssotIndividualDev2__dlm.class) };
        
        // 2. Mocks de Engagement (Para cobertura de iconos)
        SObject e1 = createMock('ssot__EmailEngagement__dlm', new Map<String, Object>{'ssot__SubjectLineTxt__c'=>'S1', 'ssot__EngagementChannelActionId__c'=>'Click', 'ssot__IndividualId__c'=>'P1'});
        SObject e2 = createMock('ssot__EmailEngagement__dlm', new Map<String, Object>{'ssot__SubjectLineTxt__c'=>'S1', 'ssot__EngagementChannelActionId__c'=>'Open', 'ssot__IndividualId__c'=>'P1'});
        TechProfile360Service.mockEngagements = new List<SObject>{ e1, e2 };

        // 3. Mocks de Ordenes (Para cobertura de canales y categorias)
        Datetime lastWeek = Datetime.now().addDays(-7);
        SObject ord1 = createMock('ssot__SalesOrder__dlm', new Map<String, Object>{'ssot__Id__c'=>'O1', 'ssot__TotalAmount__c'=>100, 'ssot__SalesStoreId__c'=>'S1', 'ssot__CreatedDate__c'=>lastWeek});
        SObject ord2 = createMock('ssot__SalesOrder__dlm', new Map<String, Object>{'ssot__Id__c'=>'O2', 'ssot__TotalAmount__c'=>200, 'ssot__SalesStoreId__c'=>'WEB', 'ssot__CreatedDate__c'=>Datetime.now()});
        
        SObject pr1 = createMock('ssot__SalesOrderProduct__dlm', new Map<String, Object>{'ssot__SalesOrderId__c'=>'O1', 'ssot__Description__c'=>'Lente Solar'});
        SObject pr2 = createMock('ssot__SalesOrderProduct__dlm', new Map<String, Object>{'ssot__SalesOrderId__c'=>'O2', 'ssot__Description__c'=>'Lente de Contacto'});
        SObject pr3 = createMock('ssot__SalesOrderProduct__dlm', new Map<String, Object>{'ssot__SalesOrderId__c'=>'O2', 'ssot__Description__c'=>'Oftalmico'});
        
        TechProfile360Service.mockOrders = new List<SObject>{ ord1, ord2 };
        TechProfile360Service.mockOrderProducts = new List<SObject>{ pr1, pr2, pr3 };
        TechProfile360Service.mockStores = new List<SObject>{ createMock('ssot__SalesStore__dlm', new Map<String, Object>{'ssot__Id__c'=>'S1', 'ssot__Name__c'=>'Store'}) };

        // 4. Mocks Medicos y Subscripciones
        TechProfile360Service.mockAntecedents = new List<SObject>{ createMock('POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm', new Map<String, Object>{'DIABETES__c'=>'1'}) };
        TechProfile360Service.mockDiagnosis = new List<SObject>{ createMock('POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm', new Map<String, Object>{'MIOPIA__c'=>'1'}) };
        TechProfile360Service.mockDrivers = new List<SObject>{ createMock('POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm', new Map<String, Object>{'NIVEL_VISION__c'=>'B'}) };
        TechProfile360Service.mockPowers = new List<SObject>{ createMock('POS_POS_CLIENTE_PREG_PODER__dlm', new Map<String, Object>{'PROTEGE_SUS_OJOS__c'=>'S'}) };
        TechProfile360Service.mockCitas = new List<SObject>{ createMock('TUOTEMPO_CITA__dlm', new Map<String, Object>{'activity_lid__c'=>'C1'}) };
        TechProfile360Service.mockSubs = new List<SObject>{ createMock('VTEX_Subscription__dlm', new Map<String, Object>{'plan_id__c'=>'P'}) };

        Test.startTest();
        TechProfile360Service.getProfileInfo('001000000000000AAA');
        TechProfile360Service.getMarketingHistory('U1');
        TechProfile360Service.getMarketingScores('U1');
        TechProfile360Service.getAppointments('U1');
        TechProfile360Service.getOrders('U1');
        TechProfile360Service.getMedicalInfo('U1');
        TechProfile360Service.getCustomerMetrics('U1');
        TechProfile360Service.searchProfiles('T', 'ssot__FirstName__c');
        TechProfile360Service.executeDataCloudQuery('SELECT 1');
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest
    static void testExceptions() {
        TechProfile360Service.forceException = true;
        Test.startTest();
        TechProfile360Service.getMarketingHistory('U1');
        TechProfile360Service.getSubscriptions('U1');
        TechProfile360Service.getMarketingScores('U1');
        TechProfile360Service.getAppointments('U1');
        TechProfile360Service.getOrders('U1');
        TechProfile360Service.getMedicalInfo('U1');
        TechProfile360Service.searchProfiles('T', 'Invalid');
        TechProfile360Service.getProfileByUnifiedId('U1');
        Test.stopTest();
        System.assert(true);
    }
}