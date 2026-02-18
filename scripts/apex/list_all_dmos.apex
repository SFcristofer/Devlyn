try {
    System.debug('--- BUSCANDO TODOS LOS DMOs ---');
    String[] targets = new String[]{'%GRAD%', '%FAM%', '%RELATION%', '%PHONE%', '%EXAM%'};
    for(String t : targets) {
        for(SObject e : Database.query('SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE \''+t+'\' AND QualifiedApiName LIKE \'%__dlm\'')) {
            System.debug('DMO DETECTADO: ' + e.get('QualifiedApiName'));
        }
    }
} catch(Exception e) { System.debug('Error: ' + e.getMessage()); }
