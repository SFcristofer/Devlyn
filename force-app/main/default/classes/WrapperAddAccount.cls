public with sharing class WrapperAddAccount {
    public Cliente cliente;
	public String token;

	public class Cliente {
		public String customId;
		public Decimal IdReferencia;
		public Decimal IdCliente;
		public String TipoMovimiento;
		public Decimal OrganizacionVentas;
		public String IdPais;
		public String Nombre1;
		public String Nombre2;
		public String Publacion;
		public Decimal IdDireccionMDS;
		public String CP;
		public String IdEstado;
		public Decimal Telefono1;
		public String Calle;
		public String NumInterior;
		public String NumExterior;
		public String Estado;
		public String ClaveTratamiento;
		public String FechaCreacion;
		public String IdGrupo;
		public String MunicipioDelegacion;
		public String RFC;
		public String ClaveRegimen;
		public Decimal Telefono2;
		public String PersonaFisica;
		public String GrupoInputacion;
		public String ViasPago;
		public String CDis;
		public String ClaveSector;
		public String ClaveCondicionesPago;
        public Decimal IDCodPostal_MDS;
	}
    public class Response{
        public String customId;
        public Decimal ESTATUS;
        public String MENSAJE;
        public String TRABAJO;
        public String IDREFERENCIA;
    }
        
    public static Response parseResponse(String json) {
        json = json.replaceAll('\\$id', 'customId');
		return (Response) System.JSON.deserialize(json, Response.class);
	}

	
    public static Account getAccount(String recordId){
        return [SELECT Id, 
            ExternalId__c,
            IdReferencia__c,
            Organizacion_de_Ventas__c,
            IdPais__c,
            Name,
            Complemento_nombre_del_cliente__c,
            BillingCity,
            Id_Direccion__c,
            BillingPostalCode,
            Id_Estado__c,
            Phone,
            BillingStreet,
            Num_Interior__c,
            Num_Exterior__c,
            BillingState,
            Tratamiento__c,
            Fecha_de_Creacion__c,
            Grupo_de_Cuentas__c,
            Municipio_Delegacion__c,
            RFC__c,
            Id_Cliente__c,
            Clave_de_Estado__c,
            Regimen__c,
            Telefono_2__c,
            Persona_Fisica__c,
            Tipo_de_Clente__c,
            Via_Pago__c,
            Canal_de_Distribucion__c,
            Sector__c,
            Condiciones_de_Pago__c,
            Tipo_de_Movimiento__c,
            IDCodPostal_MDS__c
        FROM Account WHERE Id =: recordId LIMIT 1];
    }

    public static String getBody(String recordId, String token){
        WrapperAddAccount wrapperAccount = new WrapperAddAccount();
        Account account = getAccount(recordId);
        wrapperAccount.token = token;
        wrapperAccount.cliente= new Cliente();
        if(String.isNotBlank(account.ExternalId__c)){
            wrapperAccount.cliente.customId= account.ExternalId__c;
            wrapperAccount.cliente.IdReferencia=String.isNotBlank(account.IdReferencia__c)?Decimal.valueOf(account.IdReferencia__c):0;
            wrapperAccount.cliente.IdCliente= String.isNotBlank(account.Id_Cliente__c)?Decimal.valueOf(account.Id_Cliente__c):0;
        }
        
        wrapperAccount.cliente.OrganizacionVentas= String.isNotBlank(account.Organizacion_de_Ventas__c)?Decimal.valueOf(account.Organizacion_de_Ventas__c):0;
        wrapperAccount.cliente.IdPais= account.IdPais__c;
        wrapperAccount.cliente.Nombre1= account.Name;
        wrapperAccount.cliente.Nombre2= account.Complemento_nombre_del_cliente__c;
        wrapperAccount.cliente.Publacion= account.BillingCity;
        wrapperAccount.cliente.IdDireccionMDS= account.Id_Direccion__c;
        wrapperAccount.cliente.CP= account.BillingPostalCode;
        wrapperAccount.cliente.IdEstado= account.Id_Estado__c;
        System.debug(account.Phone);
        wrapperAccount.cliente.Telefono1= String.isNotBlank(account.Phone)?Decimal.valueOf(account.Phone):0;
        wrapperAccount.cliente.Calle= account.BillingStreet;
        wrapperAccount.cliente.NumInterior= account.Num_Interior__c;
        wrapperAccount.cliente.NumExterior= account.Num_Exterior__c;
        wrapperAccount.cliente.Estado= account.BillingState;
        wrapperAccount.cliente.ClaveTratamiento= account.Tratamiento__c;
        wrapperAccount.cliente.FechaCreacion= String.valueOf(account.Fecha_de_Creacion__c);
        wrapperAccount.cliente.IdGrupo= account.Grupo_de_Cuentas__c;
        wrapperAccount.cliente.MunicipioDelegacion= account.Municipio_Delegacion__c;
        wrapperAccount.cliente.RFC= account.RFC__c;
        wrapperAccount.cliente.ClaveRegimen= account.Regimen__c;
        wrapperAccount.cliente.Telefono2= String.isNotBlank(account.Telefono_2__c)?Decimal.valueOf(account.Telefono_2__c):0;
        wrapperAccount.cliente.PersonaFisica= account.Persona_Fisica__c?'X':'';
        wrapperAccount.cliente.GrupoInputacion= account.Tipo_de_Clente__c;
        wrapperAccount.cliente.ViasPago= account.Via_Pago__c;
        wrapperAccount.cliente.CDis= account.Canal_de_Distribucion__c;
        wrapperAccount.cliente.ClaveSector= account.Sector__c;
        wrapperAccount.cliente.ClaveCondicionesPago= account.Condiciones_de_Pago__c;
        wrapperAccount.cliente.TipoMovimiento = account.Tipo_de_Movimiento__c;
        wrapperAccount.cliente.IDCodPostal_MDS = account.IDCodPostal_MDS__c;
        String json = JSON.serialize(wrapperAccount).replaceAll( 'customId','\\$id');
        return json;
    }
}