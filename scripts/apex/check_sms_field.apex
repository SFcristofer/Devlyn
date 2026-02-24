try {
    List<SObject> res = Database.query('SELECT Comunicaci_n_SMS__c FROM UnifiedssotIndividualDev2__dlm WHERE Comunicaci_n_SMS__c != null LIMIT 5'); 
    for(SObject r : res) System.debug('SMS_VAL: ' + r.get('Comunicaci_n_SMS__c'));
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
}