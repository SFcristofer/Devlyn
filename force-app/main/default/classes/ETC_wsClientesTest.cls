@IsTest
public with sharing class ETC_wsClientesTest {
    @IsTest
    public static void ETC_wsClientesTest(){
        ETC_UtilityDataFactory.addAccount('Test');
        Test.startTest();
        ETC_wsClientes.getClientesFuture();
        ETC_wsClientes.getClientes();
        Test.stopTest();
        
    }

    @IsTest
    static void ETC_wsAddAccountTest(){
        Account acc = ETC_UtilityDataFactory.addAccount('Test');
        System.debug(acc.Id);
        Test.startTest();
        ETC_wsAddAccount.addAccount(acc.Id);
        ETC_wsAddAccount.addAccountFuture(acc.Id);
        List<List<String>> listIds = new List<List<String>>();
        listIds.add(new List<String>{acc.Id});
        ETC_wsAddAccount.postPedidosFlow(listIds);
        Test.stopTest();
    }
    @isTest
    private static void ETC_wsClientesScheduleTest() {
        // Test data setup
    
        // Actual test
        Test.startTest();
        ETC_wsClientesSchedule reminder = new ETC_wsClientesSchedule();
        String jobID = System.schedule(ETC_wsClientesSchedule.class.getName() + '-' + DateTime.now().format(), ETC_UtilityMetadata.getCRONString(), reminder);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobID];
        System.assertEquals(ETC_UtilityMetadata.getCRONString(), ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        ETC_wsClientesSchedule.start();
        Test.stopTest();
    
        // Asserts
    }
}