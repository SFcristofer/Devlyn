List<UnifiedssotIndividualDev2__dlm> samples = [
    SELECT ssot__FirstName__c, ssot__LastName__c, Email__c, Id_POS__c 
    FROM UnifiedssotIndividualDev2__dlm 
    WHERE ssot__FirstName__c != null 
    LIMIT 5
];

for (UnifiedssotIndividualDev2__dlm p : samples) {
    System.debug('TEST_DATA: Name: ' + p.ssot__FirstName__c + ' ' + p.ssot__LastName__c + ' | Email: ' + p.Email__c + ' | POS_ID: ' + p.Id_POS__c);
}
