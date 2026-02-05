@isTest(SeeAllData=true)

public class DataCloudSQLControlerTest {
    // Define a mock implementation of ConnectApi.CdpQuery
    public class MockCdpQuery {
        public ConnectApi.CdpQueryOutput queryANSISql(ConnectApi.CdpQueryInput input) {
            // Simulate the behavior of ConnectApi.CdpQuery.queryANSISql
            // Create a mock response object
            ConnectApi.CdpQueryOutput mockOutput = new ConnectApi.CdpQueryOutput();
            mockOutput.data = new List<Map<String, Object>>();
			//mockOutput.columns = new List<ConnectApi.CdpColumn>();
            
            
            // Simulate the data you expect to retrieve
            Map<String, Object> row1 = new Map<String, Object>{
                'clienteId__c' => '0037e00001pP6tpAAC',
                'ordenId__c' => 'Order1',
                'fecha__c' => Date.today(),
                'monto__c' => 100.0
            };
            mockOutput.data.add(row1);

            // Return the mock response
            return mockOutput;
        }
    }

    
    public static testMethod void testGetOrderData() {
        // Create a test record (e.g., Account, Custom Object) and get its Id
 
        // Use the Test.startTest() and Test.stopTest() methods to isolate your code
        Test.startTest();

        // Replace ConnectApi.CdpQuery with the mock implementation
        MockCdpQuery queryMock = new MockCdpQuery();
        
        // Call the getOrderData method with the test data
        List<Object> result = DataCloudSQLControler.getOrderData('0037e00001pP6tpAAC');

        // Perform assertions to validate the behavior and results
        System.assertEquals(1, result.size(), 'Expected one result');
        Map<String, Object> orderData = (Map<String, Object>)result[0];
        System.assertEquals('Client1', orderData.get('clienteId__c'));
        System.assertEquals('Order1', orderData.get('ordenId__c'));

        Test.stopTest();
    }
}