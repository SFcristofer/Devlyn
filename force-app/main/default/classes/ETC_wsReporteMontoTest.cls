@isTest
public with sharing class ETC_wsReporteMontoTest {
    @IsTest
    static void ETC_wsReporteMontoTest() {
        ETC_UtilityDataFactory.addReporteMonto();
        Test.startTest();
        ETC_wsReporteMonto.getMontosFuture();
        Test.stopTest();
    }

    @isTest
    private static void ETC_wsReporteMontoScheduleTest() {
        // Actual test
        Test.startTest();
        ETC_wsReporteMontoSchedule reminder = new ETC_wsReporteMontoSchedule();
        String jobID = System.schedule(ETC_wsReporteMontoSchedule.class.getName() + '-' + DateTime.now().format(), ETC_UtilityMetadata.getCRONString(), reminder);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobID];
        System.assertEquals(ETC_UtilityMetadata.getCRONString(), ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        ETC_wsReporteMontoSchedule.start();
        Test.stopTest();
    
        // Asserts
    }

    
}