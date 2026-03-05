List<UnifiedssotIndividualDev2__dlm> r = [SELECT ssot__FirstName__c, ssot__LastName__c 
                                         FROM UnifiedssotIndividualDev2__dlm 
                                         WHERE ssot__FirstName__c LIKE '%ALEJANDRO%' 
                                         AND ssot__LastName__c LIKE '%RIVAS%' 
                                         LIMIT 5];
for(UnifiedssotIndividualDev2__dlm s : r) {
    System.debug('EXISTE EN DB: ' + s.ssot__FirstName__c + ' ' + s.ssot__LastName__c);
}