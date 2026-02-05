@RestResource(urlMapping='/Convenio/*')
global with sharing class ETC_RestConvenio {
    global class ResponseMensaje{
        public Boolean isError = false;
        public Boolean isSuccess = false;
        public Decimal numConvenio;
        public Boolean estatusConvenio;
        public String mensaje;
    }
    global static ResponseMensaje getResponseSuccess(Opportunity opp){
        ResponseMensaje response = new ResponseMensaje();
        response.isSuccess = true;
        response.isError = false;
        response.numConvenio = opp.Numero_de_convenio__c;
        response.estatusConvenio = opp.Estatus_de_Convenio__c;
        response.mensaje = opp.Mensaje__c;
        return response;
    }
    global static ResponseMensaje getResponseError( String mensaje){
        ResponseMensaje response = new ResponseMensaje();
        response.mensaje = mensaje;
        response.isError = true;
        return response;
    }
    global static ResponseMensaje getResponseNotFound( String mensaje){
        ResponseMensaje response = new ResponseMensaje();
        response.mensaje = mensaje;
        response.isError = false;
        response.isSuccess = false;
        return response;
    }
    global static Opportunity[] getOpportunityByNumeroConvenio(Integer numueroConvenio){
        return [SELECT Id, Numero_de_convenio__c, Estatus_de_Convenio__c, Mensaje__c FROM Opportunity WHERE Numero_de_convenio__c =:numueroConvenio LIMIT 1];
    }

    @HttpGet
    global static ResponseMensaje getConvenioByNumeroConvenio(){
        try {
            RestRequest request = RestContext.request;
            Integer recordId =Integer.valueOf(request.requestURI.substring(request.requestURI.lastIndexOf('/')+1));

            Opportunity[] listOpportunity = getOpportunityByNumeroConvenio(recordId);
            if(listOpportunity.isEmpty()){
                return getResponseError('No se encontro el convenio: '+ recordId); 
            }

            return getResponseSuccess(listOpportunity[0]);
        }
        catch (Exception ex) {
            return getResponseError(ex.getMessage());
        }
        
        
    }
    
}