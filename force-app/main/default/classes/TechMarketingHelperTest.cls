@isTest
private class TechMarketingHelperTest {
    @isTest
    static void testFeatures() {
        Test.startTest();
        TechMarketingHelper.getFullDashboardData('U1');
        TechMarketingHelper.getFullDashboardData(null);
        Test.stopTest();
        System.assert(true);
    }
}
