/**
 * @description Test class for TechProfile360Controller.
 * Note: Data Cloud objects (__dlm) cannot be inserted in Apex Tests. 
 * This test focuses on error handling and null safety coverage.
 * @author Cristofer Contreras
 * @email cristofer.contreras@technovalue.com.mx
 * @date 2026-01-28
 */
@isTest
private class TechProfile360ControllerTest {

    @isTest
    static void testGetProfileInfo_NoDataFound() {
        // Arrange
        Id fakeRecordId = '001000000000000AAA';

        // Act
        Test.startTest();
        // Con el nuevo código, la lista vendrá vacía y retornará null SIN ir al bloque catch.
        UnifiedssotIndividualDev2__dlm result = TechProfile360Controller.getProfileInfo(fakeRecordId);
        Test.stopTest();

        // Assert
        System.assertEquals(null, result, 'Debe retornar null grácilmente si no encuentra el Unified Link');
    }

    @isTest
    static void testGetProfileInfo_Success() {
        // Arrange
        Id fakeRecordId = '001000000000000AAA';
        String fakeUnifiedId = 'UNIFIED-123';

        // Truco para crear objetos de solo lectura (__dlm) mediante JSON
        UnifiedLinkssotIndividualDev2__dlm mockLink = (UnifiedLinkssotIndividualDev2__dlm) JSON.deserialize(
            '{"UnifiedRecordId__c": "' + fakeUnifiedId + '"}', 
            UnifiedLinkssotIndividualDev2__dlm.class
        );
        
        // CORRECCIÓN APLICADA: Id_POS__c en lugar de iD_POS__c
        UnifiedssotIndividualDev2__dlm mockProfile = (UnifiedssotIndividualDev2__dlm) JSON.deserialize(
            '{"ssot__FirstName__c": "Juan", "ssot__LastName__c": "Perez", "Id_POS__c": "POS123"}', 
            UnifiedssotIndividualDev2__dlm.class
        );

        // Inyectamos los mocks en el controlador
        TechProfile360Controller.mockLinks = new List<UnifiedLinkssotIndividualDev2__dlm>{ mockLink };
        TechProfile360Controller.mockProfiles = new List<UnifiedssotIndividualDev2__dlm>{ mockProfile };

        // Act
        Test.startTest();
        UnifiedssotIndividualDev2__dlm result = TechProfile360Controller.getProfileInfo(fakeRecordId);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Debe retornar el perfil inyectado');
        System.assertEquals('Juan', result.ssot__FirstName__c);
        // CORRECCIÓN APLICADA: Assert con Id_POS__c
        System.assertEquals('POS123', result.Id_POS__c);
    }

    @isTest
    static void testGetProfileInfo_EmptyProfile() {
        // Arrange
        Id fakeRecordId = '001000000000000AAA';
        String fakeUnifiedId = 'UNIFIED-123';

        UnifiedLinkssotIndividualDev2__dlm mockLink = (UnifiedLinkssotIndividualDev2__dlm) JSON.deserialize(
            '{"UnifiedRecordId__c": "' + fakeUnifiedId + '"}', 
            UnifiedLinkssotIndividualDev2__dlm.class
        );

        TechProfile360Controller.mockLinks = new List<UnifiedLinkssotIndividualDev2__dlm>{ mockLink };
        TechProfile360Controller.mockProfiles = new List<UnifiedssotIndividualDev2__dlm>(); // Lista vacía

        // Act
        Test.startTest();
        UnifiedssotIndividualDev2__dlm result = TechProfile360Controller.getProfileInfo(fakeRecordId);
        Test.stopTest();

        // Assert
        System.assertEquals(null, result, 'Debe retornar null si la lista de perfiles está vacía');
    }

    @isTest
    static void testGetProfileInfo_Exception() {
        // Arrange
        TechProfile360Controller.forceException = true;
        Id fakeRecordId = '001000000000000AAA';

        // Act
        Test.startTest();
        UnifiedssotIndividualDev2__dlm result = TechProfile360Controller.getProfileInfo(fakeRecordId);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result, 'Debe retornar null al capturar la excepción');
    }

    @isTest
    static void testGetProfileInfo_NullId() {
        // Act
        Test.startTest();
        UnifiedssotIndividualDev2__dlm result = TechProfile360Controller.getProfileInfo(null);
        Test.stopTest();

        // Assert
        System.assertEquals(null, result, 'El resultado debería ser null si el ID es null');
    }
}