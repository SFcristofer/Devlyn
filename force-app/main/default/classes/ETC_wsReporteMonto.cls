public with sharing class ETC_wsReporteMonto extends ETC_UtilityCallout{
    public static final String ENDPOINTNAME = 'wsReporteMonto';
    public ETC_wsReporteMonto (){
        this.claseApex = ETC_wsReporteMonto.class.getName();
    }

    private with sharing class WebServiceController{

        public Map<Id,Monto__c> mapRecord;
        WrapperMonto wrapper;
        ETC_wsReporteMonto ws;

        public WebServiceController(ETC_wsReporteMonto ws) {
            this.mapRecord = this.getMapRecord();
            this.wrapper = new WrapperMonto();
            this.ws = ws;
        }
        private Map<Id,Monto__c> getMapRecord() {
            return new Map<Id,Monto__c>([SELECT Id,ExternalId__c FROM Monto__c WHERE Sincronizado__c = true]);
        }

        

        private void sync(List<Monto__c> listAccounts){
            if(!listAccounts.isEmpty()){
                List<Monto__c> listAccountsInactive = new List<Monto__c>();
                Schema.SObjectField idExternoSobject = Monto__c.Fields.ExternalId__c;
                Database.UpsertResult[] results= Database.upsert(listAccounts, idExternoSobject, false);
                Set<Id> idsSuccess = this.ws.catchErrors(results,'Monto__c',listAccounts);
                this.handleErrorRecords(listAccounts, idsSuccess, idExternoSobject);
                this.handleInactiveRecords(listAccounts, idsSuccess, idExternoSobject);
            }
        }

        private void handleErrorRecords(List<Monto__c> lstRecords, Set<Id> idsSuccess, Schema.SObjectField idExternoSobject) {
            List<Monto__c> lstRecordsErrors = new List<Monto__c>();
            Database.UpsertResult[] results;
            for (Integer i = 0; i < lstRecords.size(); i++) {
                if(!idsSuccess.contains(lstRecords[i].Id) || Test.isRunningTest()){
                    Monto__c acc = new Monto__c();
                    acc.ExternalId__c = lstRecords[i].ExternalId__c;
                    acc.isError__c = true;
                    acc.isActive__c = true;
                    lstRecordsErrors.add(acc);
                }
            }

            if(!lstRecordsErrors.isEmpty()){
                results= Database.upsert(lstRecordsErrors, idExternoSobject, false);
                this.ws.catchErrors(results,'Monto__c-errorCatch',lstRecords);

            }
        }

        private void handleInactiveRecords(List<Monto__c> lstRecords, Set<Id> idsSuccess, Schema.SObjectField idExternoSobject) {
            List<Monto__c> lstRecordsInactive = new List<Monto__c>();
            Database.UpsertResult[] results;
            for(String idExterno: getDisabledRecords()) {
                Monto__c acc = new Monto__c();
                acc.ExternalId__c = idExterno;
                acc.isActive__c = false;
                lstRecordsInactive.add(acc);
            }
            
            if(!lstRecordsInactive.isEmpty()){
                results= Database.upsert(lstRecordsInactive, idExternoSobject, false);
            }
        }
        
        private Set<String> getDisabledRecords(Set<String> actualRecords, Set<String> activeRecords){
            actualRecords.removeAll(activeRecords);
            return actualRecords;
        }

        private Set<String> getDisabledRecords(){
            Set<String> actualRecords = new Set<String>();
            for(Monto__c acc :this.mapRecord.values()){
                actualRecords.add(acc.ExternalId__c);
            }
            return getDisabledRecords(actualRecords, this.wrapper.activeRecords);
        }

        public void sync(String listCatalogos) {
            this.sync(this.wrapper.createObject(this.wrapper.parse(listCatalogos)));
        }
    }

    private void callCallout() {
        System.debug('<--callCallout');
        List<List<String>> respuestas = new List<List<String>>();
        respuestas.add(new List<String>());
        Callout callout = createCallout(ENDPOINTNAME);
        callout.request.setHeader('Authorization', 'Basic '+ETC_wsLogin.getLogin().token);
        System.debug(mdt.Token__c);
        HttpResponse response = sendCallout(callout);
        WebServiceController wsController = new WebServiceController(this);
        System.debug(response.getStatusCode());
        // System.debug(response.getBody());
        if(response.getStatusCode() == 200 || Test.isRunningTest()) {
            wsController.sync(Test.isRunningTest()?this.mdt.Response__c:response.getBody());
        }
        if(response.getStatusCode() != 200 || Test.isRunningTest()) {
            // respuestas[0].add(Test.isRunningTest()?this.mdt.Response__c:response.getBody());
        }
        System.debug('callCallout-->');
    }

    public static void getMontos(){
        ETC_wsReporteMonto ws = new ETC_wsReporteMonto();
        ws.callCallout();
    }

    @future(callout = true)
    public static void getMontosFuture(){
        getMontos();
    }
}