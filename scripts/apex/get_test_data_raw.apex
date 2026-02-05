List<ssot__Individual__dlm> samples = [
    SELECT ssot__FirstName__c, ssot__LastName__c, ssot__Id__c 
    FROM ssot__Individual__dlm 
    WHERE ssot__FirstName__c != null 
    LIMIT 5
];

for (ssot__Individual__dlm p : samples) {
    System.debug('INDIVIDUAL_DATA: Name: ' + p.ssot__FirstName__c + ' ' + p.ssot__LastName__c + ' | ID: ' + p.ssot__Id__c);
}
