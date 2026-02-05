@isTest
public with sharing class ETC_UtilityTest {
    @IsTest
    static void ETC_UtilityCalloutTest() {
        ETC_UtilityCallout callout = new ETC_UtilityCallout();
        Test.startTest();
        ETC_UtilityCallout.getDate('0000-00-00');
        ETC_UtilityCallout.getDate('2022-01-01');
        ETC_UtilityCallout.getHour('00:00');
        ETC_UtilityCallout.getHour('12:00:00');
        ETC_UtilityCallout.getDateTime(System.today());
        ETC_UtilityCallout.getString('stringValidate');
        ETC_UtilityCallout.getString(null);
        ETC_UtilityCallout.getStringRemoveZero(null);
        ETC_UtilityCallout.getStringRemoveZero('000111');
        ETC_UtilityCallout.getDateFormated('00.00.0000');
        ETC_UtilityCallout.getDateFormated('01.01.2020');
        Test.stopTest();
    }
    @IsTest
    static void CalloutTest() {
        ETC_UtilityDataFactory.addAccount('Test');
        Test.startTest();
        ETC_wsClientes ws = new ETC_wsClientes();
        ETC_wsClientes.getClientesFuture();
        ETC_wsClientes.getClientes();
        ws.addLogServiciosWeb('objectString', 'detalles');
        Test.stopTest();
    }

    @isTest
    private static void ETC_UtilityMetadataTest() {
    
        Test.startTest();
        ETC_UtilityMetadata.getCRONString(ETC_wsClientes.ENDPOINTNAME);
        ETC_UtilityMetadata.getCRONString();
        User user = ETC_UtilityMetadata.getAdminUser();
        ETC_UtilityMetadata.getUser(user.Id);
        Test.stopTest();
    
    }
}