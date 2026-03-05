// Investigación de existencia de correo específico
String targetEmail = 'u.g.e.a.1990@gmail.com';
String upperEmail = targetEmail.toUpperCase();

System.debug('--- INVESTIGACIÓN DE EMAIL: ' + targetEmail + ' ---');

// 1. Buscar en Individual Unificado
List<SObject> unified = Database.query('SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE Email__c = :targetEmail OR Email__c = :upperEmail LIMIT 5');
System.debug('COINCIDENCIAS EXACTAS UNIFICADO: ' + unified.size());

// 2. Buscar con LIKE (por si hay puntos o caracteres ocultos)
String likeEmail = '%u%g%e%a%1990%';
List<SObject> flexible = Database.query('SELECT Email__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE Email__c LIKE :likeEmail LIMIT 5');
System.debug('COINCIDENCIAS FLEXIBLES (LIKE): ' + flexible.size());
for(SObject s : flexible) {
    System.debug('CORREO ENCONTRADO EN DB: ' + s.get('Email__c'));
}

// 3. Buscar en el objeto de Punto de Contacto Email (DMO base)
try {
    List<SObject> contactPoints = Database.query('SELECT ssot__EmailAddress__c FROM ssot__ContactPointEmail__dlm WHERE ssot__EmailAddress__c LIKE :likeEmail LIMIT 5');
    System.debug('COINCIDENCIAS EN CONTACT POINT EMAIL: ' + contactPoints.size());
} catch(Exception e) {
    System.debug('OBJETO ContactPointEmail no disponible o sin acceso.');
}

System.debug('--- FIN INVESTIGACIÓN ---');