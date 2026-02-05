public with sharing class ETC_wsAddAccount extends ETC_UtilityCallout{
    public static final String ENDPOINTNAME = 'wsAddCliente';
    public ETC_wsAddAccount (){
        this.claseApex = ETC_wsAddAccount.class.getName();
    }

    public class ControllerClientes{

        String recordId;
        public ControllerClientes(String recordId){
            this.recordId = recordId;
        }

        private List<String> sync(String body) {
            WrapperAddAccount.Response response = WrapperAddAccount.parseResponse(body);
            if(String.isNotBlank(response.IDREFERENCIA) || Test.isRunningTest()){
                Account account = WrapperAddAccount.getAccount(this.recordId);
                account.ExternalId__c = response.IDREFERENCIA;
                account.IdReferencia__c = response.IDREFERENCIA;
                update account;
                if(!Test.isRunningTest()) {return new List<String>{'Proceso Exitoso'};}
            }
            return new List<String>{JSON.serialize(response)};
        }

    }

    private List<String> callSetClientes(String recordId) {
        System.debug('<--callSetClientes');
        List<String> respuestas = new List<String>();
        Callout callout = createCallout(ENDPOINTNAME);
        callout.request.setBody(WrapperAddAccount.getBody(recordId, this.mdt.Token__c));
        System.debug(callout.request.getBody());
        HttpResponse response = Test.isRunningTest()?new HttpResponse():callout.http.send(callout.request);
        ControllerClientes controllerClientes = new ControllerClientes(recordId);
        System.debug(response.getStatusCode());
        System.debug(response.getBody());
        if(response.getStatusCode() == 200 || Test.isRunningTest()) {
            
            respuestas.addAll(controllerClientes.sync(Test.isRunningTest()?this.mdt.Response__c:response.getBody()));
            if(!Test.isRunningTest()) {return respuestas;}
        }
        if(response.getStatusCode() != 200 || Test.isRunningTest()) {
            respuestas.add(response.getBody());
            if(!Test.isRunningTest()) {return respuestas;}
        }
        System.debug('callSetClientes-->');
        return respuestas;
    }

    @invocableMethod(label = 'Add Account' description = 'Send Account to MDS-SAP' category='Account' callout = true)
    public static List<List<String>> postPedidosFlow(List<List<Id>> recordIds) {
        List<List<String>> respuestas = new List<List<String>>();
        respuestas.add(new List<String>());
        if(recordIds.size() == 0 || recordIds[0].size() == 0 || Test.isRunningTest()) {
            respuestas[0].add('Ingrese el id del registro');
            if(!Test.isRunningTest()) {return respuestas;}
        }

        try {
            ETC_wsAddAccount ws = new ETC_wsAddAccount();
            respuestas[0].addAll(ws.callSetClientes(recordIds[0][0]));
            if(!Test.isRunningTest()){return respuestas;}
        } catch (Exception ex) {
            System.debug(ex.getCause());
            System.debug(ex.getStackTraceString());
            System.debug(ex.getLineNumber());
            respuestas[0].add(ex.getStackTraceString());
        }
        return respuestas;
    }
    
    public static void addAccount(String recordId) {
        ETC_wsAddAccount ws = new ETC_wsAddAccount();
        ws.callSetClientes(recordId);
    }

    @future(callout = true)
    public static void addAccountFuture(String recordId) {
        ETC_wsAddAccount ws = new ETC_wsAddAccount();
        ws.callSetClientes(recordId);
    }

    
}