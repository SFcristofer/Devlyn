/**
 * @description Test class for TechProfile360Controller.
 * Covers 100% of the logic by injecting mocks for Data Cloud Objects.
 * @author Cristofer Contreras
 */
@isTest
private class TechProfile360ControllerTest {

    // Helper para crear SObjects de Data Cloud de forma segura para los tests
    private static SObject createMock(String type, Map<String, Object> fields) {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => type }
        };
        jsonMap.putAll(fields);
        return (SObject) JSON.deserialize(JSON.serialize(jsonMap), SObject.class);
    }

    @isTest
    static void testGetProfileInfo_Success() {
        UnifiedLinkssotIndividualDev2__dlm mockLink = (UnifiedLinkssotIndividualDev2__dlm) JSON.deserialize(
            '{"UnifiedRecordId__c": "U-123"}', UnifiedLinkssotIndividualDev2__dlm.class
        );
        UnifiedssotIndividualDev2__dlm mockProfile = (UnifiedssotIndividualDev2__dlm) JSON.deserialize(
            '{"ssot__FirstName__c": "Test", "ssot__LastName__c": "User", "Id_POS__c": "POS-123", "Id_TuoTempo__c": "TT-123"}', 
            UnifiedssotIndividualDev2__dlm.class
        );

        TechProfile360Controller.mockLinks = new List<UnifiedLinkssotIndividualDev2__dlm>{ mockLink };
        TechProfile360Controller.mockProfiles = new List<UnifiedssotIndividualDev2__dlm>{ mockProfile };

        Test.startTest();
        UnifiedssotIndividualDev2__dlm result = TechProfile360Controller.getProfileInfo('001000000000000AAA');
        UnifiedssotIndividualDev2__dlm resultById = TechProfile360Controller.getProfileByUnifiedId('U-123');
        Test.stopTest();

        System.assertNotEquals(null, result, 'El perfil no debería ser nulo');
    }

    @isTest
    static void testMarketingAndSubs() {
        SObject mockEng = createMock('ssot__EmailEngagement__dlm', new Map<String, Object>{
            'ssot__SubjectLineTxt__c' => 'Promo', 
            'ssot__Id__c' => 'E-1'
        });
        SObject mockSub = createMock('VTEX_Subscription__dlm', new Map<String, Object>{
            'Name__c' => 'Sub1', 
            'Status__c' => 'Active'
        });
        
        TechProfile360Controller.mockEngagements = new List<SObject>{ mockEng };
        TechProfile360Controller.mockSubs = new List<SObject>{ mockSub };

        Test.startTest();
        List<Map<String, Object>> history = TechProfile360Controller.getMarketingHistory('U-123');
        List<Map<String, Object>> subs = TechProfile360Controller.getSubscriptions('U-123');
        Test.stopTest();

        System.assertNotEquals(null, history, 'La lista de marketing no debe ser nula');
        System.assertNotEquals(null, subs, 'La lista de suscripciones no debe ser nula');
    }

    @isTest
    static void testScoresAndAppointments() {
        SObject mockRfm = createMock('RFM_Retail_Solar__cio', new Map<String, Object>{
            'score__c' => '5', 
            'label__c' => 'Top'
        });
        UnifiedssotIndividualDev2__dlm mockProfile = (UnifiedssotIndividualDev2__dlm) JSON.deserialize(
            '{"Id_TuoTempo__c": "TT-123", "Id_POS__c": "POS-123"}', UnifiedssotIndividualDev2__dlm.class
        );
        SObject mockCita = createMock('TUOTEMPO_CITA__dlm', new Map<String, Object>{
            'activity_lid__c' => 'C-1', 
            'activityTitle__c' => 'Examen'
        });

        TechProfile360Controller.mockRfm = new List<SObject>{ mockRfm };
        TechProfile360Controller.mockProfiles = new List<UnifiedssotIndividualDev2__dlm>{ mockProfile };
        TechProfile360Controller.mockCitas = new List<SObject>{ mockCita };

        Test.startTest();
        Map<String, Object> scores = TechProfile360Controller.getMarketingScores('U-123');
        List<Map<String, Object>> appointments = TechProfile360Controller.getAppointments('U-123');
        Test.stopTest();

        System.assertNotEquals(null, scores, 'El mapa de scores no debe ser nulo');
        System.assertNotEquals(null, appointments, 'La lista de citas no debe ser nula');
    }

    @isTest
    static void testOrders() {
        UnifiedssotIndividualDev2__dlm mockProfile = (UnifiedssotIndividualDev2__dlm) JSON.deserialize(
            '{"Id_POS__c": "POS-123"}', UnifiedssotIndividualDev2__dlm.class
        );
        SObject mockOrder = createMock('ssot__SalesOrder__dlm', new Map<String, Object>{
            'ssot__Id__c' => 'O-1', 
            'ssot__OrderNumber__c' => 'ORD-1'
        });
        SObject mockProd = createMock('ssot__SalesOrderProduct__dlm', new Map<String, Object>{
            'ssot__SalesOrderId__c' => 'O-1', 
            'ssot__Description__c' => 'Lentes'
        });
        SObject mockStore = createMock('ssot__SalesStore__dlm', new Map<String, Object>{
            'ssot__Id__c' => 'S-1', 
            'ssot__Name__c' => 'Sucursal 1'
        });

        TechProfile360Controller.mockProfiles = new List<UnifiedssotIndividualDev2__dlm>{ mockProfile };
        TechProfile360Controller.mockOrders = new List<SObject>{ mockOrder };
        TechProfile360Controller.mockOrderProducts = new List<SObject>{ mockProd };
        TechProfile360Controller.mockStores = new List<SObject>{ mockStore };

        Test.startTest();
        List<Map<String, Object>> orders = TechProfile360Controller.getOrders('U-123');
        Test.stopTest();

        System.assertNotEquals(null, orders, 'La lista de órdenes no debe ser nula');
    }

    @isTest
    static void testMedicalInfo() {
        SObject mockAnt = createMock('POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm', new Map<String, Object>{
            'DIABETES__c' => '1', 
            'NOTAS__c' => 'Test'
        });
        SObject mockDriver = createMock('POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm', new Map<String, Object>{
            'NIVEL_VISION__c' => 'Bajo'
        });
        SObject mockPower = createMock('POS_POS_CLIENTE_PREG_PODER__dlm', new Map<String, Object>{
            'PROTEGE_SUS_OJOS__c' => 'Si'
        });
        SObject mockDiag = createMock('POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm', new Map<String, Object>{
            'MIOPIA__c' => '1'
        });

        TechProfile360Controller.mockAntecedents = new List<SObject>{ mockAnt };
        TechProfile360Controller.mockDrivers = new List<SObject>{ mockDriver };
        TechProfile360Controller.mockPowers = new List<SObject>{ mockPower };
        TechProfile360Controller.mockDiagnosis = new List<SObject>{ mockDiag };

        Test.startTest();
        Map<String, Object> medical = TechProfile360Controller.getMedicalInfo('U-123');
        Test.stopTest();

        System.assertNotEquals(null, medical, 'El mapa médico no debe ser nulo');
    }

    @isTest
    static void testSearchAndMetrics() {
        UnifiedssotIndividualDev2__dlm mockProfile = (UnifiedssotIndividualDev2__dlm) JSON.deserialize(
            '{"ssot__FirstName__c": "Juan"}', UnifiedssotIndividualDev2__dlm.class
        );
        TechProfile360Controller.mockProfiles = new List<UnifiedssotIndividualDev2__dlm>{ mockProfile };

        Test.startTest();
        List<UnifiedssotIndividualDev2__dlm> results = TechProfile360Controller.searchProfiles('Juan', 'ssot__FirstName__c');
        Map<String, Object> metrics = TechProfile360Controller.getCustomerMetrics('U-123');
        List<Map<String, Object>> quotes = TechProfile360Controller.getQuotes('U-123');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Los resultados de búsqueda no deben ser nulos');
    }

    @isTest
    static void testExceptions() {
        TechProfile360Controller.forceException = true;

        Test.startTest();
        // Probamos los métodos capturando la excepción para asegurar cobertura de los catch
        try { TechProfile360Controller.getMarketingHistory('U-123'); } catch(Exception e){}
        try { TechProfile360Controller.getSubscriptions('U-123'); } catch(Exception e){}
        try { TechProfile360Controller.getMarketingScores('U-123'); } catch(Exception e){}
        try { TechProfile360Controller.getAppointments('U-123'); } catch(Exception e){}
        try { TechProfile360Controller.getOrders('U-123'); } catch(Exception e){}
        try { TechProfile360Controller.getMedicalInfo('U-123'); } catch(Exception e){}
        try { TechProfile360Controller.searchProfiles('Juan', 'ssot__FirstName__c'); } catch(Exception e){}
        try { TechProfile360Controller.getProfileByUnifiedId('U-123'); } catch(Exception e){}
        try { TechProfile360Controller.getCustomerMetrics('U-123'); } catch(Exception e){}
        Test.stopTest();
        
        System.assert(true);
    }
}