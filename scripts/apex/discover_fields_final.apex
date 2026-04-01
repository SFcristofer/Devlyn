// Buscamos cualquier objeto en Data Cloud que tenga el campo MIOPIA o ASTIGMATISMO
// Esto nos dirá si hay una tabla de "Data Model" mapeada con un nombre diferente
try {
    System.debug('--- BUSCANDO EL DATA MODEL REAL MEDIANTE CAMPOS ---');
    for(SObject f : Database.query('SELECT EntityDefinition.QualifiedApiName FROM FieldDefinition WHERE QualifiedApiName LIKE \'%MIOPIA%\' OR QualifiedApiName LIKE \'%ASTIGMATISMO%\' LIMIT 10')) {
        System.debug('POSIBLE TABLA DEL DATA MODEL: ' + f.get('EntityDefinition.QualifiedApiName'));
    }
} catch(Exception e) { 
    System.debug('Error: ' + e.getMessage()); 
}
