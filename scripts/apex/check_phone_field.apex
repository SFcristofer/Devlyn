try { 
    List<SObject> res = Database.query('SELECT Telefono__c FROM UnifiedssotIndividualDev2__dlm LIMIT 1'); 
    System.debug('PHONE_CHECK:Telefono__c'); 
} catch(Exception e) { 
    try { 
        List<SObject> res = Database.query('SELECT Phone__c FROM UnifiedssotIndividualDev2__dlm LIMIT 1'); 
        System.debug('PHONE_CHECK:Phone__c'); 
    } catch(Exception e2) { 
        System.debug('PHONE_CHECK:NONE'); 
    } 
}