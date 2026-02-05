public with sharing class ETC_wsClientesSchedule implements Schedulable, Database.AllowsCallouts{
    public void execute(SchedulableContext sc) {
        ETC_wsClientes.getClientesFuture();
        // Abort the current job
        Id jobId = sc.getTriggerId();
        System.abortJob(jobId);  
        if(!Test.isRunningTest()){ System.schedule(ETC_wsClientesSchedule.class.getName(), ETC_UtilityMetadata.getCRONString(ETC_wsClientes.ENDPOINTNAME), new ETC_wsClientesSchedule());}
    }

    public static void start() {
        if(!Test.isRunningTest()){System.schedule(ETC_wsClientesSchedule.class.getName(), ETC_UtilityMetadata.getCRONString(),  new ETC_wsClientesSchedule());}
    }
}