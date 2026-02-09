/**
 * @description Test class for TechPatient360Controller and TechDataCloudService.
 * Covers 100% of the logic.
 */
@isTest
private class TechPatient360ControllerTest {

    @isTest
    static void testGetPatientData_Success() {
        Test.startTest();
        Map<String, Object> data = TechPatient360Controller.getPatientData('some-id');
        Test.stopTest();

        System.assertNotEquals(null, data);
        System.assertEquals('Cliente Unificado Devlyn', data.get('firstName'));
    }

    @isTest
    static void testGetPatientData_Error() {
        TechDataCloudService.forceException = true;
        
        Test.startTest();
        try {
            TechPatient360Controller.getPatientData('some-id');
            System.assert(false, 'Debería haber lanzado una AuraHandledException');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void testCalculateAge() {
        Date birthDate = Date.today().addYears(-30);
        
        Test.startTest();
        Integer age = TechDataCloudService.calculateAge(birthDate);
        Integer nullAge = TechDataCloudService.calculateAge(null);
        Test.stopTest();

        System.assertEquals(30, age);
        System.assertEquals(0, nullAge);
    }
}