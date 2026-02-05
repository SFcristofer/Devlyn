@IsTest(SeeAllData=true)
public class DataCloudSQLControler_Test 
{
    @IsTest
    static void Test1()
	{
        ConnectApi.CdpQueryInput testPage = new ConnectApi.CdpQueryInput();
        List<ConnectApi.CdpQueryInput> testItemList = new List<ConnectApi.CdpQueryInput>();
        testItemList.add(new ConnectApi.CdpQueryInput());
        testItemList.add(new ConnectApi.CdpQueryInput());
        Contact contacto = new Contact(Lastname = 'TestName');
        insert contacto;
        Test.startTest();
        DataCloudSQLControler.getAntMedico(contacto.id);
        DataCloudSQLControler.getPregPoder(contacto.id);
        DataCloudSQLControler.getDriVisual(contacto.id);
        DataCloudSQLControler.getGraduacion(contacto.id);
        DataCloudSQLControler.getDiagnostico(contacto.id);
        DataCloudSQLControler.getCitas(contacto.id);
        DataCloudSQLControler.getOrderData(contacto.id);
        DataCloudSQLControler.getProductData(contacto.id);
        DataCloudSQLControler.getProductPayment(contacto.id);
        DataCloudSQLControler.getProductDev(contacto.id);
        Test.stopTest();
    }
}