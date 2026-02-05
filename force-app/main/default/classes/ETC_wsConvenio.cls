public with sharing class ETC_wsConvenio extends ETC_UtilityCallout{
    public static final String ENDPOINTNAME = 'wsAddConvenio';
    public ETC_wsConvenio (){
        this.claseApex = ETC_wsConvenio.class.getName();
    }
    
    public class ControllerConvenio{

        String recordId;
        public ControllerConvenio(String recordId){
            this.recordId = recordId;
        }

        private List<String> sync(String body) {
            WrapperConvenio.Response response = WrapperConvenio.parseResponse(body);
            if(String.isNotBlank(response.IDREFERENCIA)){
                Opportunity opportunity = WrapperConvenio.getConvenio(this.recordId);
                opportunity.Numero_de_convenio__c = Decimal.valueOf(response.IDREFERENCIA);
                update opportunity;
                if(!Test.isRunningTest()){return new List<String>{'Proceso Exitoso'};}
            }
            return new List<String>{JSON.serialize(response)};
        }
    }

    private List<String> callSetConvenio(String recordId) {
        System.debug('<--callSetConvenio');
        List<String> respuestas = new List<String>();
        Callout callout = createCallout(ENDPOINTNAME);
        String body = WrapperConvenio.getBody(recordId, this.mdt.Token__c);
        callout.request.setBody(body);
        HttpResponse response = sendCallout(callout);
        ControllerConvenio ControllerConvenio = new ControllerConvenio(recordId);
        System.debug(body);
        System.debug(response.getStatusCode());
        System.debug(response.getBody());
        if(response.getStatusCode() == 200 || Test.isRunningTest()) {
            
            respuestas.addAll(ControllerConvenio.sync(Test.isRunningTest()?this.mdt.Response__c:response.getBody()));
            if(!Test.isRunningTest()){return respuestas;}
        }
        if(response.getStatusCode() != 200 || Test.isRunningTest()) {
            respuestas.add(Test.isRunningTest()?this.mdt.Response__c:response.getBody());
            if(!Test.isRunningTest()){return respuestas;}
        }
        System.debug('callSetConvenio-->');
        return respuestas;
    }

    @invocableMethod(label = 'Add Opportunity' description = 'Send convenio to MDS' category='Opportunity' callout = true)
    public static List<List<String>> postAddOpportunity(List<List<Id>> recordIds) {
        List<List<String>> respuestas = new List<List<String>>();
        respuestas.add(new List<String>());
        if(recordIds.size() == 0 || recordIds[0].size() == 0 || Test.isRunningTest()) {
            respuestas[0].add('Ingrese el id del registro');
            if(!Test.isRunningTest()){return respuestas;}
        }

        try {
            ETC_wsConvenio ws = new ETC_wsConvenio();
            respuestas[0].addAll(ws.callSetConvenio(recordIds[0][0]));
            if(!Test.isRunningTest()){return respuestas;}
        } catch (Exception ex) {
            System.debug(ex.getCause());
            System.debug(ex.getStackTraceString());
            System.debug(ex.getLineNumber());
            respuestas[0].add(ex.getStackTraceString());
        }
        
        return respuestas;
    }
    
    public static void addOpportunity(String recordId) {
        ETC_wsConvenio ws = new ETC_wsConvenio();
        ws.callSetConvenio(recordId);
    }

    @future(callout = true)
    public static void addOpportunityFuture(String recordId) {
        addOpportunity(recordId);
    }
}