try {
    String[] ids = new String[]{'ID_CLIENTE__c', 'Id_POS__c', 'IndividualId__c', 'ssot__IndividualId__c', 'Individual__c', 'ssot__AccountId__c', 'CustomerId__c'};
    Map<String, String> found = new Map<String, String>();
    for(String f : ids) {
        try {
            String q = 'SELECT ' + f + ' FROM VTEX_Subscription__dlm LIMIT 1';
            List<SObject> r = Database.query(q);
            if(!r.isEmpty()) found.put(f, (String)r[0].get(f));
        } catch(Exception e) { }
    }
    System.debug('ENLACE_DETECTADO: ' + found.keySet());
} catch(Exception e) { }
