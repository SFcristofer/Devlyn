public with sharing class ETC_wsReporteMontoSchedule implements Schedulable, Database.AllowsCallouts{
    public void execute(SchedulableContext sc) {
        ETC_wsReporteMonto.getMontosFuture();
        // Abort the current job
        Id jobId = sc.getTriggerId();
        System.abortJob(jobId);  
        if(!Test.isRunningTest()){ System.schedule(ETC_wsReporteMontoSchedule.class.getName(), ETC_UtilityMetadata.getCRONString(ETC_wsReporteMonto.ENDPOINTNAME), new ETC_wsReporteMontoSchedule());}
    }

    public static void start() {
        if(!Test.isRunningTest()){System.schedule(ETC_wsReporteMontoSchedule.class.getName(), ETC_UtilityMetadata.getCRONString(),  new ETC_wsReporteMontoSchedule());}
    }
}