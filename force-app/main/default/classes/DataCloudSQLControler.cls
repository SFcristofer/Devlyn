public with sharing class DataCloudSQLControler {

    @AuraEnabled
    public static List<Object> getAntMedico(id recordId){
        // Temporalmente deshabilitado para permitir despliegue
        return new List<Object>();
    }

    @AuraEnabled
    public static List<Object> getPregPoder(id recordId){
        return new List<Object>();
    }

    @AuraEnabled
    public static List<Object> getDriVisual(id recordId){
        return new List<Object>();
    }

    @AuraEnabled
    public static List<Object> getGraduacion(String recordId){
        return new List<Object>();
    }

    @AuraEnabled
    public static List<Object> getDiagnostico(id recordId){
        return new List<Object>();
    } 

    @AuraEnabled
    public static List<Object> getCitas(id recordId){
        return new List<Object>();
    }
	
    @AuraEnabled
    public static List<Object> getOrderData(id recordId){
        return new List<Object>();
    }

    @AuraEnabled
    public static List<Object> getProductData(String orderId){
        return new List<Object>();
    }
    
    @AuraEnabled
    public static List<Object> getProductPayment(String orderId){
        return new List<Object>();
    }
    
     @AuraEnabled
    public static List<Object> getProductDev(String recordId){
        return new List<Object>();
    }
}