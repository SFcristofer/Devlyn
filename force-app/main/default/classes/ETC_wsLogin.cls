public with sharing class ETC_wsLogin extends ETC_UtilityCallout{
    public static final String ENDPOINTNAME = 'wsLogin';
    public ETC_wsLogin (){
        this.claseApex = ETC_wsLogin.class.getName();
    }

    private WrapperLogin callCallout() {
        System.debug('<--callCallout');
        List<List<String>> respuestas = new List<List<String>>();
        respuestas.add(new List<String>());
        Callout callout = createCallout(ENDPOINTNAME);
        
        HttpResponse response = sendCallout(callout);
        System.debug(response.getStatusCode());
        // System.debug(response.getBody());
        WrapperLogin wrapper = new WrapperLogin();
        if(response.getStatusCode() == 202 || Test.isRunningTest()) {
            return WrapperLogin.parse(Test.isRunningTest()?this.mdt.Response__c:response.getBody());
        }
        return wrapper;
    }

    public static WrapperLogin getLogin(){
        ETC_wsLogin ws = new ETC_wsLogin();
        return ws.callCallout();
    }

}