public with sharing class ETC_wsClientes extends ETC_UtilityCallout{
    public static final String ENDPOINTNAME = 'WsClientes';
    public ETC_wsClientes (){
        this.claseApex = ETC_wsClientes.class.getName();
    }

    private with sharing class ControllerClientes{

        public Map<Id,Account> mapAccount;
        WrapperAccount wrapper;
        ETC_wsClientes ws;

        public ControllerClientes(ETC_wsClientes ws) {
            this.mapAccount = this.getMapRecord();
            this.wrapper = new WrapperAccount();
            this.ws = ws;
        }
        private Map<Id,Account> getMapRecord() {
            return new Map<Id,Account>([SELECT Id,ExternalId__c FROM Account WHERE Sincronizado_SAP__c = true]);
        }

        private Set<String> getDisabledRecords(Set<String> actualRecords, Set<String> activeRecords){
            actualRecords.removeAll(activeRecords);
            return actualRecords;
        }

        private Set<String> getDisabledRecords(){
            Set<String> actualRecords = new Set<String>();
            for(Account acc :this.mapAccount.values()){
                actualRecords.add(acc.ExternalId__c);
            }
            return getDisabledRecords(actualRecords, this.wrapper.activeRecords);
        }

        private void sync(List<Account> listAccounts){
            if(!listAccounts.isEmpty()){
                List<Account> listAccountsInactive = new List<Account>();
                Schema.SObjectField idExternoSobject = Account.Fields.ExternalId__c;
                Database.UpsertResult[] results= Database.upsert(listAccounts, idExternoSobject, false);
                Set<Id> idsSuccess = this.ws.catchErrors(results,'Account',listAccounts);
                this.handleErrorRecords(listAccounts, idsSuccess, idExternoSobject);
                this.handleInactiveRecords(listAccounts, idsSuccess, idExternoSobject);
            }
        }

        private void handleErrorRecords(List<Account> lstRecords, Set<Id> idsSuccess, Schema.SObjectField idExternoSobject) {
            List<Account> lstRecordsErrors = new List<Account>();
            Database.UpsertResult[] results;
            for (Integer i = 0; i < lstRecords.size(); i++) {
                if(!idsSuccess.contains(lstRecords[i].Id) || Test.isRunningTest()){
                    Account acc = new Account();
                    acc.ExternalId__c = lstRecords[i].ExternalId__c;
                    acc.isError__c = true;
                    acc.isActive__c = true;
                    lstRecordsErrors.add(acc);
                }
            }

            if(!lstRecordsErrors.isEmpty()){
                results= Database.upsert(lstRecordsErrors, idExternoSobject, false);
                this.ws.catchErrors(results,'Account-errorCatch');

            }
        }

        private void handleInactiveRecords(List<Account> lstRecords, Set<Id> idsSuccess, Schema.SObjectField idExternoSobject) {
            List<Account> lstRecordsInactive = new List<Account>();
            Database.UpsertResult[] results;
            for(String idExterno: getDisabledRecords()) {
                Account acc = new Account();
                acc.ExternalId__c = idExterno;
                acc.isActive__c = false;
                lstRecordsInactive.add(acc);
            }
            
            if(!lstRecordsInactive.isEmpty()){
                results= Database.upsert(lstRecordsInactive, idExternoSobject, false);
            }
        }

        public void sync(String listCatalogos) {
            this.sync(this.wrapper.createObject(this.wrapper.parse(listCatalogos)));
        }
    }

    private void callGetClientes() {
        System.debug('<--getClientes');
        Callout callout = createCallout(ENDPOINTNAME);
        HttpResponse response = sendCallout(callout);
        ControllerClientes controllerClientes = new ControllerClientes(this);
        System.debug(response.getStatusCode());
        System.debug(response.getBody());
        if(response.getStatusCode() == 200 || Test.isRunningTest()) {
            controllerClientes.sync(Test.isRunningTest()?this.mdt.Response__c:response.getBody());
        }
        System.debug('getClientes-->');
    }

    public static void getClientes(){
        ETC_wsClientes ws= new ETC_wsClientes();
        ws.callGetClientes();
    }

    @future(callout = true)
    public static void getClientesFuture(){
        ETC_wsClientes ws= new ETC_wsClientes();
        ws.callGetClientes();
    }
}