@IsTest
public with sharing class ETC_wsConvenioTest {
    @IsTest
    static void ETC_wsConvenioTest(){
        Opportunity opp = ETC_UtilityDataFactory.addOpportunity('name');

        Test.startTest();
        List<List<String>> listIds = new List<List<String>>();
        listIds.add(new List<String>{opp.Id});
        ETC_wsConvenio.postAddOpportunity(listIds);

        ETC_wsConvenio.addOpportunityFuture(opp.Id);
        Test.stopTest();
        
    }
    @isTest
    private static void ETC_RestConvenioTest() {
        // Test data setup
        Opportunity opp = ETC_UtilityDataFactory.addOpportunity('name');
        // Actual test
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri =
        Url.getOrgDomainUrl().toExternalForm()+'/services/apexrest/Convenio/'
            + '1';
        request.httpMethod = 'GET';
        RestContext.request = request;
        ETC_RestConvenio.getConvenioByNumeroConvenio();
        ETC_RestConvenio.getResponseSuccess(opp);
        ETC_RestConvenio.getResponseError('mensaje');
        ETC_RestConvenio.getResponseNotFound('mensaje');
        Test.stopTest();
    
        // Asserts
    }
}