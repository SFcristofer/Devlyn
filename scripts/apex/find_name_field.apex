try {
    String[] names = new String[]{'Plan__c', 'PlanName__c', 'SubscriptionName__c', 'Description__c', 'Title__c', 'Name__c'};
    Map<String, String> found = new Map<String, String>();
    for(String f : names) {
        try {
            String q = 'SELECT ' + f + ' FROM VTEX_Subscription__dlm LIMIT 1';
            List<SObject> r = Database.query(q);
            if(!r.isEmpty()) found.put(f, (String)r[0].get(f));
        } catch(Exception e) { }
    }
    System.debug('NOMBRE_DETECTADO: ' + found.keySet());
} catch(Exception e) { }
